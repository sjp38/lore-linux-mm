Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 73A106B01B1
	for <linux-mm@kvack.org>; Tue, 25 May 2010 13:02:53 -0400 (EDT)
Subject: [PATCH V3] x86, UV: BAU performance and error recovery
Message-Id: <E1OGxWi-0000kI-Tc@eag09.americas.sgi.com>
From: Cliff Wickman <cpw@sgi.com>
Date: Tue, 25 May 2010 12:02:48 -0500
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Ingo,
This patch replaces the patch of the same name, from March 2010.
You had queued it up for v2.6.35 on April 14.

And, like that patch, it depends on patch 
   http://marc.info/?l=linux-kernel&m=126825393617669&w=2
   x86, UV: Cleanup of UV header for MMR definitions

Above and beyond versions 1 and 2, this patch:
- corrects several bugs:
  o the lack of BAU messaging to blade 0 (an uninitialized field)
  o correct message type for a normal shootdown message
  o fix to recovery from timed-out s/w acknowledge resources
  o calculation of the actual destination timeout so that a 'short' timeout can
    be identified
  o fix mishandling of non-consecutive hub and socket numbers
  o identification of a cpu's socket number
  o removal of the check the h/w stay-busy bug, as under extreme pressure it
    cannot be accurately detected
  o fall back to IPI-method when extreme pressure makes numalink very slow,
    and then resume BAU-method after an interval
- adds BAU broadcasting to the cpu's on the local node
- simplifies the returning of the original cpu bitmap when the BAU attempt
  is given up entirely.
- adds modification of tuning variables through /proc/sgi_uv

And to re-state the main ideas of versions 1 and 2:
This patch adds what we've learned about BAU usage for TLB shootdown.
- increases performance of the interrupt handler
    mainly through use of socket-local memory
- releases timed-out BAU software acknowledge resources
    uses a MSG_RETRY that acknowledges unanswered messages
    can fall back to an IPI method of BAU resource release
- throttles number of concurrent broadcasts, to avoid h/w stay-busy problem
- provides a 'nobau' boot command line option
    allows disabling of the use of the BAU altogether

Diffed against 2.6.34

Signed-off-by: Cliff Wickman <cpw@sgi.com>

---
 arch/x86/include/asm/uv/uv_bau.h |  304 +++++--
 arch/x86/kernel/tlb_uv.c         | 1577 +++++++++++++++++++++++++++++----------
 2 files changed, 1410 insertions(+), 471 deletions(-)

Index: 100524.linux.2.6.34/arch/x86/include/asm/uv/uv_bau.h
===================================================================
--- 100524.linux.2.6.34.orig/arch/x86/include/asm/uv/uv_bau.h
+++ 100524.linux.2.6.34/arch/x86/include/asm/uv/uv_bau.h
@@ -27,13 +27,15 @@
  * set 2 is at BASE + 2*512, set 3 at BASE + 3*512, and so on.
  *
  * We will use 31 sets, one for sending BAU messages from each of the 32
- * cpu's on the node.
+ * cpu's on the uvhub.
  *
  * TLB shootdown will use the first of the 8 descriptors of each set.
  * Each of the descriptors is 64 bytes in size (8*64 = 512 bytes in a set).
  */
 
 #define UV_ITEMS_PER_DESCRIPTOR		8
+/* the 'throttle' to prevent the hardware stay-busy bug */
+#define MAX_BAU_CONCURRENT		3
 #define UV_CPUS_PER_ACT_STATUS		32
 #define UV_ACT_STATUS_MASK		0x3
 #define UV_ACT_STATUS_SIZE		2
@@ -44,7 +46,24 @@
 #define UV_DESC_BASE_PNODE_SHIFT	49
 #define UV_PAYLOADQ_PNODE_SHIFT		49
 #define UV_PTC_BASENAME			"sgi_uv/ptc_statistics"
+#define UV_BAU_BASENAME			"sgi_uv/bau_tunables"
+#define WHITESPACE			" \t\n"
 #define uv_physnodeaddr(x)		((__pa((unsigned long)(x)) & uv_mmask))
+#define UV_ENABLE_INTD_SOFT_ACK_MODE_SHIFT 15
+#define UV_INTD_SOFT_ACK_TIMEOUT_PERIOD_SHIFT 16
+#define UV_INTD_SOFT_ACK_TIMEOUT_PERIOD 0x0000000009UL
+/* [19:16] SOFT_ACK timeout period  19: 1 is urgency 7  17:16 1 is multiplier */
+#define BAU_MISC_CONTROL_MULT_MASK 3
+
+#define UVH_AGING_PRESCALE_SEL 0x000000b000UL
+/* [30:28] URGENCY_7  an index into a table of times */
+#define BAU_URGENCY_7_SHIFT 28
+#define BAU_URGENCY_7_MASK 7
+
+#define UVH_TRANSACTION_TIMEOUT 0x000000b200UL
+/* [45:40] BAU - BAU transaction timeout select - a multiplier */
+#define BAU_TRANS_SHIFT 40
+#define BAU_TRANS_MASK 0x3f
 
 /*
  * bits in UVH_LB_BAU_SB_ACTIVATION_STATUS_0/1
@@ -55,15 +74,26 @@
 #define DESC_STATUS_SOURCE_TIMEOUT	3
 
 /*
- * source side thresholds at which message retries print a warning
+ * delay for 'plugged' timeout retries, in microseconds
  */
-#define SOURCE_TIMEOUT_LIMIT		20
-#define DESTINATION_TIMEOUT_LIMIT	20
+#define PLUGGED_DELAY			10
+
+/*
+ * threshholds at which to use IPI to free resources
+ */
+/* after this # consecutive 'plugged' timeouts, use IPI to release resources */
+#define PLUGSB4RESET 100
+/* after this many consecutive timeouts, use IPI to release resources */
+#define TIMEOUTSB4RESET 1
+/* at this number uses of IPI to release resources, giveup the request */
+#define IPI_RESET_LIMIT 1
+/* after this # consecutive successes, bump up the throttle if it was lowered */
+#define COMPLETE_THRESHOLD 5
 
 /*
  * number of entries in the destination side payload queue
  */
-#define DEST_Q_SIZE			17
+#define DEST_Q_SIZE			20
 /*
  * number of destination side software ack resources
  */
@@ -72,9 +102,17 @@
 /*
  * completion statuses for sending a TLB flush message
  */
-#define	FLUSH_RETRY			1
-#define	FLUSH_GIVEUP			2
-#define	FLUSH_COMPLETE			3
+#define FLUSH_RETRY_PLUGGED		1
+#define FLUSH_RETRY_TIMEOUT		2
+#define FLUSH_GIVEUP			3
+#define FLUSH_COMPLETE			4
+
+/*
+ * tuning the action when the numalink network is extremely delayed
+ */
+#define CONGESTED_RESPONSE_US 1000 /* 'long' response time, in microseconds */
+#define CONGESTED_REPS 10 /* long delays averaged over this many broadcasts */
+#define CONGESTED_PERIOD 30 /* time for the bau to be disabled, in seconds */
 
 /*
  * Distribution: 32 bytes (256 bits) (bytes 0-0x1f of descriptor)
@@ -86,14 +124,14 @@
  * 'base_dest_nodeid' field of the header corresponds to the
  * destination nodeID associated with that specified bit.
  */
-struct bau_target_nodemask {
-	unsigned long bits[BITS_TO_LONGS(256)];
+struct bau_target_uvhubmask {
+	unsigned long bits[BITS_TO_LONGS(UV_DISTRIBUTION_SIZE)];
 };
 
 /*
- * mask of cpu's on a node
+ * mask of cpu's on a uvhub
  * (during initialization we need to check that unsigned long has
- *  enough bits for max. cpu's per node)
+ *  enough bits for max. cpu's per uvhub)
  */
 struct bau_local_cpumask {
 	unsigned long bits;
@@ -135,8 +173,8 @@ struct bau_msg_payload {
 struct bau_msg_header {
 	unsigned int dest_subnodeid:6;	/* must be 0x10, for the LB */
 	/* bits 5:0 */
-	unsigned int base_dest_nodeid:15; /* nasid>>1 (pnode) of */
-	/* bits 20:6 */			  /* first bit in node_map */
+	unsigned int base_dest_nodeid:15; /* nasid (pnode<<1) of */
+	/* bits 20:6 */			  /* first bit in uvhub map */
 	unsigned int command:8;	/* message type */
 	/* bits 28:21 */
 				/* 0x38: SN3net EndPoint Message */
@@ -146,26 +184,38 @@ struct bau_msg_header {
 	unsigned int rsvd_2:9;	/* must be zero */
 	/* bits 40:32 */
 				/* Suppl_A is 56-41 */
-	unsigned int payload_2a:8;/* becomes byte 16 of msg */
-	/* bits 48:41 */	/* not currently using */
-	unsigned int payload_2b:8;/* becomes byte 17 of msg */
-	/* bits 56:49 */	/* not currently using */
+	unsigned int sequence:16;/* message sequence number */
+	/* bits 56:41 */	/* becomes bytes 16-17 of msg */
 				/* Address field (96:57) is never used as an
 				   address (these are address bits 42:3) */
+
 	unsigned int rsvd_3:1;	/* must be zero */
 	/* bit 57 */
 				/* address bits 27:4 are payload */
-				/* these 24 bits become bytes 12-14 of msg */
+	/* these next 24  (58-81) bits become bytes 12-14 of msg */
+
+	/* bits 65:58 land in byte 12 */
 	unsigned int replied_to:1;/* sent as 0 by the source to byte 12 */
 	/* bit 58 */
-
-	unsigned int payload_1a:5;/* not currently used */
-	/* bits 63:59 */
-	unsigned int payload_1b:8;/* not currently used */
-	/* bits 71:64 */
-	unsigned int payload_1c:8;/* not currently used */
-	/* bits 79:72 */
-	unsigned int payload_1d:2;/* not currently used */
+	unsigned int msg_type:3; /* software type of the message*/
+	/* bits 61:59 */
+	unsigned int canceled:1; /* message canceled, resource to be freed*/
+	/* bit 62 */
+	unsigned int payload_1a:1;/* not currently used */
+	/* bit 63 */
+	unsigned int payload_1b:2;/* not currently used */
+	/* bits 65:64 */
+
+	/* bits 73:66 land in byte 13 */
+	unsigned int payload_1ca:6;/* not currently used */
+	/* bits 71:66 */
+	unsigned int payload_1c:2;/* not currently used */
+	/* bits 73:72 */
+
+	/* bits 81:74 land in byte 14 */
+	unsigned int payload_1d:6;/* not currently used */
+	/* bits 79:74 */
+	unsigned int payload_1e:2;/* not currently used */
 	/* bits 81:80 */
 
 	unsigned int rsvd_4:7;	/* must be zero */
@@ -178,7 +228,7 @@ struct bau_msg_header {
 	/* bits 95:90 */
 	unsigned int rsvd_6:5;	/* must be zero */
 	/* bits 100:96 */
-	unsigned int int_both:1;/* if 1, interrupt both sockets on the blade */
+	unsigned int int_both:1;/* if 1, interrupt both sockets on the uvhub */
 	/* bit 101*/
 	unsigned int fairness:3;/* usually zero */
 	/* bits 104:102 */
@@ -191,13 +241,18 @@ struct bau_msg_header {
 	/* bits 127:107 */
 };
 
+/* see msg_type: */
+#define MSG_NOOP 0
+#define MSG_REGULAR 1
+#define MSG_RETRY 2
+
 /*
  * The activation descriptor:
  * The format of the message to send, plus all accompanying control
  * Should be 64 bytes
  */
 struct bau_desc {
-	struct bau_target_nodemask distribution;
+	struct bau_target_uvhubmask distribution;
 	/*
 	 * message template, consisting of header and payload:
 	 */
@@ -237,19 +292,25 @@ struct bau_payload_queue_entry {
 	unsigned short acknowledge_count; /* filled in by destination */
 	/* 16 bits, bytes 10-11 */
 
-	unsigned short replied_to:1;	/* sent as 0 by the source */
-	/* 1 bit */
-	unsigned short unused1:7;       /* not currently using */
-	/* 7 bits: byte 12) */
-
-	unsigned char unused2[2];	/* not currently using */
-	/* bytes 13-14 */
+	/* these next 3 bytes come from bits 58-81 of the message header */
+	unsigned short replied_to:1;    /* sent as 0 by the source */
+	unsigned short msg_type:3;      /* software message type */
+	unsigned short canceled:1;      /* sent as 0 by the source */
+	unsigned short unused1:3;       /* not currently using */
+	/* byte 12 */
+
+	unsigned char unused2a;		/* not currently using */
+	/* byte 13 */
+	unsigned char unused2;		/* not currently using */
+	/* byte 14 */
 
 	unsigned char sw_ack_vector;	/* filled in by the hardware */
 	/* byte 15 (bits 127:120) */
 
-	unsigned char unused4[3];	/* not currently using bytes 17-19 */
-	/* bytes 17-19 */
+	unsigned short sequence;	/* message sequence number */
+	/* bytes 16-17 */
+	unsigned char unused4[2];	/* not currently using bytes 18-19 */
+	/* bytes 18-19 */
 
 	int number_of_cpus;		/* filled in at destination */
 	/* 32 bits, bytes 20-23 (aligned) */
@@ -258,64 +319,126 @@ struct bau_payload_queue_entry {
 	/* bytes 24-31 */
 };
 
-/*
- * one for every slot in the destination payload queue
- */
-struct bau_msg_status {
-	struct bau_local_cpumask seen_by;	/* map of cpu's */
+struct msg_desc {
+	struct bau_payload_queue_entry *msg;
+	int msg_slot;
+	int sw_ack_slot;
+	struct bau_payload_queue_entry *va_queue_first;
+	struct bau_payload_queue_entry *va_queue_last;
+};
+
+struct reset_args {
+	int sender;
 };
 
 /*
- * one for every slot in the destination software ack resources
+ * This structure is allocated per_cpu for UV TLB shootdown statistics.
  */
-struct bau_sw_ack_status {
-	struct bau_payload_queue_entry *msg;	/* associated message */
-	int watcher;				/* cpu monitoring, or -1 */
+struct ptc_stats {
+	/* sender statistics */
+	unsigned long s_giveup; /* number of fall backs to IPI-style flushes */
+	unsigned long s_requestor; /* number of shootdown requests */
+	unsigned long s_stimeout; /* source side timeouts */
+	unsigned long s_dtimeout; /* destination side timeouts */
+	unsigned long s_time; /* time spent in sending side */
+	unsigned long s_retriesok; /* successful retries */
+	unsigned long s_ntargcpu; /* total number of cpu's targeted */
+	unsigned long s_ntargself; /* times the sending cpu was targeted */
+	unsigned long s_ntarglocals; /* targets of cpus on the local blade */
+	unsigned long s_ntargremotes; /* targets of cpus on remote blades */
+	unsigned long s_ntarglocaluvhub; /* targets of the local hub */
+	unsigned long s_ntargremoteuvhub; /* remotes hubs targeted */
+	unsigned long s_ntarguvhub; /* total number of uvhubs targeted */
+	unsigned long s_ntarguvhub16; /* number of times target hubs >= 16*/
+	unsigned long s_ntarguvhub8; /* number of times target hubs >= 8 */
+	unsigned long s_ntarguvhub4; /* number of times target hubs >= 4 */
+	unsigned long s_ntarguvhub2; /* number of times target hubs >= 2 */
+	unsigned long s_ntarguvhub1; /* number of times target hubs == 1 */
+	unsigned long s_resets_plug; /* ipi-style resets from plug state */
+	unsigned long s_resets_timeout; /* ipi-style resets from timeouts */
+	unsigned long s_busy; /* status stayed busy past s/w timer */
+	unsigned long s_throttles; /* waits in throttle */
+	unsigned long s_retry_messages; /* retry broadcasts */
+	unsigned long s_bau_reenabled; /* for bau enable/disable */
+	unsigned long s_bau_disabled; /* for bau enable/disable */
+	/* destination statistics */
+	unsigned long d_alltlb; /* times all tlb's on this cpu were flushed */
+	unsigned long d_onetlb; /* times just one tlb on this cpu was flushed */
+	unsigned long d_multmsg; /* interrupts with multiple messages */
+	unsigned long d_nomsg; /* interrupts with no message */
+	unsigned long d_time; /* time spent on destination side */
+	unsigned long d_requestee; /* number of messages processed */
+	unsigned long d_retries; /* number of retry messages processed */
+	unsigned long d_canceled; /* number of messages canceled by retries */
+	unsigned long d_nocanceled; /* retries that found nothing to cancel */
+	unsigned long d_resets; /* number of ipi-style requests processed */
+	unsigned long d_rcanceled; /* number of messages canceled by resets */
 };
 
 /*
- * one on every node and per-cpu; to locate the software tables
+ * one per-cpu; to locate the software tables
  */
 struct bau_control {
 	struct bau_desc *descriptor_base;
-	struct bau_payload_queue_entry *bau_msg_head;
 	struct bau_payload_queue_entry *va_queue_first;
 	struct bau_payload_queue_entry *va_queue_last;
-	struct bau_msg_status *msg_statuses;
-	int *watching; /* pointer to array */
-};
-
-/*
- * This structure is allocated per_cpu for UV TLB shootdown statistics.
- */
-struct ptc_stats {
-	unsigned long ptc_i;	/* number of IPI-style flushes */
-	unsigned long requestor;	/* number of nodes this cpu sent to */
-	unsigned long requestee;	/* times cpu was remotely requested */
-	unsigned long alltlb;	/* times all tlb's on this cpu were flushed */
-	unsigned long onetlb;	/* times just one tlb on this cpu was flushed */
-	unsigned long s_retry;	/* retries on source side timeouts */
-	unsigned long d_retry;	/* retries on destination side timeouts */
-	unsigned long sflush;	/* cycles spent in uv_flush_tlb_others */
-	unsigned long dflush;	/* cycles spent on destination side */
-	unsigned long retriesok; /* successes on retries */
-	unsigned long nomsg;	/* interrupts with no message */
-	unsigned long multmsg;	/* interrupts with multiple messages */
-	unsigned long ntargeted;/* nodes targeted */
+	struct bau_payload_queue_entry *bau_msg_head;
+	struct bau_control *uvhub_master;
+	struct bau_control *socket_master;
+	struct ptc_stats *statp;
+	unsigned long timeout_interval;
+	unsigned long set_bau_on_time;
+	atomic_t active_descriptor_count;
+	int plugged_tries;
+	int timeout_tries;
+	int ipi_attempts;
+	int conseccompletes;
+	int baudisabled;
+	int set_bau_off;
+	short cpu;
+	short uvhub_cpu;
+	short uvhub;
+	short cpus_in_socket;
+	short cpus_in_uvhub;
+	unsigned short message_number;
+	unsigned short uvhub_quiesce;
+	short socket_acknowledge_count[DEST_Q_SIZE];
+	cycles_t send_message;
+	spinlock_t uvhub_lock;
+	spinlock_t queue_lock;
+	/* tunables */
+	int max_bau_concurrent;
+	int max_bau_concurrent_constant;
+	int plugged_delay;
+	int plugsb4reset;
+	int timeoutsb4reset;
+	int ipi_reset_limit;
+	int complete_threshold;
+	int congested_response_us;
+	int congested_reps;
+	int congested_period;
+	cycles_t period_time;
+	long period_requests;
 };
 
-static inline int bau_node_isset(int node, struct bau_target_nodemask *dstp)
+static inline int bau_uvhub_isset(int uvhub, struct bau_target_uvhubmask *dstp)
 {
-	return constant_test_bit(node, &dstp->bits[0]);
+	return constant_test_bit(uvhub, &dstp->bits[0]);
 }
-static inline void bau_node_set(int node, struct bau_target_nodemask *dstp)
+static inline void bau_uvhub_set(int uvhub, struct bau_target_uvhubmask *dstp)
 {
-	__set_bit(node, &dstp->bits[0]);
+	__set_bit(uvhub, &dstp->bits[0]);
 }
-static inline void bau_nodes_clear(struct bau_target_nodemask *dstp, int nbits)
+static inline void bau_uvhubs_clear(struct bau_target_uvhubmask *dstp,
+				    int nbits)
 {
 	bitmap_zero(&dstp->bits[0], nbits);
 }
+static inline int bau_uvhub_weight(struct bau_target_uvhubmask *dstp)
+{
+	return bitmap_weight((unsigned long *)&dstp->bits[0],
+				UV_DISTRIBUTION_SIZE);
+}
 
 static inline void bau_cpubits_clear(struct bau_local_cpumask *dstp, int nbits)
 {
@@ -328,4 +451,35 @@ static inline void bau_cpubits_clear(str
 extern void uv_bau_message_intr1(void);
 extern void uv_bau_timeout_intr1(void);
 
+struct atomic_short {
+	short counter;
+};
+
+/**
+ * atomic_read_short - read a short atomic variable
+ * @v: pointer of type atomic_short
+ *
+ * Atomically reads the value of @v.
+ */
+static inline int atomic_read_short(const struct atomic_short *v)
+{
+	return v->counter;
+}
+
+/**
+ * atomic_add_short_return - add and return a short int
+ * @i: short value to add
+ * @v: pointer of type atomic_short
+ *
+ * Atomically adds @i to @v and returns @i + @v
+ */
+static inline int atomic_add_short_return(short i, struct atomic_short *v)
+{
+	short __i = i;
+	asm volatile(LOCK_PREFIX "xaddw %0, %1"
+			: "+r" (i), "+m" (v->counter)
+			: : "memory");
+	return i + __i;
+}
+
 #endif /* _ASM_X86_UV_UV_BAU_H */
Index: 100524.linux.2.6.34/arch/x86/kernel/tlb_uv.c
===================================================================
--- 100524.linux.2.6.34.orig/arch/x86/kernel/tlb_uv.c
+++ 100524.linux.2.6.34/arch/x86/kernel/tlb_uv.c
@@ -1,7 +1,7 @@
 /*
  *	SGI UltraViolet TLB flush routines.
  *
- *	(c) 2008 Cliff Wickman <cpw@sgi.com>, SGI.
+ *	(c) 2008-2010 Cliff Wickman <cpw@sgi.com>, SGI.
  *
  *	This code is released under the GNU General Public License version 2 or
  *	later.
@@ -9,7 +9,6 @@
 #include <linux/seq_file.h>
 #include <linux/proc_fs.h>
 #include <linux/kernel.h>
-#include <linux/slab.h>
 
 #include <asm/mmu_context.h>
 #include <asm/uv/uv.h>
@@ -20,42 +19,79 @@
 #include <asm/idle.h>
 #include <asm/tsc.h>
 #include <asm/irq_vectors.h>
+#include <asm/timer.h>
 
-static struct bau_control	**uv_bau_table_bases __read_mostly;
-static int			uv_bau_retry_limit __read_mostly;
+/* timeouts in nanoseconds (indexed by UVH_AGING_PRESCALE_SEL urgency7 30:28) */
+static int timeout_base_ns[] = {
+		20,
+		160,
+		1280,
+		10240,
+		81920,
+		655360,
+		5242880,
+		167772160
+};
+static int timeout_us;
+static int nobau;
+static int baudisabled;
+static spinlock_t disable_lock;
+static cycles_t congested_cycles;
+
+/* tunables: */
+static int max_bau_concurrent = MAX_BAU_CONCURRENT;
+static int max_bau_concurrent_constant = MAX_BAU_CONCURRENT;
+static int plugged_delay = PLUGGED_DELAY;
+static int plugsb4reset = PLUGSB4RESET;
+static int timeoutsb4reset = TIMEOUTSB4RESET;
+static int ipi_reset_limit = IPI_RESET_LIMIT;
+static int complete_threshold = COMPLETE_THRESHOLD;
+static int congested_response_us = CONGESTED_RESPONSE_US;
+static int congested_reps = CONGESTED_REPS;
+static int congested_period = CONGESTED_PERIOD;
 
-/* base pnode in this partition */
-static int			uv_partition_base_pnode __read_mostly;
+static int __init setup_nobau(char *arg)
+{
+	nobau = 1;
+	return 0;
+}
+early_param("nobau", setup_nobau);
 
-static unsigned long		uv_mmask __read_mostly;
+/* base pnode in this partition */
+static int uv_partition_base_pnode __read_mostly;
+/* position of pnode (which is nasid>>1): */
+static int uv_nshift __read_mostly;
+static unsigned long uv_mmask __read_mostly;
 
 static DEFINE_PER_CPU(struct ptc_stats, ptcstats);
 static DEFINE_PER_CPU(struct bau_control, bau_control);
+static DEFINE_PER_CPU(cpumask_var_t, uv_flush_tlb_mask);
 
 /*
- * Determine the first node on a blade.
+ * Determine the first node on a uvhub. 'Nodes' are used for kernel
+ * memory allocation.
  */
-static int __init blade_to_first_node(int blade)
+static int __init uvhub_to_first_node(int uvhub)
 {
 	int node, b;
 
 	for_each_online_node(node) {
 		b = uv_node_to_blade_id(node);
-		if (blade == b)
+		if (uvhub == b)
 			return node;
 	}
-	return -1; /* shouldn't happen */
+	return -1;
 }
 
 /*
- * Determine the apicid of the first cpu on a blade.
+ * Determine the apicid of the first cpu on a uvhub.
  */
-static int __init blade_to_first_apicid(int blade)
+static int __init uvhub_to_first_apicid(int uvhub)
 {
 	int cpu;
 
 	for_each_present_cpu(cpu)
-		if (blade == uv_cpu_to_blade_id(cpu))
+		if (uvhub == uv_cpu_to_blade_id(cpu))
 			return per_cpu(x86_cpu_to_apicid, cpu);
 	return -1;
 }
@@ -68,195 +104,432 @@ static int __init blade_to_first_apicid(
  * clear of the Timeout bit (as well) will free the resource. No reply will
  * be sent (the hardware will only do one reply per message).
  */
-static void uv_reply_to_message(int resource,
-				struct bau_payload_queue_entry *msg,
-				struct bau_msg_status *msp)
+static inline void uv_reply_to_message(struct msg_desc *mdp,
+				       struct bau_control *bcp)
 {
 	unsigned long dw;
+	struct bau_payload_queue_entry *msg;
 
-	dw = (1 << (resource + UV_SW_ACK_NPENDING)) | (1 << resource);
+	msg = mdp->msg;
+	if (!msg->canceled) {
+		dw = (msg->sw_ack_vector << UV_SW_ACK_NPENDING) |
+						msg->sw_ack_vector;
+		uv_write_local_mmr(
+				UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, dw);
+	}
 	msg->replied_to = 1;
 	msg->sw_ack_vector = 0;
-	if (msp)
-		msp->seen_by.bits = 0;
-	uv_write_local_mmr(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, dw);
 }
 
 /*
- * Do all the things a cpu should do for a TLB shootdown message.
- * Other cpu's may come here at the same time for this message.
+ * Process the receipt of a RETRY message
  */
-static void uv_bau_process_message(struct bau_payload_queue_entry *msg,
-				   int msg_slot, int sw_ack_slot)
+static inline void uv_bau_process_retry_msg(struct msg_desc *mdp,
+					    struct bau_control *bcp)
 {
-	unsigned long this_cpu_mask;
-	struct bau_msg_status *msp;
-	int cpu;
+	int i;
+	int cancel_count = 0;
+	int slot2;
+	unsigned long msg_res;
+	unsigned long mmr = 0;
+	struct bau_payload_queue_entry *msg;
+	struct bau_payload_queue_entry *msg2;
+	struct ptc_stats *stat;
 
-	msp = __get_cpu_var(bau_control).msg_statuses + msg_slot;
-	cpu = uv_blade_processor_id();
-	msg->number_of_cpus =
-		uv_blade_nr_online_cpus(uv_node_to_blade_id(numa_node_id()));
-	this_cpu_mask = 1UL << cpu;
-	if (msp->seen_by.bits & this_cpu_mask)
-		return;
-	atomic_or_long(&msp->seen_by.bits, this_cpu_mask);
+	msg = mdp->msg;
+	stat = bcp->statp;
+	stat->d_retries++;
+	/*
+	 * cancel any message from msg+1 to the retry itself
+	 */
+	for (msg2 = msg+1, i = 0; i < DEST_Q_SIZE; msg2++, i++) {
+		if (msg2 > mdp->va_queue_last)
+			msg2 = mdp->va_queue_first;
+		if (msg2 == msg)
+			break;
+
+		/* same conditions for cancellation as uv_do_reset */
+		if ((msg2->replied_to == 0) && (msg2->canceled == 0) &&
+		    (msg2->sw_ack_vector) && ((msg2->sw_ack_vector &
+			msg->sw_ack_vector) == 0) &&
+		    (msg2->sending_cpu == msg->sending_cpu) &&
+		    (msg2->msg_type != MSG_NOOP)) {
+			slot2 = msg2 - mdp->va_queue_first;
+			mmr = uv_read_local_mmr
+				(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE);
+			msg_res = msg2->sw_ack_vector;
+			/*
+			 * This is a message retry; clear the resources held
+			 * by the previous message only if they timed out.
+			 * If it has not timed out we have an unexpected
+			 * situation to report.
+			 */
+			if (mmr & (msg_res << UV_SW_ACK_NPENDING)) {
+				/*
+				 * is the resource timed out?
+				 * make everyone ignore the cancelled message.
+				 */
+				msg2->canceled = 1;
+				stat->d_canceled++;
+				cancel_count++;
+				uv_write_local_mmr(
+				    UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS,
+					(msg_res << UV_SW_ACK_NPENDING) |
+					 msg_res);
+			}
+		}
+	}
+	if (!cancel_count)
+		stat->d_nocanceled++;
+}
 
-	if (msg->replied_to == 1)
-		return;
+/*
+ * Do all the things a cpu should do for a TLB shootdown message.
+ * Other cpu's may come here at the same time for this message.
+ */
+static void uv_bau_process_message(struct msg_desc *mdp,
+				   struct bau_control *bcp)
+{
+	int msg_ack_count;
+	short socket_ack_count = 0;
+	struct ptc_stats *stat;
+	struct bau_payload_queue_entry *msg;
+	struct bau_control *smaster = bcp->socket_master;
 
+	/*
+	 * This must be a normal message, or retry of a normal message
+	 */
+	msg = mdp->msg;
+	stat = bcp->statp;
 	if (msg->address == TLB_FLUSH_ALL) {
 		local_flush_tlb();
-		__get_cpu_var(ptcstats).alltlb++;
+		stat->d_alltlb++;
 	} else {
 		__flush_tlb_one(msg->address);
-		__get_cpu_var(ptcstats).onetlb++;
+		stat->d_onetlb++;
 	}
+	stat->d_requestee++;
 
-	__get_cpu_var(ptcstats).requestee++;
+	/*
+	 * One cpu on each uvhub has the additional job on a RETRY
+	 * of releasing the resource held by the message that is
+	 * being retried.  That message is identified by sending
+	 * cpu number.
+	 */
+	if (msg->msg_type == MSG_RETRY && bcp == bcp->uvhub_master)
+		uv_bau_process_retry_msg(mdp, bcp);
+
+	/*
+	 * This is a sw_ack message, so we have to reply to it.
+	 * Count each responding cpu on the socket. This avoids
+	 * pinging the count's cache line back and forth between
+	 * the sockets.
+	 */
+	socket_ack_count = atomic_add_short_return(1, (struct atomic_short *)
+			&smaster->socket_acknowledge_count[mdp->msg_slot]);
+	if (socket_ack_count == bcp->cpus_in_socket) {
+		/*
+		 * Both sockets dump their completed count total into
+		 * the message's count.
+		 */
+		smaster->socket_acknowledge_count[mdp->msg_slot] = 0;
+		msg_ack_count = atomic_add_short_return(socket_ack_count,
+				(struct atomic_short *)&msg->acknowledge_count);
+
+		if (msg_ack_count == bcp->cpus_in_uvhub) {
+			/*
+			 * All cpus in uvhub saw it; reply
+			 */
+			uv_reply_to_message(mdp, bcp);
+		}
+	}
 
-	atomic_inc_short(&msg->acknowledge_count);
-	if (msg->number_of_cpus == msg->acknowledge_count)
-		uv_reply_to_message(sw_ack_slot, msg, msp);
+	return;
 }
 
 /*
- * Examine the payload queue on one distribution node to see
- * which messages have not been seen, and which cpu(s) have not seen them.
+ * Determine the first cpu on a uvhub.
+ */
+static int uvhub_to_first_cpu(int uvhub)
+{
+	int cpu;
+	for_each_present_cpu(cpu)
+		if (uvhub == uv_cpu_to_blade_id(cpu))
+			return cpu;
+	return -1;
+}
+
+/*
+ * Last resort when we get a large number of destination timeouts is
+ * to clear resources held by a given cpu.
+ * Do this with IPI so that all messages in the BAU message queue
+ * can be identified by their nonzero sw_ack_vector field.
  *
- * Returns the number of cpu's that have not responded.
+ * This is entered for a single cpu on the uvhub.
+ * The sender want's this uvhub to free a specific message's
+ * sw_ack resources.
  */
-static int uv_examine_destination(struct bau_control *bau_tablesp, int sender)
+static void
+uv_do_reset(void *ptr)
 {
-	struct bau_payload_queue_entry *msg;
-	struct bau_msg_status *msp;
-	int count = 0;
 	int i;
-	int j;
+	int slot;
+	int count = 0;
+	unsigned long mmr;
+	unsigned long msg_res;
+	struct bau_control *bcp;
+	struct reset_args *rap;
+	struct bau_payload_queue_entry *msg;
+	struct ptc_stats *stat;
 
-	for (msg = bau_tablesp->va_queue_first, i = 0; i < DEST_Q_SIZE;
-	     msg++, i++) {
-		if ((msg->sending_cpu == sender) && (!msg->replied_to)) {
-			msp = bau_tablesp->msg_statuses + i;
-			printk(KERN_DEBUG
-			       "blade %d: address:%#lx %d of %d, not cpu(s): ",
-			       i, msg->address, msg->acknowledge_count,
-			       msg->number_of_cpus);
-			for (j = 0; j < msg->number_of_cpus; j++) {
-				if (!((1L << j) & msp->seen_by.bits)) {
-					count++;
-					printk("%d ", j);
-				}
+	bcp = &per_cpu(bau_control, smp_processor_id());
+	rap = (struct reset_args *)ptr;
+	stat = bcp->statp;
+	stat->d_resets++;
+
+	/*
+	 * We're looking for the given sender, and
+	 * will free its sw_ack resource.
+	 * If all cpu's finally responded after the timeout, its
+	 * message 'replied_to' was set.
+	 */
+	for (msg = bcp->va_queue_first, i = 0; i < DEST_Q_SIZE; msg++, i++) {
+		/* uv_do_reset: same conditions for cancellation as
+		   uv_bau_process_retry_msg() */
+		if ((msg->replied_to == 0) &&
+		    (msg->canceled == 0) &&
+		    (msg->sending_cpu == rap->sender) &&
+		    (msg->sw_ack_vector) &&
+		    (msg->msg_type != MSG_NOOP)) {
+			/*
+			 * make everyone else ignore this message
+			 */
+			msg->canceled = 1;
+			slot = msg - bcp->va_queue_first;
+			count++;
+			/*
+			 * only reset the resource if it is still pending
+			 */
+			mmr = uv_read_local_mmr
+					(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE);
+			msg_res = msg->sw_ack_vector;
+			if (mmr & msg_res) {
+				stat->d_rcanceled++;
+				uv_write_local_mmr(
+				    UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS,
+					(msg_res << UV_SW_ACK_NPENDING) |
+					 msg_res);
 			}
-			printk("\n");
 		}
 	}
-	return count;
+	return;
 }
 
 /*
- * Examine the payload queue on all the distribution nodes to see
- * which messages have not been seen, and which cpu(s) have not seen them.
- *
- * Returns the number of cpu's that have not responded.
+ * Use IPI to get all target uvhubs to release resources held by
+ * a given sending cpu number.
  */
-static int uv_examine_destinations(struct bau_target_nodemask *distribution)
+static void uv_reset_with_ipi(struct bau_target_uvhubmask *distribution,
+			      int sender)
 {
-	int sender;
-	int i;
-	int count = 0;
+	int uvhub;
+	int cpu;
+	cpumask_t mask;
+	struct reset_args reset_args;
+
+	reset_args.sender = sender;
 
-	sender = smp_processor_id();
-	for (i = 0; i < sizeof(struct bau_target_nodemask) * BITSPERBYTE; i++) {
-		if (!bau_node_isset(i, distribution))
+	cpus_clear(mask);
+	/* find a single cpu for each uvhub in this distribution mask */
+	for (uvhub = 0;
+		    uvhub < sizeof(struct bau_target_uvhubmask) * BITSPERBYTE;
+		    uvhub++) {
+		if (!bau_uvhub_isset(uvhub, distribution))
 			continue;
-		count += uv_examine_destination(uv_bau_table_bases[i], sender);
+		/* find a cpu for this uvhub */
+		cpu = uvhub_to_first_cpu(uvhub);
+		cpu_set(cpu, mask);
 	}
-	return count;
+	/* IPI all cpus; Preemption is already disabled */
+	smp_call_function_many(&mask, uv_do_reset, (void *)&reset_args, 1);
+	return;
+}
+
+static inline unsigned long
+cycles_2_us(unsigned long long cyc)
+{
+	unsigned long long ns;
+	unsigned long us;
+	ns =  (cyc * per_cpu(cyc2ns, smp_processor_id()))
+						>> CYC2NS_SCALE_FACTOR;
+	us = ns / 1000;
+	return us;
 }
 
 /*
- * wait for completion of a broadcast message
- *
- * return COMPLETE, RETRY or GIVEUP
+ * wait for all cpus on this hub to finish their sends and go quiet
+ * leaves uvhub_quiesce set so that no new broadcasts are started by
+ * bau_flush_send_and_wait()
+ */
+static inline void
+quiesce_local_uvhub(struct bau_control *hmaster)
+{
+	atomic_add_short_return(1, (struct atomic_short *)
+		 &hmaster->uvhub_quiesce);
+}
+
+/*
+ * mark this quiet-requestor as done
+ */
+static inline void
+end_uvhub_quiesce(struct bau_control *hmaster)
+{
+	atomic_add_short_return(-1, (struct atomic_short *)
+		&hmaster->uvhub_quiesce);
+}
+
+/*
+ * Wait for completion of a broadcast software ack message
+ * return COMPLETE, RETRY(PLUGGED or TIMEOUT) or GIVEUP
  */
 static int uv_wait_completion(struct bau_desc *bau_desc,
-			      unsigned long mmr_offset, int right_shift)
+	unsigned long mmr_offset, int right_shift, int this_cpu,
+	struct bau_control *bcp, struct bau_control *smaster, long try)
 {
-	int exams = 0;
-	long destination_timeouts = 0;
-	long source_timeouts = 0;
 	unsigned long descriptor_status;
+	cycles_t ttime;
+	struct ptc_stats *stat = bcp->statp;
+	struct bau_control *hmaster;
 
+	hmaster = bcp->uvhub_master;
+
+	/* spin on the status MMR, waiting for it to go idle */
 	while ((descriptor_status = (((unsigned long)
 		uv_read_local_mmr(mmr_offset) >>
 			right_shift) & UV_ACT_STATUS_MASK)) !=
 			DESC_STATUS_IDLE) {
-		if (descriptor_status == DESC_STATUS_SOURCE_TIMEOUT) {
-			source_timeouts++;
-			if (source_timeouts > SOURCE_TIMEOUT_LIMIT)
-				source_timeouts = 0;
-			__get_cpu_var(ptcstats).s_retry++;
-			return FLUSH_RETRY;
-		}
 		/*
-		 * spin here looking for progress at the destinations
+		 * Our software ack messages may be blocked because there are
+		 * no swack resources available.  As long as none of them
+		 * has timed out hardware will NACK our message and its
+		 * state will stay IDLE.
 		 */
-		if (descriptor_status == DESC_STATUS_DESTINATION_TIMEOUT) {
-			destination_timeouts++;
-			if (destination_timeouts > DESTINATION_TIMEOUT_LIMIT) {
-				/*
-				 * returns number of cpus not responding
-				 */
-				if (uv_examine_destinations
-				    (&bau_desc->distribution) == 0) {
-					__get_cpu_var(ptcstats).d_retry++;
-					return FLUSH_RETRY;
-				}
-				exams++;
-				if (exams >= uv_bau_retry_limit) {
-					printk(KERN_DEBUG
-					       "uv_flush_tlb_others");
-					printk("giving up on cpu %d\n",
-					       smp_processor_id());
-					return FLUSH_GIVEUP;
-				}
-				/*
-				 * delays can hang the simulator
-				   udelay(1000);
-				 */
-				destination_timeouts = 0;
+		if (descriptor_status == DESC_STATUS_SOURCE_TIMEOUT) {
+			stat->s_stimeout++;
+			return FLUSH_GIVEUP;
+		} else if (descriptor_status ==
+					DESC_STATUS_DESTINATION_TIMEOUT) {
+			stat->s_dtimeout++;
+			ttime = get_cycles();
+
+			/*
+			 * Our retries may be blocked by all destination
+			 * swack resources being consumed, and a timeout
+			 * pending.  In that case hardware returns the
+			 * ERROR that looks like a destination timeout.
+			 */
+			if (cycles_2_us(ttime - bcp->send_message) <
+							timeout_us) {
+				bcp->conseccompletes = 0;
+				return FLUSH_RETRY_PLUGGED;
 			}
+
+			bcp->conseccompletes = 0;
+			return FLUSH_RETRY_TIMEOUT;
+		} else {
+			/*
+			 * descriptor_status is still BUSY
+			 */
+			cpu_relax();
 		}
-		cpu_relax();
 	}
+	bcp->conseccompletes++;
 	return FLUSH_COMPLETE;
 }
 
+static inline cycles_t
+sec_2_cycles(unsigned long sec)
+{
+	unsigned long ns;
+	cycles_t cyc;
+
+	ns = sec * 1000000000;
+	cyc = (ns << CYC2NS_SCALE_FACTOR)/(per_cpu(cyc2ns, smp_processor_id()));
+	return cyc;
+}
+
+/*
+ * conditionally add 1 to *v, unless *v is >= u
+ * return 0 if we cannot add 1 to *v because it is >= u
+ * return 1 if we can add 1 to *v because it is < u
+ * the add is atomic
+ *
+ * This is close to atomic_add_unless(), but this allows the 'u' value
+ * to be lowered below the current 'v'.  atomic_add_unless can only stop
+ * on equal.
+ */
+static inline int atomic_inc_unless_ge(spinlock_t *lock, atomic_t *v, int u)
+{
+	spin_lock(lock);
+	if (atomic_read(v) >= u) {
+		spin_unlock(lock);
+		return 0;
+	}
+	atomic_inc(v);
+	spin_unlock(lock);
+	return 1;
+}
+
 /**
  * uv_flush_send_and_wait
  *
- * Send a broadcast and wait for a broadcast message to complete.
+ * Send a broadcast and wait for it to complete.
  *
- * The flush_mask contains the cpus the broadcast was sent to.
+ * The flush_mask contains the cpus the broadcast is to be sent to including
+ * cpus that are on the local uvhub.
  *
- * Returns NULL if all remote flushing was done. The mask is zeroed.
- * Returns @flush_mask if some remote flushing remains to be done. The
- * mask will have some bits still set.
+ * Returns 0 if all flushing represented in the mask was done.
+ * Returns 1 if it gives up entirely and the original cpu mask is to be
+ * returned to the kernel.
  */
-const struct cpumask *uv_flush_send_and_wait(int cpu, int this_pnode,
-					     struct bau_desc *bau_desc,
-					     struct cpumask *flush_mask)
+int uv_flush_send_and_wait(struct bau_desc *bau_desc,
+			   struct cpumask *flush_mask, struct bau_control *bcp)
 {
-	int completion_status = 0;
 	int right_shift;
-	int tries = 0;
-	int pnode;
-	int bit;
+	int completion_status = 0;
+	int seq_number = 0;
+	long try = 0;
+	int cpu = bcp->uvhub_cpu;
+	int tcpu;
+	int this_cpu = bcp->cpu;
 	unsigned long mmr_offset;
 	unsigned long index;
 	cycles_t time1;
 	cycles_t time2;
+	cycles_t elapsed;
+	cycles_t local_congested_cycles = congested_cycles;
+	struct ptc_stats *stat = bcp->statp;
+	struct bau_control *smaster = bcp->socket_master;
+	struct bau_control *hmaster = bcp->uvhub_master;
+	struct bau_control *tbcp;
+
+	/*
+	 * Spin here while there are hmaster->max_bau_concurrent or more active
+	 * descriptors. This is the per-uvhub 'throttle'.
+	 */
+	if (!atomic_inc_unless_ge(&hmaster->uvhub_lock,
+			&hmaster->active_descriptor_count,
+			hmaster->max_bau_concurrent)) {
+		stat->s_throttles++;
+		do {
+			cpu_relax();
+		} while (!atomic_inc_unless_ge(&hmaster->uvhub_lock,
+			&hmaster->active_descriptor_count,
+			hmaster->max_bau_concurrent));
+	}
+
+	while (hmaster->uvhub_quiesce)
+		cpu_relax();
 
 	if (cpu < UV_CPUS_PER_ACT_STATUS) {
 		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_0;
@@ -268,44 +541,147 @@ const struct cpumask *uv_flush_send_and_
 	}
 	time1 = get_cycles();
 	do {
-		tries++;
+		/*
+		 * Every message from any given cpu gets a unique message
+		 * sequence number. But retries use that same number.
+		 * Our message may have timed out at the destination because
+		 * all sw-ack resources are in use and there is a timeout
+		 * pending there.  In that case, our last send never got
+		 * placed into the queue and we need to persist until it
+		 * does.
+		 *
+		 * Make any retry a type MSG_RETRY so that the destination will
+		 * free any resource held by a previous message from this cpu.
+		 */
+		if (try == 0) {
+			bau_desc->header.msg_type = MSG_REGULAR;
+			seq_number = bcp->message_number++;
+		} else {
+			bau_desc->header.msg_type = MSG_RETRY;
+			stat->s_retry_messages++;
+		}
+		bau_desc->header.sequence = seq_number;
 		index = (1UL << UVH_LB_BAU_SB_ACTIVATION_CONTROL_PUSH_SHFT) |
-			cpu;
+			bcp->uvhub_cpu;
+		bcp->send_message = get_cycles();
+
 		uv_write_local_mmr(UVH_LB_BAU_SB_ACTIVATION_CONTROL, index);
+
+		try++;
 		completion_status = uv_wait_completion(bau_desc, mmr_offset,
-					right_shift);
-	} while (completion_status == FLUSH_RETRY);
+			right_shift, this_cpu, bcp, smaster, try);
+
+		if (completion_status == FLUSH_RETRY_PLUGGED) {
+			/*
+			 * Our retries may be blocked by all destination swack
+			 * resources being consumed, and a timeout pending. In
+			 * that case hardware immediately returns the ERROR
+			 * that looks like a destination timeout.
+			 */
+			udelay(bcp->plugged_delay);
+			bcp->plugged_tries++;
+			if (bcp->plugged_tries >= bcp->plugsb4reset) {
+				bcp->plugged_tries = 0;
+				quiesce_local_uvhub(hmaster);
+				spin_lock(&hmaster->queue_lock);
+				uv_reset_with_ipi(&bau_desc->distribution,
+							this_cpu);
+				spin_unlock(&hmaster->queue_lock);
+				end_uvhub_quiesce(hmaster);
+				bcp->ipi_attempts++;
+				stat->s_resets_plug++;
+			}
+		} else if (completion_status == FLUSH_RETRY_TIMEOUT) {
+			hmaster->max_bau_concurrent = 1;
+			bcp->timeout_tries++;
+			if (bcp->timeout_tries >= bcp->timeoutsb4reset) {
+				bcp->timeout_tries = 0;
+				quiesce_local_uvhub(hmaster);
+				spin_lock(&hmaster->queue_lock);
+				uv_reset_with_ipi(&bau_desc->distribution,
+								this_cpu);
+				spin_unlock(&hmaster->queue_lock);
+				end_uvhub_quiesce(hmaster);
+				bcp->ipi_attempts++;
+				stat->s_resets_timeout++;
+			}
+		}
+		if (bcp->ipi_attempts >= bcp->ipi_reset_limit) {
+			bcp->ipi_attempts = 0;
+			completion_status = FLUSH_GIVEUP;
+			break;
+		}
+		cpu_relax();
+	} while ((completion_status == FLUSH_RETRY_PLUGGED) ||
+		 (completion_status == FLUSH_RETRY_TIMEOUT));
 	time2 = get_cycles();
-	__get_cpu_var(ptcstats).sflush += (time2 - time1);
-	if (tries > 1)
-		__get_cpu_var(ptcstats).retriesok++;
 
-	if (completion_status == FLUSH_GIVEUP) {
+	bcp->plugged_tries = 0;
+	bcp->timeout_tries = 0;
+
+	if ((completion_status == FLUSH_COMPLETE) &&
+	    (bcp->conseccompletes > bcp->complete_threshold) &&
+	    (hmaster->max_bau_concurrent <
+					hmaster->max_bau_concurrent_constant))
+			hmaster->max_bau_concurrent++;
+
+	/*
+	 * hold any cpu not timing out here; no other cpu currently held by
+	 * the 'throttle' should enter the activation code
+	 */
+	while (hmaster->uvhub_quiesce)
+		cpu_relax();
+	atomic_dec(&hmaster->active_descriptor_count);
+
+	/* guard against cycles wrap */
+	if (time2 > time1) {
+		elapsed = time2 - time1;
+		stat->s_time += elapsed;
+		/* check for a sustained long, non-timeout request times */
+		if ((completion_status == FLUSH_COMPLETE) && (try == 1)) {
+			bcp->period_requests++;
+			bcp->period_time += elapsed;
+			if ((elapsed > local_congested_cycles) &&
+			    (bcp->period_requests > bcp->congested_reps)) {
+				/* let only one cpu do this disabling */
+				spin_lock(&disable_lock);
+				if (!baudisabled && bcp->period_requests &&
+				    ((bcp->period_time / bcp->period_requests) >
+						local_congested_cycles)) {
+					/* it becomes this cpu's job to turn
+					   on the use of the BAU again */
+					baudisabled = 1;
+					bcp->set_bau_off = 1;
+					bcp->set_bau_on_time = get_cycles() +
+					sec_2_cycles(bcp->congested_period);
+					stat->s_bau_disabled++;
+					for_each_present_cpu(tcpu) {
+						tbcp = &per_cpu(bau_control,
+									tcpu);
+						tbcp->baudisabled = 1;
+					}
+				}
+				spin_unlock(&disable_lock);
+			}
+		}
+	} else
+		stat->s_requestor--; /* don't count this one */
+	if (completion_status == FLUSH_COMPLETE && try > 1)
+		stat->s_retriesok++;
+	else if (completion_status == FLUSH_GIVEUP) {
 		/*
 		 * Cause the caller to do an IPI-style TLB shootdown on
-		 * the cpu's, all of which are still in the mask.
+		 * the target cpu's using the original mask.
 		 */
-		__get_cpu_var(ptcstats).ptc_i++;
-		return flush_mask;
+		stat->s_giveup++;
+		return 1;
 	}
-
 	/*
-	 * Success, so clear the remote cpu's from the mask so we don't
-	 * use the IPI method of shootdown on them.
+	 * Success
 	 */
-	for_each_cpu(bit, flush_mask) {
-		pnode = uv_cpu_to_pnode(bit);
-		if (pnode == this_pnode)
-			continue;
-		cpumask_clear_cpu(bit, flush_mask);
-	}
-	if (!cpumask_empty(flush_mask))
-		return flush_mask;
-	return NULL;
+	return 0;
 }
 
-static DEFINE_PER_CPU(cpumask_var_t, uv_flush_tlb_mask);
-
 /**
  * uv_flush_tlb_others - globally purge translation cache of a virtual
  * address or all TLB's
@@ -322,8 +698,8 @@ static DEFINE_PER_CPU(cpumask_var_t, uv_
  * The caller has derived the cpumask from the mm_struct.  This function
  * is called only if there are bits set in the mask. (e.g. flush_tlb_page())
  *
- * The cpumask is converted into a nodemask of the nodes containing
- * the cpus.
+ * The cpumask is converted into a uvhubmask of the uvhubs containing
+ * those cpus.
  *
  * Note that this function should be called with preemption disabled.
  *
@@ -335,52 +711,100 @@ const struct cpumask *uv_flush_tlb_other
 					  struct mm_struct *mm,
 					  unsigned long va, unsigned int cpu)
 {
-	struct cpumask *flush_mask = __get_cpu_var(uv_flush_tlb_mask);
-	int i;
-	int bit;
-	int pnode;
-	int uv_cpu;
-	int this_pnode;
+	int tcpu;
+	int uvhub;
 	int locals = 0;
+	int remotes = 0;
+	int hubs = 0;
 	struct bau_desc *bau_desc;
+	struct cpumask *flush_mask;
+	struct ptc_stats *stat;
+	struct bau_control *bcp;
+	struct bau_control *tbcp;
 
-	cpumask_andnot(flush_mask, cpumask, cpumask_of(cpu));
+	bcp = &per_cpu(bau_control, cpu);
+	stat = bcp->statp;
 
-	uv_cpu = uv_blade_processor_id();
-	this_pnode = uv_hub_info->pnode;
-	bau_desc = __get_cpu_var(bau_control).descriptor_base;
-	bau_desc += UV_ITEMS_PER_DESCRIPTOR * uv_cpu;
-
-	bau_nodes_clear(&bau_desc->distribution, UV_DISTRIBUTION_SIZE);
-
-	i = 0;
-	for_each_cpu(bit, flush_mask) {
-		pnode = uv_cpu_to_pnode(bit);
-		BUG_ON(pnode > (UV_DISTRIBUTION_SIZE - 1));
-		if (pnode == this_pnode) {
-			locals++;
-			continue;
+	/* bau was disabled due to slow response */
+	if (bcp->baudisabled) {
+		/* the cpu that disabled it must re-enable it */
+		if (bcp->set_bau_off) {
+			if (get_cycles() >= bcp->set_bau_on_time) {
+				stat->s_bau_reenabled++;
+				baudisabled = 0;
+				for_each_present_cpu(tcpu) {
+					tbcp = &per_cpu(bau_control, tcpu);
+					tbcp->baudisabled = 0;
+					tbcp->period_requests = 0;
+					tbcp->period_time = 0;
+				}
+			}
 		}
-		bau_node_set(pnode - uv_partition_base_pnode,
-				&bau_desc->distribution);
-		i++;
+		return cpumask;
 	}
-	if (i == 0) {
-		/*
-		 * no off_node flushing; return status for local node
-		 */
-		if (locals)
-			return flush_mask;
+
+	/*
+	 * Each sending cpu has a per-cpu mask which it fills from the caller's
+	 * cpu mask.  All cpus are converted to uvhubs and copied to the
+	 * activation descriptor.
+	 */
+	flush_mask = (struct cpumask *)per_cpu(uv_flush_tlb_mask, cpu);
+	/* don't actually do a shootdown of the local cpu */
+	cpumask_andnot(flush_mask, cpumask, cpumask_of(cpu));
+	if (cpu_isset(cpu, *cpumask))
+		stat->s_ntargself++;
+
+	bau_desc = bcp->descriptor_base;
+	bau_desc += UV_ITEMS_PER_DESCRIPTOR * bcp->uvhub_cpu;
+	bau_uvhubs_clear(&bau_desc->distribution, UV_DISTRIBUTION_SIZE);
+
+	/* cpu statistics */
+	for_each_cpu(tcpu, flush_mask) {
+		uvhub = uv_cpu_to_blade_id(tcpu);
+		bau_uvhub_set(uvhub, &bau_desc->distribution);
+		if (uvhub == bcp->uvhub)
+			locals++;
 		else
-			return NULL;
+			remotes++;
 	}
-	__get_cpu_var(ptcstats).requestor++;
-	__get_cpu_var(ptcstats).ntargeted += i;
+	if ((locals + remotes) == 0)
+		return NULL;
+	stat->s_requestor++;
+	stat->s_ntargcpu += remotes + locals;
+	stat->s_ntargremotes += remotes;
+	stat->s_ntarglocals += locals;
+	remotes = bau_uvhub_weight(&bau_desc->distribution);
+
+	/* uvhub statistics */
+	hubs = bau_uvhub_weight(&bau_desc->distribution);
+	if (locals) {
+		stat->s_ntarglocaluvhub++;
+		stat->s_ntargremoteuvhub += (hubs - 1);
+	} else
+		stat->s_ntargremoteuvhub += hubs;
+	stat->s_ntarguvhub += hubs;
+	if (hubs >= 16)
+		stat->s_ntarguvhub16++;
+	else if (hubs >= 8)
+		stat->s_ntarguvhub8++;
+	else if (hubs >= 4)
+		stat->s_ntarguvhub4++;
+	else if (hubs >= 2)
+		stat->s_ntarguvhub2++;
+	else
+		stat->s_ntarguvhub1++;
 
 	bau_desc->payload.address = va;
 	bau_desc->payload.sending_cpu = cpu;
 
-	return uv_flush_send_and_wait(uv_cpu, this_pnode, bau_desc, flush_mask);
+	/*
+	 * uv_flush_send_and_wait returns 0 if all cpu's were messaged,
+	 * or 1 if it gave up and the original cpumask should be returned.
+	 */
+	if (!uv_flush_send_and_wait(bau_desc, flush_mask, bcp))
+		return NULL;
+	else
+		return cpumask;
 }
 
 /*
@@ -389,87 +813,70 @@ const struct cpumask *uv_flush_tlb_other
  *
  * We received a broadcast assist message.
  *
- * Interrupts may have been disabled; this interrupt could represent
+ * Interrupts are disabled; this interrupt could represent
  * the receipt of several messages.
  *
- * All cores/threads on this node get this interrupt.
- * The last one to see it does the s/w ack.
+ * All cores/threads on this hub get this interrupt.
+ * The last one to see it does the software ack.
  * (the resource will not be freed until noninterruptable cpus see this
- *  interrupt; hardware will timeout the s/w ack and reply ERROR)
+ *  interrupt; hardware may timeout the s/w ack and reply ERROR)
  */
 void uv_bau_message_interrupt(struct pt_regs *regs)
 {
-	struct bau_payload_queue_entry *va_queue_first;
-	struct bau_payload_queue_entry *va_queue_last;
-	struct bau_payload_queue_entry *msg;
-	struct pt_regs *old_regs = set_irq_regs(regs);
-	cycles_t time1;
-	cycles_t time2;
-	int msg_slot;
-	int sw_ack_slot;
-	int fw;
 	int count = 0;
-	unsigned long local_pnode;
-
-	ack_APIC_irq();
-	exit_idle();
-	irq_enter();
-
-	time1 = get_cycles();
-
-	local_pnode = uv_blade_to_pnode(uv_numa_blade_id());
-
-	va_queue_first = __get_cpu_var(bau_control).va_queue_first;
-	va_queue_last = __get_cpu_var(bau_control).va_queue_last;
+	cycles_t time_start;
+	struct bau_payload_queue_entry *msg;
+	struct bau_control *bcp;
+	struct ptc_stats *stat;
+	struct msg_desc msgdesc;
 
-	msg = __get_cpu_var(bau_control).bau_msg_head;
+	time_start = get_cycles();
+	bcp = &per_cpu(bau_control, smp_processor_id());
+	stat = bcp->statp;
+	msgdesc.va_queue_first = bcp->va_queue_first;
+	msgdesc.va_queue_last = bcp->va_queue_last;
+	msg = bcp->bau_msg_head;
 	while (msg->sw_ack_vector) {
 		count++;
-		fw = msg->sw_ack_vector;
-		msg_slot = msg - va_queue_first;
-		sw_ack_slot = ffs(fw) - 1;
-
-		uv_bau_process_message(msg, msg_slot, sw_ack_slot);
-
+		msgdesc.msg_slot = msg - msgdesc.va_queue_first;
+		msgdesc.sw_ack_slot = ffs(msg->sw_ack_vector) - 1;
+		msgdesc.msg = msg;
+		uv_bau_process_message(&msgdesc, bcp);
 		msg++;
-		if (msg > va_queue_last)
-			msg = va_queue_first;
-		__get_cpu_var(bau_control).bau_msg_head = msg;
+		if (msg > msgdesc.va_queue_last)
+			msg = msgdesc.va_queue_first;
+		bcp->bau_msg_head = msg;
 	}
+	stat->d_time += (get_cycles() - time_start);
 	if (!count)
-		__get_cpu_var(ptcstats).nomsg++;
+		stat->d_nomsg++;
 	else if (count > 1)
-		__get_cpu_var(ptcstats).multmsg++;
-
-	time2 = get_cycles();
-	__get_cpu_var(ptcstats).dflush += (time2 - time1);
-
-	irq_exit();
-	set_irq_regs(old_regs);
+		stat->d_multmsg++;
+	ack_APIC_irq();
 }
 
 /*
  * uv_enable_timeouts
  *
- * Each target blade (i.e. blades that have cpu's) needs to have
+ * Each target uvhub (i.e. a uvhub that has no cpu's) needs to have
  * shootdown message timeouts enabled.  The timeout does not cause
  * an interrupt, but causes an error message to be returned to
  * the sender.
  */
 static void uv_enable_timeouts(void)
 {
-	int blade;
-	int nblades;
+	int uvhub;
+	int nuvhubs;
 	int pnode;
 	unsigned long mmr_image;
 
-	nblades = uv_num_possible_blades();
+	nuvhubs = uv_num_possible_blades();
 
-	for (blade = 0; blade < nblades; blade++) {
-		if (!uv_blade_nr_possible_cpus(blade))
+	for (uvhub = 0; uvhub < nuvhubs; uvhub++) {
+		if (!uv_blade_nr_possible_cpus(uvhub))
 			continue;
 
-		pnode = uv_blade_to_pnode(blade);
+		pnode = uv_blade_to_pnode(uvhub);
 		mmr_image =
 		    uv_read_global_mmr64(pnode, UVH_LB_BAU_MISC_CONTROL);
 		/*
@@ -479,16 +886,16 @@ static void uv_enable_timeouts(void)
 		 * To program the period, the SOFT_ACK_MODE must be off.
 		 */
 		mmr_image &= ~((unsigned long)1 <<
-			       UV_ENABLE_INTD_SOFT_ACK_MODE_SHIFT);
+		    UVH_LB_BAU_MISC_CONTROL_ENABLE_INTD_SOFT_ACK_MODE_SHFT);
 		uv_write_global_mmr64
 		    (pnode, UVH_LB_BAU_MISC_CONTROL, mmr_image);
 		/*
 		 * Set the 4-bit period.
 		 */
 		mmr_image &= ~((unsigned long)0xf <<
-			UV_INTD_SOFT_ACK_TIMEOUT_PERIOD_SHIFT);
+		     UVH_LB_BAU_MISC_CONTROL_INTD_SOFT_ACK_TIMEOUT_PERIOD_SHFT);
 		mmr_image |= (UV_INTD_SOFT_ACK_TIMEOUT_PERIOD <<
-			     UV_INTD_SOFT_ACK_TIMEOUT_PERIOD_SHIFT);
+		     UVH_LB_BAU_MISC_CONTROL_INTD_SOFT_ACK_TIMEOUT_PERIOD_SHFT);
 		uv_write_global_mmr64
 		    (pnode, UVH_LB_BAU_MISC_CONTROL, mmr_image);
 		/*
@@ -497,7 +904,7 @@ static void uv_enable_timeouts(void)
 		 * indicated in bits 2:0 (7 causes all of them to timeout).
 		 */
 		mmr_image |= ((unsigned long)1 <<
-			      UV_ENABLE_INTD_SOFT_ACK_MODE_SHIFT);
+		    UVH_LB_BAU_MISC_CONTROL_ENABLE_INTD_SOFT_ACK_MODE_SHFT);
 		uv_write_global_mmr64
 		    (pnode, UVH_LB_BAU_MISC_CONTROL, mmr_image);
 	}
@@ -522,9 +929,20 @@ static void uv_ptc_seq_stop(struct seq_f
 {
 }
 
+static inline unsigned long long
+microsec_2_cycles(unsigned long microsec)
+{
+	unsigned long ns;
+	unsigned long long cyc;
+
+	ns = microsec * 1000;
+	cyc = (ns << CYC2NS_SCALE_FACTOR)/(per_cpu(cyc2ns, smp_processor_id()));
+	return cyc;
+}
+
 /*
- * Display the statistics thru /proc
- * data points to the cpu number
+ * Display the statistics thru /proc.
+ * 'data' points to the cpu number
  */
 static int uv_ptc_seq_show(struct seq_file *file, void *data)
 {
@@ -535,80 +953,312 @@ static int uv_ptc_seq_show(struct seq_fi
 
 	if (!cpu) {
 		seq_printf(file,
-		"# cpu requestor requestee one all sretry dretry ptc_i ");
+			"# cpu sent stime self locals remotes ncpus localhub ");
+		seq_printf(file,
+			"remotehub numuvhubs numuvhubs16 numuvhubs8 ");
+		seq_printf(file,
+			"numuvhubs4 numuvhubs2 numuvhubs1 dto ");
+		seq_printf(file,
+			"retries rok resetp resett giveup sto bz throt ");
+		seq_printf(file,
+			"sw_ack recv rtime all ");
+		seq_printf(file,
+			"one mult none retry canc nocan reset rcan ");
 		seq_printf(file,
-		"sw_ack sflush dflush sok dnomsg dmult starget\n");
+			"disable enable\n");
 	}
 	if (cpu < num_possible_cpus() && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
-		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld ",
-			   cpu, stat->requestor,
-			   stat->requestee, stat->onetlb, stat->alltlb,
-			   stat->s_retry, stat->d_retry, stat->ptc_i);
-		seq_printf(file, "%lx %ld %ld %ld %ld %ld %ld\n",
+		/* source side statistics */
+		seq_printf(file,
+			"cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld ",
+			   cpu, stat->s_requestor, cycles_2_us(stat->s_time),
+			   stat->s_ntargself, stat->s_ntarglocals,
+			   stat->s_ntargremotes, stat->s_ntargcpu,
+			   stat->s_ntarglocaluvhub, stat->s_ntargremoteuvhub,
+			   stat->s_ntarguvhub, stat->s_ntarguvhub16);
+		seq_printf(file, "%ld %ld %ld %ld %ld ",
+			   stat->s_ntarguvhub8, stat->s_ntarguvhub4,
+			   stat->s_ntarguvhub2, stat->s_ntarguvhub1,
+			   stat->s_dtimeout);
+		seq_printf(file, "%ld %ld %ld %ld %ld %ld %ld %ld ",
+			   stat->s_retry_messages, stat->s_retriesok,
+			   stat->s_resets_plug, stat->s_resets_timeout,
+			   stat->s_giveup, stat->s_stimeout,
+			   stat->s_busy, stat->s_throttles);
+
+		/* destination side statistics */
+		seq_printf(file,
+			   "%lx %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld ",
 			   uv_read_global_mmr64(uv_cpu_to_pnode(cpu),
 					UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE),
-			   stat->sflush, stat->dflush,
-			   stat->retriesok, stat->nomsg,
-			   stat->multmsg, stat->ntargeted);
+			   stat->d_requestee, cycles_2_us(stat->d_time),
+			   stat->d_alltlb, stat->d_onetlb, stat->d_multmsg,
+			   stat->d_nomsg, stat->d_retries, stat->d_canceled,
+			   stat->d_nocanceled, stat->d_resets,
+			   stat->d_rcanceled);
+		seq_printf(file, "%ld %ld\n",
+			stat->s_bau_disabled, stat->s_bau_reenabled);
 	}
 
 	return 0;
 }
 
 /*
+ * Display the tunables thru /proc.
+ */
+static int uv_bau_show(struct seq_file *file, void *p)
+{
+	seq_printf(file, "max_bau_concurrent plugged_delay plugsb4reset ");
+	seq_printf(file, "timeoutsb4reset ipi_reset_limit complete_threshold ");
+	seq_printf(file, "congested_response_us congested_reps ");
+	seq_printf(file, "congested_period\n");
+	seq_printf(file, "%d %d %d %d %d %d %d %d %d\n",
+		max_bau_concurrent, plugged_delay, plugsb4reset,
+		timeoutsb4reset, ipi_reset_limit, complete_threshold,
+		congested_response_us, congested_reps, congested_period);
+
+	return 0;
+}
+
+/*
+ * -1: resetf the statistics
  *  0: display meaning of the statistics
- * >0: retry limit
  */
 static ssize_t uv_ptc_proc_write(struct file *file, const char __user *user,
 				 size_t count, loff_t *data)
 {
-	long newmode;
+	int cpu;
+	long input_arg;
 	char optstr[64];
+	struct ptc_stats *stat;
 
 	if (count == 0 || count > sizeof(optstr))
 		return -EINVAL;
 	if (copy_from_user(optstr, user, count))
 		return -EFAULT;
 	optstr[count - 1] = '\0';
-	if (strict_strtoul(optstr, 10, &newmode) < 0) {
+	if (strict_strtol(optstr, 10, &input_arg) < 0) {
 		printk(KERN_DEBUG "%s is invalid\n", optstr);
 		return -EINVAL;
 	}
 
-	if (newmode == 0) {
+	if (input_arg == 0) {
 		printk(KERN_DEBUG "# cpu:      cpu number\n");
+		printk(KERN_DEBUG "Sender statistics:\n");
 		printk(KERN_DEBUG
-		"requestor:  times this cpu was the flush requestor\n");
+		"sent:     number of shootdown messages sent\n");
 		printk(KERN_DEBUG
-		"requestee:  times this cpu was requested to flush its TLBs\n");
+		"stime:    time spent sending messages\n");
 		printk(KERN_DEBUG
-		"one:        times requested to flush a single address\n");
+		"numuvhubs: number of hubs targeted with shootdown\n");
 		printk(KERN_DEBUG
-		"all:        times requested to flush all TLB's\n");
+		"numuvhubs16: number times 16 or more hubs targeted\n");
 		printk(KERN_DEBUG
-		"sretry:     number of retries of source-side timeouts\n");
+		"numuvhubs8: number times 8 or more hubs targeted\n");
 		printk(KERN_DEBUG
-		"dretry:     number of retries of destination-side timeouts\n");
+		"numuvhubs4: number times 4 or more hubs targeted\n");
 		printk(KERN_DEBUG
-		"ptc_i:      times UV fell through to IPI-style flushes\n");
+		"numuvhubs2: number times 2 or more hubs targeted\n");
 		printk(KERN_DEBUG
-		"sw_ack:     image of UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE\n");
+		"numuvhubs1: number times 1 hub targeted\n");
 		printk(KERN_DEBUG
-		"sflush_us:  cycles spent in uv_flush_tlb_others()\n");
+		"numcpus:  number of cpus targeted with shootdown\n");
 		printk(KERN_DEBUG
-		"dflush_us:  cycles spent in handling flush requests\n");
-		printk(KERN_DEBUG "sok:        successes on retry\n");
-		printk(KERN_DEBUG "dnomsg:     interrupts with no message\n");
+		"dto:      number of destination timeouts\n");
 		printk(KERN_DEBUG
-		"dmult:      interrupts with multiple messages\n");
-		printk(KERN_DEBUG "starget:    nodes targeted\n");
-	} else {
-		uv_bau_retry_limit = newmode;
-		printk(KERN_DEBUG "timeout retry limit:%d\n",
-		       uv_bau_retry_limit);
+		"retries:  destination timeout retries sent\n");
+		printk(KERN_DEBUG
+		"rok:   :  destination timeouts successfully retried\n");
+		printk(KERN_DEBUG
+		"resetp:   ipi-style resource resets for plugs\n");
+		printk(KERN_DEBUG
+		"resett:   ipi-style resource resets for timeouts\n");
+		printk(KERN_DEBUG
+		"giveup:   fall-backs to ipi-style shootdowns\n");
+		printk(KERN_DEBUG
+		"sto:      number of source timeouts\n");
+		printk(KERN_DEBUG
+		"bz:       number of stay-busy's\n");
+		printk(KERN_DEBUG
+		"throt:    number times spun in throttle\n");
+		printk(KERN_DEBUG "Destination side statistics:\n");
+		printk(KERN_DEBUG
+		"sw_ack:   image of UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE\n");
+		printk(KERN_DEBUG
+		"recv:     shootdown messages received\n");
+		printk(KERN_DEBUG
+		"rtime:    time spent processing messages\n");
+		printk(KERN_DEBUG
+		"all:      shootdown all-tlb messages\n");
+		printk(KERN_DEBUG
+		"one:      shootdown one-tlb messages\n");
+		printk(KERN_DEBUG
+		"mult:     interrupts that found multiple messages\n");
+		printk(KERN_DEBUG
+		"none:     interrupts that found no messages\n");
+		printk(KERN_DEBUG
+		"retry:    number of retry messages processed\n");
+		printk(KERN_DEBUG
+		"canc:     number messages canceled by retries\n");
+		printk(KERN_DEBUG
+		"nocan:    number retries that found nothing to cancel\n");
+		printk(KERN_DEBUG
+		"reset:    number of ipi-style reset requests processed\n");
+		printk(KERN_DEBUG
+		"rcan:     number messages canceled by reset requests\n");
+		printk(KERN_DEBUG
+		"disable:  number times use of the BAU was disabled\n");
+		printk(KERN_DEBUG
+		"enable:   number times use of the BAU was re-enabled\n");
+	} else if (input_arg == -1) {
+		for_each_present_cpu(cpu) {
+			stat = &per_cpu(ptcstats, cpu);
+			memset(stat, 0, sizeof(struct ptc_stats));
+		}
+	}
+
+	return count;
+}
+
+static int local_atoi(const char *name)
+{
+	int val = 0;
+
+	for (;; name++) {
+		switch (*name) {
+		case '0' ... '9':
+			val = 10*val+(*name-'0');
+			break;
+		default:
+			return val;
+		}
+	}
+}
+
+/*
+ * set the tunables
+ * 0 values reset them to defaults
+ */
+static ssize_t uv_bau_proc_write(struct file *file, const char __user *user,
+				 size_t count, loff_t *data)
+{
+	int cpu;
+	int cnt = 0;
+	int val;
+	char *p;
+	char *q;
+	char instr[64];
+	struct bau_control *bcp;
+
+	if (count == 0 || count > sizeof(instr)-1)
+		return -EINVAL;
+	if (copy_from_user(instr, user, count))
+		return -EFAULT;
+
+	instr[count] = '\0';
+	/* count the fields */
+	p = instr + strspn(instr, WHITESPACE);
+	q = p;
+	for (; *p; p = q + strspn(q, WHITESPACE)) {
+		q = p + strcspn(p, WHITESPACE);
+		cnt++;
+		if (q == p)
+			break;
+	}
+	if (cnt != 9) {
+		printk(KERN_INFO "bau tunable error: should be 9 numbers\n");
+		return -EINVAL;
 	}
 
+	p = instr + strspn(instr, WHITESPACE);
+	q = p;
+	for (cnt = 0; *p; p = q + strspn(q, WHITESPACE), cnt++) {
+		q = p + strcspn(p, WHITESPACE);
+		val = local_atoi(p);
+		switch (cnt) {
+		case 0:
+			if (val == 0) {
+				max_bau_concurrent = MAX_BAU_CONCURRENT;
+				max_bau_concurrent_constant =
+							MAX_BAU_CONCURRENT;
+				continue;
+			}
+			bcp = &per_cpu(bau_control, smp_processor_id());
+			if (val < 1 || val > bcp->cpus_in_uvhub) {
+				printk(KERN_DEBUG
+				"Error: BAU max concurrent %d is invalid\n",
+				val);
+				return -EINVAL;
+			}
+			max_bau_concurrent = val;
+			max_bau_concurrent_constant = val;
+			continue;
+		case 1:
+			if (val == 0)
+				plugged_delay = PLUGGED_DELAY;
+			else
+				plugged_delay = val;
+			continue;
+		case 2:
+			if (val == 0)
+				plugsb4reset = PLUGSB4RESET;
+			else
+				plugsb4reset = val;
+			continue;
+		case 3:
+			if (val == 0)
+				timeoutsb4reset = TIMEOUTSB4RESET;
+			else
+				timeoutsb4reset = val;
+			continue;
+		case 4:
+			if (val == 0)
+				ipi_reset_limit = IPI_RESET_LIMIT;
+			else
+				ipi_reset_limit = val;
+			continue;
+		case 5:
+			if (val == 0)
+				complete_threshold = COMPLETE_THRESHOLD;
+			else
+				complete_threshold = val;
+			continue;
+		case 6:
+			if (val == 0)
+				congested_response_us = CONGESTED_RESPONSE_US;
+			else
+				congested_response_us = val;
+			continue;
+		case 7:
+			if (val == 0)
+				congested_reps = CONGESTED_REPS;
+			else
+				congested_reps = val;
+			continue;
+		case 8:
+			if (val == 0)
+				congested_period = CONGESTED_PERIOD;
+			else
+				congested_period = val;
+			continue;
+		}
+		if (q == p)
+			break;
+	}
+	for_each_present_cpu(cpu) {
+		bcp = &per_cpu(bau_control, cpu);
+		bcp->max_bau_concurrent = max_bau_concurrent;
+		bcp->max_bau_concurrent_constant = max_bau_concurrent;
+		bcp->plugged_delay = plugged_delay;
+		bcp->plugsb4reset = plugsb4reset;
+		bcp->timeoutsb4reset = timeoutsb4reset;
+		bcp->ipi_reset_limit = ipi_reset_limit;
+		bcp->complete_threshold = complete_threshold;
+		bcp->congested_response_us = congested_response_us;
+		bcp->congested_reps = congested_reps;
+		bcp->congested_period = congested_period;
+	}
 	return count;
 }
 
@@ -624,6 +1274,11 @@ static int uv_ptc_proc_open(struct inode
 	return seq_open(file, &uv_ptc_seq_ops);
 }
 
+static int uv_bau_proc_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, uv_bau_show, NULL);
+}
+
 static const struct file_operations proc_uv_ptc_operations = {
 	.open		= uv_ptc_proc_open,
 	.read		= seq_read,
@@ -631,10 +1286,18 @@ static const struct file_operations proc
 	.llseek		= seq_lseek,
 	.release	= seq_release,
 };
+static const struct file_operations proc_uv_bau_operations = {
+	.open		= uv_bau_proc_open,
+	.read		= seq_read,
+	.write		= uv_bau_proc_write,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
 
 static int __init uv_ptc_init(void)
 {
 	struct proc_dir_entry *proc_uv_ptc;
+	struct proc_dir_entry *proc_uv_bau;
 
 	if (!is_uv_system())
 		return 0;
@@ -646,83 +1309,41 @@ static int __init uv_ptc_init(void)
 		       UV_PTC_BASENAME);
 		return -EINVAL;
 	}
-	return 0;
-}
-
-/*
- * begin the initialization of the per-blade control structures
- */
-static struct bau_control * __init uv_table_bases_init(int blade, int node)
-{
-	int i;
-	struct bau_msg_status *msp;
-	struct bau_control *bau_tabp;
-
-	bau_tabp =
-	    kmalloc_node(sizeof(struct bau_control), GFP_KERNEL, node);
-	BUG_ON(!bau_tabp);
-
-	bau_tabp->msg_statuses =
-	    kmalloc_node(sizeof(struct bau_msg_status) *
-			 DEST_Q_SIZE, GFP_KERNEL, node);
-	BUG_ON(!bau_tabp->msg_statuses);
-
-	for (i = 0, msp = bau_tabp->msg_statuses; i < DEST_Q_SIZE; i++, msp++)
-		bau_cpubits_clear(&msp->seen_by, (int)
-				  uv_blade_nr_possible_cpus(blade));
-
-	uv_bau_table_bases[blade] = bau_tabp;
-
-	return bau_tabp;
-}
-
-/*
- * finish the initialization of the per-blade control structures
- */
-static void __init
-uv_table_bases_finish(int blade,
-		      struct bau_control *bau_tablesp,
-		      struct bau_desc *adp)
-{
-	struct bau_control *bcp;
-	int cpu;
-
-	for_each_present_cpu(cpu) {
-		if (blade != uv_cpu_to_blade_id(cpu))
-			continue;
-
-		bcp = (struct bau_control *)&per_cpu(bau_control, cpu);
-		bcp->bau_msg_head	= bau_tablesp->va_queue_first;
-		bcp->va_queue_first	= bau_tablesp->va_queue_first;
-		bcp->va_queue_last	= bau_tablesp->va_queue_last;
-		bcp->msg_statuses	= bau_tablesp->msg_statuses;
-		bcp->descriptor_base	= adp;
+	proc_uv_bau = proc_create(UV_BAU_BASENAME, 0444, NULL,
+				  &proc_uv_bau_operations);
+	if (!proc_uv_bau) {
+		printk(KERN_ERR "unable to create %s proc entry\n",
+		       UV_BAU_BASENAME);
+		return -EINVAL;
 	}
+	return 0;
 }
 
 /*
  * initialize the sending side's sending buffers
  */
-static struct bau_desc * __init
+static void
 uv_activation_descriptor_init(int node, int pnode)
 {
 	int i;
+	int cpu;
 	unsigned long pa;
 	unsigned long m;
 	unsigned long n;
-	struct bau_desc *adp;
-	struct bau_desc *ad2;
+	struct bau_desc *bau_desc;
+	struct bau_desc *bd2;
+	struct bau_control *bcp;
 
 	/*
 	 * each bau_desc is 64 bytes; there are 8 (UV_ITEMS_PER_DESCRIPTOR)
-	 * per cpu; and up to 32 (UV_ADP_SIZE) cpu's per blade
+	 * per cpu; and up to 32 (UV_ADP_SIZE) cpu's per uvhub
 	 */
-	adp = (struct bau_desc *)kmalloc_node(sizeof(struct bau_desc)*
+	bau_desc = (struct bau_desc *)kmalloc_node(sizeof(struct bau_desc)*
 		UV_ADP_SIZE*UV_ITEMS_PER_DESCRIPTOR, GFP_KERNEL, node);
-	BUG_ON(!adp);
+	BUG_ON(!bau_desc);
 
-	pa = uv_gpa(adp); /* need the real nasid*/
-	n = uv_gpa_to_pnode(pa);
+	pa = uv_gpa(bau_desc); /* need the real nasid*/
+	n = pa >> uv_nshift;
 	m = pa & uv_mmask;
 
 	uv_write_global_mmr64(pnode, UVH_LB_BAU_SB_DESCRIPTOR_BASE,
@@ -731,96 +1352,243 @@ uv_activation_descriptor_init(int node, 
 	/*
 	 * initializing all 8 (UV_ITEMS_PER_DESCRIPTOR) descriptors for each
 	 * cpu even though we only use the first one; one descriptor can
-	 * describe a broadcast to 256 nodes.
+	 * describe a broadcast to 256 uv hubs.
 	 */
-	for (i = 0, ad2 = adp; i < (UV_ADP_SIZE*UV_ITEMS_PER_DESCRIPTOR);
-		i++, ad2++) {
-		memset(ad2, 0, sizeof(struct bau_desc));
-		ad2->header.sw_ack_flag = 1;
+	for (i = 0, bd2 = bau_desc; i < (UV_ADP_SIZE*UV_ITEMS_PER_DESCRIPTOR);
+		i++, bd2++) {
+		memset(bd2, 0, sizeof(struct bau_desc));
+		bd2->header.sw_ack_flag = 1;
 		/*
-		 * base_dest_nodeid is the first node in the partition, so
-		 * the bit map will indicate partition-relative node numbers.
-		 * note that base_dest_nodeid is actually a nasid.
+		 * base_dest_nodeid is the nasid (pnode<<1) of the first uvhub
+		 * in the partition. The bit map will indicate uvhub numbers,
+		 * which are 0-N in a partition. Pnodes are unique system-wide.
 		 */
-		ad2->header.base_dest_nodeid = uv_partition_base_pnode << 1;
-		ad2->header.dest_subnodeid = 0x10; /* the LB */
-		ad2->header.command = UV_NET_ENDPOINT_INTD;
-		ad2->header.int_both = 1;
+		bd2->header.base_dest_nodeid = uv_partition_base_pnode << 1;
+		bd2->header.dest_subnodeid = 0x10; /* the LB */
+		bd2->header.command = UV_NET_ENDPOINT_INTD;
+		bd2->header.int_both = 1;
 		/*
 		 * all others need to be set to zero:
 		 *   fairness chaining multilevel count replied_to
 		 */
 	}
-	return adp;
+	for_each_present_cpu(cpu) {
+		if (pnode != uv_blade_to_pnode(uv_cpu_to_blade_id(cpu)))
+			continue;
+		bcp = &per_cpu(bau_control, cpu);
+		bcp->descriptor_base = bau_desc;
+	}
 }
 
 /*
  * initialize the destination side's receiving buffers
+ * entered for each uvhub in the partition
+ * - node is first node (kernel memory notion) on the uvhub
+ * - pnode is the uvhub's physical identifier
  */
-static struct bau_payload_queue_entry * __init
-uv_payload_queue_init(int node, int pnode, struct bau_control *bau_tablesp)
+static void
+uv_payload_queue_init(int node, int pnode)
 {
-	struct bau_payload_queue_entry *pqp;
-	unsigned long pa;
 	int pn;
+	int cpu;
 	char *cp;
+	unsigned long pa;
+	struct bau_payload_queue_entry *pqp;
+	struct bau_payload_queue_entry *pqp_malloc;
+	struct bau_control *bcp;
 
 	pqp = (struct bau_payload_queue_entry *) kmalloc_node(
 		(DEST_Q_SIZE + 1) * sizeof(struct bau_payload_queue_entry),
 		GFP_KERNEL, node);
 	BUG_ON(!pqp);
+	pqp_malloc = pqp;
 
 	cp = (char *)pqp + 31;
 	pqp = (struct bau_payload_queue_entry *)(((unsigned long)cp >> 5) << 5);
-	bau_tablesp->va_queue_first = pqp;
+
+	for_each_present_cpu(cpu) {
+		if (pnode != uv_cpu_to_pnode(cpu))
+			continue;
+		/* for every cpu on this pnode: */
+		bcp = &per_cpu(bau_control, cpu);
+		bcp->va_queue_first = pqp;
+		bcp->bau_msg_head = pqp;
+		bcp->va_queue_last = pqp + (DEST_Q_SIZE - 1);
+	}
 	/*
 	 * need the pnode of where the memory was really allocated
 	 */
 	pa = uv_gpa(pqp);
-	pn = uv_gpa_to_pnode(pa);
+	pn = pa >> uv_nshift;
 	uv_write_global_mmr64(pnode,
 			      UVH_LB_BAU_INTD_PAYLOAD_QUEUE_FIRST,
 			      ((unsigned long)pn << UV_PAYLOADQ_PNODE_SHIFT) |
 			      uv_physnodeaddr(pqp));
 	uv_write_global_mmr64(pnode, UVH_LB_BAU_INTD_PAYLOAD_QUEUE_TAIL,
 			      uv_physnodeaddr(pqp));
-	bau_tablesp->va_queue_last = pqp + (DEST_Q_SIZE - 1);
 	uv_write_global_mmr64(pnode, UVH_LB_BAU_INTD_PAYLOAD_QUEUE_LAST,
 			      (unsigned long)
-			      uv_physnodeaddr(bau_tablesp->va_queue_last));
+			      uv_physnodeaddr(pqp + (DEST_Q_SIZE - 1)));
+	/* in effect, all msg_type's are set to MSG_NOOP */
 	memset(pqp, 0, sizeof(struct bau_payload_queue_entry) * DEST_Q_SIZE);
-
-	return pqp;
 }
 
 /*
- * Initialization of each UV blade's structures
+ * Initialization of each UV hub's structures
  */
-static int __init uv_init_blade(int blade)
+static void __init uv_init_uvhub(int uvhub, int vector)
 {
 	int node;
 	int pnode;
-	unsigned long pa;
 	unsigned long apicid;
-	struct bau_desc *adp;
-	struct bau_payload_queue_entry *pqp;
-	struct bau_control *bau_tablesp;
 
-	node = blade_to_first_node(blade);
-	bau_tablesp = uv_table_bases_init(blade, node);
-	pnode = uv_blade_to_pnode(blade);
-	adp = uv_activation_descriptor_init(node, pnode);
-	pqp = uv_payload_queue_init(node, pnode, bau_tablesp);
-	uv_table_bases_finish(blade, bau_tablesp, adp);
+	node = uvhub_to_first_node(uvhub);
+	pnode = uv_blade_to_pnode(uvhub);
+	uv_activation_descriptor_init(node, pnode);
+	uv_payload_queue_init(node, pnode);
 	/*
 	 * the below initialization can't be in firmware because the
 	 * messaging IRQ will be determined by the OS
 	 */
-	apicid = blade_to_first_apicid(blade);
-	pa = uv_read_global_mmr64(pnode, UVH_BAU_DATA_CONFIG);
+	apicid = uvhub_to_first_apicid(uvhub);
 	uv_write_global_mmr64(pnode, UVH_BAU_DATA_CONFIG,
-				      ((apicid << 32) | UV_BAU_MESSAGE));
-	return 0;
+				      ((apicid << 32) | vector));
+}
+
+/*
+ * We will set BAU_MISC_CONTROL with a timeout period.
+ * But the BIOS has set UVH_AGING_PRESCALE_SEL and UVH_TRANSACTION_TIMEOUT.
+ * So the destination timeout period has be be calculated from them.
+ */
+static int
+calculate_destination_timeout(void)
+{
+	unsigned long mmr_image;
+	int mult1;
+	int mult2;
+	int index;
+	int base;
+	int ret;
+	unsigned long ts_ns;
+
+	mult1 = UV_INTD_SOFT_ACK_TIMEOUT_PERIOD & BAU_MISC_CONTROL_MULT_MASK;
+	mmr_image = uv_read_local_mmr(UVH_AGING_PRESCALE_SEL);
+	index = (mmr_image >> BAU_URGENCY_7_SHIFT) & BAU_URGENCY_7_MASK;
+	mmr_image = uv_read_local_mmr(UVH_TRANSACTION_TIMEOUT);
+	mult2 = (mmr_image >> BAU_TRANS_SHIFT) & BAU_TRANS_MASK;
+	base = timeout_base_ns[index];
+	ts_ns = base * mult1 * mult2;
+	ret = ts_ns / 1000;
+	return ret;
+}
+
+/*
+ * initialize the bau_control structure for each cpu
+ */
+static void uv_init_per_cpu(int nuvhubs)
+{
+	int i;
+	int cpu;
+	int pnode;
+	int uvhub;
+	short socket = 0;
+	unsigned short socket_mask;
+	unsigned int uvhub_mask;
+	struct bau_control *bcp;
+	struct uvhub_desc *bdp;
+	struct socket_desc *sdp;
+	struct bau_control *hmaster = NULL;
+	struct bau_control *smaster = NULL;
+	struct socket_desc {
+		short num_cpus;
+		short cpu_number[16];
+	};
+	struct uvhub_desc {
+		unsigned short socket_mask;
+		short num_cpus;
+		short uvhub;
+		short pnode;
+		struct socket_desc socket[2];
+	};
+	struct uvhub_desc *uvhub_descs;
+
+	timeout_us = calculate_destination_timeout();
+
+	uvhub_descs = (struct uvhub_desc *)
+		kmalloc(nuvhubs * sizeof(struct uvhub_desc), GFP_KERNEL);
+	memset(uvhub_descs, 0, nuvhubs * sizeof(struct uvhub_desc));
+	for_each_present_cpu(cpu) {
+		bcp = &per_cpu(bau_control, cpu);
+		memset(bcp, 0, sizeof(struct bau_control));
+		pnode = uv_cpu_hub_info(cpu)->pnode;
+		uvhub = uv_cpu_hub_info(cpu)->numa_blade_id;
+		uvhub_mask |= (1 << uvhub);
+		bdp = &uvhub_descs[uvhub];
+		bdp->num_cpus++;
+		bdp->uvhub = uvhub;
+		bdp->pnode = pnode;
+		/* kludge: 'assuming' one node per socket, and assuming that
+		   disabling a socket just leaves a gap in node numbers */
+		socket = (cpu_to_node(cpu) & 1);;
+		bdp->socket_mask |= (1 << socket);
+		sdp = &bdp->socket[socket];
+		sdp->cpu_number[sdp->num_cpus] = cpu;
+		sdp->num_cpus++;
+	}
+	uvhub = 0;
+	while (uvhub_mask) {
+		if (!(uvhub_mask & 1))
+			goto nexthub;
+		bdp = &uvhub_descs[uvhub];
+		socket_mask = bdp->socket_mask;
+		socket = 0;
+		while (socket_mask) {
+			if (!(socket_mask & 1))
+				goto nextsocket;
+			sdp = &bdp->socket[socket];
+			for (i = 0; i < sdp->num_cpus; i++) {
+				cpu = sdp->cpu_number[i];
+				bcp = &per_cpu(bau_control, cpu);
+				bcp->cpu = cpu;
+				if (i == 0) {
+					smaster = bcp;
+					if (socket == 0)
+						hmaster = bcp;
+				}
+				bcp->cpus_in_uvhub = bdp->num_cpus;
+				bcp->cpus_in_socket = sdp->num_cpus;
+				bcp->socket_master = smaster;
+				bcp->uvhub = bdp->uvhub;
+				bcp->uvhub_master = hmaster;
+				bcp->uvhub_cpu = uv_cpu_hub_info(cpu)->
+						blade_processor_id;
+			}
+nextsocket:
+			socket++;
+			socket_mask = (socket_mask >> 1);
+		}
+nexthub:
+		uvhub++;
+		uvhub_mask = (uvhub_mask >> 1);
+	}
+	kfree(uvhub_descs);
+	for_each_present_cpu(cpu) {
+		bcp = &per_cpu(bau_control, cpu);
+		bcp->baudisabled = 0;
+		bcp->statp = &per_cpu(ptcstats, cpu);
+		/* time interval to catch a hardware stay-busy bug */
+		bcp->timeout_interval = microsec_2_cycles(2*timeout_us);
+		bcp->max_bau_concurrent = max_bau_concurrent;
+		bcp->max_bau_concurrent_constant = max_bau_concurrent;
+		bcp->plugged_delay = plugged_delay;
+		bcp->plugsb4reset = plugsb4reset;
+		bcp->timeoutsb4reset = timeoutsb4reset;
+		bcp->ipi_reset_limit = ipi_reset_limit;
+		bcp->complete_threshold = complete_threshold;
+		bcp->congested_response_us = congested_response_us;
+		bcp->congested_reps = congested_reps;
+		bcp->congested_period = congested_period;
+	}
 }
 
 /*
@@ -828,38 +1596,55 @@ static int __init uv_init_blade(int blad
  */
 static int __init uv_bau_init(void)
 {
-	int blade;
-	int nblades;
+	int uvhub;
+	int pnode;
+	int nuvhubs;
 	int cur_cpu;
+	int vector;
+	unsigned long mmr;
 
 	if (!is_uv_system())
 		return 0;
 
+	if (nobau)
+		return 0;
+
 	for_each_possible_cpu(cur_cpu)
 		zalloc_cpumask_var_node(&per_cpu(uv_flush_tlb_mask, cur_cpu),
 				       GFP_KERNEL, cpu_to_node(cur_cpu));
 
-	uv_bau_retry_limit = 1;
+	uv_nshift = uv_hub_info->m_val;
 	uv_mmask = (1UL << uv_hub_info->m_val) - 1;
-	nblades = uv_num_possible_blades();
+	nuvhubs = uv_num_possible_blades();
+	spin_lock_init(&disable_lock);
+	congested_cycles = microsec_2_cycles(congested_response_us);
 
-	uv_bau_table_bases = (struct bau_control **)
-	    kmalloc(nblades * sizeof(struct bau_control *), GFP_KERNEL);
-	BUG_ON(!uv_bau_table_bases);
+	uv_init_per_cpu(nuvhubs);
 
 	uv_partition_base_pnode = 0x7fffffff;
-	for (blade = 0; blade < nblades; blade++)
-		if (uv_blade_nr_possible_cpus(blade) &&
-			(uv_blade_to_pnode(blade) < uv_partition_base_pnode))
-			uv_partition_base_pnode = uv_blade_to_pnode(blade);
-	for (blade = 0; blade < nblades; blade++)
-		if (uv_blade_nr_possible_cpus(blade))
-			uv_init_blade(blade);
+	for (uvhub = 0; uvhub < nuvhubs; uvhub++)
+		if (uv_blade_nr_possible_cpus(uvhub) &&
+			(uv_blade_to_pnode(uvhub) < uv_partition_base_pnode))
+			uv_partition_base_pnode = uv_blade_to_pnode(uvhub);
+
+	vector = UV_BAU_MESSAGE;
+	for_each_possible_blade(uvhub)
+		if (uv_blade_nr_possible_cpus(uvhub))
+			uv_init_uvhub(uvhub, vector);
 
-	alloc_intr_gate(UV_BAU_MESSAGE, uv_bau_message_intr1);
 	uv_enable_timeouts();
+	alloc_intr_gate(vector, uv_bau_message_intr1);
+
+	for_each_possible_blade(uvhub) {
+		pnode = uv_blade_to_pnode(uvhub);
+		/* INIT the bau */
+		uv_write_global_mmr64(pnode, UVH_LB_BAU_SB_ACTIVATION_CONTROL,
+				      ((unsigned long)1 << 63));
+		mmr = 1; /* should be 1 to broadcast to both sockets */
+		uv_write_global_mmr64(pnode, UVH_BAU_DATA_BROADCAST, mmr);
+	}
 
 	return 0;
 }
-__initcall(uv_bau_init);
-__initcall(uv_ptc_init);
+core_initcall(uv_bau_init);
+core_initcall(uv_ptc_init);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

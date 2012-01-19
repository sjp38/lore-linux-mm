Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 182E46B004F
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 17:40:58 -0500 (EST)
Date: Thu, 19 Jan 2012 14:40:39 -0800
Message-Id: <201201192240.q0JMedHh003527@tazenda.hos.anvin.org>
From: "H. Peter Anvin" <hpa@zytor.com>
Subject: [GIT PULL] x86 fixes for v3.3-rc1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: stable@kernel.org, Andy Lutomirski <luto@mit.edu>, Anton Vorontsov <cbouatmailru@gmail.com>, Cliff Wickman <cpw@sgi.com>, Dan Carpenter <error27@gmail.com>, David Rientjes <rientjes@google.com>, Dmitry Kasatkin <dmitry.kasatkin@intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@elte.hu>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Randy Dunlap <rdunlap@xenotime.net>, Suresh Siddha <suresh.b.siddha@intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ulrich Drepper <drepper@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi Linus,

The following changes since commit 90a4c0f51e8e44111a926be6f4c87af3938a79c3:

  uml: fix compile for x86-64 (2012-01-18 19:26:11 -0800)

are available in the git repository at:
  /home/hpa/kernel/mirror/tip x86-urgent-for-linus

Anton Vorontsov (1):
      x86: Get rid of dubious one-bit signed bitfield

Cliff Wickman (6):
      x86/UV2: Fix new UV2 hardware by using native UV2 broadcast mode
      x86/UV2: Fix BAU destination timeout initialization
      x86/UV2: Work around BAU bug
      x86/UV2: Remove stale no-resources test for UV2 BAU
      x86/UV2: Ack BAU interrupt earlier
      x86/UV2: Add accounting for BAU strong nacks

H. Peter Anvin (2):
      Merge remote-tracking branch 'linus/master' into x86/urgent
      x86, syscall: Need __ARCH_WANT_SYS_IPC for 32 bits

Linus Torvalds (1):
      x86, tsc: Fix SMI induced variation in quick_pit_calibrate()

Randy Dunlap (1):
      x86/kconfig: Move the ZONE_DMA entry under a menu

Ulrich Drepper (1):
      x86, opcode: ANDN and Group 17 in x86-opcode-map.txt

 arch/x86/Kconfig                 |   20 +-
 arch/x86/include/asm/unistd.h    |    1 +
 arch/x86/include/asm/uv/uv_bau.h |  107 ++++++++++-
 arch/x86/kernel/tsc.c            |   14 +-
 arch/x86/lib/x86-opcode-map.txt  |    4 +-
 arch/x86/platform/uv/tlb_uv.c    |  388 +++++++++++++++++++++++++++++++-------
 6 files changed, 434 insertions(+), 100 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 6c14ecd..864cc6e 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -125,16 +125,6 @@ config HAVE_LATENCYTOP_SUPPORT
 config MMU
 	def_bool y
 
-config ZONE_DMA
-	bool "DMA memory allocation support" if EXPERT
-	default y
-	help
-	  DMA memory allocation support allows devices with less than 32-bit
-	  addressing to allocate within the first 16MB of address space.
-	  Disable if no such devices will be used.
-
-	  If unsure, say Y.
-
 config SBUS
 	bool
 
@@ -255,6 +245,16 @@ source "kernel/Kconfig.freezer"
 
 menu "Processor type and features"
 
+config ZONE_DMA
+	bool "DMA memory allocation support" if EXPERT
+	default y
+	help
+	  DMA memory allocation support allows devices with less than 32-bit
+	  addressing to allocate within the first 16MB of address space.
+	  Disable if no such devices will be used.
+
+	  If unsure, say Y.
+
 source "kernel/time/Kconfig"
 
 config SMP
diff --git a/arch/x86/include/asm/unistd.h b/arch/x86/include/asm/unistd.h
index b4a3db7..21f77b8 100644
--- a/arch/x86/include/asm/unistd.h
+++ b/arch/x86/include/asm/unistd.h
@@ -7,6 +7,7 @@
 #  include <asm/unistd_32.h>
 #  define __ARCH_WANT_IPC_PARSE_VERSION
 #  define __ARCH_WANT_STAT64
+#  define __ARCH_WANT_SYS_IPC
 #  define __ARCH_WANT_SYS_OLD_MMAP
 #  define __ARCH_WANT_SYS_OLD_SELECT
 
diff --git a/arch/x86/include/asm/uv/uv_bau.h b/arch/x86/include/asm/uv/uv_bau.h
index 8e862aa..becf47b 100644
--- a/arch/x86/include/asm/uv/uv_bau.h
+++ b/arch/x86/include/asm/uv/uv_bau.h
@@ -65,7 +65,7 @@
  * UV2: Bit 19 selects between
  *  (0): 10 microsecond timebase and
  *  (1): 80 microseconds
- *  we're using 655us, similar to UV1: 65 units of 10us
+ *  we're using 560us, similar to UV1: 65 units of 10us
  */
 #define UV1_INTD_SOFT_ACK_TIMEOUT_PERIOD (9UL)
 #define UV2_INTD_SOFT_ACK_TIMEOUT_PERIOD (15UL)
@@ -167,6 +167,7 @@
 #define FLUSH_RETRY_TIMEOUT		2
 #define FLUSH_GIVEUP			3
 #define FLUSH_COMPLETE			4
+#define FLUSH_RETRY_BUSYBUG		5
 
 /*
  * tuning the action when the numalink network is extremely delayed
@@ -235,10 +236,10 @@ struct bau_msg_payload {
 
 
 /*
- * Message header:  16 bytes (128 bits) (bytes 0x30-0x3f of descriptor)
+ * UV1 Message header:  16 bytes (128 bits) (bytes 0x30-0x3f of descriptor)
  * see table 4.2.3.0.1 in broacast_assist spec.
  */
-struct bau_msg_header {
+struct uv1_bau_msg_header {
 	unsigned int	dest_subnodeid:6;	/* must be 0x10, for the LB */
 	/* bits 5:0 */
 	unsigned int	base_dest_nasid:15;	/* nasid of the first bit */
@@ -318,19 +319,87 @@ struct bau_msg_header {
 };
 
 /*
+ * UV2 Message header:  16 bytes (128 bits) (bytes 0x30-0x3f of descriptor)
+ * see figure 9-2 of harp_sys.pdf
+ */
+struct uv2_bau_msg_header {
+	unsigned int	base_dest_nasid:15;	/* nasid of the first bit */
+	/* bits 14:0 */				/* in uvhub map */
+	unsigned int	dest_subnodeid:5;	/* must be 0x10, for the LB */
+	/* bits 19:15 */
+	unsigned int	rsvd_1:1;		/* must be zero */
+	/* bit 20 */
+	/* Address bits 59:21 */
+	/* bits 25:2 of address (44:21) are payload */
+	/* these next 24 bits become bytes 12-14 of msg */
+	/* bits 28:21 land in byte 12 */
+	unsigned int	replied_to:1;		/* sent as 0 by the source to
+						   byte 12 */
+	/* bit 21 */
+	unsigned int	msg_type:3;		/* software type of the
+						   message */
+	/* bits 24:22 */
+	unsigned int	canceled:1;		/* message canceled, resource
+						   is to be freed*/
+	/* bit 25 */
+	unsigned int	payload_1:3;		/* not currently used */
+	/* bits 28:26 */
+
+	/* bits 36:29 land in byte 13 */
+	unsigned int	payload_2a:3;		/* not currently used */
+	unsigned int	payload_2b:5;		/* not currently used */
+	/* bits 36:29 */
+
+	/* bits 44:37 land in byte 14 */
+	unsigned int	payload_3:8;		/* not currently used */
+	/* bits 44:37 */
+
+	unsigned int	rsvd_2:7;		/* reserved */
+	/* bits 51:45 */
+	unsigned int	swack_flag:1;		/* software acknowledge flag */
+	/* bit 52 */
+	unsigned int	rsvd_3a:3;		/* must be zero */
+	unsigned int	rsvd_3b:8;		/* must be zero */
+	unsigned int	rsvd_3c:8;		/* must be zero */
+	unsigned int	rsvd_3d:3;		/* must be zero */
+	/* bits 74:53 */
+	unsigned int	fairness:3;		/* usually zero */
+	/* bits 77:75 */
+
+	unsigned int	sequence:16;		/* message sequence number */
+	/* bits 93:78  Suppl_A  */
+	unsigned int	chaining:1;		/* next descriptor is part of
+						   this activation*/
+	/* bit 94 */
+	unsigned int	multilevel:1;		/* multi-level multicast
+						   format */
+	/* bit 95 */
+	unsigned int	rsvd_4:24;		/* ordered / source node /
+						   source subnode / aging
+						   must be zero */
+	/* bits 119:96 */
+	unsigned int	command:8;		/* message type */
+	/* bits 127:120 */
+};
+
+/*
  * The activation descriptor:
  * The format of the message to send, plus all accompanying control
  * Should be 64 bytes
  */
 struct bau_desc {
-	struct pnmask			distribution;
+	struct pnmask				distribution;
 	/*
 	 * message template, consisting of header and payload:
 	 */
-	struct bau_msg_header		header;
-	struct bau_msg_payload		payload;
+	union bau_msg_header {
+		struct uv1_bau_msg_header	uv1_hdr;
+		struct uv2_bau_msg_header	uv2_hdr;
+	} header;
+
+	struct bau_msg_payload			payload;
 };
-/*
+/* UV1:
  *   -payload--    ---------header------
  *   bytes 0-11    bits 41-56  bits 58-81
  *       A           B  (2)      C (3)
@@ -340,6 +409,16 @@ struct bau_desc {
  *   bytes 0-11  bytes 12-14  bytes 16-17  (byte 15 filled in by hw as vector)
  *   ------------payload queue-----------
  */
+/* UV2:
+ *   -payload--    ---------header------
+ *   bytes 0-11    bits 70-78  bits 21-44
+ *       A           B  (2)      C (3)
+ *
+ *            A/B/C are moved to:
+ *       A            C          B
+ *   bytes 0-11  bytes 12-14  bytes 16-17  (byte 15 filled in by hw as vector)
+ *   ------------payload queue-----------
+ */
 
 /*
  * The payload queue on the destination side is an array of these.
@@ -385,7 +464,6 @@ struct bau_pq_entry {
 struct msg_desc {
 	struct bau_pq_entry	*msg;
 	int			msg_slot;
-	int			swack_slot;
 	struct bau_pq_entry	*queue_first;
 	struct bau_pq_entry	*queue_last;
 };
@@ -405,6 +483,7 @@ struct ptc_stats {
 						   requests */
 	unsigned long	s_stimeout;		/* source side timeouts */
 	unsigned long	s_dtimeout;		/* destination side timeouts */
+	unsigned long	s_strongnacks;		/* number of strong nack's */
 	unsigned long	s_time;			/* time spent in sending side */
 	unsigned long	s_retriesok;		/* successful retries */
 	unsigned long	s_ntargcpu;		/* total number of cpu's
@@ -439,6 +518,9 @@ struct ptc_stats {
 	unsigned long	s_retry_messages;	/* retry broadcasts */
 	unsigned long	s_bau_reenabled;	/* for bau enable/disable */
 	unsigned long	s_bau_disabled;		/* for bau enable/disable */
+	unsigned long	s_uv2_wars;		/* uv2 workaround, perm. busy */
+	unsigned long	s_uv2_wars_hw;		/* uv2 workaround, hiwater */
+	unsigned long	s_uv2_war_waits;	/* uv2 workaround, long waits */
 	/* destination statistics */
 	unsigned long	d_alltlb;		/* times all tlb's on this
 						   cpu were flushed */
@@ -511,9 +593,12 @@ struct bau_control {
 	short			osnode;
 	short			uvhub_cpu;
 	short			uvhub;
+	short			uvhub_version;
 	short			cpus_in_socket;
 	short			cpus_in_uvhub;
 	short			partition_base_pnode;
+	short			using_desc; /* an index, like uvhub_cpu */
+	unsigned int		inuse_map;
 	unsigned short		message_number;
 	unsigned short		uvhub_quiesce;
 	short			socket_acknowledge_count[DEST_Q_SIZE];
@@ -531,6 +616,7 @@ struct bau_control {
 	int			cong_response_us;
 	int			cong_reps;
 	int			cong_period;
+	unsigned long		clocks_per_100_usec;
 	cycles_t		period_time;
 	long			period_requests;
 	struct hub_and_pnode	*thp;
@@ -591,6 +677,11 @@ static inline void write_mmr_sw_ack(unsigned long mr)
 	uv_write_local_mmr(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, mr);
 }
 
+static inline void write_gmmr_sw_ack(int pnode, unsigned long mr)
+{
+	write_gmmr(pnode, UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, mr);
+}
+
 static inline unsigned long read_mmr_sw_ack(void)
 {
 	return read_lmmr(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE);
diff --git a/arch/x86/kernel/tsc.c b/arch/x86/kernel/tsc.c
index c0dd5b6..a62c201 100644
--- a/arch/x86/kernel/tsc.c
+++ b/arch/x86/kernel/tsc.c
@@ -290,14 +290,15 @@ static inline int pit_verify_msb(unsigned char val)
 static inline int pit_expect_msb(unsigned char val, u64 *tscp, unsigned long *deltap)
 {
 	int count;
-	u64 tsc = 0;
+	u64 tsc = 0, prev_tsc = 0;
 
 	for (count = 0; count < 50000; count++) {
 		if (!pit_verify_msb(val))
 			break;
+		prev_tsc = tsc;
 		tsc = get_cycles();
 	}
-	*deltap = get_cycles() - tsc;
+	*deltap = get_cycles() - prev_tsc;
 	*tscp = tsc;
 
 	/*
@@ -311,9 +312,9 @@ static inline int pit_expect_msb(unsigned char val, u64 *tscp, unsigned long *de
  * How many MSB values do we want to see? We aim for
  * a maximum error rate of 500ppm (in practice the
  * real error is much smaller), but refuse to spend
- * more than 25ms on it.
+ * more than 50ms on it.
  */
-#define MAX_QUICK_PIT_MS 25
+#define MAX_QUICK_PIT_MS 50
 #define MAX_QUICK_PIT_ITERATIONS (MAX_QUICK_PIT_MS * PIT_TICK_RATE / 1000 / 256)
 
 static unsigned long quick_pit_calibrate(void)
@@ -383,15 +384,12 @@ success:
 	 *
 	 * As a result, we can depend on there not being
 	 * any odd delays anywhere, and the TSC reads are
-	 * reliable (within the error). We also adjust the
-	 * delta to the middle of the error bars, just
-	 * because it looks nicer.
+	 * reliable (within the error).
 	 *
 	 * kHz = ticks / time-in-seconds / 1000;
 	 * kHz = (t2 - t1) / (I * 256 / PIT_TICK_RATE) / 1000
 	 * kHz = ((t2 - t1) * PIT_TICK_RATE) / (I * 256 * 1000)
 	 */
-	delta += (long)(d2 - d1)/2;
 	delta *= PIT_TICK_RATE;
 	do_div(delta, i*256*1000);
 	printk("Fast TSC calibration using PIT\n");
diff --git a/arch/x86/lib/x86-opcode-map.txt b/arch/x86/lib/x86-opcode-map.txt
index 5b83c51..4c8010d 100644
--- a/arch/x86/lib/x86-opcode-map.txt
+++ b/arch/x86/lib/x86-opcode-map.txt
@@ -729,8 +729,8 @@ de: VAESDEC Vdq,Hdq,Wdq (66),(v1)
 df: VAESDECLAST Vdq,Hdq,Wdq (66),(v1)
 f0: MOVBE Gy,My | MOVBE Gw,Mw (66) | CRC32 Gd,Eb (F2)
 f1: MOVBE My,Gy | MOVBE Mw,Gw (66) | CRC32 Gd,Ey (F2)
-f3: ANDN Gy,By,Ey (v)
-f4: Grp17 (1A)
+f2: ANDN Gy,By,Ey (v)
+f3: Grp17 (1A)
 f5: BZHI Gy,Ey,By (v) | PEXT Gy,By,Ey (F3),(v) | PDEP Gy,By,Ey (F2),(v)
 f6: MULX By,Gy,rDX,Ey (F2),(v)
 f7: BEXTR Gy,Ey,By (v) | SHLX Gy,Ey,By (66),(v) | SARX Gy,Ey,By (F3),(v) | SHRX Gy,Ey,By (F2),(v)
diff --git a/arch/x86/platform/uv/tlb_uv.c b/arch/x86/platform/uv/tlb_uv.c
index 5b55219..9be4cff 100644
--- a/arch/x86/platform/uv/tlb_uv.c
+++ b/arch/x86/platform/uv/tlb_uv.c
@@ -157,13 +157,14 @@ static int __init uvhub_to_first_apicid(int uvhub)
  * clear of the Timeout bit (as well) will free the resource. No reply will
  * be sent (the hardware will only do one reply per message).
  */
-static void reply_to_message(struct msg_desc *mdp, struct bau_control *bcp)
+static void reply_to_message(struct msg_desc *mdp, struct bau_control *bcp,
+						int do_acknowledge)
 {
 	unsigned long dw;
 	struct bau_pq_entry *msg;
 
 	msg = mdp->msg;
-	if (!msg->canceled) {
+	if (!msg->canceled && do_acknowledge) {
 		dw = (msg->swack_vec << UV_SW_ACK_NPENDING) | msg->swack_vec;
 		write_mmr_sw_ack(dw);
 	}
@@ -212,8 +213,8 @@ static void bau_process_retry_msg(struct msg_desc *mdp,
 			if (mmr & (msg_res << UV_SW_ACK_NPENDING)) {
 				unsigned long mr;
 				/*
-				 * is the resource timed out?
-				 * make everyone ignore the cancelled message.
+				 * Is the resource timed out?
+				 * Make everyone ignore the cancelled message.
 				 */
 				msg2->canceled = 1;
 				stat->d_canceled++;
@@ -231,8 +232,8 @@ static void bau_process_retry_msg(struct msg_desc *mdp,
  * Do all the things a cpu should do for a TLB shootdown message.
  * Other cpu's may come here at the same time for this message.
  */
-static void bau_process_message(struct msg_desc *mdp,
-					struct bau_control *bcp)
+static void bau_process_message(struct msg_desc *mdp, struct bau_control *bcp,
+						int do_acknowledge)
 {
 	short socket_ack_count = 0;
 	short *sp;
@@ -284,8 +285,9 @@ static void bau_process_message(struct msg_desc *mdp,
 		if (msg_ack_count == bcp->cpus_in_uvhub) {
 			/*
 			 * All cpus in uvhub saw it; reply
+			 * (unless we are in the UV2 workaround)
 			 */
-			reply_to_message(mdp, bcp);
+			reply_to_message(mdp, bcp, do_acknowledge);
 		}
 	}
 
@@ -491,27 +493,138 @@ static int uv1_wait_completion(struct bau_desc *bau_desc,
 /*
  * UV2 has an extra bit of status in the ACTIVATION_STATUS_2 register.
  */
-static unsigned long uv2_read_status(unsigned long offset, int rshft, int cpu)
+static unsigned long uv2_read_status(unsigned long offset, int rshft, int desc)
 {
 	unsigned long descriptor_status;
 	unsigned long descriptor_status2;
 
 	descriptor_status = ((read_lmmr(offset) >> rshft) & UV_ACT_STATUS_MASK);
-	descriptor_status2 = (read_mmr_uv2_status() >> cpu) & 0x1UL;
+	descriptor_status2 = (read_mmr_uv2_status() >> desc) & 0x1UL;
 	descriptor_status = (descriptor_status << 1) | descriptor_status2;
 	return descriptor_status;
 }
 
+/*
+ * Return whether the status of the descriptor that is normally used for this
+ * cpu (the one indexed by its hub-relative cpu number) is busy.
+ * The status of the original 32 descriptors is always reflected in the 64
+ * bits of UVH_LB_BAU_SB_ACTIVATION_STATUS_0.
+ * The bit provided by the activation_status_2 register is irrelevant to
+ * the status if it is only being tested for busy or not busy.
+ */
+int normal_busy(struct bau_control *bcp)
+{
+	int cpu = bcp->uvhub_cpu;
+	int mmr_offset;
+	int right_shift;
+
+	mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_0;
+	right_shift = cpu * UV_ACT_STATUS_SIZE;
+	return (((((read_lmmr(mmr_offset) >> right_shift) &
+				UV_ACT_STATUS_MASK)) << 1) == UV2H_DESC_BUSY);
+}
+
+/*
+ * Entered when a bau descriptor has gone into a permanent busy wait because
+ * of a hardware bug.
+ * Workaround the bug.
+ */
+int handle_uv2_busy(struct bau_control *bcp)
+{
+	int busy_one = bcp->using_desc;
+	int normal = bcp->uvhub_cpu;
+	int selected = -1;
+	int i;
+	unsigned long descriptor_status;
+	unsigned long status;
+	int mmr_offset;
+	struct bau_desc *bau_desc_old;
+	struct bau_desc *bau_desc_new;
+	struct bau_control *hmaster = bcp->uvhub_master;
+	struct ptc_stats *stat = bcp->statp;
+	cycles_t ttm;
+
+	stat->s_uv2_wars++;
+	spin_lock(&hmaster->uvhub_lock);
+	/* try for the original first */
+	if (busy_one != normal) {
+		if (!normal_busy(bcp))
+			selected = normal;
+	}
+	if (selected < 0) {
+		/* can't use the normal, select an alternate */
+		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_1;
+		descriptor_status = read_lmmr(mmr_offset);
+
+		/* scan available descriptors 32-63 */
+		for (i = 0; i < UV_CPUS_PER_AS; i++) {
+			if ((hmaster->inuse_map & (1 << i)) == 0) {
+				status = ((descriptor_status >>
+						(i * UV_ACT_STATUS_SIZE)) &
+						UV_ACT_STATUS_MASK) << 1;
+				if (status != UV2H_DESC_BUSY) {
+					selected = i + UV_CPUS_PER_AS;
+					break;
+				}
+			}
+		}
+	}
+
+	if (busy_one != normal)
+		/* mark the busy alternate as not in-use */
+		hmaster->inuse_map &= ~(1 << (busy_one - UV_CPUS_PER_AS));
+
+	if (selected >= 0) {
+		/* switch to the selected descriptor */
+		if (selected != normal) {
+			/* set the selected alternate as in-use */
+			hmaster->inuse_map |=
+					(1 << (selected - UV_CPUS_PER_AS));
+			if (selected > stat->s_uv2_wars_hw)
+				stat->s_uv2_wars_hw = selected;
+		}
+		bau_desc_old = bcp->descriptor_base;
+		bau_desc_old += (ITEMS_PER_DESC * busy_one);
+		bcp->using_desc = selected;
+		bau_desc_new = bcp->descriptor_base;
+		bau_desc_new += (ITEMS_PER_DESC * selected);
+		*bau_desc_new = *bau_desc_old;
+	} else {
+		/*
+		 * All are busy. Wait for the normal one for this cpu to
+		 * free up.
+		 */
+		stat->s_uv2_war_waits++;
+		spin_unlock(&hmaster->uvhub_lock);
+		ttm = get_cycles();
+		do {
+			cpu_relax();
+		} while (normal_busy(bcp));
+		spin_lock(&hmaster->uvhub_lock);
+		/* switch to the original descriptor */
+		bcp->using_desc = normal;
+		bau_desc_old = bcp->descriptor_base;
+		bau_desc_old += (ITEMS_PER_DESC * bcp->using_desc);
+		bcp->using_desc = (ITEMS_PER_DESC * normal);
+		bau_desc_new = bcp->descriptor_base;
+		bau_desc_new += (ITEMS_PER_DESC * normal);
+		*bau_desc_new = *bau_desc_old; /* copy the entire descriptor */
+	}
+	spin_unlock(&hmaster->uvhub_lock);
+	return FLUSH_RETRY_BUSYBUG;
+}
+
 static int uv2_wait_completion(struct bau_desc *bau_desc,
 				unsigned long mmr_offset, int right_shift,
 				struct bau_control *bcp, long try)
 {
 	unsigned long descriptor_stat;
 	cycles_t ttm;
-	int cpu = bcp->uvhub_cpu;
+	int desc = bcp->using_desc;
+	long busy_reps = 0;
 	struct ptc_stats *stat = bcp->statp;
 
-	descriptor_stat = uv2_read_status(mmr_offset, right_shift, cpu);
+	descriptor_stat = uv2_read_status(mmr_offset, right_shift, desc);
 
 	/* spin on the status MMR, waiting for it to go idle */
 	while (descriptor_stat != UV2H_DESC_IDLE) {
@@ -522,32 +635,35 @@ static int uv2_wait_completion(struct bau_desc *bau_desc,
 		 * our message and its state will stay IDLE.
 		 */
 		if ((descriptor_stat == UV2H_DESC_SOURCE_TIMEOUT) ||
-		    (descriptor_stat == UV2H_DESC_DEST_STRONG_NACK) ||
 		    (descriptor_stat == UV2H_DESC_DEST_PUT_ERR)) {
 			stat->s_stimeout++;
 			return FLUSH_GIVEUP;
+		} else if (descriptor_stat == UV2H_DESC_DEST_STRONG_NACK) {
+			stat->s_strongnacks++;
+			bcp->conseccompletes = 0;
+			return FLUSH_GIVEUP;
 		} else if (descriptor_stat == UV2H_DESC_DEST_TIMEOUT) {
 			stat->s_dtimeout++;
-			ttm = get_cycles();
-			/*
-			 * Our retries may be blocked by all destination
-			 * swack resources being consumed, and a timeout
-			 * pending.  In that case hardware returns the
-			 * ERROR that looks like a destination timeout.
-			 */
-			if (cycles_2_us(ttm - bcp->send_message) < timeout_us) {
-				bcp->conseccompletes = 0;
-				return FLUSH_RETRY_PLUGGED;
-			}
 			bcp->conseccompletes = 0;
 			return FLUSH_RETRY_TIMEOUT;
 		} else {
+			busy_reps++;
+			if (busy_reps > 1000000) {
+				/* not to hammer on the clock */
+				busy_reps = 0;
+				ttm = get_cycles();
+				if ((ttm - bcp->send_message) >
+					(bcp->clocks_per_100_usec)) {
+					return handle_uv2_busy(bcp);
+				}
+			}
 			/*
 			 * descriptor_stat is still BUSY
 			 */
 			cpu_relax();
 		}
-		descriptor_stat = uv2_read_status(mmr_offset, right_shift, cpu);
+		descriptor_stat = uv2_read_status(mmr_offset, right_shift,
+									desc);
 	}
 	bcp->conseccompletes++;
 	return FLUSH_COMPLETE;
@@ -563,17 +679,17 @@ static int wait_completion(struct bau_desc *bau_desc,
 {
 	int right_shift;
 	unsigned long mmr_offset;
-	int cpu = bcp->uvhub_cpu;
+	int desc = bcp->using_desc;
 
-	if (cpu < UV_CPUS_PER_AS) {
+	if (desc < UV_CPUS_PER_AS) {
 		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_0;
-		right_shift = cpu * UV_ACT_STATUS_SIZE;
+		right_shift = desc * UV_ACT_STATUS_SIZE;
 	} else {
 		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_1;
-		right_shift = ((cpu - UV_CPUS_PER_AS) * UV_ACT_STATUS_SIZE);
+		right_shift = ((desc - UV_CPUS_PER_AS) * UV_ACT_STATUS_SIZE);
 	}
 
-	if (is_uv1_hub())
+	if (bcp->uvhub_version == 1)
 		return uv1_wait_completion(bau_desc, mmr_offset, right_shift,
 								bcp, try);
 	else
@@ -752,19 +868,22 @@ static void handle_cmplt(int completion_status, struct bau_desc *bau_desc,
  * Returns 1 if it gives up entirely and the original cpu mask is to be
  * returned to the kernel.
  */
-int uv_flush_send_and_wait(struct bau_desc *bau_desc,
-			struct cpumask *flush_mask, struct bau_control *bcp)
+int uv_flush_send_and_wait(struct cpumask *flush_mask, struct bau_control *bcp)
 {
 	int seq_number = 0;
 	int completion_stat = 0;
+	int uv1 = 0;
 	long try = 0;
 	unsigned long index;
 	cycles_t time1;
 	cycles_t time2;
 	struct ptc_stats *stat = bcp->statp;
 	struct bau_control *hmaster = bcp->uvhub_master;
+	struct uv1_bau_msg_header *uv1_hdr = NULL;
+	struct uv2_bau_msg_header *uv2_hdr = NULL;
+	struct bau_desc *bau_desc;
 
-	if (is_uv1_hub())
+	if (bcp->uvhub_version == 1)
 		uv1_throttle(hmaster, stat);
 
 	while (hmaster->uvhub_quiesce)
@@ -772,22 +891,39 @@ int uv_flush_send_and_wait(struct bau_desc *bau_desc,
 
 	time1 = get_cycles();
 	do {
-		if (try == 0) {
-			bau_desc->header.msg_type = MSG_REGULAR;
+		bau_desc = bcp->descriptor_base;
+		bau_desc += (ITEMS_PER_DESC * bcp->using_desc);
+		if (bcp->uvhub_version == 1) {
+			uv1 = 1;
+			uv1_hdr = &bau_desc->header.uv1_hdr;
+		} else
+			uv2_hdr = &bau_desc->header.uv2_hdr;
+		if ((try == 0) || (completion_stat == FLUSH_RETRY_BUSYBUG)) {
+			if (uv1)
+				uv1_hdr->msg_type = MSG_REGULAR;
+			else
+				uv2_hdr->msg_type = MSG_REGULAR;
 			seq_number = bcp->message_number++;
 		} else {
-			bau_desc->header.msg_type = MSG_RETRY;
+			if (uv1)
+				uv1_hdr->msg_type = MSG_RETRY;
+			else
+				uv2_hdr->msg_type = MSG_RETRY;
 			stat->s_retry_messages++;
 		}
 
-		bau_desc->header.sequence = seq_number;
-		index = (1UL << AS_PUSH_SHIFT) | bcp->uvhub_cpu;
+		if (uv1)
+			uv1_hdr->sequence = seq_number;
+		else
+			uv2_hdr->sequence = seq_number;
+		index = (1UL << AS_PUSH_SHIFT) | bcp->using_desc;
 		bcp->send_message = get_cycles();
 
 		write_mmr_activation(index);
 
 		try++;
 		completion_stat = wait_completion(bau_desc, bcp, try);
+		/* UV2: wait_completion() may change the bcp->using_desc */
 
 		handle_cmplt(completion_stat, bau_desc, bcp, hmaster, stat);
 
@@ -798,6 +934,7 @@ int uv_flush_send_and_wait(struct bau_desc *bau_desc,
 		}
 		cpu_relax();
 	} while ((completion_stat == FLUSH_RETRY_PLUGGED) ||
+		 (completion_stat == FLUSH_RETRY_BUSYBUG) ||
 		 (completion_stat == FLUSH_RETRY_TIMEOUT));
 
 	time2 = get_cycles();
@@ -812,6 +949,7 @@ int uv_flush_send_and_wait(struct bau_desc *bau_desc,
 	record_send_stats(time1, time2, bcp, stat, completion_stat, try);
 
 	if (completion_stat == FLUSH_GIVEUP)
+		/* FLUSH_GIVEUP will fall back to using IPI's for tlb flush */
 		return 1;
 	return 0;
 }
@@ -967,7 +1105,7 @@ const struct cpumask *uv_flush_tlb_others(const struct cpumask *cpumask,
 		stat->s_ntargself++;
 
 	bau_desc = bcp->descriptor_base;
-	bau_desc += ITEMS_PER_DESC * bcp->uvhub_cpu;
+	bau_desc += (ITEMS_PER_DESC * bcp->using_desc);
 	bau_uvhubs_clear(&bau_desc->distribution, UV_DISTRIBUTION_SIZE);
 	if (set_distrib_bits(flush_mask, bcp, bau_desc, &locals, &remotes))
 		return NULL;
@@ -980,13 +1118,86 @@ const struct cpumask *uv_flush_tlb_others(const struct cpumask *cpumask,
 	 * uv_flush_send_and_wait returns 0 if all cpu's were messaged,
 	 * or 1 if it gave up and the original cpumask should be returned.
 	 */
-	if (!uv_flush_send_and_wait(bau_desc, flush_mask, bcp))
+	if (!uv_flush_send_and_wait(flush_mask, bcp))
 		return NULL;
 	else
 		return cpumask;
 }
 
 /*
+ * Search the message queue for any 'other' message with the same software
+ * acknowledge resource bit vector.
+ */
+struct bau_pq_entry *find_another_by_swack(struct bau_pq_entry *msg,
+			struct bau_control *bcp, unsigned char swack_vec)
+{
+	struct bau_pq_entry *msg_next = msg + 1;
+
+	if (msg_next > bcp->queue_last)
+		msg_next = bcp->queue_first;
+	while ((msg_next->swack_vec != 0) && (msg_next != msg)) {
+		if (msg_next->swack_vec == swack_vec)
+			return msg_next;
+		msg_next++;
+		if (msg_next > bcp->queue_last)
+			msg_next = bcp->queue_first;
+	}
+	return NULL;
+}
+
+/*
+ * UV2 needs to work around a bug in which an arriving message has not
+ * set a bit in the UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE register.
+ * Such a message must be ignored.
+ */
+void process_uv2_message(struct msg_desc *mdp, struct bau_control *bcp)
+{
+	unsigned long mmr_image;
+	unsigned char swack_vec;
+	struct bau_pq_entry *msg = mdp->msg;
+	struct bau_pq_entry *other_msg;
+
+	mmr_image = read_mmr_sw_ack();
+	swack_vec = msg->swack_vec;
+
+	if ((swack_vec & mmr_image) == 0) {
+		/*
+		 * This message was assigned a swack resource, but no
+		 * reserved acknowlegment is pending.
+		 * The bug has prevented this message from setting the MMR.
+		 * And no other message has used the same sw_ack resource.
+		 * Do the requested shootdown but do not reply to the msg.
+		 * (the 0 means make no acknowledge)
+		 */
+		bau_process_message(mdp, bcp, 0);
+		return;
+	}
+
+	/*
+	 * Some message has set the MMR 'pending' bit; it might have been
+	 * another message.  Look for that message.
+	 */
+	other_msg = find_another_by_swack(msg, bcp, msg->swack_vec);
+	if (other_msg) {
+		/* There is another.  Do not ack the current one. */
+		bau_process_message(mdp, bcp, 0);
+		/*
+		 * Let the natural processing of that message acknowledge
+		 * it. Don't get the processing of sw_ack's out of order.
+		 */
+		return;
+	}
+
+	/*
+	 * There is no other message using this sw_ack, so it is safe to
+	 * acknowledge it.
+	 */
+	bau_process_message(mdp, bcp, 1);
+
+	return;
+}
+
+/*
  * The BAU message interrupt comes here. (registered by set_intr_gate)
  * See entry_64.S
  *
@@ -1009,6 +1220,7 @@ void uv_bau_message_interrupt(struct pt_regs *regs)
 	struct ptc_stats *stat;
 	struct msg_desc msgdesc;
 
+	ack_APIC_irq();
 	time_start = get_cycles();
 
 	bcp = &per_cpu(bau_control, smp_processor_id());
@@ -1022,9 +1234,11 @@ void uv_bau_message_interrupt(struct pt_regs *regs)
 		count++;
 
 		msgdesc.msg_slot = msg - msgdesc.queue_first;
-		msgdesc.swack_slot = ffs(msg->swack_vec) - 1;
 		msgdesc.msg = msg;
-		bau_process_message(&msgdesc, bcp);
+		if (bcp->uvhub_version == 2)
+			process_uv2_message(&msgdesc, bcp);
+		else
+			bau_process_message(&msgdesc, bcp, 1);
 
 		msg++;
 		if (msg > msgdesc.queue_last)
@@ -1036,8 +1250,6 @@ void uv_bau_message_interrupt(struct pt_regs *regs)
 		stat->d_nomsg++;
 	else if (count > 1)
 		stat->d_multmsg++;
-
-	ack_APIC_irq();
 }
 
 /*
@@ -1083,7 +1295,7 @@ static void __init enable_timeouts(void)
 		 */
 		mmr_image |= (1L << SOFTACK_MSHIFT);
 		if (is_uv2_hub()) {
-			mmr_image |= (1L << UV2_LEG_SHFT);
+			mmr_image &= ~(1L << UV2_LEG_SHFT);
 			mmr_image |= (1L << UV2_EXT_SHFT);
 		}
 		write_mmr_misc_control(pnode, mmr_image);
@@ -1136,13 +1348,13 @@ static int ptc_seq_show(struct seq_file *file, void *data)
 		seq_printf(file,
 			"remotehub numuvhubs numuvhubs16 numuvhubs8 ");
 		seq_printf(file,
-			"numuvhubs4 numuvhubs2 numuvhubs1 dto retries rok ");
+		    "numuvhubs4 numuvhubs2 numuvhubs1 dto snacks retries rok ");
 		seq_printf(file,
 			"resetp resett giveup sto bz throt swack recv rtime ");
 		seq_printf(file,
 			"all one mult none retry canc nocan reset rcan ");
 		seq_printf(file,
-			"disable enable\n");
+			"disable enable wars warshw warwaits\n");
 	}
 	if (cpu < num_possible_cpus() && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
@@ -1154,10 +1366,10 @@ static int ptc_seq_show(struct seq_file *file, void *data)
 			   stat->s_ntargremotes, stat->s_ntargcpu,
 			   stat->s_ntarglocaluvhub, stat->s_ntargremoteuvhub,
 			   stat->s_ntarguvhub, stat->s_ntarguvhub16);
-		seq_printf(file, "%ld %ld %ld %ld %ld ",
+		seq_printf(file, "%ld %ld %ld %ld %ld %ld ",
 			   stat->s_ntarguvhub8, stat->s_ntarguvhub4,
 			   stat->s_ntarguvhub2, stat->s_ntarguvhub1,
-			   stat->s_dtimeout);
+			   stat->s_dtimeout, stat->s_strongnacks);
 		seq_printf(file, "%ld %ld %ld %ld %ld %ld %ld %ld ",
 			   stat->s_retry_messages, stat->s_retriesok,
 			   stat->s_resets_plug, stat->s_resets_timeout,
@@ -1173,8 +1385,10 @@ static int ptc_seq_show(struct seq_file *file, void *data)
 			   stat->d_nomsg, stat->d_retries, stat->d_canceled,
 			   stat->d_nocanceled, stat->d_resets,
 			   stat->d_rcanceled);
-		seq_printf(file, "%ld %ld\n",
-			stat->s_bau_disabled, stat->s_bau_reenabled);
+		seq_printf(file, "%ld %ld %ld %ld %ld\n",
+			stat->s_bau_disabled, stat->s_bau_reenabled,
+			stat->s_uv2_wars, stat->s_uv2_wars_hw,
+			stat->s_uv2_war_waits);
 	}
 	return 0;
 }
@@ -1432,12 +1646,15 @@ static void activation_descriptor_init(int node, int pnode, int base_pnode)
 {
 	int i;
 	int cpu;
+	int uv1 = 0;
 	unsigned long gpa;
 	unsigned long m;
 	unsigned long n;
 	size_t dsize;
 	struct bau_desc *bau_desc;
 	struct bau_desc *bd2;
+	struct uv1_bau_msg_header *uv1_hdr;
+	struct uv2_bau_msg_header *uv2_hdr;
 	struct bau_control *bcp;
 
 	/*
@@ -1451,6 +1668,8 @@ static void activation_descriptor_init(int node, int pnode, int base_pnode)
 	gpa = uv_gpa(bau_desc);
 	n = uv_gpa_to_gnode(gpa);
 	m = uv_gpa_to_offset(gpa);
+	if (is_uv1_hub())
+		uv1 = 1;
 
 	/* the 14-bit pnode */
 	write_mmr_descriptor_base(pnode, (n << UV_DESC_PSHIFT | m));
@@ -1461,21 +1680,33 @@ static void activation_descriptor_init(int node, int pnode, int base_pnode)
 	 */
 	for (i = 0, bd2 = bau_desc; i < (ADP_SZ * ITEMS_PER_DESC); i++, bd2++) {
 		memset(bd2, 0, sizeof(struct bau_desc));
-		bd2->header.swack_flag =	1;
-		/*
-		 * The base_dest_nasid set in the message header is the nasid
-		 * of the first uvhub in the partition. The bit map will
-		 * indicate destination pnode numbers relative to that base.
-		 * They may not be consecutive if nasid striding is being used.
-		 */
-		bd2->header.base_dest_nasid =	UV_PNODE_TO_NASID(base_pnode);
-		bd2->header.dest_subnodeid =	UV_LB_SUBNODEID;
-		bd2->header.command =		UV_NET_ENDPOINT_INTD;
-		bd2->header.int_both =		1;
-		/*
-		 * all others need to be set to zero:
-		 *   fairness chaining multilevel count replied_to
-		 */
+		if (uv1) {
+			uv1_hdr = &bd2->header.uv1_hdr;
+			uv1_hdr->swack_flag =	1;
+			/*
+			 * The base_dest_nasid set in the message header
+			 * is the nasid of the first uvhub in the partition.
+			 * The bit map will indicate destination pnode numbers
+			 * relative to that base. They may not be consecutive
+			 * if nasid striding is being used.
+			 */
+			uv1_hdr->base_dest_nasid =
+						UV_PNODE_TO_NASID(base_pnode);
+			uv1_hdr->dest_subnodeid =	UV_LB_SUBNODEID;
+			uv1_hdr->command =		UV_NET_ENDPOINT_INTD;
+			uv1_hdr->int_both =		1;
+			/*
+			 * all others need to be set to zero:
+			 *   fairness chaining multilevel count replied_to
+			 */
+		} else {
+			uv2_hdr = &bd2->header.uv2_hdr;
+			uv2_hdr->swack_flag =	1;
+			uv2_hdr->base_dest_nasid =
+						UV_PNODE_TO_NASID(base_pnode);
+			uv2_hdr->dest_subnodeid =	UV_LB_SUBNODEID;
+			uv2_hdr->command =		UV_NET_ENDPOINT_INTD;
+		}
 	}
 	for_each_present_cpu(cpu) {
 		if (pnode != uv_blade_to_pnode(uv_cpu_to_blade_id(cpu)))
@@ -1531,6 +1762,7 @@ static void pq_init(int node, int pnode)
 	write_mmr_payload_first(pnode, pn_first);
 	write_mmr_payload_tail(pnode, first);
 	write_mmr_payload_last(pnode, last);
+	write_gmmr_sw_ack(pnode, 0xffffUL);
 
 	/* in effect, all msg_type's are set to MSG_NOOP */
 	memset(pqp, 0, sizeof(struct bau_pq_entry) * DEST_Q_SIZE);
@@ -1584,14 +1816,14 @@ static int calculate_destination_timeout(void)
 		ts_ns = base * mult1 * mult2;
 		ret = ts_ns / 1000;
 	} else {
-		/* 4 bits  0/1 for 10/80us, 3 bits of multiplier */
-		mmr_image = uv_read_local_mmr(UVH_AGING_PRESCALE_SEL);
+		/* 4 bits  0/1 for 10/80us base, 3 bits of multiplier */
+		mmr_image = uv_read_local_mmr(UVH_LB_BAU_MISC_CONTROL);
 		mmr_image = (mmr_image & UV_SA_MASK) >> UV_SA_SHFT;
 		if (mmr_image & (1L << UV2_ACK_UNITS_SHFT))
-			mult1 = 80;
+			base = 80;
 		else
-			mult1 = 10;
-		base = mmr_image & UV2_ACK_MASK;
+			base = 10;
+		mult1 = mmr_image & UV2_ACK_MASK;
 		ret = mult1 * base;
 	}
 	return ret;
@@ -1618,6 +1850,7 @@ static void __init init_per_cpu_tunables(void)
 		bcp->cong_response_us		= congested_respns_us;
 		bcp->cong_reps			= congested_reps;
 		bcp->cong_period		= congested_period;
+		bcp->clocks_per_100_usec =	usec_2_cycles(100);
 	}
 }
 
@@ -1728,8 +1961,17 @@ static int scan_sock(struct socket_desc *sdp, struct uvhub_desc *bdp,
 		bcp->cpus_in_socket = sdp->num_cpus;
 		bcp->socket_master = *smasterp;
 		bcp->uvhub = bdp->uvhub;
+		if (is_uv1_hub())
+			bcp->uvhub_version = 1;
+		else if (is_uv2_hub())
+			bcp->uvhub_version = 2;
+		else {
+			printk(KERN_EMERG "uvhub version not 1 or 2\n");
+			return 1;
+		}
 		bcp->uvhub_master = *hmasterp;
 		bcp->uvhub_cpu = uv_cpu_hub_info(cpu)->blade_processor_id;
+		bcp->using_desc = bcp->uvhub_cpu;
 		if (bcp->uvhub_cpu >= MAX_CPUS_PER_UVHUB) {
 			printk(KERN_EMERG "%d cpus per uvhub invalid\n",
 				bcp->uvhub_cpu);
@@ -1845,6 +2087,8 @@ static int __init uv_bau_init(void)
 			uv_base_pnode = uv_blade_to_pnode(uvhub);
 	}
 
+	enable_timeouts();
+
 	if (init_per_cpu(nuvhubs, uv_base_pnode)) {
 		nobau = 1;
 		return 0;
@@ -1855,7 +2099,6 @@ static int __init uv_bau_init(void)
 		if (uv_blade_nr_possible_cpus(uvhub))
 			init_uvhub(uvhub, vector, uv_base_pnode);
 
-	enable_timeouts();
 	alloc_intr_gate(vector, uv_bau_message_intr1);
 
 	for_each_possible_blade(uvhub) {
@@ -1867,7 +2110,8 @@ static int __init uv_bau_init(void)
 			val = 1L << 63;
 			write_gmmr_activation(pnode, val);
 			mmr = 1; /* should be 1 to broadcast to both sockets */
-			write_mmr_data_broadcast(pnode, mmr);
+			if (!is_uv1_hub())
+				write_mmr_data_broadcast(pnode, mmr);
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

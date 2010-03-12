Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D27A56B013B
	for <linux-mm@kvack.org>; Fri, 12 Mar 2010 09:36:54 -0500 (EST)
Subject: [PATCH] x86, UV: BAU performance and error recovery
Message-Id: <E1Nq5yy-0006ot-8E@eag09.americas.sgi.com>
From: Cliff Wickman <cpw@sgi.com>
Date: Fri, 12 Mar 2010 08:36:56 -0600
Sender: owner-linux-mm@kvack.org
To: mingo@elte.hu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


This patch adds what we've learned about BAU usage for TLB shootdown.
- increases performance of the interrupt handler
    mainly through use of socket-local memory
- releases timed-out BAU software acknowledge resources
    uses a MSG_RETRY that acknowledges unanswered messages
    can fall back to an IPI method of BAU resource release
- recovers from continuous-busy status due to a hardware issue
    throttles number of concurrent broadcasts, to avoid the problem
    clears the busy state after a too-long busy status
- provides a 'nobau' boot command line option
    allows disabling of the use of the BAU altogether

This patch depends on patch 
   http://marc.info/?l=linux-kernel&m=126825393617669&w=2
   x86, UV: Cleanup of UV header for MMR definitions

Diffed against 2.6.34.rc1

Signed-off-by: Cliff Wickman <cpw@sgi.com>

---
 arch/x86/include/asm/uv/uv_bau.h |  182 +++++--
 arch/x86/kernel/tlb_uv.c         |  985 +++++++++++++++++++++++++++------------
 2 files changed, 827 insertions(+), 340 deletions(-)

Index: 100311.linux.2.6.34-rc1/arch/x86/kernel/tlb_uv.c
===================================================================
--- 100311.linux.2.6.34-rc1.orig/arch/x86/kernel/tlb_uv.c
+++ 100311.linux.2.6.34-rc1/arch/x86/kernel/tlb_uv.c
@@ -1,7 +1,7 @@
 /*
  *	SGI UltraViolet TLB flush routines.
  *
- *	(c) 2008 Cliff Wickman <cpw@sgi.com>, SGI.
+ *	(c) 2008-2010 Cliff Wickman <cpw@sgi.com>, SGI.
  *
  *	This code is released under the GNU General Public License version 2 or
  *	later.
@@ -19,17 +19,31 @@
 #include <asm/idle.h>
 #include <asm/tsc.h>
 #include <asm/irq_vectors.h>
+#include <asm/timer.h>
 
-static struct bau_control	**uv_bau_table_bases __read_mostly;
-static int			uv_bau_retry_limit __read_mostly;
+static int uv_bau_max_concurrent __read_mostly;
 
-/* base pnode in this partition */
-static int			uv_partition_base_pnode __read_mostly;
+static int nobau;
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
+
+struct reset_args {
+	int sender;
+};
 
 /*
  * Determine the first node on a blade.
@@ -43,7 +57,7 @@ static int __init blade_to_first_node(in
 		if (blade == b)
 			return node;
 	}
-	return -1; /* shouldn't happen */
+	return -1;
 }
 
 /*
@@ -67,17 +81,15 @@ static int __init blade_to_first_apicid(
  * clear of the Timeout bit (as well) will free the resource. No reply will
  * be sent (the hardware will only do one reply per message).
  */
-static void uv_reply_to_message(int resource,
-				struct bau_payload_queue_entry *msg,
-				struct bau_msg_status *msp)
+static inline void uv_reply_to_message(int msg_slot, int resource,
+		struct bau_payload_queue_entry *msg,
+		struct bau_control *bcp)
 {
 	unsigned long dw;
 
-	dw = (1 << (resource + UV_SW_ACK_NPENDING)) | (1 << resource);
+	dw = (msg->sw_ack_vector << UV_SW_ACK_NPENDING) | msg->sw_ack_vector;
 	msg->replied_to = 1;
 	msg->sw_ack_vector = 0;
-	if (msp)
-		msp->seen_by.bits = 0;
 	uv_write_local_mmr(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, dw);
 }
 
@@ -86,148 +98,363 @@ static void uv_reply_to_message(int reso
  * Other cpu's may come here at the same time for this message.
  */
 static void uv_bau_process_message(struct bau_payload_queue_entry *msg,
-				   int msg_slot, int sw_ack_slot)
+			int msg_slot, int sw_ack_slot, struct bau_control *bcp,
+			struct bau_payload_queue_entry *va_queue_first,
+			struct bau_payload_queue_entry *va_queue_last)
 {
-	unsigned long this_cpu_mask;
-	struct bau_msg_status *msp;
-	int cpu;
-
-	msp = __get_cpu_var(bau_control).msg_statuses + msg_slot;
-	cpu = uv_blade_processor_id();
-	msg->number_of_cpus =
-		uv_blade_nr_online_cpus(uv_node_to_blade_id(numa_node_id()));
-	this_cpu_mask = 1UL << cpu;
-	if (msp->seen_by.bits & this_cpu_mask)
-		return;
-	atomic_or_long(&msp->seen_by.bits, this_cpu_mask);
-
-	if (msg->replied_to == 1)
-		return;
+	int i;
+	int sending_cpu;
+	int msg_ack_count;
+	int slot2;
+	int cancel_count = 0;
+	unsigned char this_sw_ack_vector;
+	short socket_ack_count = 0;
+	unsigned long mmr = 0;
+	unsigned long msg_res;
+	struct ptc_stats *stat;
+	struct bau_payload_queue_entry *msg2;
+	struct bau_control *smaster = bcp->socket_master;
 
+	/*
+	 * This must be a normal message, or retry of a normal message
+	 */
+	stat = &per_cpu(ptcstats, bcp->cpu);
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
+	 * One cpu on each blade has the additional job on a RETRY
+	 * of releasing the resource held by the message that is
+	 * being retried.  That message is identified by sending
+	 * cpu number.
+	 */
+	if (msg->msg_type == MSG_RETRY && bcp == bcp->pnode_master) {
+		sending_cpu = msg->sending_cpu;
+		this_sw_ack_vector = msg->sw_ack_vector;
+		stat->d_retries++;
+		/*
+		 * cancel any from msg+1 to the retry itself
+		 */
+		bcp->retry_message_scans++;
+		for (msg2 = msg+1, i = 0; i < DEST_Q_SIZE; msg2++, i++) {
+			if (msg2 > va_queue_last)
+				msg2 = va_queue_first;
+			if (msg2 == msg)
+				break;
+
+			/* uv_bau_process_message: same conditions
+			   for cancellation as uv_do_reset */
+			if ((msg2->replied_to == 0) &&
+			    (msg2->canceled == 0) &&
+			    (msg2->sw_ack_vector) &&
+			    ((msg2->sw_ack_vector &
+				this_sw_ack_vector) == 0) &&
+			    (msg2->sending_cpu == sending_cpu) &&
+			    (msg2->msg_type != MSG_NOOP)) {
+				bcp->retry_message_actions++;
+				slot2 = msg2 - va_queue_first;
+				mmr = uv_read_local_mmr
+				(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE);
+				msg_res = ((msg2->sw_ack_vector << 8) |
+					   msg2->sw_ack_vector);
+				/*
+				 * If this message timed out elsewhere
+				 * so that a retry was broadcast, it
+				 * should have timed out here too.
+				 * It is not 'replied_to' so some local
+				 * cpu has not seen it.  When it does
+				 * get around to processing the
+				 * interrupt it should skip it, as
+				 * it's going to be marked 'canceled'.
+				 */
+				msg2->canceled = 1;
+				cancel_count++;
+				/*
+				 * this is a message retry; clear
+				 * the resources held by the previous
+				 * message or retries even if they did
+				 * not time out
+				 */
+				if (mmr & msg_res) {
+					stat->d_canceled++;
+					uv_write_local_mmr(
+			    UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS,
+						msg_res);
+				}
+			}
+		}
+		if (!cancel_count)
+			stat->d_nocanceled++;
+	}
 
-	atomic_inc_short(&msg->acknowledge_count);
-	if (msg->number_of_cpus == msg->acknowledge_count)
-		uv_reply_to_message(sw_ack_slot, msg, msp);
+	/*
+	 * This is a sw_ack message, so we have to reply to it.
+	 * Count each responding cpu on the socket. This avoids
+	 * pinging the count's cache line back and forth between
+	 * the sockets.
+	 */
+	socket_ack_count = atomic_add_short_return(1, (struct atomic_short *)
+				&smaster->socket_acknowledge_count[msg_slot]);
+	if (socket_ack_count == bcp->cpus_in_socket) {
+		/*
+		 * Both sockets dump their completed count total into
+		 * the message's count.
+		 */
+		smaster->socket_acknowledge_count[msg_slot] = 0;
+		msg_ack_count = atomic_add_short_return(socket_ack_count,
+				(struct atomic_short *)&msg->acknowledge_count);
+
+		if (msg_ack_count == bcp->cpus_in_blade) {
+			/*
+			 * All cpus in blade saw it; reply
+			 */
+			uv_reply_to_message(msg_slot, sw_ack_slot, msg, bcp);
+		}
+	}
+
+	return;
+}
+
+/*
+ * Determine the first cpu on a blade.
+ */
+static int blade_to_first_cpu(int blade)
+{
+	int cpu;
+	for_each_present_cpu(cpu)
+		if (blade == uv_cpu_to_blade_id(cpu))
+			return cpu;
+	return -1;
 }
 
 /*
- * Examine the payload queue on one distribution node to see
- * which messages have not been seen, and which cpu(s) have not seen them.
+ * Last resort when we get a large number of destination timeouts is
+ * to clear resources held by a given cpu.
+ * Do this with IPI so that all messages in the BAU message queue
+ * can be identified by their nonzero sw_ack_vector field.
  *
- * Returns the number of cpu's that have not responded.
+ * This is entered for a single cpu on the blade.
+ * The sender want's this blade to free a specific message's
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
+	bcp = (struct bau_control *)&per_cpu(bau_control, smp_processor_id());
+	rap = (struct reset_args *)ptr;
+	stat = &per_cpu(ptcstats, bcp->cpu);
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
+		   uv_bau_process_message */
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
+			 * only reset the resource if it is still
+			 * pending
+			 */
+			mmr = uv_read_local_mmr
+					(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE);
+			msg_res = ((msg->sw_ack_vector << 8) |
+						   msg->sw_ack_vector);
+			/*
+			 * this is an ipi-method reset; clear the resources
+			 * held by previous message or retries even if they
+			 * did not time out
+			 */
+			if (mmr & msg_res) {
+				stat->d_rcanceled++;
+				uv_write_local_mmr(
+				    UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS,
+							msg_res);
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
+ * Use IPI to get all target pnodes to release resources held by
+ * a given sending cpu number.
  */
-static int uv_examine_destinations(struct bau_target_nodemask *distribution)
+static void uv_reset_with_ipi(struct bau_target_nodemask *distribution,
+		int sender)
 {
-	int sender;
-	int i;
-	int count = 0;
+	int blade;
+	int cpu;
+	cpumask_t mask;
+	struct reset_args reset_args;
 
-	sender = smp_processor_id();
-	for (i = 0; i < sizeof(struct bau_target_nodemask) * BITSPERBYTE; i++) {
-		if (!bau_node_isset(i, distribution))
+	reset_args.sender = sender;
+
+	cpus_clear(mask);
+	/* find a single cpu for each blade in this distribution mask */
+	for (blade = 0;
+		    blade < sizeof(struct bau_target_nodemask) * BITSPERBYTE;
+		    blade++) {
+		if (!bau_node_isset(blade, distribution))
 			continue;
-		count += uv_examine_destination(uv_bau_table_bases[i], sender);
+		/* find a cpu for this blade */
+		cpu = blade_to_first_cpu(blade);
+		cpu_set(cpu, mask);
 	}
-	return count;
+	/* IPI all cpus; Preemption is already disabled */
+	smp_call_function_many(&mask, uv_do_reset, (void *)&reset_args, 1);
+	return;
 }
 
 /*
- * wait for completion of a broadcast message
- *
+ * The UVH_LB_BAU_SB_ACTIVATION_STATUS_0|1 status for this broadcast has
+ * stayed busy beyond a sane timeout period.  Quiet BAU activity on this
+ * blade and reset the status to idle.
+ */
+static void
+uv_reset_busy(struct bau_control *bcp, unsigned long mmr_offset,
+		int right_shift, struct ptc_stats *stat)
+{
+	short busy;
+	struct bau_control *pmaster;
+	unsigned long mmr;
+	unsigned long mask = 0UL;
+
+	pmaster = bcp->pnode_master;
+	atomic_add_short_return(1,
+		(struct atomic_short *)&pmaster->pnode_quiesce);
+	printk(KERN_INFO "cpu %d bau quiet, reset mmr\n", bcp->cpu);
+	while (atomic_read_short(
+		(struct atomic_short *)&pmaster->pnode_active_count) >
+		atomic_read_short(
+		(struct atomic_short *)&pmaster->pnode_quiesce)) {
+		cpu_relax();
+	}
+	spin_lock(&pmaster->quiesce_lock);
+	mmr = uv_read_local_mmr(mmr_offset);
+	mask |= (3UL < right_shift);
+	mask = ~mask;
+	mmr &= mask;
+	uv_write_local_mmr(mmr_offset, mmr);
+	spin_unlock(&pmaster->quiesce_lock);
+	atomic_add_short_return(-1,
+		(struct atomic_short *)&pmaster->pnode_quiesce);
+	stat->s_busy++;
+	/* wait for all to finish */
+	do {
+		busy = atomic_read_short
+			((struct atomic_short *)&pmaster->pnode_quiesce);
+	} while (busy);
+}
+
+/*
+ * Wait for completion of a broadcast software ack message
  * return COMPLETE, RETRY or GIVEUP
  */
 static int uv_wait_completion(struct bau_desc *bau_desc,
-			      unsigned long mmr_offset, int right_shift)
+	unsigned long mmr_offset, int right_shift, int this_cpu,
+	struct bau_control *bcp, struct bau_control *smaster, long try)
 {
-	int exams = 0;
-	long destination_timeouts = 0;
+	long relaxes = 0;
 	long source_timeouts = 0;
 	unsigned long descriptor_status;
+	unsigned long long otime, ntime;
+	unsigned long long timeout_time;
+	struct ptc_stats *stat = &per_cpu(ptcstats, this_cpu);
+
+	otime = get_cycles();
+	timeout_time = otime + bcp->timeout_interval;
 
+	/* spin on the status MMR, waiting for it to go idle */
 	while ((descriptor_status = (((unsigned long)
 		uv_read_local_mmr(mmr_offset) >>
 			right_shift) & UV_ACT_STATUS_MASK)) !=
 			DESC_STATUS_IDLE) {
+		/*
+		 * Our software ack messages may be blocked because there are
+		 * no swack resources available.  As long as none of them
+		 * has timed out hardware will NACK our message and its
+		 * state will stay IDLE.
+		 */
 		if (descriptor_status == DESC_STATUS_SOURCE_TIMEOUT) {
 			source_timeouts++;
-			if (source_timeouts > SOURCE_TIMEOUT_LIMIT)
+			stat->s_stimeout++;
+			if (source_timeouts > SOURCE_TIMEOUT_LIMIT) {
 				source_timeouts = 0;
-			__get_cpu_var(ptcstats).s_retry++;
+				printk(KERN_INFO
+			   "uv_wait_completion dest cpus done; FLUSH_RETRY\n");
+			}
+			udelay(1000); /*source side timeouts are long*/
 			return FLUSH_RETRY;
-		}
-		/*
-		 * spin here looking for progress at the destinations
-		 */
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
+		} else if (descriptor_status ==
+					DESC_STATUS_DESTINATION_TIMEOUT) {
+			stat->s_dtimeout++;
+			ntime = get_cycles();
+			/*
+			 * Our retries may be blocked by all destination
+			 * swack resources being consumed, and a timeout
+			 * pending.  In that case hardware returns the
+			 * ERROR that looks like a destination timeout.
+			 * After 1000 retries clear this situation
+			 * with an IPI message.
+			 */
+
+			if (bcp->timeout_retry_count >= 1000) {
+				bcp->timeout_retry_count = 0;
+				stat->s_resets++;
+				uv_reset_with_ipi(&bau_desc->distribution,
+							this_cpu);
+			}
+			bcp->timeout_retry_count++;
+			return FLUSH_RETRY;
+		} else {
+			/*
+			 * descriptor_status is still BUSY
+			 */
+			cpu_relax();
+			relaxes++;
+			if (relaxes >= 1000000) {
+				relaxes = 0;
+				if (get_cycles() > timeout_time) {
+					uv_reset_busy(bcp, mmr_offset,
+							right_shift, stat);
+					/* The message probably was broadcast
+					 * and completed.  But not for sure.
+					 * Use an IPI to clear things.
+					 */
 					return FLUSH_GIVEUP;
 				}
-				/*
-				 * delays can hang the simulator
-				   udelay(1000);
-				 */
-				destination_timeouts = 0;
 			}
 		}
-		cpu_relax();
 	}
 	return FLUSH_COMPLETE;
 }
@@ -243,19 +470,32 @@ static int uv_wait_completion(struct bau
  * Returns @flush_mask if some remote flushing remains to be done. The
  * mask will have some bits still set.
  */
-const struct cpumask *uv_flush_send_and_wait(int cpu, int this_pnode,
-					     struct bau_desc *bau_desc,
-					     struct cpumask *flush_mask)
+const struct cpumask *uv_flush_send_and_wait(struct bau_desc *bau_desc,
+					     struct cpumask *flush_mask,
+					     struct bau_control *bcp)
 {
-	int completion_status = 0;
 	int right_shift;
-	int tries = 0;
 	int pnode;
 	int bit;
+	int completion_status = 0;
+	int seq_number = 0;
+	long try = 0;
+	int cpu = bcp->blade_cpu;
+	int this_cpu = bcp->cpu;
+	int this_pnode = bcp->pnode;
 	unsigned long mmr_offset;
 	unsigned long index;
 	cycles_t time1;
 	cycles_t time2;
+	struct ptc_stats *stat = &per_cpu(ptcstats, bcp->cpu);
+	struct bau_control *smaster = bcp->socket_master;
+	struct bau_control *pmaster = bcp->pnode_master;
+
+	/* spin here while there are bcp->max_concurrent active descriptors */
+	while (!atomic_add_unless(&pmaster->active_descripter_count, 1,
+						pmaster->max_concurrent)) {
+		cpu_relax();
+	}
 
 	if (cpu < UV_CPUS_PER_ACT_STATUS) {
 		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_0;
@@ -265,26 +505,58 @@ const struct cpumask *uv_flush_send_and_
 		right_shift =
 		    ((cpu - UV_CPUS_PER_ACT_STATUS) * UV_ACT_STATUS_SIZE);
 	}
+	bcp->timeout_retry_count = 0;
 	time1 = get_cycles();
 	do {
-		tries++;
+		/*
+		 * Every message from any given cpu gets a unique message
+		 * number. But retries use that same number.
+		 * Our message may have timed out at the destination because
+		 * all sw-ack resources are in use and there is a timeout
+		 * pending there.  In that case, our last send never got
+		 * placed into the queue and we need to persist until it
+		 * does.
+		 * The uv_wait_completion() function will take care of
+		 * sending the occasional reset message to clear this
+		 * message number and the resource it is using.
+		 *
+		 * Make any retry a type MSG_RETRY so that the destination will
+		 * free any resource held by a previous message from this cpu.
+		 */
+		if (try == 0) {
+			/* use message type set by the caller the first time */
+			/* sequence number plays no role in the logic */
+			seq_number = bcp->message_number++;
+		} else {
+			/* use RETRY type on all the rest; same sequence */
+			bau_desc->header.msg_type = MSG_RETRY;
+		}
+		bau_desc->header.sequence = seq_number;
 		index = (1UL << UVH_LB_BAU_SB_ACTIVATION_CONTROL_PUSH_SHFT) |
-			cpu;
+			bcp->blade_cpu;
+
 		uv_write_local_mmr(UVH_LB_BAU_SB_ACTIVATION_CONTROL, index);
+
+		try++;
 		completion_status = uv_wait_completion(bau_desc, mmr_offset,
-					right_shift);
+			right_shift, this_cpu, bcp, smaster, try);
 	} while (completion_status == FLUSH_RETRY);
 	time2 = get_cycles();
-	__get_cpu_var(ptcstats).sflush += (time2 - time1);
-	if (tries > 1)
-		__get_cpu_var(ptcstats).retriesok++;
+	atomic_dec(&pmaster->active_descripter_count);
 
-	if (completion_status == FLUSH_GIVEUP) {
+	/* guard against cycles wrap */
+	if (time2 > time1)
+		stat->s_time += (time2 - time1);
+	else
+		stat->s_requestor--; /* don't count this one */
+	if (completion_status == FLUSH_COMPLETE && try > 1)
+		stat->s_retriesok++;
+	else if (completion_status == FLUSH_GIVEUP) {
 		/*
 		 * Cause the caller to do an IPI-style TLB shootdown on
-		 * the cpu's, all of which are still in the mask.
+		 * the target cpu's, all of which are still in the mask.
 		 */
-		__get_cpu_var(ptcstats).ptc_i++;
+		stat->s_giveup++;
 		return flush_mask;
 	}
 
@@ -300,11 +572,10 @@ const struct cpumask *uv_flush_send_and_
 	}
 	if (!cpumask_empty(flush_mask))
 		return flush_mask;
+
 	return NULL;
 }
 
-static DEFINE_PER_CPU(cpumask_var_t, uv_flush_tlb_mask);
-
 /**
  * uv_flush_tlb_others - globally purge translation cache of a virtual
  * address or all TLB's
@@ -334,29 +605,38 @@ const struct cpumask *uv_flush_tlb_other
 					  struct mm_struct *mm,
 					  unsigned long va, unsigned int cpu)
 {
-	struct cpumask *flush_mask = __get_cpu_var(uv_flush_tlb_mask);
 	int i;
 	int bit;
 	int pnode;
-	int uv_cpu;
-	int this_pnode;
 	int locals = 0;
 	struct bau_desc *bau_desc;
+	struct cpumask *flush_mask;
+	struct ptc_stats *stat;
+	struct bau_control *bcp;
+
+	if (nobau)
+		return cpumask;
 
+	bcp = &per_cpu(bau_control, cpu);
+	/*
+	 * Each sending cpu has a cpu mask which it fills from the caller's
+	 * cpu mask.  Only remote cpus are converted to pnodes and copied.
+	 */
+	flush_mask = (struct cpumask *)per_cpu(uv_flush_tlb_mask, cpu);
+	/* removes current cpu: */
 	cpumask_andnot(flush_mask, cpumask, cpumask_of(cpu));
+	if (cpu_isset(cpu, *cpumask))
+		locals++;  /* current cpu is targeted */
 
-	uv_cpu = uv_blade_processor_id();
-	this_pnode = uv_hub_info->pnode;
-	bau_desc = __get_cpu_var(bau_control).descriptor_base;
-	bau_desc += UV_ITEMS_PER_DESCRIPTOR * uv_cpu;
+	bau_desc = bcp->descriptor_base;
+	bau_desc += UV_ITEMS_PER_DESCRIPTOR * bcp->blade_cpu;
 
 	bau_nodes_clear(&bau_desc->distribution, UV_DISTRIBUTION_SIZE);
-
 	i = 0;
 	for_each_cpu(bit, flush_mask) {
 		pnode = uv_cpu_to_pnode(bit);
 		BUG_ON(pnode > (UV_DISTRIBUTION_SIZE - 1));
-		if (pnode == this_pnode) {
+		if (pnode == bcp->pnode) {
 			locals++;
 			continue;
 		}
@@ -366,20 +646,28 @@ const struct cpumask *uv_flush_tlb_other
 	}
 	if (i == 0) {
 		/*
-		 * no off_node flushing; return status for local node
+		 * No off_node flushing; return status for local node
+		 * Return the caller's mask if all were local (the current
+		 * cpu may be in that mask).
 		 */
 		if (locals)
-			return flush_mask;
+			return cpumask;
 		else
 			return NULL;
 	}
-	__get_cpu_var(ptcstats).requestor++;
-	__get_cpu_var(ptcstats).ntargeted += i;
+	stat = &per_cpu(ptcstats, cpu);
+	stat->s_requestor++;
+	stat->s_ntargcpu += i;
+	stat->s_ntargpnod += bau_node_weight(&bau_desc->distribution);
 
 	bau_desc->payload.address = va;
 	bau_desc->payload.sending_cpu = cpu;
 
-	return uv_flush_send_and_wait(uv_cpu, this_pnode, bau_desc, flush_mask);
+	/*
+	 * uv_flush_send_and_wait returns null if all cpu's were messaged, or
+	 * the adjusted flush_mask if any cpu's were not messaged.
+	 */
+	return uv_flush_send_and_wait(bau_desc, flush_mask, bcp);
 }
 
 /*
@@ -398,59 +686,64 @@ const struct cpumask *uv_flush_tlb_other
  */
 void uv_bau_message_interrupt(struct pt_regs *regs)
 {
-	struct bau_payload_queue_entry *va_queue_first;
-	struct bau_payload_queue_entry *va_queue_last;
-	struct bau_payload_queue_entry *msg;
-	struct pt_regs *old_regs = set_irq_regs(regs);
-	cycles_t time1;
-	cycles_t time2;
 	int msg_slot;
 	int sw_ack_slot;
 	int fw;
 	int count = 0;
-	unsigned long local_pnode;
+	int this_cpu;
+	cycles_t time1;
+	cycles_t time2;
+	struct bau_payload_queue_entry *va_queue_first;
+	struct bau_payload_queue_entry *va_queue_last;
+	struct bau_payload_queue_entry *msg;
+	struct pt_regs *old_regs = set_irq_regs(regs);
+	struct bau_control *bcp;
+	struct ptc_stats *stat;
 
+	local_irq_disable();
 	ack_APIC_irq();
-	exit_idle();
-	irq_enter();
 
 	time1 = get_cycles();
 
-	local_pnode = uv_blade_to_pnode(uv_numa_blade_id());
+	this_cpu = smp_processor_id();
+	bcp = &per_cpu(bau_control, this_cpu);
+	stat = &per_cpu(ptcstats, this_cpu);
+	va_queue_first = bcp->va_queue_first;
+	va_queue_last = bcp->va_queue_last;
 
-	va_queue_first = __get_cpu_var(bau_control).va_queue_first;
-	va_queue_last = __get_cpu_var(bau_control).va_queue_last;
-
-	msg = __get_cpu_var(bau_control).bau_msg_head;
+	msg = bcp->bau_msg_head;
 	while (msg->sw_ack_vector) {
+		if (msg->canceled)
+			goto nextmsg;
 		count++;
 		fw = msg->sw_ack_vector;
 		msg_slot = msg - va_queue_first;
 		sw_ack_slot = ffs(fw) - 1;
 
-		uv_bau_process_message(msg, msg_slot, sw_ack_slot);
-
+		uv_bau_process_message(msg, msg_slot, sw_ack_slot, bcp,
+					va_queue_first, va_queue_last);
+nextmsg:
 		msg++;
 		if (msg > va_queue_last)
 			msg = va_queue_first;
-		__get_cpu_var(bau_control).bau_msg_head = msg;
+		bcp->bau_msg_head = msg;
 	}
 	if (!count)
-		__get_cpu_var(ptcstats).nomsg++;
+		stat->d_nomsg++;
 	else if (count > 1)
-		__get_cpu_var(ptcstats).multmsg++;
+		stat->d_multmsg++;
 
 	time2 = get_cycles();
-	__get_cpu_var(ptcstats).dflush += (time2 - time1);
+	stat->d_time += (time2 - time1);
 
-	irq_exit();
+	local_irq_enable();
 	set_irq_regs(old_regs);
 }
 
 /*
  * uv_enable_timeouts
  *
- * Each target blade (i.e. blades that have cpu's) needs to have
+ * Each target blade (i.e. a blade that has no cpu's) needs to have
  * shootdown message timeouts enabled.  The timeout does not cause
  * an interrupt, but causes an error message to be returned to
  * the sender.
@@ -521,9 +814,36 @@ static void uv_ptc_seq_stop(struct seq_f
 {
 }
 
+static inline unsigned long
+cycles_2_us(unsigned long long cyc)
+{
+	unsigned long long ns;
+	unsigned long flags, us;
+	local_irq_save(flags);
+	ns =  (cyc * per_cpu(cyc2ns, smp_processor_id()))
+						>> CYC2NS_SCALE_FACTOR;
+	us = ns / 1000;
+	local_irq_restore(flags);
+	return us;
+}
+
+static inline unsigned long long
+millisec_2_cycles(unsigned long millisec)
+{
+	unsigned long flags;
+	unsigned long ns;
+	unsigned long long cyc;
+
+	ns = millisec * 1000;
+	local_irq_save(flags);
+	cyc = (ns << CYC2NS_SCALE_FACTOR)/(per_cpu(cyc2ns, smp_processor_id()));
+	local_irq_restore(flags);
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
@@ -534,78 +854,116 @@ static int uv_ptc_seq_show(struct seq_fi
 
 	if (!cpu) {
 		seq_printf(file,
-		"# cpu requestor requestee one all sretry dretry ptc_i ");
+	"# cpu sent stime numnodes numcpus dto retried resets giveup sto bz ");
 		seq_printf(file,
-		"sw_ack sflush dflush sok dnomsg dmult starget\n");
+	   "sw_ack recv rtime all one mult none retry canc nocan reset rcan\n");
 	}
 	if (cpu < num_possible_cpus() && cpu_online(cpu)) {
 		stat = &per_cpu(ptcstats, cpu);
-		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld ",
-			   cpu, stat->requestor,
-			   stat->requestee, stat->onetlb, stat->alltlb,
-			   stat->s_retry, stat->d_retry, stat->ptc_i);
-		seq_printf(file, "%lx %ld %ld %ld %ld %ld %ld\n",
+		seq_printf(file,
+			   "cpu %d %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld ",
+			   cpu, stat->s_requestor, cycles_2_us(stat->s_time),
+			   stat->s_ntargpnod, stat->s_ntargcpu,
+			   stat->s_dtimeout, stat->s_retriesok, stat->s_resets,
+			   stat->s_giveup, stat->s_stimeout, stat->s_busy);
+		seq_printf(file,
+			   "%lx %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld %ld\n",
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
 	}
 
+
 	return 0;
 }
 
 /*
+ * -1: resetf the statistics
  *  0: display meaning of the statistics
- * >0: retry limit
+ * >0: maximum concurrent active descriptors per blade (throttle)
  */
 static ssize_t uv_ptc_proc_write(struct file *file, const char __user *user,
 				 size_t count, loff_t *data)
 {
-	long newmode;
+	int cpu;
+	long input_arg;
 	char optstr[64];
+	struct ptc_stats *stat;
+	struct bau_control *bcp;
 
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
+		"numnodes: number of pnodes targeted with shootdown\n");
 		printk(KERN_DEBUG
-		"all:        times requested to flush all TLB's\n");
+		"numcpus:  number of cpus targeted with shootdown\n");
 		printk(KERN_DEBUG
-		"sretry:     number of retries of source-side timeouts\n");
+		"dto:      number of destination timeouts\n");
 		printk(KERN_DEBUG
-		"dretry:     number of retries of destination-side timeouts\n");
+		"retried:  destination timeouts sucessfully retried\n");
 		printk(KERN_DEBUG
-		"ptc_i:      times UV fell through to IPI-style flushes\n");
+		"resets:   ipi-style resource resets done\n");
 		printk(KERN_DEBUG
-		"sw_ack:     image of UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE\n");
+		"giveup:   fall-backs to ipi-style shootdowns\n");
 		printk(KERN_DEBUG
-		"sflush_us:  cycles spent in uv_flush_tlb_others()\n");
+		"sto:      number of source timeouts\n");
+		printk(KERN_DEBUG "Destination side statistics:\n");
 		printk(KERN_DEBUG
-		"dflush_us:  cycles spent in handling flush requests\n");
-		printk(KERN_DEBUG "sok:        successes on retry\n");
-		printk(KERN_DEBUG "dnomsg:     interrupts with no message\n");
+		"sw_ack:   image of UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE\n");
 		printk(KERN_DEBUG
-		"dmult:      interrupts with multiple messages\n");
-		printk(KERN_DEBUG "starget:    nodes targeted\n");
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
+	} else if (input_arg == -1) {
+		for_each_present_cpu(cpu) {
+			stat = &per_cpu(ptcstats, cpu);
+			memset(stat, 0, sizeof(struct ptc_stats));
+		}
 	} else {
-		uv_bau_retry_limit = newmode;
-		printk(KERN_DEBUG "timeout retry limit:%d\n",
-		       uv_bau_retry_limit);
+		uv_bau_max_concurrent = input_arg;
+		printk(KERN_DEBUG "Set BAU max concurrent:%d\n",
+		       uv_bau_max_concurrent);
+		for_each_present_cpu(cpu) {
+			bcp = &per_cpu(bau_control, cpu);
+			bcp->max_concurrent = uv_bau_max_concurrent;
+		}
 	}
 
 	return count;
@@ -649,79 +1007,30 @@ static int __init uv_ptc_init(void)
 }
 
 /*
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
-	}
-}
-
-/*
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
 	 * per cpu; and up to 32 (UV_ADP_SIZE) cpu's per blade
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
@@ -732,94 +1041,182 @@ uv_activation_descriptor_init(int node, 
 	 * cpu even though we only use the first one; one descriptor can
 	 * describe a broadcast to 256 nodes.
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
 		 * base_dest_nodeid is the first node in the partition, so
 		 * the bit map will indicate partition-relative node numbers.
 		 * note that base_dest_nodeid is actually a nasid.
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
+ * entered for each pnode (node is the first node on the blade)
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
+		bcp->timeout_interval = millisec_2_cycles(1);
+		spin_lock_init(&bcp->quiesce_lock);
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
  * Initialization of each UV blade's structures
  */
-static int __init uv_init_blade(int blade)
+static void __init uv_init_blade(int blade, int vector)
 {
 	int node;
 	int pnode;
-	unsigned long pa;
 	unsigned long apicid;
-	struct bau_desc *adp;
-	struct bau_payload_queue_entry *pqp;
-	struct bau_control *bau_tablesp;
 
 	node = blade_to_first_node(blade);
-	bau_tablesp = uv_table_bases_init(blade, node);
 	pnode = uv_blade_to_pnode(blade);
-	adp = uv_activation_descriptor_init(node, pnode);
-	pqp = uv_payload_queue_init(node, pnode, bau_tablesp);
-	uv_table_bases_finish(blade, bau_tablesp, adp);
+	uv_activation_descriptor_init(node, pnode);
+	uv_payload_queue_init(node, pnode);
 	/*
 	 * the below initialization can't be in firmware because the
 	 * messaging IRQ will be determined by the OS
 	 */
 	apicid = blade_to_first_apicid(blade);
-	pa = uv_read_global_mmr64(pnode, UVH_BAU_DATA_CONFIG);
 	uv_write_global_mmr64(pnode, UVH_BAU_DATA_CONFIG,
-				      ((apicid << 32) | UV_BAU_MESSAGE));
-	return 0;
+				      ((apicid << 32) | vector));
+}
+
+/*
+ * initialize the bau_control structure for each cpu
+ */
+static void uv_init_per_cpu(int nblades)
+{
+	int i, j, k;
+	int cpu;
+	int pnode;
+	int blade;
+	short socket = 0;
+	struct bau_control *bcp;
+	struct blade_desc *bdp;
+	struct socket_desc *sdp;
+	struct bau_control *pmaster = NULL;
+	struct bau_control *smaster = NULL;
+	struct socket_desc {
+		short num_cpus;
+		short cpu_number[16];
+	};
+	struct blade_desc {
+		short num_sockets;
+		short num_cpus;
+		short pnode;
+		struct socket_desc socket[2];
+	};
+	struct blade_desc *blade_descs;
+
+	blade_descs = (struct blade_desc *)
+		kmalloc(nblades * sizeof(struct blade_desc), GFP_KERNEL);
+	memset(blade_descs, 0, nblades * sizeof(struct blade_desc));
+	for_each_present_cpu(cpu) {
+		bcp = &per_cpu(bau_control, cpu);
+		memset(bcp, 0, sizeof(struct bau_control));
+		bcp->max_concurrent = uv_bau_max_concurrent;
+		pnode = uv_cpu_hub_info(cpu)->pnode;
+		blade = uv_cpu_hub_info(cpu)->numa_blade_id;
+		bdp = &blade_descs[blade];
+		bdp->num_cpus++;
+		bdp->pnode = pnode;
+		/* kludge: assume uv_hub.h is constant */
+		socket = (cpu_physical_id(cpu)>>5)&1;
+		if (socket >= bdp->num_sockets)
+			bdp->num_sockets = socket+1;
+		sdp = &bdp->socket[socket];
+		sdp->cpu_number[sdp->num_cpus] = cpu;
+		sdp->num_cpus++;
+	}
+	socket = 0;
+	for_each_possible_blade(blade) {
+		bdp = &blade_descs[blade];
+		for (i = 0; i < bdp->num_sockets; i++) {
+			sdp = &bdp->socket[i];
+			for (j = 0; j < sdp->num_cpus; j++) {
+				cpu = sdp->cpu_number[j];
+				bcp = &per_cpu(bau_control, cpu);
+				bcp->cpu = cpu;
+				if (j == 0) {
+					smaster = bcp;
+					if (i == 0)
+						pmaster = bcp;
+				}
+				bcp->cpus_in_blade = bdp->num_cpus;
+				bcp->cpus_in_socket = sdp->num_cpus;
+				bcp->socket_master = smaster;
+				bcp->pnode_master = pmaster;
+				for (k = 0; k < DEST_Q_SIZE; k++)
+					bcp->socket_acknowledge_count[k] = 0;
+				bcp->pnode = bdp->pnode;
+				bcp->blade_cpu =
+				  uv_cpu_hub_info(cpu)->blade_processor_id;
+			}
+			socket++;
+		}
+	}
+	kfree(blade_descs);
 }
 
 /*
@@ -828,35 +1225,51 @@ static int __init uv_init_blade(int blad
 static int __init uv_bau_init(void)
 {
 	int blade;
+	int pnode;
 	int nblades;
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
+	uv_bau_max_concurrent = MAX_BAU_CONCURRENT;
+	uv_nshift = uv_hub_info->m_val;
 	uv_mmask = (1UL << uv_hub_info->m_val) - 1;
 	nblades = uv_num_possible_blades();
 
-	uv_bau_table_bases = (struct bau_control **)
-	    kmalloc(nblades * sizeof(struct bau_control *), GFP_KERNEL);
-	BUG_ON(!uv_bau_table_bases);
+	uv_init_per_cpu(nblades);
 
 	uv_partition_base_pnode = 0x7fffffff;
 	for (blade = 0; blade < nblades; blade++)
 		if (uv_blade_nr_possible_cpus(blade) &&
 			(uv_blade_to_pnode(blade) < uv_partition_base_pnode))
 			uv_partition_base_pnode = uv_blade_to_pnode(blade);
-	for (blade = 0; blade < nblades; blade++)
+
+	vector = UV_BAU_MESSAGE;
+	for_each_possible_blade(blade)
 		if (uv_blade_nr_possible_cpus(blade))
-			uv_init_blade(blade);
+			uv_init_blade(blade, vector);
 
-	alloc_intr_gate(UV_BAU_MESSAGE, uv_bau_message_intr1);
 	uv_enable_timeouts();
+	alloc_intr_gate(vector, uv_bau_message_intr1);
+
+	for_each_possible_blade(blade) {
+		pnode = uv_blade_to_pnode(blade);
+		/* INIT the bau */
+		uv_write_global_mmr64(pnode, UVH_LB_BAU_SB_ACTIVATION_CONTROL,
+				      ((unsigned long)1 << 63));
+		mmr = 1; /* should be 1 to broadcast to both sockets */
+		uv_write_global_mmr64(pnode, UVH_BAU_DATA_BROADCAST, mmr);
+	}
 
 	return 0;
 }
Index: 100311.linux.2.6.34-rc1/arch/x86/include/asm/uv/uv_bau.h
===================================================================
--- 100311.linux.2.6.34-rc1.orig/arch/x86/include/asm/uv/uv_bau.h
+++ 100311.linux.2.6.34-rc1/arch/x86/include/asm/uv/uv_bau.h
@@ -34,6 +34,7 @@
  */
 
 #define UV_ITEMS_PER_DESCRIPTOR		8
+#define MAX_BAU_CONCURRENT		4
 #define UV_CPUS_PER_ACT_STATUS		32
 #define UV_ACT_STATUS_MASK		0x3
 #define UV_ACT_STATUS_SIZE		2
@@ -45,6 +46,9 @@
 #define UV_PAYLOADQ_PNODE_SHIFT		49
 #define UV_PTC_BASENAME			"sgi_uv/ptc_statistics"
 #define uv_physnodeaddr(x)		((__pa((unsigned long)(x)) & uv_mmask))
+#define UV_ENABLE_INTD_SOFT_ACK_MODE_SHIFT 15
+#define UV_INTD_SOFT_ACK_TIMEOUT_PERIOD_SHIFT 16
+#define UV_INTD_SOFT_ACK_TIMEOUT_PERIOD 0x000000000bUL
 
 /*
  * bits in UVH_LB_BAU_SB_ACTIVATION_STATUS_0/1
@@ -87,7 +91,7 @@
  * destination nodeID associated with that specified bit.
  */
 struct bau_target_nodemask {
-	unsigned long bits[BITS_TO_LONGS(256)];
+	unsigned long bits[BITS_TO_LONGS(UV_DISTRIBUTION_SIZE)];
 };
 
 /*
@@ -146,26 +150,38 @@ struct bau_msg_header {
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
@@ -191,6 +207,11 @@ struct bau_msg_header {
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
@@ -237,19 +258,25 @@ struct bau_payload_queue_entry {
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
@@ -259,49 +286,60 @@ struct bau_payload_queue_entry {
 };
 
 /*
- * one for every slot in the destination payload queue
- */
-struct bau_msg_status {
-	struct bau_local_cpumask seen_by;	/* map of cpu's */
-};
-
-/*
- * one for every slot in the destination software ack resources
- */
-struct bau_sw_ack_status {
-	struct bau_payload_queue_entry *msg;	/* associated message */
-	int watcher;				/* cpu monitoring, or -1 */
-};
-
-/*
  * one on every node and per-cpu; to locate the software tables
  */
 struct bau_control {
 	struct bau_desc *descriptor_base;
-	struct bau_payload_queue_entry *bau_msg_head;
 	struct bau_payload_queue_entry *va_queue_first;
 	struct bau_payload_queue_entry *va_queue_last;
-	struct bau_msg_status *msg_statuses;
-	int *watching; /* pointer to array */
+	struct bau_payload_queue_entry *bau_msg_head;
+	struct bau_control *pnode_master;
+	struct bau_control *socket_master;
+	unsigned long timeout_interval;
+	spinlock_t quiesce_lock;
+	atomic_t active_descripter_count;
+	int max_concurrent;
+	int retry_message_scans;
+	int retry_message_actions;
+	int timeout_retry_count;
+	short cpu;
+	short blade_cpu;
+	short pnode;
+	short cpus_in_socket;
+	short cpus_in_blade;
+	unsigned short pnode_active_count;
+	unsigned short pnode_quiesce;
+	unsigned short message_number;
+	short socket_acknowledge_count[DEST_Q_SIZE];
 };
 
 /*
  * This structure is allocated per_cpu for UV TLB shootdown statistics.
  */
 struct ptc_stats {
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
+	/* sender statistics */
+	unsigned long s_giveup; /* number of fall backs to IPI-style flushes */
+	unsigned long s_requestor; /* number of shootdown requests */
+	unsigned long s_stimeout; /* source side timeouts */
+	unsigned long s_dtimeout; /* destination side timeouts */
+	unsigned long s_time; /* time spent in sending side */
+	unsigned long s_retriesok; /* successful retries */
+	unsigned long s_ntargcpu; /* number of cpus targeted */
+	unsigned long s_ntargpnod; /* number of blades targeted */
+	unsigned long s_resets; /* ipi-style resets */
+	unsigned long s_busy; /* status stayed busy past s/w timer */
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
 
 static inline int bau_node_isset(int node, struct bau_target_nodemask *dstp)
@@ -316,6 +354,11 @@ static inline void bau_nodes_clear(struc
 {
 	bitmap_zero(&dstp->bits[0], nbits);
 }
+static inline int bau_node_weight(struct bau_target_nodemask *dstp)
+{
+	return bitmap_weight((unsigned long *)&dstp->bits[0],
+				UV_DISTRIBUTION_SIZE);
+}
 
 static inline void bau_cpubits_clear(struct bau_local_cpumask *dstp, int nbits)
 {
@@ -328,4 +371,35 @@ static inline void bau_cpubits_clear(str
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Subject: [PATCH 1/1] SGI UV: TLB shootdown using broadcast assist unit
Message-Id: <E1K3fF0-00056O-HE@eag09.americas.sgi.com>
From: Cliff Wickman <cpw@sgi.com>
Date: Tue, 03 Jun 2008 17:44:30 -0500
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


From: Cliff Wickman <cpw@sgi.com>

TLB shootdown for SGI UV.

This patch provides the ability to flush TLB's in cpu's that are not on
the local node.  The hardware mechanism for distributing the flush
messages is the UV's "broadcast assist unit".

The hook to intercept TLB shootdown requests is a 2-line change to
native_flush_tlb_others() (arch/x86/kernel/tlb_64.c).

This code has been tested on a hardware simulator. The real hardware
is not yet available.

The shootdown statistics are provided through /proc/sgi_uv/ptc_statistics.
The use of /sys was considered, but would have required the use of
many /sys files.  The debugfs was also considered, but these statistics
should be available on an ongoing basis, not just for debugging.

Issues to be fixed later:
- The IRQ for the messaging interrupt is currently hardcoded as 200
  (see UV_BAU_MESSAGE).  It should be dynamically assigned in the future.
- The use of appropriate udelay()'s is untested, as they are a problem
  in the simulator.

Diffed against 2.6.26-rc4

Signed-off-by: Cliff Wickman <cpw@sgi.com>
---
 arch/x86/kernel/Makefile    |    2 
 arch/x86/kernel/entry_64.S  |    4 
 arch/x86/kernel/tlb_64.c    |    5 
 arch/x86/kernel/tlb_uv.c    |  785 ++++++++++++++++++++++++++++++++++++++++++++
 include/asm-x86/atomic_64.h |   30 +
 include/asm-x86/uv/uv_bau.h |  336 ++++++++++++++++++
 6 files changed, 1161 insertions(+), 1 deletion(-)

Index: 080602.ingo/arch/x86/kernel/entry_64.S
===================================================================
--- 080602.ingo.orig/arch/x86/kernel/entry_64.S
+++ 080602.ingo/arch/x86/kernel/entry_64.S
@@ -844,6 +844,10 @@ ENTRY(apic_timer_interrupt)
 	apicinterrupt LOCAL_TIMER_VECTOR,smp_apic_timer_interrupt
 END(apic_timer_interrupt)
 
+ENTRY(uv_bau_message_intr1)
+	apicinterrupt 220,uv_bau_message_interrupt
+END(uv_bau_message_intr1)
+
 ENTRY(error_interrupt)
 	apicinterrupt ERROR_APIC_VECTOR,smp_error_interrupt
 END(error_interrupt)
Index: 080602.ingo/arch/x86/kernel/tlb_64.c
===================================================================
--- 080602.ingo.orig/arch/x86/kernel/tlb_64.c
+++ 080602.ingo/arch/x86/kernel/tlb_64.c
@@ -15,6 +15,8 @@
 #include <asm/proto.h>
 #include <asm/apicdef.h>
 #include <asm/idle.h>
+#include <asm/uv/uv_hub.h>
+#include <asm/uv/uv_bau.h>
 
 #include <mach_ipi.h>
 /*
@@ -162,6 +164,9 @@ void native_flush_tlb_others(const cpuma
 	union smp_flush_state *f;
 	cpumask_t cpumask = *cpumaskp;
 
+	if (is_uv_system() && uv_flush_tlb_others(&cpumask, mm, va))
+		return;
+
 	/* Caller has disabled preemption */
 	sender = smp_processor_id() % NUM_INVALIDATE_TLB_VECTORS;
 	f = &per_cpu(flush_state, sender);
Index: 080602.ingo/arch/x86/kernel/tlb_uv.c
===================================================================
--- /dev/null
+++ 080602.ingo/arch/x86/kernel/tlb_uv.c
@@ -0,0 +1,785 @@
+/*
+ *	SGI UltraViolet TLB flush routines.
+ *
+ *	(c) 2008 Cliff Wickman <cpw@sgi.com>, SGI.
+ *
+ *	This code is released under the GNU General Public License version 2 or
+ *	later.
+ */
+#include <linux/mc146818rtc.h>
+#include <linux/proc_fs.h>
+#include <linux/kernel.h>
+
+#include <asm/mach-bigsmp/mach_apic.h>
+#include <asm/mmu_context.h>
+#include <asm/idle.h>
+#include <asm/genapic.h>
+#include <asm/uv/uv_hub.h>
+#include <asm/uv/uv_mmrs.h>
+#include <asm/uv/uv_bau.h>
+#include <asm/tsc.h>
+
+static struct bau_control **uv_bau_table_bases __read_mostly;
+static int uv_bau_retry_limit __read_mostly;
+static int uv_nshift __read_mostly; /* position of pnode (which is nasid>>1) */
+static unsigned long uv_mmask __read_mostly;
+
+char *status_table[] = {
+	"IDLE",
+	"ACTIVE",
+	"DESTINATION TIMEOUT",
+	"SOURCE TIMEOUT"
+};
+
+DEFINE_PER_CPU(struct ptc_stats, ptcstats);
+DEFINE_PER_CPU(struct bau_control, bau_control);
+
+/*
+ * Free a software acknowledge hardware resource by clearing its Pending
+ * bit. This will return a reply to the sender.
+ * If the message has timed out, a reply has already been sent by the
+ * hardware but the resource has not been released. In that case our
+ * clear of the Timeout bit (as well) will free the resource. No reply will
+ * be sent (the hardware will only do one reply per message).
+ */
+static void uv_reply_to_message(int resource,
+		    struct bau_payload_queue_entry *msg,
+		    struct bau_msg_status *msp)
+{
+	unsigned long dw;
+
+	dw = (1 << (resource + UV_SW_ACK_NPENDING)) | (1 << resource);
+	msg->replied_to = 1;
+	msg->sw_ack_vector = 0;
+	if (msp)
+		msp->seen_by.bits = 0;
+	uv_write_local_mmr(UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE_ALIAS, dw);
+	return;
+}
+
+/*
+ * Do all the things a cpu should do for a TLB shootdown message.
+ * Other cpu's may come here at the same time for this message.
+ */
+static void uv_bau_process_message(struct bau_payload_queue_entry *msg,
+		       int msg_slot, int sw_ack_slot)
+{
+	int cpu;
+	unsigned long this_cpu_mask;
+	struct bau_msg_status *msp;
+
+	msp = __get_cpu_var(bau_control).msg_statuses + msg_slot;
+	cpu = uv_blade_processor_id();
+	msg->number_of_cpus =
+	    uv_blade_nr_online_cpus(uv_node_to_blade_id(numa_node_id()));
+	this_cpu_mask = (unsigned long)1 << cpu;
+	if (msp->seen_by.bits & this_cpu_mask)
+		return;
+	atomic_or_long(&msp->seen_by.bits, this_cpu_mask);
+
+	if (msg->replied_to == 1)
+		return;
+
+	if (msg->address == TLB_FLUSH_ALL) {
+		local_flush_tlb();
+		__get_cpu_var(ptcstats).alltlb++;
+	} else {
+		__flush_tlb_one(msg->address);
+		__get_cpu_var(ptcstats).onetlb++;
+	}
+
+	__get_cpu_var(ptcstats).requestee++;
+
+	atomic_inc_short(&msg->acknowledge_count);
+	if (msg->number_of_cpus == msg->acknowledge_count)
+		uv_reply_to_message(sw_ack_slot, msg, msp);
+	return;
+}
+
+/*
+ * Examine the payload queue on all the distribution nodes to see
+ * which messages have not been seen, and which cpu(s) have not seen them.
+ *
+ * Returns the number of cpu's that have not responded.
+ */
+static int uv_examine_destinations(struct bau_target_nodemask *distribution)
+{
+	int sender;
+	int i;
+	int j;
+	int k;
+	int count = 0;
+	struct bau_control *bau_tablesp;
+	struct bau_payload_queue_entry *msg;
+	struct bau_msg_status *msp;
+
+	sender = smp_processor_id();
+	for (i = 0; i < (sizeof(struct bau_target_nodemask) * BITSPERBYTE);
+	     i++) {
+		if (!bau_node_isset(i, distribution))
+			continue;
+		bau_tablesp = uv_bau_table_bases[i];
+		for (msg = bau_tablesp->va_queue_first, j = 0;
+		     j < DESTINATION_PAYLOAD_QUEUE_SIZE; msg++, j++) {
+			if ((msg->sending_cpu == sender) &&
+			    (!msg->replied_to)) {
+				msp = bau_tablesp->msg_statuses + j;
+				printk(KERN_DEBUG
+				"blade %d: address:%#lx %d of %d, not cpu(s): ",
+				       i, msg->address,
+				       msg->acknowledge_count,
+				       msg->number_of_cpus);
+				for (k = 0; k < msg->number_of_cpus;
+				     k++) {
+					if (!((long)1 << k & msp->
+					      seen_by.bits)) {
+						count++;
+						printk("%d ", k);
+					}
+				}
+				printk("\n");
+			}
+		}
+	}
+	return count;
+}
+
+/*
+ * wait for completion of a broadcast message
+ *
+ * return COMPLETE, RETRY or GIVEUP
+ */
+static int uv_wait_completion(struct bau_activation_descriptor *bau_desc,
+			      unsigned long mmr_offset, int right_shift)
+{
+	int exams = 0;
+	long destination_timeouts = 0;
+	long source_timeouts = 0;
+	unsigned long descriptor_status;
+
+	while ((descriptor_status = (((unsigned long)
+		uv_read_local_mmr(mmr_offset) >>
+			right_shift) & UV_ACT_STATUS_MASK)) !=
+			DESC_STATUS_IDLE) {
+		if (descriptor_status == DESC_STATUS_SOURCE_TIMEOUT) {
+			source_timeouts++;
+			if (source_timeouts > SOURCE_TIMEOUT_LIMIT)
+				source_timeouts = 0;
+			__get_cpu_var(ptcstats).s_retry++;
+			return FLUSH_RETRY;
+		}
+		/*
+		 * spin here looking for progress at the destinations
+		 */
+		if (descriptor_status == DESC_STATUS_DESTINATION_TIMEOUT) {
+			destination_timeouts++;
+			if (destination_timeouts > DESTINATION_TIMEOUT_LIMIT) {
+				/*
+				 * returns number of cpus not responding
+				 */
+				if (uv_examine_destinations
+				    (&bau_desc->distribution) == 0) {
+					__get_cpu_var(ptcstats).d_retry++;
+					return FLUSH_RETRY;
+				}
+				exams++;
+				if (exams >= uv_bau_retry_limit) {
+					printk(KERN_DEBUG
+					       "uv_flush_tlb_others");
+					printk("giving up on cpu %d\n",
+					       smp_processor_id());
+					return FLUSH_GIVEUP;
+				}
+				/*
+				 * delays can hang the simulator
+				   udelay(1000);
+				 */
+				destination_timeouts = 0;
+			}
+		}
+	}
+	return FLUSH_COMPLETE;
+}
+
+/**
+ * uv_flush_send_and_wait
+ *
+ * Send a broadcast and wait for a broadcast message to complete.
+ *
+ * The cpumaskp mask contains the cpus the broadcast was sent to.
+ *
+ * Returns 1 if all remote flushing was done. The mask is zeroed.
+ * Returns 0 if some remote flushing remains to be done. The mask is left
+ * unchanged.
+ */
+int uv_flush_send_and_wait(int cpu, int this_blade,
+	struct bau_activation_descriptor *bau_desc, cpumask_t *cpumaskp)
+{
+	int completion_status = 0;
+	int right_shift;
+	int bit;
+	int blade;
+	int tries = 0;
+	unsigned long index;
+	unsigned long mmr_offset;
+	cycles_t time1;
+	cycles_t time2;
+
+	if (cpu < UV_CPUS_PER_ACT_STATUS) {
+		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_0;
+		right_shift = cpu * UV_ACT_STATUS_SIZE;
+	} else {
+		mmr_offset = UVH_LB_BAU_SB_ACTIVATION_STATUS_1;
+		right_shift =
+		    ((cpu - UV_CPUS_PER_ACT_STATUS) * UV_ACT_STATUS_SIZE);
+	}
+	time1 = get_cycles();
+	do {
+		tries++;
+		index = ((unsigned long)
+			1 << UVH_LB_BAU_SB_ACTIVATION_CONTROL_PUSH_SHFT) | cpu;
+		uv_write_local_mmr(UVH_LB_BAU_SB_ACTIVATION_CONTROL, index);
+		completion_status = uv_wait_completion(bau_desc, mmr_offset,
+					right_shift);
+	} while (completion_status == FLUSH_RETRY);
+	time2 = get_cycles();
+	__get_cpu_var(ptcstats).sflush += (time2 - time1);
+	if (tries > 1)
+		__get_cpu_var(ptcstats).retriesok++;
+
+	if (completion_status == FLUSH_GIVEUP) {
+		/*
+		 * Cause the caller to do an IPI-style TLB shootdown on
+		 * the cpu's, all of which are still in the mask.
+		 */
+		__get_cpu_var(ptcstats).ptc_i++;
+		return 0;
+	}
+
+	/*
+	 * Success, so clear the remote cpu's from the mask so we don't
+	 * use the IPI method of shootdown on them.
+	 */
+	for_each_cpu_mask(bit, *cpumaskp) {
+		blade = uv_cpu_to_blade_id(bit);
+		if (blade == this_blade)
+			continue;
+		cpu_clear(bit, *cpumaskp);
+	}
+	if (!cpus_empty(*cpumaskp))
+		return 0;
+	return 1;
+}
+
+/**
+ * uv_flush_tlb_others - globally purge translation cache of a virtual
+ * address or all TLB's
+ * @cpumaskp: mask of all cpu's in which the address is to be removed
+ * @mm: mm_struct containing virtual address range
+ * @va: virtual address to be removed (or TLB_FLUSH_ALL for all TLB's on cpu)
+ *
+ * This is the entry point for initiating any UV global TLB shootdown.
+ *
+ * Purges the translation caches of all specified processors of the given
+ * virtual address, or purges all TLB's on specified processors.
+ *
+ * The caller has derived the cpumaskp from the mm_struct and has subtracted
+ * the local cpu from the mask.  This function is called only if there
+ * are bits set in the mask. (e.g. flush_tlb_page())
+ *
+ * The cpumaskp is converted into a nodemask of the nodes containing
+ * the cpus.
+ *
+ * Returns 1 if all remote flushing was done.
+ * Returns 0 if some remote flushing remains to be done.
+ */
+int uv_flush_tlb_others(cpumask_t *cpumaskp, struct mm_struct *mm,
+	unsigned long va)
+{
+	int i;
+	int bit;
+	int blade;
+	int cpu;
+	int this_blade;
+	int locals = 0;
+	struct bau_activation_descriptor *bau_desc;
+
+	cpu = uv_blade_processor_id();
+	this_blade = uv_numa_blade_id();
+	bau_desc = __get_cpu_var(bau_control).descriptor_base;
+	bau_desc += UV_ITEMS_PER_DESCRIPTOR * cpu;
+
+	bau_nodes_clear(&bau_desc->distribution, UV_DISTRIBUTION_SIZE);
+
+	i = 0;
+	for_each_cpu_mask(bit, *cpumaskp) {
+		blade = uv_cpu_to_blade_id(bit);
+		if (blade > (UV_DISTRIBUTION_SIZE - 1))
+			BUG();
+		if (blade == this_blade) {
+			locals++;
+			continue;
+		}
+		bau_node_set(blade, &bau_desc->distribution);
+		i++;
+	}
+	if (i == 0) {
+		/*
+		 * no off_node flushing; return status for local node
+		 */
+		if (locals)
+			return 0;
+		else
+			return 1;
+	}
+	__get_cpu_var(ptcstats).requestor++;
+	__get_cpu_var(ptcstats).ntargeted += i;
+
+	bau_desc->payload.address = va;
+	bau_desc->payload.sending_cpu = smp_processor_id();
+
+	return uv_flush_send_and_wait(cpu, this_blade, bau_desc, cpumaskp);
+}
+
+/*
+ * The BAU message interrupt comes here. (registered by set_intr_gate)
+ * See entry_64.S
+ *
+ * We received a broadcast assist message.
+ *
+ * Interrupts may have been disabled; this interrupt could represent
+ * the receipt of several messages.
+ *
+ * All cores/threads on this node get this interrupt.
+ * The last one to see it does the s/w ack.
+ * (the resource will not be freed until noninterruptable cpus see this
+ *  interrupt; hardware will timeout the s/w ack and reply ERROR)
+ */
+void uv_bau_message_interrupt(struct pt_regs *regs)
+{
+	struct bau_payload_queue_entry *pqp;
+	struct bau_payload_queue_entry *msg;
+	struct pt_regs *old_regs = set_irq_regs(regs);
+	cycles_t time1, time2;
+	int msg_slot;
+	int sw_ack_slot;
+	int fw;
+	int count = 0;
+	unsigned long local_pnode;
+
+	ack_APIC_irq();
+	exit_idle();
+	irq_enter();
+
+	time1 = get_cycles();
+
+	local_pnode = uv_blade_to_pnode(uv_numa_blade_id());
+
+	pqp = __get_cpu_var(bau_control).va_queue_first;
+	msg = __get_cpu_var(bau_control).bau_msg_head;
+	while (msg->sw_ack_vector) {
+		count++;
+		fw = msg->sw_ack_vector;
+		msg_slot = msg - pqp;
+		sw_ack_slot = ffs(fw) - 1;
+
+		uv_bau_process_message(msg, msg_slot, sw_ack_slot);
+
+		msg++;
+		if (msg > __get_cpu_var(bau_control).va_queue_last)
+			msg = __get_cpu_var(bau_control).va_queue_first;
+		__get_cpu_var(bau_control).bau_msg_head = msg;
+	}
+	if (!count)
+		__get_cpu_var(ptcstats).nomsg++;
+	else if (count > 1)
+		__get_cpu_var(ptcstats).multmsg++;
+
+	time2 = get_cycles();
+	__get_cpu_var(ptcstats).dflush += (time2 - time1);
+
+	irq_exit();
+	set_irq_regs(old_regs);
+	return;
+}
+
+static void uv_enable_timeouts(void)
+{
+	int i;
+	int blade;
+	int last_blade;
+	int pnode;
+	int cur_cpu = 0;
+	unsigned long apicid;
+
+	last_blade = -1;
+	for_each_online_node(i) {
+		blade = uv_node_to_blade_id(i);
+		if (blade == last_blade)
+			continue;
+		last_blade = blade;
+		apicid = per_cpu(x86_cpu_to_apicid, cur_cpu);
+		pnode = uv_blade_to_pnode(blade);
+		cur_cpu += uv_blade_nr_possible_cpus(i);
+	}
+	return;
+}
+
+static void *uv_ptc_seq_start(struct seq_file *file, loff_t *offset)
+{
+	if (*offset < num_possible_cpus())
+		return offset;
+	return NULL;
+}
+
+static void *uv_ptc_seq_next(struct seq_file *file, void *data, loff_t *offset)
+{
+	(*offset)++;
+	if (*offset < num_possible_cpus())
+		return offset;
+	return NULL;
+}
+
+static void uv_ptc_seq_stop(struct seq_file *file, void *data)
+{
+}
+
+/*
+ * Display the statistics thru /proc
+ * data points to the cpu number
+ */
+static int uv_ptc_seq_show(struct seq_file *file, void *data)
+{
+	struct ptc_stats *stat;
+	int cpu;
+
+	cpu = *(loff_t *)data;
+
+	if (!cpu) {
+		seq_printf(file,
+		"# cpu requestor requestee one all sretry dretry ptc_i ");
+		seq_printf(file,
+		"sw_ack sflush dflush sok dnomsg dmult starget\n");
+	}
+	if (cpu < num_possible_cpus() && cpu_online(cpu)) {
+		stat = &per_cpu(ptcstats, cpu);
+		seq_printf(file, "cpu %d %ld %ld %ld %ld %ld %ld %ld ",
+			   cpu, stat->requestor,
+			   stat->requestee, stat->onetlb, stat->alltlb,
+			   stat->s_retry, stat->d_retry, stat->ptc_i);
+		seq_printf(file, "%lx %ld %ld %ld %ld %ld %ld\n",
+			   uv_read_global_mmr64(uv_blade_to_pnode
+					(uv_cpu_to_blade_id(cpu)),
+					UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE),
+			   stat->sflush, stat->dflush,
+			   stat->retriesok, stat->nomsg,
+			   stat->multmsg, stat->ntargeted);
+	}
+
+	return 0;
+}
+
+/*
+ *  0: display meaning of the statistics
+ * >0: retry limit
+ */
+static ssize_t uv_ptc_proc_write(struct file *file, const char __user *user,
+		  size_t count, loff_t *data)
+{
+	long newmode;
+	char optstr[64];
+
+	if (copy_from_user(optstr, user, count))
+		return -EFAULT;
+	optstr[count - 1] = '\0';
+	if (strict_strtoul(optstr, 10, &newmode) < 0) {
+		printk(KERN_DEBUG "%s is invalid\n", optstr);
+		return -EINVAL;
+	}
+
+	if (newmode == 0) {
+		printk(KERN_DEBUG "# cpu:      cpu number\n");
+		printk(KERN_DEBUG
+		"requestor:  times this cpu was the flush requestor\n");
+		printk(KERN_DEBUG
+		"requestee:  times this cpu was requested to flush its TLBs\n");
+		printk(KERN_DEBUG
+		"one:        times requested to flush a single address\n");
+		printk(KERN_DEBUG
+		"all:        times requested to flush all TLB's\n");
+		printk(KERN_DEBUG
+		"sretry:     number of retries of source-side timeouts\n");
+		printk(KERN_DEBUG
+		"dretry:     number of retries of destination-side timeouts\n");
+		printk(KERN_DEBUG
+		"ptc_i:      times UV fell through to IPI-style flushes\n");
+		printk(KERN_DEBUG
+		"sw_ack:     image of UVH_LB_BAU_INTD_SOFTWARE_ACKNOWLEDGE\n");
+		printk(KERN_DEBUG
+		"sflush_us:  cycles spent in uv_flush_tlb_others()\n");
+		printk(KERN_DEBUG
+		"dflush_us:  cycles spent in handling flush requests\n");
+		printk(KERN_DEBUG "sok:        successes on retry\n");
+		printk(KERN_DEBUG "dnomsg:     interrupts with no message\n");
+		printk(KERN_DEBUG
+		"dmult:      interrupts with multiple messages\n");
+		printk(KERN_DEBUG "starget:    nodes targeted\n");
+	} else {
+		uv_bau_retry_limit = newmode;
+		printk(KERN_DEBUG "timeout retry limit:%d\n",
+		       uv_bau_retry_limit);
+	}
+
+	return count;
+}
+
+static const struct seq_operations uv_ptc_seq_ops = {
+	.start	= uv_ptc_seq_start,
+	.next	= uv_ptc_seq_next,
+	.stop	= uv_ptc_seq_stop,
+	.show	= uv_ptc_seq_show
+};
+
+static int uv_ptc_proc_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &uv_ptc_seq_ops);
+}
+
+static const struct file_operations proc_uv_ptc_operations = {
+	.open		= uv_ptc_proc_open,
+	.read		= seq_read,
+	.write		= uv_ptc_proc_write,
+	.llseek		= seq_lseek,
+	.release	= seq_release,
+};
+
+static int __init uv_ptc_init(void)
+{
+	struct proc_dir_entry *proc_uv_ptc;
+
+	if (!is_uv_system())
+		return 0;
+
+	if (!proc_mkdir("sgi_uv", NULL))
+		return -EINVAL;
+
+	proc_uv_ptc = create_proc_entry(UV_PTC_BASENAME, 0444, NULL);
+	if (!proc_uv_ptc) {
+		printk(KERN_ERR "unable to create %s proc entry\n",
+		       UV_PTC_BASENAME);
+		return -EINVAL;
+	}
+	proc_uv_ptc->proc_fops = &proc_uv_ptc_operations;
+	return 0;
+}
+
+/*
+ * begin the initialization of the per-blade control structures
+ */
+static struct bau_control * __init uv_table_bases_init(int blade, int node)
+{
+	int i;
+	int *ip;
+	struct bau_msg_status *msp;
+	struct bau_control *bau_tablesp;
+
+	bau_tablesp =
+	    kmalloc_node(sizeof(struct bau_control), GFP_KERNEL, node);
+	if (!bau_tablesp)
+		BUG();
+	bau_tablesp->msg_statuses =
+	    kmalloc_node(sizeof(struct bau_msg_status) *
+			 DESTINATION_PAYLOAD_QUEUE_SIZE, GFP_KERNEL, node);
+	if (!bau_tablesp->msg_statuses)
+		BUG();
+	for (i = 0, msp = bau_tablesp->msg_statuses;
+	     i < DESTINATION_PAYLOAD_QUEUE_SIZE; i++, msp++) {
+		bau_cpubits_clear(&msp->seen_by, (int)
+				  uv_blade_nr_possible_cpus(blade));
+	}
+	bau_tablesp->watching =
+	    kmalloc_node(sizeof(int) * DESTINATION_NUM_RESOURCES,
+			 GFP_KERNEL, node);
+	if (!bau_tablesp->watching)
+		BUG();
+	for (i = 0, ip = bau_tablesp->watching;
+	     i < DESTINATION_PAYLOAD_QUEUE_SIZE; i++, ip++) {
+		*ip = 0;
+	}
+	uv_bau_table_bases[i] = bau_tablesp;
+	return bau_tablesp;
+}
+
+/*
+ * finish the initialization of the per-blade control structures
+ */
+static void __init uv_table_bases_finish(int blade, int node, int cur_cpu,
+				  struct bau_control *bau_tablesp,
+				  struct bau_activation_descriptor *adp)
+{
+	int i;
+	struct bau_control *bcp;
+
+	for (i = cur_cpu; i < (cur_cpu + uv_blade_nr_possible_cpus(blade));
+	     i++) {
+		bcp = (struct bau_control *)&per_cpu(bau_control, i);
+		bcp->bau_msg_head = bau_tablesp->va_queue_first;
+		bcp->va_queue_first = bau_tablesp->va_queue_first;
+		bcp->va_queue_last = bau_tablesp->va_queue_last;
+		bcp->watching = bau_tablesp->watching;
+		bcp->msg_statuses = bau_tablesp->msg_statuses;
+		bcp->descriptor_base = adp;
+	}
+}
+
+/*
+ * initialize the sending side's sending buffers
+ */
+static struct bau_activation_descriptor * __init
+uv_activation_descriptor_init(int node, int pnode)
+{
+	int i;
+	unsigned long pa;
+	unsigned long m;
+	unsigned long n;
+	unsigned long mmr_image;
+	struct bau_activation_descriptor *adp;
+	struct bau_activation_descriptor *ad2;
+
+	adp = (struct bau_activation_descriptor *)
+	    kmalloc_node(16384, GFP_KERNEL, node);
+	if (!adp)
+		BUG();
+	pa = __pa((unsigned long)adp);
+	n = pa >> uv_nshift;
+	m = pa & uv_mmask;
+	mmr_image = uv_read_global_mmr64(pnode, UVH_LB_BAU_SB_DESCRIPTOR_BASE);
+	if (mmr_image)
+		uv_write_global_mmr64(pnode, (unsigned long)
+				      UVH_LB_BAU_SB_DESCRIPTOR_BASE,
+				      (n << UV_DESC_BASE_PNODE_SHIFT | m));
+	for (i = 0, ad2 = adp; i < UV_ACTIVATION_DESCRIPTOR_SIZE; i++, ad2++) {
+		memset(ad2, 0, sizeof(struct bau_activation_descriptor));
+		ad2->header.sw_ack_flag = 1;
+		ad2->header.base_dest_nodeid =
+		    uv_blade_to_pnode(uv_cpu_to_blade_id(0));
+		ad2->header.command = UV_NET_ENDPOINT_INTD;
+		ad2->header.int_both = 1;
+		/*
+		 * all others need to be set to zero:
+		 *   fairness chaining multilevel count replied_to
+		 */
+	}
+	return adp;
+}
+
+/*
+ * initialize the destination side's receiving buffers
+ */
+static struct bau_payload_queue_entry * __init uv_payload_queue_init(int node,
+				int pnode, struct bau_control *bau_tablesp)
+{
+	char *cp;
+	struct bau_payload_queue_entry *pqp;
+
+	pqp = (struct bau_payload_queue_entry *)
+	    kmalloc_node((DESTINATION_PAYLOAD_QUEUE_SIZE + 1) *
+			 sizeof(struct bau_payload_queue_entry),
+			 GFP_KERNEL, node);
+	if (!pqp)
+		BUG();
+	cp = (char *)pqp + 31;
+	pqp = (struct bau_payload_queue_entry *)(((unsigned long)cp >> 5) << 5);
+	bau_tablesp->va_queue_first = pqp;
+	uv_write_global_mmr64(pnode,
+			      UVH_LB_BAU_INTD_PAYLOAD_QUEUE_FIRST,
+			      ((unsigned long)pnode <<
+			       UV_PAYLOADQ_PNODE_SHIFT) |
+			      uv_physnodeaddr(pqp));
+	uv_write_global_mmr64(pnode, UVH_LB_BAU_INTD_PAYLOAD_QUEUE_TAIL,
+			      uv_physnodeaddr(pqp));
+	bau_tablesp->va_queue_last =
+	    pqp + (DESTINATION_PAYLOAD_QUEUE_SIZE - 1);
+	uv_write_global_mmr64(pnode, UVH_LB_BAU_INTD_PAYLOAD_QUEUE_LAST,
+			      (unsigned long)
+			      uv_physnodeaddr(bau_tablesp->va_queue_last));
+	memset(pqp, 0, sizeof(struct bau_payload_queue_entry) *
+	       DESTINATION_PAYLOAD_QUEUE_SIZE);
+	return pqp;
+}
+
+/*
+ * Initialization of each UV blade's structures
+ */
+static int __init uv_init_blade(int blade, int node, int cur_cpu)
+{
+	int pnode;
+	unsigned long pa;
+	unsigned long apicid;
+	struct bau_activation_descriptor *adp;
+	struct bau_payload_queue_entry *pqp;
+	struct bau_control *bau_tablesp;
+
+	bau_tablesp = uv_table_bases_init(blade, node);
+	pnode = uv_blade_to_pnode(blade);
+	adp = uv_activation_descriptor_init(node, pnode);
+	pqp = uv_payload_queue_init(node, pnode, bau_tablesp);
+	uv_table_bases_finish(blade, node, cur_cpu, bau_tablesp, adp);
+	/*
+	 * the below initialization can't be in firmware because the
+	 * messaging IRQ will be determined by the OS
+	 */
+	apicid = per_cpu(x86_cpu_to_apicid, cur_cpu);
+	pa = uv_read_global_mmr64(pnode, UVH_BAU_DATA_CONFIG);
+	if ((pa & 0xff) != UV_BAU_MESSAGE) {
+		uv_write_global_mmr64(pnode, UVH_BAU_DATA_CONFIG,
+				      ((apicid << 32) | UV_BAU_MESSAGE));
+	}
+	return 0;
+}
+
+/*
+ * Initialization of BAU-related structures
+ */
+static int __init uv_bau_init(void)
+{
+	int blade;
+	int node;
+	int nblades;
+	int last_blade;
+	int cur_cpu = 0;
+
+	if (!is_uv_system())
+		return 0;
+
+	uv_bau_retry_limit = 1;
+	uv_nshift = uv_hub_info->n_val;
+	uv_mmask = ((unsigned long)1 << uv_hub_info->n_val) - 1;
+	nblades = 0;
+	last_blade = -1;
+	for_each_online_node(node) {
+		blade = uv_node_to_blade_id(node);
+		if (blade == last_blade)
+			continue;
+		last_blade = blade;
+		nblades++;
+	}
+	uv_bau_table_bases = (struct bau_control **)
+	    kmalloc(nblades * sizeof(struct bau_control *), GFP_KERNEL);
+	if (!uv_bau_table_bases)
+		BUG();
+	last_blade = -1;
+	for_each_online_node(node) {
+		blade = uv_node_to_blade_id(node);
+		if (blade == last_blade)
+			continue;
+		last_blade = blade;
+		uv_init_blade(blade, node, cur_cpu);
+		cur_cpu += uv_blade_nr_possible_cpus(blade);
+	}
+	set_intr_gate(UV_BAU_MESSAGE, uv_bau_message_intr1);
+	uv_enable_timeouts();
+	return 0;
+}
+__initcall(uv_bau_init);
+__initcall(uv_ptc_init);
Index: 080602.ingo/include/asm-x86/uv/uv_bau.h
===================================================================
--- /dev/null
+++ 080602.ingo/include/asm-x86/uv/uv_bau.h
@@ -0,0 +1,336 @@
+/*
+ * This file is subject to the terms and conditions of the GNU General Public
+ * License.  See the file "COPYING" in the main directory of this archive
+ * for more details.
+ *
+ * SGI UV Broadcast Assist Unit definitions
+ *
+ * Copyright (C) 2008 Silicon Graphics, Inc. All rights reserved.
+ */
+
+#ifndef __ASM_X86_UV_BAU__
+#define __ASM_X86_UV_BAU__
+
+#include <linux/bitmap.h>
+#define BITSPERBYTE 8
+
+/*
+ * Broadcast Assist Unit messaging structures
+ *
+ * Selective Broadcast activations are induced by software action
+ * specifying a particular 8-descriptor "set" via a 6-bit index written
+ * to an MMR.
+ * Thus there are 64 unique 512-byte sets of SB descriptors - one set for
+ * each 6-bit index value. These descriptor sets are mapped in sequence
+ * starting with set 0 located at the address specified in the
+ * BAU_SB_DESCRIPTOR_BASE register, set 1 is located at BASE + 512,
+ * set 2 is at BASE + 2*512, set 3 at BASE + 3*512, and so on.
+ *
+ * We will use 31 sets, one for sending BAU messages from each of the 32
+ * cpu's on the node.
+ *
+ * TLB shootdown will use the first of the 8 descriptors of each set.
+ * Each of the descriptors is 64 bytes in size (8*64 = 512 bytes in a set).
+ */
+
+#define UV_ITEMS_PER_DESCRIPTOR		8
+#define UV_CPUS_PER_ACT_STATUS		32
+#define UV_ACT_STATUS_MASK		0x3
+#define UV_ACT_STATUS_SIZE		2
+#define UV_ACTIVATION_DESCRIPTOR_SIZE	32
+#define UV_DISTRIBUTION_SIZE		256
+#define UV_SW_ACK_NPENDING		8
+#define UV_BAU_MESSAGE			200
+/*
+ * Messaging irq; see irq_64.h and include/asm-x86/hw_irq_64.h
+ * To be dynamically allocated in the future
+ */
+#define UV_NET_ENDPOINT_INTD		0x38
+#define UV_DESC_BASE_PNODE_SHIFT	49
+#define UV_PAYLOADQ_PNODE_SHIFT		49
+#define UV_PTC_BASENAME			"sgi_uv/ptc_statistics"
+#define uv_physnodeaddr(x)		((__pa((unsigned long)(x)) & uv_mmask))
+
+/*
+ * bits in UVH_LB_BAU_SB_ACTIVATION_STATUS_0/1
+ */
+#define DESC_STATUS_IDLE                0
+#define DESC_STATUS_ACTIVE              1
+#define DESC_STATUS_DESTINATION_TIMEOUT 2
+#define DESC_STATUS_SOURCE_TIMEOUT      3
+
+/*
+ * source side threshholds at which message retries print a warning
+ */
+#define SOURCE_TIMEOUT_LIMIT            20
+#define DESTINATION_TIMEOUT_LIMIT       20
+
+/*
+ * number of entries in the destination side payload queue
+ */
+#define DESTINATION_PAYLOAD_QUEUE_SIZE  17
+/*
+ * number of destination side software ack resources
+ */
+#define DESTINATION_NUM_RESOURCES       8
+#define MAX_CPUS_PER_NODE		32
+/*
+ * completion statuses for sending a TLB flush message
+ */
+#define	FLUSH_RETRY			1
+#define	FLUSH_GIVEUP			2
+#define	FLUSH_COMPLETE			3
+
+/*
+ * Distribution: 32 bytes (256 bits) (bytes 0-0x1f of descriptor)
+ * If the 'multilevel' flag in the header portion of the descriptor
+ * has been set to 0, then endpoint multi-unicast mode is selected.
+ * The distribution specification (32 bytes) is interpreted as a 256-bit
+ * distribution vector. Adjacent bits correspond to consecutive even numbered
+ * nodeIDs. The result of adding the index of a given bit to the 15-bit
+ * 'base_dest_nodeid' field of the header corresponds to the
+ * destination nodeID associated with that specified bit.
+ */
+struct bau_target_nodemask {
+	unsigned long bits[BITS_TO_LONGS(256)];
+};
+
+/*
+ * mask of cpu's on a node
+ * (during initialization we need to check that unsigned long has
+ *  enough bits for max. cpu's per node)
+ */
+struct bau_local_cpumask {
+	unsigned long bits;
+};
+
+/*
+ * Payload: 16 bytes (128 bits) (bytes 0x20-0x2f of descriptor)
+ * only 12 bytes (96 bits) of the payload area are usable.
+ * An additional 3 bytes (bits 27:4) of the header address are carried
+ * to the next bytes of the destination payload queue.
+ * And an additional 2 bytes of the header Suppl_A field are also
+ * carried to the destination payload queue.
+ * But the first byte of the Suppl_A becomes bits 127:120 (the 16th byte)
+ * of the destination payload queue, which is written by the hardware
+ * with the s/w ack resource bit vector.
+ * [ effective message contents (16 bytes (128 bits) maximum), not counting
+ *   the s/w ack bit vector  ]
+ */
+
+/*
+ * The payload is software-defined for INTD transactions
+ */
+struct bau_msg_payload {
+	unsigned long address;		/* signifies a page or all TLB's
+						of the cpu */
+	/* 64 bits */
+	unsigned short sending_cpu;	/* filled in by sender */
+	/* 16 bits */
+	unsigned short acknowledge_count;/* filled in by destination */
+	/* 16 bits */
+	unsigned int reserved1:32;	/* not usable */
+};
+
+
+/*
+ * Message header:  16 bytes (128 bits) (bytes 0x30-0x3f of descriptor)
+ * see table 4.2.3.0.1 in broacast_assist spec.
+ */
+struct bau_msg_header {
+	int dest_subnodeid:6;	/* must be zero */
+	/* bits 5:0 */
+	int base_dest_nodeid:15; /* nasid>>1 (pnode) of first bit in node_map */
+	/* bits 20:6 */
+	int command:8;		/* message type */
+	/* bits 28:21 */
+				/* 0x38: SN3net EndPoint Message */
+	int rsvd_1:3;		/* must be zero */
+	/* bits 31:29 */
+				/* int will align on 32 bits */
+	int rsvd_2:9;		/* must be zero */
+	/* bits 40:32 */
+				/* Suppl_A is 56-41 */
+	int payload_2a:8;	/* becomes byte 16 of msg */
+	/* bits 48:41 */	/* not currently using */
+	int payload_2b:8;	/* becomes byte 17 of msg */
+	/* bits 56:49 */	/* not currently using */
+				/* Address field (96:57) is never used as an
+				   address (these are address bits 42:3) */
+	int rsvd_3:1;		/* must be zero */
+	/* bit 57 */
+				/* address bits 27:4 are payload */
+				/* these 24 bits become bytes 12-14 of msg */
+	int replied_to:1;	/* sent as 0 by the source to byte 12 */
+	/* bit 58 */
+
+	int payload_1a:5;	/* not currently used */
+	/* bits 63:59 */
+	int payload_1b:8;	/* not currently used */
+	/* bits 71:64 */
+	int payload_1c:8;	/* not currently used */
+	/* bits 79:72 */
+	int payload_1d:2;	/* not currently used */
+	/* bits 81:80 */
+
+	int rsvd_4:7;		/* must be zero */
+	/* bits 88:82 */
+	int sw_ack_flag:1;	/* software acknowledge flag */
+	/* bit 89 */
+				/* INTD trasactions at destination are to
+				   wait for software acknowledge */
+	int rsvd_5:6;		/* must be zero */
+	/* bits 95:90 */
+	int rsvd_6:5;		/* must be zero */
+	/* bits 100:96 */
+	int int_both:1;		/* if 1, interrupt both sockets on the blade */
+	/* bit 101*/
+	int fairness:3;		/* usually zero */
+	/* bits 104:102 */
+	int multilevel:1;	/* multi-level multicast format */
+	/* bit 105 */
+				/* 0 for TLB: endpoint multi-unicast messages */
+	int chaining:1;		/* next descriptor is part of this activation*/
+	/* bit 106 */
+	int rsvd_7:21;		/* must be zero */
+	/* bits 127:107 */
+};
+
+/*
+ * The format of the message to send, plus all accompanying control
+ * Should be 64 bytes
+ */
+struct bau_activation_descriptor {
+	struct bau_target_nodemask distribution;
+	/*
+	 * message template, consisting of header and payload:
+	 */
+	struct bau_msg_header header;
+	struct bau_msg_payload payload;
+};
+/*
+ *   -payload--    ---------header------
+ *   bytes 0-11    bits 41-56  bits 58-81
+ *       A           B  (2)      C (3)
+ *
+ *            A/B/C are moved to:
+ *       A            C          B
+ *   bytes 0-11  bytes 12-14  bytes 16-17  (byte 15 filled in by hw as vector)
+ *   ------------payload queue-----------
+ */
+
+/*
+ * The payload queue on the destination side is an array of these.
+ * With BAU_MISC_CONTROL set for software acknowledge mode, the messages
+ * are 32 bytes (2 micropackets) (256 bits) in length, but contain only 17
+ * bytes of usable data, including the sw ack vector in byte 15 (bits 127:120)
+ * (12 bytes come from bau_msg_payload, 3 from payload_1, 2 from
+ *  sw_ack_vector and payload_2)
+ * "Enabling Software Acknowledgment mode (see Section 4.3.3 Software
+ *  Acknowledge Processing) also selects 32 byte (17 bytes usable) payload
+ *  operation."
+ */
+struct bau_payload_queue_entry {
+	unsigned long address;		/* signifies a page or all TLB's
+						of the cpu */
+	/* 64 bits, bytes 0-7 */
+
+	unsigned short sending_cpu;	/* cpu that sent the message */
+	/* 16 bits, bytes 8-9 */
+
+	unsigned short acknowledge_count; /* filled in by destination */
+	/* 16 bits, bytes 10-11 */
+
+	unsigned short replied_to:1;	/* sent as 0 by the source */
+	/* 1 bit */
+	unsigned short unused1:7;       /* not currently using */
+	/* 7 bits: byte 12) */
+
+	unsigned char unused2[2];	/* not currently using */
+	/* bytes 13-14 */
+
+	unsigned char sw_ack_vector;	/* filled in by the hardware */
+	/* byte 15 (bits 127:120) */
+
+	unsigned char unused4[3];	/* not currently using bytes 17-19 */
+	/* bytes 17-19 */
+
+	int number_of_cpus;		/* filled in at destination */
+	/* 32 bits, bytes 20-23 (aligned) */
+
+	unsigned char unused5[8];       /* not using */
+	/* bytes 24-31 */
+};
+
+/*
+ * one for every slot in the destination payload queue
+ */
+struct bau_msg_status {
+	struct bau_local_cpumask seen_by;	/* map of cpu's */
+};
+
+/*
+ * one for every slot in the destination software ack resources
+ */
+struct bau_sw_ack_status {
+	struct bau_payload_queue_entry *msg;	/* associated message */
+	int watcher;				/* cpu monitoring, or -1 */
+};
+
+/*
+ * one on every node and per-cpu; to locate the software tables
+ */
+struct bau_control {
+	struct bau_activation_descriptor *descriptor_base;
+	struct bau_payload_queue_entry *bau_msg_head;
+	struct bau_payload_queue_entry *va_queue_first;
+	struct bau_payload_queue_entry *va_queue_last;
+	struct bau_msg_status *msg_statuses;
+	int *watching; /* pointer to array */
+};
+
+/*
+ * This structure is allocated per_cpu for UV TLB shootdown statistics.
+ */
+struct ptc_stats {
+	unsigned long ptc_i;	/* number of IPI-style flushes */
+	unsigned long requestor;	/* number of nodes this cpu sent to */
+	unsigned long requestee;	/* times cpu was remotely requested */
+	unsigned long alltlb;	/* times all tlb's on this cpu were flushed */
+	unsigned long onetlb;	/* times just one tlb on this cpu was flushed */
+	unsigned long s_retry;	/* retries on source side timeouts */
+	unsigned long d_retry;	/* retries on destination side timeouts */
+	unsigned long sflush;	/* cycles spent in uv_flush_tlb_others */
+	unsigned long dflush;	/* cycles spent on destination side */
+	unsigned long retriesok; /* successes on retries */
+	unsigned long nomsg;	/* interrupts with no message */
+	unsigned long multmsg;	/* interrupts with multiple messages */
+	unsigned long ntargeted;/* nodes targeted */
+};
+
+static inline int bau_node_isset(int node, struct bau_target_nodemask *dstp)
+{
+	return constant_test_bit(node, &dstp->bits[0]);
+}
+static inline void bau_node_set(int node, struct bau_target_nodemask *dstp)
+{
+	__set_bit(node, &dstp->bits[0]);
+}
+static inline void bau_nodes_clear(struct bau_target_nodemask *dstp, int nbits)
+{
+	bitmap_zero(&dstp->bits[0], nbits);
+}
+
+static inline void bau_cpubits_clear(struct bau_local_cpumask *dstp, int nbits)
+{
+	bitmap_zero(&dstp->bits, nbits);
+}
+
+#define cpubit_isset(cpu, bau_local_cpumask) \
+	test_bit((cpu), (bau_local_cpumask).bits)
+
+extern int uv_flush_tlb_others(cpumask_t *, struct mm_struct *, unsigned long);
+extern void uv_bau_message_intr1(void);
+extern void uv_bau_timeout_intr1(void);
+
+#endif /* __ASM_X86_UV_BAU__ */
Index: 080602.ingo/arch/x86/kernel/Makefile
===================================================================
--- 080602.ingo.orig/arch/x86/kernel/Makefile
+++ 080602.ingo/arch/x86/kernel/Makefile
@@ -105,7 +105,7 @@ obj-$(CONFIG_KMEMCHECK)		+= kmemcheck.o
 ###
 # 64 bit specific files
 ifeq ($(CONFIG_X86_64),y)
-        obj-y				+= genapic_64.o genapic_flat_64.o genx2apic_uv_x.o
+        obj-y				+= genapic_64.o genapic_flat_64.o genx2apic_uv_x.o tlb_uv.o
         obj-$(CONFIG_X86_PM_TIMER)	+= pmtimer_64.o
         obj-$(CONFIG_AUDIT)		+= audit_64.o
 
Index: 080602.ingo/include/asm-x86/atomic_64.h
===================================================================
--- 080602.ingo.orig/include/asm-x86/atomic_64.h
+++ 080602.ingo/include/asm-x86/atomic_64.h
@@ -425,6 +425,36 @@ static inline int atomic64_add_unless(at
 	return c != (u);
 }
 
+/**
+ * atomic_inc_short - increment of a short integer
+ * @v: pointer to type int
+ *
+ * Atomically adds 1 to @v
+ * Returns the new value of @u
+ */
+static inline short int atomic_inc_short(short int *v)
+{
+	asm volatile("movw $1, %%cx; lock; xaddw %%cx, %0\n"
+		: "+m" (*v) : : "cx");
+		/* clobbers counter register cx */
+	return *v;
+}
+
+/**
+ * atomic_or_long - OR of two long integers
+ * @v1: pointer to type unsigned long
+ * @v2: pointer to type unsigned long
+ *
+ * Atomically ORs @v1 and @v2
+ * Returns the result of the OR
+ */
+static inline void atomic_or_long(unsigned long *v1, unsigned long v2)
+{
+	asm volatile("movq %1, %%rax; lock; orq %%rax, %0\n"
+		: "+m" (*v1) : "g" (v2): "rax");
+		/* clobbers accumulator register ax */
+}
+
 #define atomic64_inc_not_zero(v) atomic64_add_unless((v), 1, 0)
 
 /* These are x86-specific, used by some header files */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

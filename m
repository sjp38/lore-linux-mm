Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 6423F6B003A
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 12:49:13 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so10943739pac.33
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 09:49:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id bt3si27568936pbb.82.2014.07.01.09.49.11
        for <linux-mm@kvack.org>;
        Tue, 01 Jul 2014 09:49:12 -0700 (PDT)
Subject: [PATCH 6/7] x86: mm: new tunable for single vs full TLB flush
From: Dave Hansen <dave@sr71.net>
Date: Tue, 01 Jul 2014 09:48:55 -0700
References: <20140701164845.8D1A5702@viggo.jf.intel.com>
In-Reply-To: <20140701164845.8D1A5702@viggo.jf.intel.com>
Message-Id: <20140701164855.30A8A282@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hpa@zytor.com, mingo@redhat.com, tglx@linutronix.de, x86@kernel.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, riel@redhat.com, mgorman@suse.de


From: Dave Hansen <dave.hansen@linux.intel.com>

Most of the logic here is in the documentation file.  Please take
a look at it.

I know we've come full-circle here back to a tunable, but this
new one is *WAY* simpler.  I challenge anyone to describe in one
sentence how the old one worked.  Here's the way the new one
works:

	If we are flushing more pages than the ceiling, we use
	the full flush, otherwise we use per-page flushes.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Mel Gorman <mgorman@suse.de>
---

 b/Documentation/x86/tlb.txt |   75 ++++++++++++++++++++++++++++++++++++++++++++
 b/arch/x86/mm/tlb.c         |   46 ++++++++++++++++++++++++++
 2 files changed, 121 insertions(+)

diff -puN arch/x86/mm/tlb.c~new-tunable-for-single-vs-full-tlb-flush arch/x86/mm/tlb.c
--- a/arch/x86/mm/tlb.c~new-tunable-for-single-vs-full-tlb-flush	2014-06-30 16:18:42.105201432 -0700
+++ b/arch/x86/mm/tlb.c	2014-06-30 16:18:42.111201706 -0700
@@ -265,3 +265,49 @@ void flush_tlb_kernel_range(unsigned lon
 		on_each_cpu(do_kernel_range_flush, &info, 1);
 	}
 }
+
+static ssize_t tlbflush_read_file(struct file *file, char __user *user_buf,
+			     size_t count, loff_t *ppos)
+{
+	char buf[32];
+	unsigned int len;
+
+	len = sprintf(buf, "%ld\n", tlb_single_page_flush_ceiling);
+	return simple_read_from_buffer(user_buf, count, ppos, buf, len);
+}
+
+static ssize_t tlbflush_write_file(struct file *file,
+		 const char __user *user_buf, size_t count, loff_t *ppos)
+{
+	char buf[32];
+	ssize_t len;
+	int ceiling;
+
+	len = min(count, sizeof(buf) - 1);
+	if (copy_from_user(buf, user_buf, len))
+		return -EFAULT;
+
+	buf[len] = '\0';
+	if (kstrtoint(buf, 0, &ceiling))
+		return -EINVAL;
+
+	if (ceiling < 0)
+		return -EINVAL;
+
+	tlb_single_page_flush_ceiling = ceiling;
+	return count;
+}
+
+static const struct file_operations fops_tlbflush = {
+	.read = tlbflush_read_file,
+	.write = tlbflush_write_file,
+	.llseek = default_llseek,
+};
+
+static int __init create_tlb_single_page_flush_ceiling(void)
+{
+	debugfs_create_file("tlb_single_page_flush_ceiling", S_IRUSR | S_IWUSR,
+			    arch_debugfs_dir, NULL, &fops_tlbflush);
+	return 0;
+}
+late_initcall(create_tlb_single_page_flush_ceiling);
diff -puN /dev/null Documentation/x86/tlb.txt
--- /dev/null	2014-04-10 11:28:14.066815724 -0700
+++ b/Documentation/x86/tlb.txt	2014-06-30 16:18:42.112201751 -0700
@@ -0,0 +1,75 @@
+When the kernel unmaps or modified the attributes of a range of
+memory, it has two choices:
+ 1. Flush the entire TLB with a two-instruction sequence.  This is
+    a quick operation, but it causes collateral damage: TLB entries
+    from areas other than the one we are trying to flush will be
+    destroyed and must be refilled later, at some cost.
+ 2. Use the invlpg instruction to invalidate a single page at a
+    time.  This could potentialy cost many more instructions, but
+    it is a much more precise operation, causing no collateral
+    damage to other TLB entries.
+
+Which method to do depends on a few things:
+ 1. The size of the flush being performed.  A flush of the entire
+    address space is obviously better performed by flushing the
+    entire TLB than doing 2^48/PAGE_SIZE individual flushes.
+ 2. The contents of the TLB.  If the TLB is empty, then there will
+    be no collateral damage caused by doing the global flush, and
+    all of the individual flush will have ended up being wasted
+    work.
+ 3. The size of the TLB.  The larger the TLB, the more collateral
+    damage we do with a full flush.  So, the larger the TLB, the
+    more attrative an individual flush looks.  Data and
+    instructions have separate TLBs, as do different page sizes.
+ 4. The microarchitecture.  The TLB has become a multi-level
+    cache on modern CPUs, and the global flushes have become more
+    expensive relative to single-page flushes.
+
+There is obviously no way the kernel can know all these things,
+especially the contents of the TLB during a given flush.  The
+sizes of the flush will vary greatly depending on the workload as
+well.  There is essentially no "right" point to choose.
+
+You may be doing too many individual invalidations if you see the
+invlpg instruction (or instructions _near_ it) show up high in
+profiles.  If you believe that individual invalidations being
+called too often, you can lower the tunable:
+
+	/sys/debug/kernel/x86/tlb_single_page_flush_ceiling
+
+This will cause us to do the global flush for more cases.
+Lowering it to 0 will disable the use of the individual flushes.
+Setting it to 1 is a very conservative setting and it should
+never need to be 0 under normal circumstances.
+
+Despite the fact that a single individual flush on x86 is
+guaranteed to flush a full 2MB [1], hugetlbfs always uses the full
+flushes.  THP is treated exactly the same as normal memory.
+
+You might see invlpg inside of flush_tlb_mm_range() show up in
+profiles, or you can use the trace_tlb_flush() tracepoints. to
+determine how long the flush operations are taking.
+
+Essentially, you are balancing the cycles you spend doing invlpg
+with the cycles that you spend refilling the TLB later.
+
+You can measure how expensive TLB refills are by using
+performance counters and 'perf stat', like this:
+
+perf stat -e
+	cpu/event=0x8,umask=0x84,name=dtlb_load_misses_walk_duration/,
+	cpu/event=0x8,umask=0x82,name=dtlb_load_misses_walk_completed/,
+	cpu/event=0x49,umask=0x4,name=dtlb_store_misses_walk_duration/,
+	cpu/event=0x49,umask=0x2,name=dtlb_store_misses_walk_completed/,
+	cpu/event=0x85,umask=0x4,name=itlb_misses_walk_duration/,
+	cpu/event=0x85,umask=0x2,name=itlb_misses_walk_completed/
+
+That works on an IvyBridge-era CPU (i5-3320M).  Different CPUs
+may have differently-named counters, but they should at least
+be there in some form.  You can use pmu-tools 'ocperf list'
+(https://github.com/andikleen/pmu-tools) to find the right
+counters for a given CPU.
+
+1. A footnote in Intel's SDM "4.10.4.2 Recommended Invalidation"
+   says: "One execution of INVLPG is sufficient even for a page
+   with size greater than 4 KBytes."
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

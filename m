Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id AC7A96B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 19:44:05 -0400 (EDT)
Message-ID: <51E5DABC.3060104@sr71.net>
Date: Tue, 16 Jul 2013 16:43:56 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmstats: tlb flush counters
References: <20130716155304.AF1A88F8@viggo.jf.intel.com> <20130716233632.GD30164@hacker.(null)>
In-Reply-To: <20130716233632.GD30164@hacker.(null)>
Content-Type: multipart/mixed;
 boundary="------------000800050304070906030309"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

This is a multi-part message in MIME format.
--------------000800050304070906030309
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 07/16/2013 04:36 PM, Wanpeng Li wrote:
> On Tue, Jul 16, 2013 at 08:53:04AM -0700, Dave Hansen wrote:
>> I was investigating some TLB flush scaling issues and realized
>> that we do not have any good methods for figuring out how many
>> TLB flushes we are doing.
>>
>> It would be nice to be able to do these in generic code, but the
>> arch-independent calls don't explicitly specify whether we
>> actually need to do remote flushes or not.  In the end, we really
>> need to know if we actually _did_ global vs. local invalidations,
>> so that leaves us with few options other than to muck with the
>> counters from arch-specific code.
>>
>> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
>>
> There is no context in the patch?

Weird.  I've attached another copy and I'll resent to the mailing list.

--------------000800050304070906030309
Content-Type: text/x-patch;
 name="tlb-vmstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="tlb-vmstats.patch"


I was investigating some TLB flush scaling issues and realized
that we do not have any good methods for figuring out how many
TLB flushes we are doing.

It would be nice to be able to do these in generic code, but the
arch-independent calls don't explicitly specify whether we
actually need to do remote flushes or not.  In the end, we really
need to know if we actually _did_ global vs. local invalidations,
so that leaves us with few options other than to muck with the
counters from arch-specific code.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 linux.git-davehans/arch/x86/mm/tlb.c             |   18 ++++++++++++++----
 linux.git-davehans/include/linux/vm_event_item.h |    5 +++++
 linux.git-davehans/mm/vmstat.c                   |    5 +++++
 3 files changed, 24 insertions(+), 4 deletions(-)

diff -puN arch/x86/mm/tlb.c~tlb-vmstats arch/x86/mm/tlb.c
--- linux.git/arch/x86/mm/tlb.c~tlb-vmstats	2013-07-16 16:41:56.476280350 -0700
+++ linux.git-davehans/arch/x86/mm/tlb.c	2013-07-16 16:41:56.483280658 -0700
@@ -103,6 +103,7 @@ static void flush_tlb_func(void *info)
 	if (f->flush_mm != this_cpu_read(cpu_tlbstate.active_mm))
 		return;
 
+	count_vm_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_OK) {
 		if (f->flush_end == TLB_FLUSH_ALL)
 			local_flush_tlb();
@@ -130,6 +131,7 @@ void native_flush_tlb_others(const struc
 	info.flush_start = start;
 	info.flush_end = end;
 
+	count_vm_event(NR_TLB_REMOTE_FLUSH);
 	if (is_uv_system()) {
 		unsigned int cpu;
 
@@ -149,6 +151,7 @@ void flush_tlb_current_task(void)
 
 	preempt_disable();
 
+	count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
 	local_flush_tlb();
 	if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) < nr_cpu_ids)
 		flush_tlb_others(mm_cpumask(mm), mm, 0UL, TLB_FLUSH_ALL);
@@ -211,16 +214,19 @@ void flush_tlb_mm_range(struct mm_struct
 	act_entries = mm->total_vm > tlb_entries ? tlb_entries : mm->total_vm;
 
 	/* tlb_flushall_shift is on balance point, details in commit log */
-	if ((end - start) >> PAGE_SHIFT > act_entries >> tlb_flushall_shift)
+	if ((end - start) >> PAGE_SHIFT > act_entries >> tlb_flushall_shift) {
+		count_vm_event(NR_TLB_LOCAL_FLUSH_ALL);
 		local_flush_tlb();
-	else {
+	} else {
 		if (has_large_page(mm, start, end)) {
 			local_flush_tlb();
 			goto flush_all;
 		}
 		/* flush range by one by one 'invlpg' */
-		for (addr = start; addr < end;	addr += PAGE_SIZE)
+		for (addr = start; addr < end;	addr += PAGE_SIZE) {
+			count_vm_event(NR_TLB_LOCAL_FLUSH_ONE);
 			__flush_tlb_single(addr);
+		}
 
 		if (cpumask_any_but(mm_cpumask(mm),
 				smp_processor_id()) < nr_cpu_ids)
@@ -256,6 +262,7 @@ void flush_tlb_page(struct vm_area_struc
 
 static void do_flush_tlb_all(void *info)
 {
+	count_vm_event(NR_TLB_REMOTE_FLUSH_RECEIVED);
 	__flush_tlb_all();
 	if (this_cpu_read(cpu_tlbstate.state) == TLBSTATE_LAZY)
 		leave_mm(smp_processor_id());
@@ -263,6 +270,7 @@ static void do_flush_tlb_all(void *info)
 
 void flush_tlb_all(void)
 {
+	count_vm_event(NR_TLB_REMOTE_FLUSH);
 	on_each_cpu(do_flush_tlb_all, NULL, 1);
 }
 
@@ -272,8 +280,10 @@ static void do_kernel_range_flush(void *
 	unsigned long addr;
 
 	/* flush range by one by one 'invlpg' */
-	for (addr = f->flush_start; addr < f->flush_end; addr += PAGE_SIZE)
+	for (addr = f->flush_start; addr < f->flush_end; addr += PAGE_SIZE) {
+		count_vm_event(NR_TLB_LOCAL_FLUSH_ONE_KERNEL);
 		__flush_tlb_single(addr);
+	}
 }
 
 void flush_tlb_kernel_range(unsigned long start, unsigned long end)
diff -puN include/linux/vm_event_item.h~tlb-vmstats include/linux/vm_event_item.h
--- linux.git/include/linux/vm_event_item.h~tlb-vmstats	2013-07-16 16:41:56.478280438 -0700
+++ linux.git-davehans/include/linux/vm_event_item.h	2013-07-16 16:41:56.483280658 -0700
@@ -70,6 +70,11 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
 		THP_ZERO_PAGE_ALLOC,
 		THP_ZERO_PAGE_ALLOC_FAILED,
 #endif
+		NR_TLB_REMOTE_FLUSH,	/* cpu tried to flush others' tlbs */
+		NR_TLB_REMOTE_FLUSH_RECEIVED,/* cpu received ipi for flush */
+		NR_TLB_LOCAL_FLUSH_ALL,
+		NR_TLB_LOCAL_FLUSH_ONE,
+		NR_TLB_LOCAL_FLUSH_ONE_KERNEL,
 		NR_VM_EVENT_ITEMS
 };
 
diff -puN mm/vmstat.c~tlb-vmstats mm/vmstat.c
--- linux.git/mm/vmstat.c~tlb-vmstats	2013-07-16 16:41:56.480280525 -0700
+++ linux.git-davehans/mm/vmstat.c	2013-07-16 16:41:56.484280703 -0700
@@ -817,6 +817,11 @@ const char * const vmstat_text[] = {
 	"thp_zero_page_alloc",
 	"thp_zero_page_alloc_failed",
 #endif
+	"nr_tlb_remote_flush",
+	"nr_tlb_remote_flush_received",
+	"nr_tlb_local_flush_all",
+	"nr_tlb_local_flush_one",
+	"nr_tlb_local_flush_one_kernel",
 
 #endif /* CONFIG_VM_EVENTS_COUNTERS */
 };
_

--------------000800050304070906030309--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

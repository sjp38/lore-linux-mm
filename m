Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE2776B02B4
	for <linux-mm@kvack.org>; Wed, 31 May 2017 21:49:07 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id o99so11627430qko.15
        for <linux-mm@kvack.org>; Wed, 31 May 2017 18:49:07 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k28si18355177qtf.298.2017.05.31.18.49.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 May 2017 18:49:07 -0700 (PDT)
Message-ID: <1496281743.29205.96.camel@redhat.com>
Subject: Re: [PATCH v4 3/8] x86/mm: Refactor flush_tlb_mm_range() to merge
 local and remote cases
From: Rik van Riel <riel@redhat.com>
Date: Wed, 31 May 2017 21:49:03 -0400
In-Reply-To: <CALCETrWgR-npO9dgGsiD0DKU5Ovxrf7+8Z88UR5H67mLUAar5g@mail.gmail.com>
References: <cover.1495990440.git.luto@kernel.org>
	 <bcaf9dbdd1216b7fc03ad4870477e9772edecfc9.1495990440.git.luto@kernel.org>
	 <1496101359.29205.73.camel@redhat.com>
	 <CALCETrWgR-npO9dgGsiD0DKU5Ovxrf7+8Z88UR5H67mLUAar5g@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: X86 ML <x86@kernel.org>, Borislav Petkov <bpetkov@suse.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Nadav Amit <namit@vmware.com>, Michal Hocko <mhocko@suse.com>, Arjan van de Ven <arjan@linux.intel.com>

On Wed, 2017-05-31 at 06:58 -0700, Andy Lutomirski wrote:
> On Mon, May 29, 2017 at 4:42 PM, Rik van Riel <riel@redhat.com>
> wrote:
> > On Sun, 2017-05-28 at 10:00 -0700, Andy Lutomirski wrote:
> > 
> > > @@ -292,61 +303,33 @@ static unsigned long
> > > tlb_single_page_flush_ceiling __read_mostly = 33;
> > > A void flush_tlb_mm_range(struct mm_struct *mm, unsigned long
> > > start,
> > > A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A unsigned long end, unsigned long
> > > vmflag)
> > > A {
> > > -A A A A A unsigned long addr;
> > > -A A A A A struct flush_tlb_info info;
> > > -A A A A A /* do a global flush by default */
> > > -A A A A A unsigned long base_pages_to_flush = TLB_FLUSH_ALL;
> > > -
> > > -A A A A A preempt_disable();
> > > +A A A A A int cpu;
> > > 
> > > -A A A A A if ((end != TLB_FLUSH_ALL) && !(vmflag & VM_HUGETLB))
> > > -A A A A A A A A A A A A A base_pages_to_flush = (end - start) >> PAGE_SHIFT;
> > > -A A A A A if (base_pages_to_flush > tlb_single_page_flush_ceiling)
> > > -A A A A A A A A A A A A A base_pages_to_flush = TLB_FLUSH_ALL;
> > > -
> > > -A A A A A if (current->active_mm != mm) {
> > > -A A A A A A A A A A A A A /* Synchronize with switch_mm. */
> > > -A A A A A A A A A A A A A smp_mb();
> > > -
> > > -A A A A A A A A A A A A A goto out;
> > > -A A A A A }
> > > -
> > > -A A A A A if (this_cpu_read(cpu_tlbstate.state) != TLBSTATE_OK) {
> > > -A A A A A A A A A A A A A leave_mm(smp_processor_id());
> > > +A A A A A struct flush_tlb_info info = {
> > > +A A A A A A A A A A A A A .mm = mm,
> > > +A A A A A };
> > > 
> > > -A A A A A A A A A A A A A /* Synchronize with switch_mm. */
> > > -A A A A A A A A A A A A A smp_mb();
> > > +A A A A A cpu = get_cpu();
> > > 
> > > -A A A A A A A A A A A A A goto out;
> > > -A A A A A }
> > > +A A A A A /* Synchronize with switch_mm. */
> > > +A A A A A smp_mb();
> > > 
> > > -A A A A A /*
> > > -A A A A A A * Both branches below are implicit full barriers (MOV to
> > > CR
> > > or
> > > -A A A A A A * INVLPG) that synchronize with switch_mm.
> > > -A A A A A A */
> > > -A A A A A if (base_pages_to_flush == TLB_FLUSH_ALL) {
> > > -A A A A A A A A A A A A A count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ALL);
> > > -A A A A A A A A A A A A A local_flush_tlb();
> > > +A A A A A /* Should we flush just the requested range? */
> > > +A A A A A if ((end != TLB_FLUSH_ALL) &&
> > > +A A A A A A A A A !(vmflag & VM_HUGETLB) &&
> > > +A A A A A A A A A ((end - start) >> PAGE_SHIFT) <=
> > > tlb_single_page_flush_ceiling) {
> > > +A A A A A A A A A A A A A info.start = start;
> > > +A A A A A A A A A A A A A info.end = end;
> > > A A A A A A } else {
> > > -A A A A A A A A A A A A A /* flush range by one by one 'invlpg' */
> > > -A A A A A A A A A A A A A for (addr = start; addr < end;A A addr +=
> > > PAGE_SIZE) {
> > > -A A A A A A A A A A A A A A A A A A A A A count_vm_tlb_event(NR_TLB_LOCAL_FLUSH_ONE);
> > > -A A A A A A A A A A A A A A A A A A A A A __flush_tlb_single(addr);
> > > -A A A A A A A A A A A A A }
> > > -A A A A A }
> > > -A A A A A trace_tlb_flush(TLB_LOCAL_MM_SHOOTDOWN,
> > > base_pages_to_flush);
> > > -out:
> > > -A A A A A info.mm = mm;
> > > -A A A A A if (base_pages_to_flush == TLB_FLUSH_ALL) {
> > > A A A A A A A A A A A A A A info.start = 0UL;
> > > A A A A A A A A A A A A A A info.end = TLB_FLUSH_ALL;
> > > -A A A A A } else {
> > > -A A A A A A A A A A A A A info.start = start;
> > > -A A A A A A A A A A A A A info.end = end;
> > > A A A A A A }
> > > -A A A A A if (cpumask_any_but(mm_cpumask(mm), smp_processor_id()) <
> > > nr_cpu_ids)
> > > +
> > > +A A A A A if (mm == current->active_mm)
> > > +A A A A A A A A A A A A A flush_tlb_func_local(&info,
> > > TLB_LOCAL_MM_SHOOTDOWN);
> > 
> > It looks like this could cause flush_tlb_func_local to be
> > called over and over again even while cpu_tlbstate.state
> > equals TLBSTATE_LAZY, because active_mm is not changed by
> > leave_mm.
> > 
> > Do you want to also test cpu_tlbstate.state != TLBSTATE_OK
> > here, to ensure flush_tlb_func_local is only called when
> > necessary?
> > 
> 
> I don't think that would buy us much.A A func_tlb_flush_local will be
> called, but it will call flush_tlb_func_common(), which will notice
> that we're lazy and call leave_mm() instead of flushing.A A leave_mm()
> won't do anything if we're already using init_mm.A A The overall effect
> should be the same as it was before this patch, although it's a bit
> more indirect with the patch applied.

OK, fair enough.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

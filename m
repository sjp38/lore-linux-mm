Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 46C076B0031
	for <linux-mm@kvack.org>; Tue, 15 Jul 2014 16:48:04 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so4277970pdj.8
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 13:48:03 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id qy9si5874607pab.205.2014.07.15.13.48.02
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Jul 2014 13:48:03 -0700 (PDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so1516682pad.39
        for <linux-mm@kvack.org>; Tue, 15 Jul 2014 13:48:02 -0700 (PDT)
Date: Tue, 15 Jul 2014 13:46:26 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: PROBLEM: repeated remap_file_pages on tmpfs triggers bug on
 process exit
In-Reply-To: <20140715115456.32886E00A3@blue.fi.intel.com>
Message-ID: <alpine.LSU.2.11.1407151346000.3571@eggly.anvils>
References: <748020aaaf5c5c2924a16232313e0175.squirrel@webmail.tu-dortmund.de> <alpine.LSU.2.11.1407141209160.17242@eggly.anvils> <CALYGNiM9Fu9-i7hXMQNTUP69RfydN+2NqO29wZYd+4Gn25GbCQ@mail.gmail.com> <20140715105547.C4832E00A3@blue.fi.intel.com>
 <CALYGNiM3tQUCvSPxPbum5jkhNOPeKpAVL=x3ggFmZH-QaqULcA@mail.gmail.com> <20140715115456.32886E00A3@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Hugh Dickins <hughd@google.com>, Ingo Korb <ingo.korb@tu-dortmund.de>, Ning Qu <quning@google.com>, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, 15 Jul 2014, Kirill A. Shutemov wrote:
> Konstantin Khlebnikov wrote:
> > On Tue, Jul 15, 2014 at 2:55 PM, Kirill A. Shutemov
> > <kirill.shutemov@linux.intel.com> wrote:
> > > Konstantin Khlebnikov wrote:
> > >> It seems boundng logic in do_fault_around is wrong:
> > >>
> > >> start_addr = max(address & fault_around_mask(), vma->vm_start);
> > >> off = ((address - start_addr) >> PAGE_SHIFT) & (PTRS_PER_PTE - 1);
> > >> pte -= off;
> > >> pgoff -= off;
> > >>
> > >> Ok, off  <= 511, but it might be bigger than pte offset in pte table.
> > >
> > > I don't see how it possible: fault_around_mask() cannot be more than 0x1ff000
> > > (x86-64, fault_around_bytes == 2M). It means start_addr will be aligned to 2M
> > > boundary in this case which is start of the page table pte belong to.
> > >
> > > Do I miss something?
> > 
> > Nope, you're right. This fixes kernel crash but not the original problem.
> > 
> > Problem is caused by calling do_fault_around for _non-linear_ faiult.
> > In this case pgoff is shifted and might become negative during calculation.
> > I'll send another patch.
> 
> I've got to the same conclusion. My patch is below.

Many thanks to Ingo and Konstantin and Kirill for nailing this.
So now we have two not-quite-identical patches to fix it.
I feel I have to judge a beauty contest.

I think my slight preference is for Kirill's below, because it has
a better description (mentions "kernel BUG at mm/filemap.c:202!" and
Ccs stable) and uses the familiar VM_NONLINEAR flag rather than the
never-heard-of-before-and-otherwise-unused FAULT_FLAG_NONLINEAR.

But please please add a credit to Ingo, who made the breakthrough for
us, and to Konstantin who analysed what was going on.  Ingo, this is
not quite the version you tested...

... ah, forget it, Andrew has just now gone for Konstantin's,
adding in more info from Kirill's: that's fine.

Thanks all,
Hugh

> 
> From dd761b693cd06c649499e913713ae5bc7c029f6e Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 15 Jul 2014 14:40:02 +0300
> Subject: [PATCH] mm: avoid do_fault_around() on non-linear mappings
> 
> Originally, I've wrongly assumed that non-linear mapping are always
> populated at least with pte_file() entries there, so !pte_none() check
> will catch them. It's not always the case: we can get there from
> __mm_populte in remap_file_pages() and pte will be clear.

__mm_populate

> 
> Let's put explicit check for non-linear mapping.
> 
> This is a root cause of recent "kernel BUG at mm/filemap.c:202!".
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: stable@vger.kernel.org # 3.15+
> ---
>  mm/memory.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index d67fd9fcf1f2..440ad48266d6 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2882,7 +2882,8 @@ static int do_read_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>  	 * if page by the offset is not ready to be mapped (cold cache or
>  	 * something).
>  	 */
> -	if (vma->vm_ops->map_pages && fault_around_pages() > 1) {
> +	if (vma->vm_ops->map_pages && fault_around_pages() > 1 &&
> +			!(vma->vm_flags & VM_NONLINEAR)) {
>  		pte = pte_offset_map_lock(mm, pmd, address, &ptl);
>  		do_fault_around(vma, address, pte, pgoff, flags);
>  		if (!pte_same(*pte, orig_pte))
> -- 
> 2.0.1
> 
> -- 
>  Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

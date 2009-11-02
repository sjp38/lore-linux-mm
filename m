Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 37BD96B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 01:03:57 -0500 (EST)
Received: by yxe10 with SMTP id 10so4626822yxe.12
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 22:03:55 -0800 (PST)
Date: Mon, 2 Nov 2009 15:01:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: OOM killer, page fault
Message-Id: <20091102150110.74f8a601.minchan.kim@barrios-desktop>
In-Reply-To: <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at>
	<20091102005218.8352.A69D9226@jp.fujitsu.com>
	<20091102135640.93de7c2a.minchan.kim@barrios-desktop>
	<20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Norbert Preining <preining@logic.at>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009 14:02:16 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Mon, 2 Nov 2009 13:56:40 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > On Mon,  2 Nov 2009 13:24:06 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > Hi,
> > > 
> > > (Cc to linux-mm)
> > > 
> > > Wow, this is very strange log.
> > > 
> > > > Dear all,
> > > > 
> > > > (please Cc)
> > > > 
> > > > With 2.6.32-rc5 I got that one:
> > > > [13832.210068] Xorg invoked oom-killer: gfp_mask=0x0, order=0, oom_adj=0
> > > 
> > > order = 0
> > 
> > I think this problem results from 'gfp_mask = 0x0'.
> > Is it possible?
> > 
> > If it isn't H/W problem, Who passes gfp_mask with 0x0?
> > It's culpit. 
> > 
> > Could you add BUG_ON(gfp_mask == 0x0) in __alloc_pages_nodemask's head?
> > 
> 
> Maybe some code returns VM_FAULT_OOM by mistake and pagefault_oom_killer()
> is called. digging mm/memory.c is necessary...
> 
> I wonder why...now is this code
> ===
> static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
>                 unsigned long address, pte_t *page_table, pmd_t *pmd,
>                 unsigned int flags, pte_t orig_pte)
> {
>         pgoff_t pgoff;
> 
>         flags |= FAULT_FLAG_NONLINEAR;
> 
> 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
>                 return 0;
> 
>         if (unlikely(!(vma->vm_flags & VM_NONLINEAR))) {
>                 /*
>                  * Page table corrupted: show pte and kill process.
>                  */
>                 print_bad_pte(vma, address, orig_pte, NULL);
>                 return VM_FAULT_OOM;
>         }
> 
>         pgoff = pte_to_pgoff(orig_pte);
>         return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
> }
> ==
> Then, OOM...is this really OOM ?

It seems that the goal is to kill process by OOM trick as comment said.

I found It results from Hugh's commit 65500d234e74fc4e8f18e1a429bc24e51e75de4a.
I think it's not a real OOM. 

BTW, If it is culpit in this case, print_bad_pte should have remained any log. :)

> 
> Thanks,
> -Kame
> 


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

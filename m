Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id ED1D86B004D
	for <linux-mm@kvack.org>; Mon,  2 Nov 2009 01:37:41 -0500 (EST)
Received: by ywh26 with SMTP id 26so4622616ywh.12
        for <linux-mm@kvack.org>; Sun, 01 Nov 2009 22:37:40 -0800 (PST)
Date: Mon, 2 Nov 2009 15:35:00 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: OOM killer, page fault
Message-Id: <20091102153500.78d4f862.minchan.kim@barrios-desktop>
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
Cc: Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Norbert Preining <preining@logic.at>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>
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

I suspect GPU drivers related to X.
It seems many of them returs VM_FAULT_OOM.

If it happens by file map fault, following debug patch can show the culpit.

Norbert, Could you apply this patch and test again?
If you can get the address, you can find function symbol with System.map.


diff --git a/mm/memory.c b/mm/memory.c
index 7e91b5f..47e4b15 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2713,7 +2713,11 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
        vmf.page = NULL;
 
        ret = vma->vm_ops->fault(vma, &vmf);
-       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
+       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
+               printk(KERN_DEBUG "vma->vm_ops->fault : 0x%lx\n", vma->vm_ops->fault);
+               WARN_ON(1);
+               
+       }
                return ret;
 
        if (unlikely(PageHWPoison(vmf.page))) {





-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

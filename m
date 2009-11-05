Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0E3886B0044
	for <linux-mm@kvack.org>; Thu,  5 Nov 2009 15:40:08 -0500 (EST)
Received: from list by lo.gmane.org with local (Exim 4.50)
	id 1N697k-0007Lv-FB
	for linux-mm@kvack.org; Thu, 05 Nov 2009 21:40:04 +0100
Received: from office.weekscomputing.com ([89.105.122.66])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Nov 2009 21:40:04 +0100
Received: from jody+lkml by office.weekscomputing.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Thu, 05 Nov 2009 21:40:04 +0100
From: Jody Belka <jody+lkml@jj79.org>
Subject: Re: OOM killer, page fault
Date: Thu, 5 Nov 2009 20:37:56 +0000 (UTC)
Message-ID: <loom.20091105T213323-393@post.gmane.org>
References: <20091030063216.GA30712@gamma.logic.tuwien.ac.at> <20091102005218.8352.A69D9226@jp.fujitsu.com> <20091102135640.93de7c2a.minchan.kim@barrios-desktop> <28c262360911012300h4535118ewd65238c746b91a52@mail.gmail.com> <20091102155543.E60E.A69D9226@jp.fujitsu.com> <20091102140216.02567ff8.kamezawa.hiroyu@jp.fujitsu.com> <20091102141917.GJ2116@gamma.logic.tuwien.ac.at> <28c262360911020640k3f9dfcdct2cac6cc1d193144d@mail.gmail.com> <20091105132109.GA12676@gamma.logic.tuwien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Norbert Preining <preining <at> logic.at> writes:
> Don't ask me why, please, and I don't have a serial/net console so that
> I can tell you more, but the booting hangs badly at:

<snip>

> 
> > diff --git a/mm/memory.c b/mm/memory.c
> > index 7e91b5f..47e4b15 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2713,7 +2713,11 @@ static int __do_fault(struct mm_struct *mm,
> > struct vm_area_struct *vma,
> >        vmf.page = NULL;
> > 
> >        ret = vma->vm_ops->fault(vma, &vmf);
> > -       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> > +       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))) {
> > +               printk(KERN_DEBUG "vma->vm_ops->fault : 0x%lx\n",
> > vma->vm_ops->fault);
> > +               WARN_ON(1);
> > +
> > +       }
> >                return ret;
> > 
> >        if (unlikely(PageHWPoison(vmf.page))) {
> 

Erm, could it not be due to the "return ret;" line being moved outside of the
if(), so that it always executes?


J

ps, sending this through gmane, don't know if it'll keep cc's or not, so
apologies if not. please cc me on any replies

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

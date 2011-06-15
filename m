Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id A64E36B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 05:03:44 -0400 (EDT)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5F90aDR006770
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 03:00:36 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5F93GNL162718
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 03:03:16 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5F333uV014621
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 21:03:06 -0600
Date: Wed, 15 Jun 2011 14:25:15 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
Message-ID: <20110615085515.GE4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
 <20110613170020.GA27137@redhat.com>
 <20110614123530.GC4952@linux.vnet.ibm.com>
 <20110614142023.GA5139@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110614142023.GA5139@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

> > > > +
> > > > +	/* Read the page with vaddr into memory */
> > > > +	ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> > >
> > > Sorry if this was already discussed... But why we are using FOLL_WRITE here?
> > > We are not going to write into this page, and this provokes the unnecessary
> > > cow, no?
> >
> > Yes, We are not going to write to the page returned by get_user_pages
> > but a copy of that page.
> 
> Yes I see. But the page returned by get_user_pages(write => 1) is already
> a cow'ed copy (this mapping should be read-only).
> 
> > The idea was if we cow the page then we dont
> > need to cow it at the replace_page time
> 
> Yes, replace_page() shouldn't cow.
> 
> > and since get_user_pages knows
> > the right way to cow the page, we dont have to write another routine to
> > cow the page.
> 
> Confused. write_opcode() allocs another page and does memcpy. This is
> correct, but I don't understand the first cow.
> 

we decided on get_user_pages(FOLL_WRITE|FOLL_FORCE) based on discussions
in these threads https://lkml.org/lkml/2010/4/23/327 and
https://lkml.org/lkml/2010/5/12/119

Summary of those two sub-threads as I understand was to have
get_user_pages do the "real" cow for us.

If I understand correctly, your concern is on the extra overhead added
by the get_user_pages. Other than that is there any side-effect of we
forcing the cow through get_user_pages.

> > I am still not clear on your concern.
> 
> Probably I missed something... but could you please explain why we can't
> 
> 	- ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 1, 1, &old_page, &vma);
> 	+ ret = get_user_pages(tsk, tsk->mm, vaddr, 1, 0, 0, &old_page, &vma);
> 
> ?

I tried the code with this change and it works for regular cases.
I am not sure if it affects cases where programs do mprotect 
So I am okay to not force cow through get_user_pages.

> 
> > > Also. This is called under down_read(mmap_sem), can't we race with
> > > access_process_vm() modifying the same memory?
> >
> > Yes, we could be racing with access_process_vm on the same memory.
> >
> > Do we have any other option other than making write_opcode/read_opcode
> > being called under down_write(mmap_sem)?
> 
> I dunno. Probably we can simply ignore this issue, there are other ways
> to modify this memory.
> 

Okay.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

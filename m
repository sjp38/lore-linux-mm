Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D5F66B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 04:14:07 -0400 (EDT)
Date: Mon, 30 May 2011 10:14:00 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] mm: Fix boot crash in mm_alloc()
Message-ID: <20110530081400.GK27557@elte.hu>
References: <20110529072256.GA20983@elte.hu>
 <BANLkTikHejgEyz9LfJ962Bu89vn1cBP+WQ@mail.gmail.com>
 <BANLkTimqhkiBSArm7n0_9FD+LW6hWBWxFA@mail.gmail.com>
 <BANLkTin8yxh=Bjwf7AEyzPCoghnYO2brLQ@mail.gmail.com>
 <4DE2EEFB.1080803@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DE2EEFB.1080803@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org, tglx@linutronix.de, linux-kernel@vger.kernel.org, a.p.zijlstra@chello.nl, linux-mm@kvack.org


* KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> (2011/05/30 3:43), Linus Torvalds wrote:
> > On Sun, May 29, 2011 at 10:19 AM, Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:
> >>
> >> STILL TOTALLY UNTESTED! The fixes were just from eyeballing it a bit
> >> more, not from any actual testing.
> > 
> > Ok, I eyeballed it some more, and tested both the OFFSTACK and ONSTACK
> > case, and decided that I had better commit it now rather than wait any
> > later since I'll do the -rc1 later today, and will be on an airplane
> > most of tomorrow.
> > 
> > The exact placement of the cpu_vm_mask_var is up for grabs. For
> > example, I started thinking that it might be better to put it *after*
> > the mm_context_t, since for the non-OFFSTACK case it's generally
> > touched at the beginning rather than the end.
> > 
> > And the actual change to make the mm_cachep kmem_cache_create() use a
> > variable-sized allocation for the OFFSTACK case is similarly left as
> > an exercise for the the reader. So effectively, this reverts a lot of
> > de03c72cfce5, but does so in a way that should make very it easy to
> > get back to where KOSAKI was aiming for.
> > 
> > Whatever. I was hoping to get comments on it, but I think I need to
> > rather push it out to get tested and public than wait any longer. The
> > patch *looks* fine, tests ok on my machine, and removes more lines
> > than it adds despite the new big comment.
> 
> Hi
> 
> Thank you Linus and I'm sorry for bother you and guys. So, if I 
> understand this thread correctly, rest my homework is 1) make 
> cpumask_allocation variable size 2) remove NR_CPUS bit fill/copy 
> from fork/exec path. Right?
> 
> I think (2) is big matter than (1). NR_CPUS(=4096) bits copy easily 
> screw up cache behavior. Anyway, will do. Thank you!

I think the first task would be to double check that the code in 
3.0-rc1 is indeed correct! :-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

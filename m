In-reply-to: <1191501626.22357.14.camel@twins> (message from Peter Zijlstra on
	Thu, 04 Oct 2007 14:40:26 +0200)
Subject: Re: [PATCH] remove throttle_vm_writeout()
References: <E1IdPla-0002Bd-00@dorka.pomaz.szeredi.hu> <1191501626.22357.14.camel@twins>
Message-Id: <E1IdQJn-0002Cv-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 04 Oct 2007 15:00:43 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, akpm@linux-foundation.org, wfg@mail.ustc.edu.cn, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> > 1) File backed pages -> file
> > 
> >   dirty + writeback count remains constant
> > 
> > 2) Anonymous pages -> swap
> > 
> >   writeback count increases, dirty balancing will hold back file
> >   writeback in favor of swap
> > 
> > So the real question is: does case 2 need rate limiting, or is it OK
> > to let the device queue fill with swap pages as fast as possible?
> 
> > Because balance_dirty_pages() maintains:
> 
>  nr_dirty + nr_unstable + nr_writeback < 
> 	total_dirty + nr_cpus * ratelimit_pages
> 
> throttle_vm_writeout() _should_ not deadlock on that, unless you're
> caught in the error term: nr_cpus * ratelimit_pages. 

And it does get caught on that in small memory machines.  This
deadlock is easily reproducable on a 32MB UML instance.  I haven't yet
tested with the per-bdi patches, but I don't think they make a
difference in this case.

> Which can only happen when it is larger than 10% of dirty_thresh.
> 
> Which is even more unlikely since it doesn't account nr_dirty (as I
> think it should).

I think nr_dirty is totally irrelevant.  Since we don't care about
case 1), and in case 2) nr_dirty doesn't play any role.

> As for 2), yes I think having a limit on the total number of pages in
> flight is a good thing.

Why?

> But that said, there might be better ways to do that.

Sure, if we do need to globally limit the number of under-writeback
pages, then I think we need to do it independently of the dirty
accounting.

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

In-reply-to: <1200655438.5920.21.camel@twins> (message from Peter Zijlstra on
	Fri, 18 Jan 2008 12:23:58 +0100)
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped
	files
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <12006091211208-git-send-email-salikhmetov@gmail.com>
	 <E1JFnsg-0008UU-LU@pomaz-ex.szeredi.hu> <1200651337.5920.9.camel@twins>
	 <E1JFobo-00009i-Dk@pomaz-ex.szeredi.hu> <1200654050.5920.14.camel@twins>
	 <E1JFpDg-0000F6-12@pomaz-ex.szeredi.hu> <1200655438.5920.21.camel@twins>
Message-Id: <E1JFpW4-0000Hc-Sp@pomaz-ex.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Fri, 18 Jan 2008 12:36:08 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: miklos@szeredi.hu, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, torvalds@linux-foundation.org, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

> Possibly, I didn't see a quick way to break that iteration.
> >From a quick glance at prio_tree.c the iterator isn't valid anymore
> after releasing i_mmap_lock. Fixing that would be,.. 'fun'.

Maybe i_mmap_lock isn't needed at all, since msync holds mmap_sem,
which protects the prio tree as well, no?

> I also realized I forgot to copy/paste the prio_tree_iter declaration
> and ought to make all these functions static.
> 
> But for a quick draft it conveys the idea pretty well, I guess :-)

Yes :)

There could also be nasty performance corner cases, like having a huge
file mapped thousands of times, and having only a couple of pages
dirtied between MS_ASYNC invocations.  Then most of that page table
walking would be just unnecessary overhead.

There's something to be said for walking only the dirty pages, and
doing page_mkclean on them, even if in some cases that would be
slower.

But I have a strong feeling of deja vu, and last time it ended with
Andrew not liking the whole thing...

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

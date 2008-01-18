Received: by wa-out-1112.google.com with SMTP id m33so1896673wag.8
        for <linux-mm@kvack.org>; Fri, 18 Jan 2008 11:58:52 -0800 (PST)
Message-ID: <4df4ef0c0801181158s3f783beaqead3d7049d4d3fa7@mail.gmail.com>
Date: Fri, 18 Jan 2008 22:58:52 +0300
From: "Anton Salikhmetov" <salikhmetov@gmail.com>
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped files
In-Reply-To: <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <12006091182260-git-send-email-salikhmetov@gmail.com>
	 <1200651337.5920.9.camel@twins> <1200651958.5920.12.camel@twins>
	 <alpine.LFD.1.00.0801180949040.2957@woody.linux-foundation.org>
	 <E1JFvgx-0000zz-2C@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181033580.2957@woody.linux-foundation.org>
	 <E1JFwOz-00019k-Uo@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181106340.2957@woody.linux-foundation.org>
	 <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu>
	 <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, staubach@redhat.com, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

2008/1/18, Linus Torvalds <torvalds@linux-foundation.org>:
>
>
> On Fri, 18 Jan 2008, Miklos Szeredi wrote:
> >
> > What I'm saying is that the times could be left un-updated for a long
> > time if program doesn't do munmap() or msync(MS_SYNC) for a long time.
>
> Sure.
>
> But in those circumstances, the programmer cannot depend on the mtime
> *anyway* (because there is no synchronization), so what's the downside?
>
> Let's face it, there's exactly three possible solutions:
>
>  - the insane one: trap EVERY SINGLE instruction that does a write to the
>    page, and update mtime each and every time.
>
>    This one is so obviously STUPID that it's not even worth discussing
>    further, except to say that "yes, there is an 'exact' algorithm, but
>    no, we are never EVER going to use it".
>
>  - the non-exact solutions that don't give you mtime updates every time
>    a write to the page happens, but give *some* guarantees for things that
>    will update it.
>
>    This is the one I think we can do, and the only things a programmer can
>    impact using it is "msync()" and "munmap()", since no other operations
>    really have any thing to do with it in a programmer-visible way (ie a
>    normal "sync" operation may happen in the background and has no
>    progam-relevant timing information)
>
>    Other things *may* or may not update mtime (some filesystems - take
>    most networked one as an example - will *always* update mtime on the
>    server on writeback, so we cannot ever guarantee that nothing but
>    msync/munmap does so), but at least we'll have a minimum set of things
>    that people can depend on.
>
>  - the "we don't care at all solutions".
>
>    mmap(MAP_WRITE) doesn't really update times reliably after the write
>    has happened (but might do it *before* - maybe the mmap() itself does).
>
> Those are the three choices, I think. We currently approximate #3. We
> *can* do #2 (and there are various flavors of it). And even *aiming* for
> #1 is totally insane and stupid.

The current solution doesn't hit the performance at all when compared to
the competitor POSIX-compliant systems. It is faster and does even more
than the POSIX standard requires.

Please see the test results I've sent into the thread "-v6 0/2":

http://lkml.org/lkml/2008/1/18/447

I guess, the current solution is ready to use.

>
>                         Linus
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 28 Sep 2007 21:30:18 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [patch] splice mmap_sem deadlock
Message-ID: <20070928193017.GC11717@kernel.dk>
References: <20070928160035.GD12538@wotan.suse.de> <20070928173144.GA11717@kernel.dk> <alpine.LFD.0.999.0709281109290.3579@woody.linux-foundation.org> <20070928181513.GB11717@kernel.dk> <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709281120220.3579@woody.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 28 2007, Linus Torvalds wrote:
> 
> 
> On Fri, 28 Sep 2007, Jens Axboe wrote:
> > 
> > It actually looks like it was buggy from day 1 there, unfortunately. The
> > code is from april 2006 and used down_read() even then.
> 
> I was thinking of my *original* patch from way back when. But that one 
> didn't actually do any of that stuff so no, it wasn't from there.

Right, vmsplice() wasn't part of the original stuff.

> > So can you apply Nicks patch
> 
> I don't even have it, I only have a quoted-corrupted version of it. I 
> wasn't originally cc'd.

Hmm, part of me doesn't like this patch, since we now end up beating on
mmap_sem for each part of the vec. It's fine for a stable patch, but how
about

- prefaulting the iovec
- using __get_user()
- only dropping/regrabbing the lock if we have to fault

?

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

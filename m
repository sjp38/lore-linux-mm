Date: Thu, 31 Jul 2008 09:34:44 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch v3] splice: fix race with page invalidation
In-Reply-To: <20080731061201.GA7156@shareable.org>
Message-ID: <alpine.LFD.1.10.0807310925360.3277@nehalem.linux-foundation.org>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 31 Jul 2008, Jamie Lokier wrote:
> 
> Having implemented an equivalent zero-copy thing in userspace, I can
> confidently say it's not fundamental at all.

Oh yes it is.

Doing it in user space is _trivial_, because you control everything, and 
there are no barriers.

> What is fundamental is that you either (a) treat sendfile as an async
> operation, and get a notification when it's finished with the data,
> just like any other async operation

Umm. And that's exactly what I *described*.

But it's trivial to do inside one program (either all in user space, or 
all in kernel space).

It's very difficult indeed to do across two totally different domains.

Have you _looked_ at the complexities of async IO in UNIX? They are 
horrible. The overhead to even just _track_ the notifiers basically undoes 
all relevant optimizations for doing zero-copy.

IOW, AIO is useful not because of zero-copy, but because it allows 
_overlapping_ IO. Anybody who confuses the two is seriously misguided.

>			, or (b) while sendfile claims those
> pages, they are marked COW.

.. and this one shows that you have no clue about performance of a memcpy.

Once you do that COW, you're actually MUCH BETTER OFF just copying.

Really.

Copying a page is much cheaper than doing COW on it. Doing a "write()" 
really isn't that expensive. People think that memory is slow, but memory 
isn't all that slow, and caches work really well. Yes, memory is slow 
compared to a few reference count increments, but memory is absolutely 
*not* slow when compared to the overhead of TLB invalidates across CPUs 
etc.

So don't do it. If you think you need it, you should not be using 
zero-copy in the first place.

In other words, let me repeat:

 - use splice() when you *understand* that it's just taking a refcount and 
   you don't care.

 - use read()/write() when you can't be bothered.

There's nothing wrong with read/write. The _normal_ situation should be 
that 99.9% of all IO is done using the regular interfaces. Splice() (and 
sendpage() before it) is a special case. You should be using splice if you 
have a DVR and you can do all the DMA from the tuner card into buffers 
that you can then split up and send off to show real-time at the same time 
as you copy them to disk.

THAT is when zero-copy is useful. If you think you need to play games with 
async notifiers, you're already off the deep end.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

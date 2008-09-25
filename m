Date: Thu, 25 Sep 2008 02:15:57 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] hugetlbfs: add llseek method
Message-ID: <20080925011557.GA17155@csn.ul.ie>
References: <20080908174634.GC19912@lst.de> <20080922185624.GA26551@csn.ul.ie> <20080924190043.GA2312@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080924190043.GA2312@lst.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: viro@zeniv.linux.org.uk, linux-fsdevel@vger.kernl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (24/09/08 21:00), Christoph Hellwig didst pronounce:
> On Mon, Sep 22, 2008 at 07:56:25PM +0100, Mel Gorman wrote:
> > On (08/09/08 19:46), Christoph Hellwig didst pronounce:
> > > Hugetlbfs currently doesn't set a llseek method for regular files, which
> > > means it will fall back to default_llseek.  This means no one can seek
> > > beyond 2 Gigabytes.
> > > 
> > 
> > I took another look at this as it was pointed out to me by apw that this
> > might be a SEEK_CUR vs SEEK_SET thing and also whether lseek() was the
> > key. To use lseek though, the large file defines had to be used or it failed
> > whether your patch was applied or not. The error as you'd expect is lseek()
> > complaining that the type was too small.
> > 
> > At the face of it, the patch seems sensible but it works whether it is set
> > or not so clearly I'm still missing something. The second test I tried is
> > below. In the unlikely event it makes a difference, I was testing on qemu
> > for i386.
> 
> Sorry, my original description was complete bullsh*t ;-)  The problem
> is the inverse of what I wrote.  With default_llseek you can seek
> everywhere even if that's outside of the fs limit.  This should give you
> quite interesting results if you seek outside of what we can represent
> page->index on 32bit platforms.
> 

Ahh right. To be honest, I can't even tell what the effect is for sure. In
ordinary circumstances, I expect it either wraps or zeros are returned when
real data should be there.

ftruncate can create a file larger than 4GB of course. However, as hugetlbfs
doesn't support write and mmap64 does not map beyond the 4GB boundary,
I couldn't create a proper test file. It means I can't verify if the zeros
returned after seek above the 4GB boundary are garbage zeros or real zeros
(seek above 4GB is allowed with or without the patch, is that expected?).
The patch may fix a problem in theory but I can't prove it.

With your filesystem hat on, I'm happy to accept this is a problem in theory
and should be applied in case someone adds write() support in the future
and gets an unexpected kick in the pants due to lseek(). I'll ack a patch
with a fixed-up description and will run the libhugetlbfs regression tests
with the patch appliued just to make sure there are no side-effects.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 5BAD16B002B
	for <linux-mm@kvack.org>; Sat, 15 Dec 2012 22:59:54 -0500 (EST)
Date: Sun, 16 Dec 2012 03:59:53 +0000
From: Eric Wong <normalperson@yhbt.net>
Subject: Re: [PATCH] fadvise: perform WILLNEED readahead in a workqueue
Message-ID: <20121216035953.GA30689@dcvr.yhbt.net>
References: <20121215005448.GA7698@dcvr.yhbt.net>
 <20121216024520.GH9806@dastard>
 <20121216030442.GA28172@dcvr.yhbt.net>
 <20121216033601.GJ9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121216033601.GJ9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Dave Chinner <david@fromorbit.com> wrote:
> On Sun, Dec 16, 2012 at 03:04:42AM +0000, Eric Wong wrote:
> > Dave Chinner <david@fromorbit.com> wrote:
> > > On Sat, Dec 15, 2012 at 12:54:48AM +0000, Eric Wong wrote:
> > > > 
> > > >  Before: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <2.484832>
> > > >   After: fadvise64(3, 0, 0, POSIX_FADV_WILLNEED) = 0 <0.000061>
> > > 
> > > You've basically asked fadvise() to readahead the entire file if it
> > > can. That means it is likely to issue enough readahead to fill the
> > > IO queue, and that's where all the latency is coming from. If all
> > > you are trying to do is reduce the latency of the first read, then
> > > only readahead the initial range that you are going to need to read...
> > 
> > Yes, I do want to read the whole file, eventually.  So I want to put
> > the file into the page cache ASAP and allow the disk to spin down.
> 
> Issuing readahead is not going to speed up the first read. Either
> you will spend more time issuing all the readahead, or you block
> waiting for the first read to complete. And the way you are issuing
> readahead does not guarantee the entire file is brought into the
> page cache....

I'm not relying on readahead to speed up the first read.

By using fadvise/readahead, I want a _best-effort_ attempt to
keep the file in cache.

> > But I also want the first read() to be fast.
> 
> You can't have a pony, sorry.

I want the first read() to happen sooner than it would under current
fadvise.  If it's slightly slower that w/o fadvise, that's fine.
The 1-2s slower with current fadvise is what bothers me.

> > > Also, Pushing readahead off to a workqueue potentially allows
> > > someone to DOS the system because readahead won't ever get throttled
> > > in the syscall context...
> > 
> > Yes, I'm a little worried about this, too.
> > Perhaps squashing something like the following will work?
> > 
> > diff --git a/mm/readahead.c b/mm/readahead.c
> > index 56a80a9..51dc58e 100644
> > --- a/mm/readahead.c
> > +++ b/mm/readahead.c
> > @@ -246,16 +246,18 @@ void wq_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  {
> >  	struct wq_ra_req *req;
> >  
> > +	nr_to_read = max_sane_readahead(nr_to_read);
> > +	if (!nr_to_read)
> > +		goto skip_ra;
> 
> You do realise that anything you read ahead will be accounted as
> inactive pages, so nr_to_read doesn't decrease at all as you fill
> memory with readahead pages...

Ah, ok, I'll see if I can rework it.

> >  	req = kzalloc(sizeof(*req), GFP_ATOMIC);
> 
> GFP_ATOMIC? Really?

Sorry, I'm really new at this.

> In reality, I think you are looking in the wrong place to fix your
> "first read" latency problem. No matter what you do, there is going
> to be IO latency on the first read. And readahead doesn't guarantee
> that the pages are brought into the page cache (ever heard of
> readahead thrashing?) so the way you are doing your readahead is not
> going to result in you being able to spin the disk down after
> issuing a readahead command...

Right, I want a _best-effort_ readahead (which seems to be what an
advisory interface should offer).

> You've really got two problems - minimal initial latency, and
> reading the file quickly and pinning it in memory until you get
> around to needing it. The first can't be made faster by using
> readahead, and the second can not be guaranteed by using readahead.

Agreed.  I think I overstated the requirements.

I want "less-bad" initial latency than I was getting.

So I don't mind if open()+fadvise()+read() is a couple of milliseconds
slower than just open()+read(), but I do mind if fadvise() takes 1-2
seconds.

> IOWs, readahead is the wrong tool for solving your problems. Minimal
> IO latency from the first read will come from just issuing pread()
> after open(), and ensuring that the file is read quickly and pinned
> in memory can really only be done by allocating RAM in the
> application to hold it until it is needed....

I definitely only want a best-effort method to put a file into memory.
I want the kernel to decide whether or not to cache it.

Thanks for looking at this!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

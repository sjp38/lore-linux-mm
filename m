Date: Thu, 31 Jul 2008 17:29:53 +0400
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [patch v3] splice: fix race with page invalidation
Message-ID: <20080731132953.GB1120@2ka.mipt.ru>
References: <E1KOIYA-0002FG-Rg@pomaz-ex.szeredi.hu> <20080731001131.GA30900@shareable.org> <20080731004214.GA32207@shareable.org> <alpine.LFD.1.10.0807301746500.3277@nehalem.linux-foundation.org> <20080731061201.GA7156@shareable.org> <20080731102612.GA29766@2ka.mipt.ru> <20080731123350.GB16481@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080731123350.GB16481@shareable.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jamie Lokier <jamie@shareable.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Miklos Szeredi <miklos@szeredi.hu>, jens.axboe@oracle.com, akpm@linux-foundation.org, nickpiggin@yahoo.com.au, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 31, 2008 at 01:33:50PM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> This is why marking the pages COW would be better.  Automatic!
> There's no need for a notification, merely letting go of the page
> references - yes, the hardware / TCP acks already do that, no locking
> or anything!  :-)  The last reference is nothing special, it just means
> the next file write/truncate sees the count is 1 and doesn't need to
> COW the page.

It depends... COW can DoS the system: consider attacker who sends a
page, writes there, sends again and so on in lots of threads. Depending
on link capacity eventually COW will eat the whole RAM.

> > There was a linux aio_sendfile() too. Google still knows about its
> > numbers, graphs and so on... :)
> 
> I vaguely remember it's performance didn't seem that good.

<q>
Benchmark of the 100 1MB files transfer (files are in VFS already) using
sync sendfile() against aio_sendfile_path() shows about 10MB/sec
performance win (78 MB/s vs 66-72 MB/s over 1 Gb network, sendfile
sending server is one-way AMD Athlong 64 3500+) for aio_sendfile_path().
</q>

So, it was really better that sync sendfile :)

> One of the problems is you don't really want AIO all the time, just
> when a process would block because the data isn't in cache.  You
> really don't want to be sending *all* ops to worker threads, even
> kernel threads.  And you preferably don't want the AIO interface
> overhead for ops satisfied from cache.

That's how all AIO should work of course. We are getting into a bit of
offtopic, but aio_sendfile() worked that way as long as syslets,
although the former did allocate some structures before trying to send
the data.

> Syslets got some of the way there, and maybe that's why they were
> faster than AIO for some things.  There are user-space hacks which are
> a bit like syslets.  (Bind two processes to the same CPU, process 1
> wakes process 2 just before 1 does a syscall, and puts 2 back to sleep
> if 2 didn't wake and do an atomic op to prove it's awake).  I haven't
> tested their performance, it could suck.

Looks scary :)
Thread allocation in userspace is rather costly operations compared to
syslet threads in kernelspace. But depending on IO pattern this may or
may not be a noticeble factor... It requires testing and numbers.

-- 
	Evgeniy Polyakov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

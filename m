Date: Thu, 27 Apr 2006 13:16:25 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Lockless page cache test results
Message-ID: <20060427111625.GD23137@suse.de>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426185750.GM5002@suse.de> <20060427111937.deeed668.kamezawa.hiroyu@jp.fujitsu.com> <20060427080316.GL9211@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060427080316.GL9211@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 27 2006, Jens Axboe wrote:
> On Thu, Apr 27 2006, KAMEZAWA Hiroyuki wrote:
> > On Wed, 26 Apr 2006 20:57:50 +0200
> > Jens Axboe <axboe@suse.de> wrote:
> > 
> > > On Wed, Apr 26 2006, Jens Axboe wrote:
> > > > We can speedup the lookups with find_get_pages(). The test does 64k max,
> > > > so with luck we should be able to pull 16 pages in at the time. I'll try
> > > > and run such a test. But boy I wish find_get_pages_contig() was there
> > > > for that. I think I'd prefer adding that instead of coding that logic in
> > > > splice, it can get a little tricky.
> > > 
> > > Here's such a run, graphed with the other two. I'll redo the lockless
> > > side as well now, it's only fair to compare with that batching as well.
> > > 
> > 
> > Hi, thank you for interesting tests.
> > 
> > >From user's view, I want to see the comparison among 
> > - splice(file,/dev/null),
> > - mmap+madvise(file,WILLNEED)/write(/dev/null),
> > - read(file)/write(/dev/null)
> > in this 1-4 threads test. 
> > 
> > This will show when splice() can be used effectively.
> 
> Sure, should be easy enough to do.

Added, 1 vs 2/3/4 clients isn't very interesting, so to keep it short
here are numbers for 2 clients to /dev/null and localhost.

Sending to /dev/null

ml370:/data # ./splice-bench -n2 -l10 -a -s -z file
Waiting for clients
Client1 (splice): 19030 MiB/sec (10240MiB in 551 msecs)
Client0 (splice): 18961 MiB/sec (10240MiB in 553 msecs)
Client1 (mmap): 158875 MiB/sec (10240MiB in 66 msecs)
Client0 (mmap): 158875 MiB/sec (10240MiB in 66 msecs)
Client1 (rw): 1691 MiB/sec (10240MiB in 6200 msecs)
Client0 (rw): 1690 MiB/sec (10240MiB in 6201 msecs)

Sending/receiving over lo

ml370:/data # ./splice-bench -n2 -l10 -a -s file
Waiting for clients
Client0 (splice): 3007 MiB/sec (10240MiB in 3486 msecs)
Client1 (splice): 3003 MiB/sec (10240MiB in 3491 msecs)
Client0 (mmap): 555 MiB/sec (8192MiB in 15094 msecs)
Client1 (mmap): 580 MiB/sec (9216MiB in 16257 msecs)
Client0 (rw): 538 MiB/sec (8192MiB in 15573 msecs)
Client1 (rw): 541 MiB/sec (8192MiB in 15498 msecs)

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

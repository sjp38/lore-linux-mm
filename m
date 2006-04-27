Date: Thu, 27 Apr 2006 13:45:06 +0200
From: Jens Axboe <axboe@suse.de>
Subject: Re: Lockless page cache test results
Message-ID: <20060427114506.GE23137@suse.de>
References: <20060426135310.GB5083@suse.de> <20060426095511.0cc7a3f9.akpm@osdl.org> <20060426174235.GC5002@suse.de> <20060426185750.GM5002@suse.de> <20060427111937.deeed668.kamezawa.hiroyu@jp.fujitsu.com> <20060427080316.GL9211@suse.de> <20060427111625.GD23137@suse.de> <20060427204132.2150e5cb.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060427204132.2150e5cb.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, npiggin@suse.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 27 2006, KAMEZAWA Hiroyuki wrote:
> On Thu, 27 Apr 2006 13:16:25 +0200
> Jens Axboe <axboe@suse.de> wrote:
> 
> > Added, 1 vs 2/3/4 clients isn't very interesting, so to keep it short
> > here are numbers for 2 clients to /dev/null and localhost.
> > 
> Thank you! looks splice has significant advantage :)
> 
> > Sending to /dev/null
> > 
> > ml370:/data # ./splice-bench -n2 -l10 -a -s -z file
> > Waiting for clients
> > Client1 (splice): 19030 MiB/sec (10240MiB in 551 msecs)
> > Client0 (splice): 18961 MiB/sec (10240MiB in 553 msecs)
> This maybe shows cost of gathering page-cache.

Precisely, it's basically the cost of looking up the pages and adding
them to the pipe.

> > Client1 (mmap): 158875 MiB/sec (10240MiB in 66 msecs)
> > Client0 (mmap): 158875 MiB/sec (10240MiB in 66 msecs)
> This shows read/write system-call and user program cost. right ?

It shows the cost of write()'ing the mmap'ed file area to /dev/null.

> > Client1 (rw): 1691 MiB/sec (10240MiB in 6200 msecs)
> > Client0 (rw): 1690 MiB/sec (10240MiB in 6201 msecs)
> > 
> This shows 10240MiB copy_to_user() cost.
> BTW, How big are cpu-cache-size and read/write buffer size in this test ?

This was done on a xeon with 2mb l2. The buffers size used was 64k in
all cases.

> > Sending/receiving over lo
> > 
> read from a file and write to lo ?

I'd rather say input is a file and output is a socket going to lo, that
is a little more precisely given the differing methods the clients use.
But I suspect this is what you meant.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

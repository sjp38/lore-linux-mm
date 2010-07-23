Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0C7566B024D
	for <linux-mm@kvack.org>; Fri, 23 Jul 2010 11:35:39 -0400 (EDT)
Date: Sat, 24 Jul 2010 01:35:28 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: VFS scalability git tree
Message-ID: <20100723153528.GA4514@amd>
References: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100722190100.GA22269@amd>
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>, Michael Neuling <mikey@neuling.org>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jul 23, 2010 at 05:01:00AM +1000, Nick Piggin wrote:
> I'm pleased to announce I have a git tree up of my vfs scalability work.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
> http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git

> Summary of a few numbers I've run. google's socket teardown workload
> runs 3-4x faster on my 2 socket Opteron. Single thread git diff runs 20%
> on same machine. 32 node Altix runs dbench on ramfs 150x faster (100MB/s
> up to 15GB/s).

Following post just contains some preliminary benchmark numbers on a
POWER7. Boring if you're not interested in this stuff.

IBM and Mikey kindly allowed me to do some test runs on a big POWER7
system today.  Very is the only word I'm authorized to describe how big
is big. We tested the vfs-scale-working and master branches from my git
tree as of today.  I'll stick with relative numbers to be safe. All
tests were run on ramfs.


First and very important is single threaded performance of basic code.
POWER7 is obviously vastly different from a Barcelona or Nehalem. and
store-free path walk uses a lot of seqlocks, which are cheap on x86, a
little more epensive on others.

Test case	time difference, vanilla to vfs-scale (negative is better)
stat()		-10.8% +/- 0.3%
close(open())	  4.3% +/- 0.3%
unlink(creat())	 36.8% +/- 0.3%

stat is significantly faster which is really good.

open/close is a bit slower which we didn't get time to analyse. There
are one or two seqlock checks which might be avoided, which could make
up the difference. It's not horrible, but I hope to get POWER7
open/close more competitive (on x86 open/close is even a bit faster).

Note this is a worst case for rcu-path-walk: lookup of "./file", because
it has to take refcount on the final element. With more elements, rcu
walk should gain the advantage.

creat/unlink is showing the big RCU penalty. However I have penciled
out a working design with Linus of how to do SLAB_DESTROY_BY_RCU.
However it makes the store-free path walking and some inode RCU list
walking a little bit trickier, so I prefer not to dump too much on
at once. There is something that can be done if regressions show up.
I don't anticipate many regressions outside microbenchmarks, and this
is about the absolute worst case.


On to parallel tests. Firstly, the google socket workload.
Running with "NR_THREADS" children, vfs-scale patches do this:

root@p7ih06:~/google# time ./google --files_per_cpu 10000 > /dev/null
real	0m4.976s
user	8m38.925s
sys	6m45.236s

root@p7ih06:~/google# time ./google --files_per_cpu 20000 > /dev/null
real	0m7.816s
user	11m21.034s
sys	14m38.258s

root@p7ih06:~/google# time ./google --files_per_cpu 40000 > /dev/null
real	0m11.358s
user	11m37.955s
sys	28m44.911s

Reducing to NR_THREADS/4 children allows vanilla to complete:

root@p7ih06:~/google# time ./google  --files_per_cpu 10000
real    1m23.118s
user    3m31.820s
sys     81m10.405s

I was actually surprised it did that well.


Dbench was an interesting one. We didn't manage to stretch the box's
legs, unfortunately!  dbench with 1 proc gave about 500MB/s, 64 procs 
gave 21GB/s, 128 and throughput dropped dramatically. Turns out that
weird things start happening with rename seqlock versus d_lookup, and
d_move contention (dbench does a sprinkle of renaming). That can be
improved I think, but noth worth bothering with for the time being.

It's not really worth testing vanilla at high dbench parallelism.


Parallel git diff workload looked OK. It seemed to be scaling fine
in the vfs, but it hit a bottlneck in powerpc's tlb invalidation, so
numbers may not be so interesting.


Lastly, some parallel syscall microbenchmarks:

procs		vanilla		vfs-scale
open-close, seperate-cwd
1		384557.70	355923.82	op/s/proc
NR_CORES	    86.63	164054.64	op/s/proc
NR_THREADS	    18.68 (ouch!)

open-close, same-cwd
1		381074.32	339161.25
NR_CORES	   104.16	107653.05

creat-unlink, seperate-cwd
1		145891.05	104301.06
NR_CORES	    29.81	 10061.66

creat-unlink, same-cwd
1		129681.27	104301.06
NR_CORES	    12.68	   181.24

So we can see the single thread performance regressions here, but
the vanilla case really chokes at high CPU counts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

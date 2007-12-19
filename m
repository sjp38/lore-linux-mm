Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <200712191148.06506.nickpiggin@yahoo.com.au>
References: <20071218211539.250334036@redhat.com>
	 <20071218211548.784184591@redhat.com>
	 <200712191148.06506.nickpiggin@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 19 Dec 2007 10:52:09 -0500
Message-Id: <1198079529.5333.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2007-12-19 at 11:48 +1100, Nick Piggin wrote:
> On Wednesday 19 December 2007 08:15, Rik van Riel wrote:
> > I have seen soft cpu lockups in page_referenced_file() due to
> > contention on i_mmap_lock() for different pages.  Making the
> > i_mmap_lock a reader/writer lock should increase parallelism
> > in vmscan for file back pages mapped into many address spaces.
> >
> > Read lock the i_mmap_lock for all usage except:
> >
> > 1) mmap/munmap:  linking vma into i_mmap prio_tree or removing
> > 2) unmap_mapping_range:   protecting vm_truncate_count
> >
> > rmap:  try_to_unmap_file() required new cond_resched_rwlock().
> > To reduce code duplication, I recast cond_resched_lock() as a
> > [static inline] wrapper around reworked cond_sched_lock() =>
> > __cond_resched_lock(void *lock, int type).
> > New cond_resched_rwlock() implemented as another wrapper.
> 
> Reader/writer locks really suck in terms of fairness and starvation,
> especially when the read-side is common and frequent. (also, single
> threaded performance of the read-side is worse).
> 
> I know Lee saw some big latencies on the anon_vma list lock when
> running (IIRC) a large benchmark... but are there more realistic
> situations where this is a problem?

Yes, we see the stall on the anon_vma lock most frequently running the
AIM benchmark with several tens of thousands of processes--all forked
from the same parent.  If we push the system into reclaim, all cpus end
up spinning on the lock in one of the anon_vma's shared by all the
tasks.  Quite easy to reproduce.  I have also seen this running stress
tests to force reclaim under Dave Anderson's "usex" exerciser--e.g.,
testing the split LRU and noreclaim patches--even with the reader-writer
lock patch. 

I've seen the lockups on the i_mmap_lock running Oracle workloads on our
large servers.  This is running an OLTP workload with only a thousand or
so "clients" all running the same application image.   Again, when the
system attempts to reclaim we end up spinning on the i_mmap_lock of one
of the files [possibly the shared global shmem segment] shared by all
the applications.  I also see it with the usex stress load--also, with
and without this patch.  I think this is a more probably
scenario--thousands of processes sharing a single file, such as
libc.so--than thousands of processes all descended from a single
ancestor w/o exec'ing.

I keep these patches up to date for testing.  I don't have conclusive
evidence whether they alleviate or exacerbate the problem nor by how
much.  

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

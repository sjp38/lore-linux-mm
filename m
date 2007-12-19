From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [patch 02/20] make the inode i_mmap_lock a reader/writer lock
Date: Wed, 19 Dec 2007 11:48:06 +1100
References: <20071218211539.250334036@redhat.com> <20071218211548.784184591@redhat.com>
In-Reply-To: <20071218211548.784184591@redhat.com>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200712191148.06506.nickpiggin@yahoo.com.au>
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, lee.shermerhorn@hp.com, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 19 December 2007 08:15, Rik van Riel wrote:
> I have seen soft cpu lockups in page_referenced_file() due to
> contention on i_mmap_lock() for different pages.  Making the
> i_mmap_lock a reader/writer lock should increase parallelism
> in vmscan for file back pages mapped into many address spaces.
>
> Read lock the i_mmap_lock for all usage except:
>
> 1) mmap/munmap:  linking vma into i_mmap prio_tree or removing
> 2) unmap_mapping_range:   protecting vm_truncate_count
>
> rmap:  try_to_unmap_file() required new cond_resched_rwlock().
> To reduce code duplication, I recast cond_resched_lock() as a
> [static inline] wrapper around reworked cond_sched_lock() =>
> __cond_resched_lock(void *lock, int type).
> New cond_resched_rwlock() implemented as another wrapper.

Reader/writer locks really suck in terms of fairness and starvation,
especially when the read-side is common and frequent. (also, single
threaded performance of the read-side is worse).

I know Lee saw some big latencies on the anon_vma list lock when
running (IIRC) a large benchmark... but are there more realistic
situations where this is a problem?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

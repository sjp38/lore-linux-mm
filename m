Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id CCEE46B0044
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 21:27:34 -0400 (EDT)
Date: Thu, 29 Mar 2012 09:22:01 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
Message-ID: <20120329012201.GB25447@localhost>
References: <20120328121308.568545879@intel.com>
 <4F73ADFC.7040404@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F73ADFC.7040404@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Vivek Goyal <vgoyal@redhat.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 29, 2012 at 09:34:04AM +0900, KAMEZAWA Hiroyuki wrote:
> (2012/03/28 21:13), Fengguang Wu wrote:
> 
> > Here is one possible solution to "buffered write IO controller", based on Linux
> > v3.3
> > 
> > git://git.kernel.org/pub/scm/linux/kernel/git/wfg/linux.git  buffered-write-io-controller
> > 
> > Features:
> > - support blkio.weight
> > - support blkio.throttle.buffered_write_bps
> > 
> > Possibilities:
> > - it's trivial to support per-bdi .weight or .buffered_write_bps
> > 
> > Pros:
> > 1) simple
> > 2) virtually no space/time overheads
> > 3) independent of the block layer and IO schedulers, hence
> > 3.1) supports all filesystems/storages, eg. NFS/pNFS, CIFS, sshfs, ...
> > 3.2) supports all IO schedulers. One may use noop for SSDs, inside virtual machines, over iSCSI, etc.
> > 
> > Cons:
> > 1) don't try to smooth bursty IO submission in the flusher thread (*)
> > 2) don't support IOPS based throttling
> > 3) introduces semantic differences to blkio.weight, which will be
> >    - working by "bandwidth" for buffered writes
> >    - working by "device time" for direct IO
> > 
> > (*) Maybe not a big concern, since the bursties are limited to 500ms: if one dd
> > is throttled to 50% disk bandwidth, the flusher thread will be waking up on
> > every 1 second, keep the disk busy for 500ms and then go idle for 500ms; if
> > throttled to 10% disk bandwidth, the flusher thread will wake up on every 5s,
> > keep busy for 500ms and stay idle for 4.5s.
> > 
> > The test results included in the last patch look pretty good in despite of the
> > simple implementation.
> > 
> 
> yes, seems very good.
> 
> >  [PATCH 1/6] blk-cgroup: move blk-cgroup.h in include/linux/blk-cgroup.h
> >  [PATCH 2/6] blk-cgroup: account dirtied pages
> >  [PATCH 3/6] blk-cgroup: buffered write IO controller - bandwidth weight
> >  [PATCH 4/6] blk-cgroup: buffered write IO controller - bandwidth limit
> >  [PATCH 5/6] blk-cgroup: buffered write IO controller - bandwidth limit interface
> >  [PATCH 6/6] blk-cgroup: buffered write IO controller - debug trace
> > 
> > The changeset is dominated by the blk-cgroup.h move.
> > The core changes (to page-writeback.c) are merely 77 lines.
> > 
> >  block/blk-cgroup.c               |   27 +
> >  block/blk-cgroup.h               |  364 --------------------------
> >  block/blk-throttle.c             |    2 
> >  block/cfq.h                      |    2 
> >  include/linux/blk-cgroup.h       |  396 +++++++++++++++++++++++++++++
> >  include/trace/events/writeback.h |   34 ++
> >  mm/page-writeback.c              |   77 +++++
> >  7 files changed, 530 insertions(+), 372 deletions(-)
> > 
> 
> 
> Thank you very much. I like this simple implementation.

Thank you :)

> I have 3 questions..
> 
> - Do you have any plan to enhance this to support hierarchical accounting ?

Given hierarchy A/B/C and when throttling a task from C,

- blkio.weight is relatively simple, just scale task_ratelimit by

        C.weight * B.weight * A.weight / BLKIO_WEIGHT_DEFAULT^3

*Optionally*, if there comes heavy use of really deep hierarchy, to
avoid repeated runtime overheads, we may cache the above value inside memcg C.

- blkio.throttle.buffered_write_bps can be carried out by limiting
  task_ratelimit to

        min(C.dirty_throttle, B.dirty_throttle, A.dirty_throttle, bdi.dirty_throttle)

*Optionally*, to avoid repeated runtime overheads of walking the
hierarchy, we may also cache the above value (taking away the bdi one)
inside memcg C, taking advantage of the fact that *.dirty_throttle are
all updated in 200ms intervals.

The dirty count need some special care:
- in account_page_dirtied(), increase dirty count of the task's *direct* attached cgroup
- in blkcg_update_bandwidth(), which runs on every 200ms, compute A's
  hierarchical dirty count as
          A.total_dirtied = A.nr_dirtied + B.nr_dirtied + C.nr_dirtied

> - Can we get wait-time-for-dirty-pages summary per blkio cgroup ?

Sure it's possible. We may export min/max/avg/stddev summaries of the
wait time.

> - Can we get status (dirty/sec) per blkio cgroup ?

It would be trivial to do, too.

For now, the above stats can be derived from the blkcg_dirty_ratelimit
and balance_dirty_pages trace events.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

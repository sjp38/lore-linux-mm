Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 3873D6B0125
	for <linux-mm@kvack.org>; Wed, 28 Mar 2012 20:35:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id B67093EE0AE
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:35:50 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 91CFF45DE62
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:35:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 669E845DE56
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:35:50 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 53DBF1DB8051
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:35:50 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DEE13E08004
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 09:35:49 +0900 (JST)
Message-ID: <4F73ADFC.7040404@jp.fujitsu.com>
Date: Thu, 29 Mar 2012 09:34:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
References: <20120328121308.568545879@intel.com>
In-Reply-To: <20120328121308.568545879@intel.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Vivek Goyal <vgoyal@redhat.com>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

(2012/03/28 21:13), Fengguang Wu wrote:

> Here is one possible solution to "buffered write IO controller", based on Linux
> v3.3
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/wfg/linux.git  buffered-write-io-controller
> 
> Features:
> - support blkio.weight
> - support blkio.throttle.buffered_write_bps
> 
> Possibilities:
> - it's trivial to support per-bdi .weight or .buffered_write_bps
> 
> Pros:
> 1) simple
> 2) virtually no space/time overheads
> 3) independent of the block layer and IO schedulers, hence
> 3.1) supports all filesystems/storages, eg. NFS/pNFS, CIFS, sshfs, ...
> 3.2) supports all IO schedulers. One may use noop for SSDs, inside virtual machines, over iSCSI, etc.
> 
> Cons:
> 1) don't try to smooth bursty IO submission in the flusher thread (*)
> 2) don't support IOPS based throttling
> 3) introduces semantic differences to blkio.weight, which will be
>    - working by "bandwidth" for buffered writes
>    - working by "device time" for direct IO
> 
> (*) Maybe not a big concern, since the bursties are limited to 500ms: if one dd
> is throttled to 50% disk bandwidth, the flusher thread will be waking up on
> every 1 second, keep the disk busy for 500ms and then go idle for 500ms; if
> throttled to 10% disk bandwidth, the flusher thread will wake up on every 5s,
> keep busy for 500ms and stay idle for 4.5s.
> 
> The test results included in the last patch look pretty good in despite of the
> simple implementation.
> 

yes, seems very good.

>  [PATCH 1/6] blk-cgroup: move blk-cgroup.h in include/linux/blk-cgroup.h
>  [PATCH 2/6] blk-cgroup: account dirtied pages
>  [PATCH 3/6] blk-cgroup: buffered write IO controller - bandwidth weight
>  [PATCH 4/6] blk-cgroup: buffered write IO controller - bandwidth limit
>  [PATCH 5/6] blk-cgroup: buffered write IO controller - bandwidth limit interface
>  [PATCH 6/6] blk-cgroup: buffered write IO controller - debug trace
> 
> The changeset is dominated by the blk-cgroup.h move.
> The core changes (to page-writeback.c) are merely 77 lines.
> 
>  block/blk-cgroup.c               |   27 +
>  block/blk-cgroup.h               |  364 --------------------------
>  block/blk-throttle.c             |    2 
>  block/cfq.h                      |    2 
>  include/linux/blk-cgroup.h       |  396 +++++++++++++++++++++++++++++
>  include/trace/events/writeback.h |   34 ++
>  mm/page-writeback.c              |   77 +++++
>  7 files changed, 530 insertions(+), 372 deletions(-)
> 


Thank you very much. I like this simple implementation.
I have 3 questions..

- Do you have any plan to enhance this to support hierarchical accounting ?
- Can we get wait-time-for-dirty-pages summary per blkio cgroup ?
- Can we get status (dirty/sec) per blkio cgroup ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

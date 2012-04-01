Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id EE4EB6B0044
	for <linux-mm@kvack.org>; Sun,  1 Apr 2012 00:16:21 -0400 (EDT)
Message-ID: <4F77D686.3020308@suse.com>
Date: Sun, 01 Apr 2012 09:46:06 +0530
From: Suresh Jayaraman <sjayaraman@suse.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
References: <20120328121308.568545879@intel.com>
In-Reply-To: <20120328121308.568545879@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On 03/28/2012 05:43 PM, Fengguang Wu wrote:
> Here is one possible solution to "buffered write IO controller", based on Linux
> v3.3
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/wfg/linux.git  buffered-write-io-controller
> 

The implementation looks unbelievably simple. I ran a few tests
(throttling) and I found it working well generally.

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

There is a chance that this semantic difference might confuse users.

> (*) Maybe not a big concern, since the bursties are limited to 500ms: if one dd
> is throttled to 50% disk bandwidth, the flusher thread will be waking up on
> every 1 second, keep the disk busy for 500ms and then go idle for 500ms; if
> throttled to 10% disk bandwidth, the flusher thread will wake up on every 5s,
> keep busy for 500ms and stay idle for 4.5s.
> 
> The test results included in the last patch look pretty good in despite of the
> simple implementation.
> 
>  [PATCH 1/6] blk-cgroup: move blk-cgroup.h in include/linux/blk-cgroup.h
>  [PATCH 2/6] blk-cgroup: account dirtied pages
>  [PATCH 3/6] blk-cgroup: buffered write IO controller - bandwidth weight
>  [PATCH 4/6] blk-cgroup: buffered write IO controller - bandwidth limit
>  [PATCH 5/6] blk-cgroup: buffered write IO controller - bandwidth limit interface
>  [PATCH 6/6] blk-cgroup: buffered write IO controller - debug trace
> 

How about a BOF on this topic during LSF/MM as there seems to be enough
interest?


Thanks
Suresh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

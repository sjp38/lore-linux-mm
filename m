Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 3ABD96B0044
	for <linux-mm@kvack.org>; Sun,  1 Apr 2012 16:56:55 -0400 (EDT)
Date: Sun, 1 Apr 2012 16:56:47 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/6] buffered write IO controller in balance_dirty_pages()
Message-ID: <20120401205647.GD6116@redhat.com>
References: <20120328121308.568545879@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120328121308.568545879@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Suresh Jayaraman <sjayaraman@suse.com>, Andrea Righi <andrea@betterlinux.com>, Jeff Moyer <jmoyer@redhat.com>, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Mar 28, 2012 at 08:13:08PM +0800, Fengguang Wu wrote:
> 
> Here is one possible solution to "buffered write IO controller", based on Linux
> v3.3
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/wfg/linux.git  buffered-write-io-controller
> 
> Features:
> - support blkio.weight
> - support blkio.throttle.buffered_write_bps

Introducing separate knob for buffered write makes sense. It is different
throttling done at block layer.

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

Yes, this is a core limitation of throttling while writing to cache. I think
once we had agreed that IO scheduler in general should be able to handle
burstiness caused by WRITES. CFQ does it well. deadline not so much.

> 2) don't support IOPS based throttling

If need be then you can still support it. Isn't it? Just that it will
require more code in buffered write controller to keep track of number
of operations per second and throttle task if IOPS limit is crossed. So
it does not sound like a limitation of design but just limitation of
current set of patches?

> 3) introduces semantic differences to blkio.weight, which will be
>    - working by "bandwidth" for buffered writes
>    - working by "device time" for direct IO

I think blkio.weight can be thought of a system wide weight of a cgroup
and more than one entity/subsystem should be able to make use of it and
differentiate between IO in its own way. CFQ can decide to do proportional
time division, and buffered write controller should be able to use the
same weight and do write bandwidth differentiation. I think it is better
than introducing another buffered write controller tunable for weight.

Personally, I am not too worried about this point. We can document and
explain it well.


> 
> (*) Maybe not a big concern, since the bursties are limited to 500ms: if one dd
> is throttled to 50% disk bandwidth, the flusher thread will be waking up on
> every 1 second, keep the disk busy for 500ms and then go idle for 500ms; if
> throttled to 10% disk bandwidth, the flusher thread will wake up on every 5s,
> keep busy for 500ms and stay idle for 4.5s.
> 
> The test results included in the last patch look pretty good in despite of the
> simple implementation.

Can you give more details about test results. Did you test throttling or you
tested write speed differentation based on weight too.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

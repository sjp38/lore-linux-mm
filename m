Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 640298D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:01:35 -0500 (EST)
Date: Mon, 28 Feb 2011 18:01:14 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/3] blk-throttle: async write throttling
Message-ID: <20110228230114.GB20845@redhat.com>
References: <1298888105-3778-1-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1298888105-3778-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Gui Jianfeng <guijianfeng@cn.fujitsu.com>, Ryo Tsuruta <ryov@valinux.co.jp>, Hirokazu Takahashi <taka@valinux.co.jp>, Jens Axboe <axboe@kernel.dk>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Feb 28, 2011 at 11:15:02AM +0100, Andrea Righi wrote:
> Overview
> ========
> Currently the blkio.throttle controller only support synchronous IO requests.
> This means that we always look at the current task to identify the "owner" of
> each IO request.
> 
> However dirty pages in the page cache can be wrote to disk asynchronously by
> the per-bdi flusher kernel threads or by any other thread in the system,
> according to the writeback policy.
> 
> For this reason the real writes to the underlying block devices may
> occur in a different IO context respect to the task that originally
> generated the dirty pages involved in the IO operation. This makes the
> tracking and throttling of writeback IO more complicate respect to the
> synchronous IO from the blkio controller's perspective.
> 
> Proposed solution
> =================
> In the previous patch set http://lwn.net/Articles/429292/ I proposed to resolve
> the problem of the buffered writes limitation by tracking the ownership of all
> the dirty pages in the system.
> 
> This would allow to always identify the owner of each IO operation at the block
> layer and apply the appropriate throttling policy implemented by the
> blkio.throttle controller.
> 
> This solution makes the blkio.throttle controller to work as expected also for
> writeback IO, but it does not resolve the problem of faster cgroups getting
> blocked by slower cgroups (that would expose a potential way to create DoS in
> the system).
> 
> In fact, at the moment critical IO requests (that have dependency with other IO
> requests made by other cgroups) and non-critical requests are mixed together at
> the filesystem layer in a way that throttling a single write request may stop
> also other requests in the system, and at the block layer it's not possible to
> retrieve such informations to make the right decision.
> 
> A simple solution to this problem could be to just limit the rate of async
> writes at the time a task is generating dirty pages in the page cache. The
> big advantage of this approach is that it does not need the overhead of
> tracking the ownership of the dirty pages, because in this way from the blkio
> controller perspective all the IO operations will happen from the process
> context: writes in memory and synchronous reads from the block device.
> 
> The drawback of this approach is that the blkio.throttle controller becomes a
> little bit leaky, because with this solution the controller is still affected
> by the IO spikes during the writeback of dirty pages executed by the kernel
> threads.
> 
> Probably an even better approach would be to introduce the tracking of the
> dirty page ownership to properly account the cost of each IO operation at the
> block layer and apply the throttling of async writes in memory only when IO
> limits are exceeded.

Andrea, I am curious to know more about it third option. Can you give more
details about accouting in block layer but throttling in memory. So say 
a process starts IO, then it will still be in throttle limits at block
layer (because no writeback has started), then the process will write
bunch of pages in cache. By the time throttle limits are crossed at
block layer, we already have lots of dirty data in page cache and
throttling process now is already late?

> 
> To summarize, we can identify three possible solutions to properly throttle the
> buffered writes:
> 
> 1) account & throttle everything at block IO layer (bad for "priority
>    inversion" problems, needs page tracking for blkio)
> 
> 2) account at block IO layer and throttle in memory (needs page tracking for
>    blkio)
> 
> 3) account & throttle in memory (affected by IO spikes, depending on
>    dirty_ratio / dirty_background_ratio settings)
> 
> For now we start with the solution 3) that seems to be the simplest way to
> proceed.

Yes, IO spikes is the weakness of this 3rd solution. But it should be
simple too. Also as you said problem can be reduced up to some extent
by changing reducing dirty_ratio and background dirty ratio But that
will have other trade offs, I guess.

Thanks
Vivek

> 
> Testcase
> ========
> - create a cgroup with 4MiB/s write limit:
>   # mount -t cgroup -o blkio none /mnt/cgroup
>   # mkdir /mnt/cgroup/foo
>   # echo 8:0 $((4 * 1024 * 1024)) > /mnt/cgroup/foo/blkio.throttle.write_bps_device
> 
>   NOTE: async io is still limited per-device, as well as sync io
> 
> - move a task into the cgroup and run a dd to generate some writeback IO
> 
> Results:
> 
>   - 2.6.38-rc6 vanilla:
> 
>   $ cat /proc/$$/cgroup
>   1:blkio:/foo
>   $ dd if=/dev/zero of=zero bs=1M count=128 &
>   $ dstat -df
>   --dsk/sda--
>    read  writ
>    0     0
>   ...
>    0     0
>    0    22M  <--- writeback starts here and is not limited at all
>    0    43M
>    0    45M
>    0    18M
>   ...
> 
>   - 2.6.38-rc6 + async write throttling:
> 
>   $ cat /proc/$$/cgroup
>   1:blkio:/foo
>   $ dd if=/dev/zero of=zero bs=1M count=128 &
>   $ dstat -df
>   --dsk/sda--
>    read  writ
>    0     0
>    0     0
>    0     0
>    0     0
>    0    22M  <--- we have some IO spikes but the overall writeback IO
>    0     0        is controlled according to the blkio write limit
>    0     0
>    0     0
>    0     0
>    0    29M
>    0     0
>    0     0
>    0     0
>    0     0
>    0    26M
>    0     0
>    0     0
>    0     0
>    0     0
>    0    30M
>    0     0
>    0     0
>    0     0
>    0     0
>    0    20M
> 
> TODO
> ~~~~
>  - Consider to add the following new files in the blkio controller to allow the
>    user to explicitly limit async writes as well as sync writes:
> 
>    blkio.throttle.async.write_bps_limit
>    blkio.throttle.async.write_iops_limit
> 
> Any feedback is welcome.
> -Andrea
> 
> [PATCH 1/3] block: introduce REQ_DIRECT to track direct io bio
> [PATCH 2/3] blkio-throttle: infrastructure to throttle async io
> [PATCH 3/3] blkio-throttle: async write io instrumentation
> 
>  block/blk-throttle.c      |  106 ++++++++++++++++++++++++++++++---------------
>  fs/direct-io.c            |    1 +
>  include/linux/blk_types.h |    2 +
>  include/linux/blkdev.h    |    6 +++
>  mm/page-writeback.c       |   17 +++++++
>  5 files changed, 97 insertions(+), 35 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

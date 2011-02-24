Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D7CD68D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:11:15 -0500 (EST)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.4/8.13.1) with ESMTP id p1O5EKWR010524
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 10:44:20 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1O6B9eA958716
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 11:41:09 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1O6B82U007324
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 17:11:09 +1100
Date: Thu, 24 Feb 2011 11:38:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 0/5] blk-throttle: writeback and swap IO control
Message-ID: <20110224060853.GN3379@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1298394776-9957-1-git-send-email-arighi@develer.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1298394776-9957-1-git-send-email-arighi@develer.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <arighi@develer.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Jens Axboe <axboe@kernel.dk>, containers@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, Hirokazu Takahashi <taka@valinux.co.jp>, linux-mm@kvack.org, Ryo Tsuruta <ryov@valinux.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>

* Andrea Righi <arighi@develer.com> [2011-02-22 18:12:51]:

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
> The same concept is also valid for anonymous pages involed in IO operations
> (swap).
> 
> This patch allow to track the cgroup that originally dirtied each page in page
> cache and each anonymous page and pass these informations to the blk-throttle
> controller. These informations can be used to provide a better service level
> differentiation of buffered writes swap IO between different cgroups.
> 
> Testcase
> ========
> - create a cgroup with 1MiB/s write limit:
>   # mount -t cgroup -o blkio none /mnt/cgroup
>   # mkdir /mnt/cgroup/foo
>   # echo 8:0 $((1024 * 1024)) > /mnt/cgroup/foo/blkio.throttle.write_bps_device
> 
> - move a task into the cgroup and run a dd to generate some writeback IO
> 
> Results:
>   - 2.6.38-rc6 vanilla:
>   $ cat /proc/$$/cgroup
>   1:blkio:/foo
>   $ dd if=/dev/zero of=zero bs=1M count=1024 &
>   $ dstat -df
>   --dsk/sda--
>    read  writ
>      0    19M
>      0    19M
>      0     0
>      0     0
>      0    19M
>   ...
> 
>   - 2.6.38-rc6 + blk-throttle writeback IO control:
>   $ cat /proc/$$/cgroup
>   1:blkio:/foo
>   $ dd if=/dev/zero of=zero bs=1M count=1024 &
>   $ dstat -df
>   --dsk/sda--
>    read  writ
>      0  1024
>      0  1024
>      0  1024
>      0  1024
>      0  1024
>   ...
> 

Thanks for looking into this, further review follows.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

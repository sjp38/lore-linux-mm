Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 1F0796B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:02:28 -0500 (EST)
Received: by pbaa12 with SMTP id a12so1373302pba.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 06:02:27 -0800 (PST)
Date: Wed, 1 Feb 2012 22:02:17 +0800
From: Wu Fengguang <fengguang.wu@gmail.com>
Subject: Re: [Bug 12309] Large I/O operations result in poor interactive
 performance and high iowait times
Message-ID: <20120201140217.GA11896@localhost>
References: <bug-12309-27@https.bugzilla.kernel.org/>
 <201201201611.q0KGBPf6029256@bugzilla.kernel.org>
 <20120120144513.f457a58d.akpm@linux-foundation.org>
 <AAFC850A73EC0C40804D40FD09800642101AEA51@SHSMSX102.ccr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AAFC850A73EC0C40804D40FD09800642101AEA51@SHSMSX102.ccr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Mel Gorman <mel@csn.ul.ie>

On Sat, Jan 28, 2012 at 02:44:24PM +0000, Wu, Fengguang wrote:
> [replying from webmail and CC my gmail account]
> 
> >> https://bugzilla.kernel.org/show_bug.cgi?id=12309
> 
> > We've had some recent updates to the world's largest bug report.
> > Apparently our large-writer-paralyses-the-machine problems have
> > worsened in recent kernels.
> 
> Yeah I can reproduce the interactive problem on 3.3-rc1, and the main stalls seem to happen when loading the task and allocating memory.

However I find no allocstall/nr_vmscan_write in this test box:

wfg@bee /export/writeback/lkp-nex04% g vmscan JBOD*/*/vmstat-end         
JBOD-10HDD-thresh=1000M/ext4-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_write 0
JBOD-10HDD-thresh=1000M/ext4-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_immediate_reclaim 39380
JBOD-10HDD-thresh=100M/ext4-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_write 0
JBOD-10HDD-thresh=100M/ext4-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_immediate_reclaim 12795
JBOD-10HDD-thresh=100M/xfs-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_write 0
JBOD-10HDD-thresh=100M/xfs-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_immediate_reclaim 2328
JBOD-10HDD-thresh=4G/ext4-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_write 0
JBOD-10HDD-thresh=4G/ext4-1dd-1-3.3.0-rc1/vmstat-end:nr_vmscan_immediate_reclaim 42120
wfg@bee /export/writeback/lkp-nex04% g stall JBOD*/*/vmstat-end 
JBOD-10HDD-thresh=1000M/ext4-1dd-1-3.3.0-rc1/vmstat-end:allocstall 0
JBOD-10HDD-thresh=100M/ext4-1dd-1-3.3.0-rc1/vmstat-end:allocstall 0
JBOD-10HDD-thresh=100M/xfs-1dd-1-3.3.0-rc1/vmstat-end:allocstall 8
JBOD-10HDD-thresh=4G/ext4-1dd-1-3.3.0-rc1/vmstat-end:allocstall 0

On the other side, I'd like to share some facts that indicate improved
responsiveness since Linux 3.2:

- the vmstat "allocstall" and "nr_vmscan_write" fields mostly drop to 0
  thanks to Mel's IO-less page reclaim patches (data listed below)

- I personally feel a lot better responsiveness when ssh into the test
  boxes checking things out when they are doing heavy writeback tests,
  thanks to the IO-less balance_dirty_pages() patches.

There is a user report on impressive improvements on desktop responsiveness
(see below email).

Thanks,
Fengguang
---

wfg@bee /export/writeback/snb% g allocstall JBOD*/*3.1.0+/vmstat-end
JBOD-4HDD-thresh=100M/btrfs-100dd-1-3.1.0+/vmstat-end:allocstall 38
JBOD-4HDD-thresh=100M/btrfs-100dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-10dd-1-3.1.0+/vmstat-end:allocstall 20
JBOD-4HDD-thresh=100M/btrfs-10dd-2-3.1.0+/vmstat-end:allocstall 36
JBOD-4HDD-thresh=100M/btrfs-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-100dd-1-3.1.0+/vmstat-end:allocstall 39
JBOD-4HDD-thresh=100M/ext3-100dd-2-3.1.0+/vmstat-end:allocstall 59
JBOD-4HDD-thresh=100M/ext3-10dd-1-3.1.0+/vmstat-end:allocstall 16
JBOD-4HDD-thresh=100M/ext3-10dd-2-3.1.0+/vmstat-end:allocstall 14
JBOD-4HDD-thresh=100M/ext3-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-100dd-1-3.1.0+/vmstat-end:allocstall 1502
JBOD-4HDD-thresh=100M/ext4-100dd-2-3.1.0+/vmstat-end:allocstall 953
JBOD-4HDD-thresh=100M/ext4-10dd-1-3.1.0+/vmstat-end:allocstall 158
JBOD-4HDD-thresh=100M/ext4-10dd-2-3.1.0+/vmstat-end:allocstall 107
JBOD-4HDD-thresh=100M/ext4-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-100dd-1-3.1.0+/vmstat-end:allocstall 498
JBOD-4HDD-thresh=100M/xfs-100dd-2-3.1.0+/vmstat-end:allocstall 486
JBOD-4HDD-thresh=100M/xfs-10dd-1-3.1.0+/vmstat-end:allocstall 159
JBOD-4HDD-thresh=100M/xfs-10dd-2-3.1.0+/vmstat-end:allocstall 621
JBOD-4HDD-thresh=100M/xfs-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-100dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-100dd-2-3.1.0+/vmstat-end:allocstall 29
JBOD-4HDD-thresh=1G/btrfs-10dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-10dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-100dd-1-3.1.0+/vmstat-end:allocstall 307
JBOD-4HDD-thresh=1G/ext3-100dd-2-3.1.0+/vmstat-end:allocstall 128
JBOD-4HDD-thresh=1G/ext3-10dd-1-3.1.0+/vmstat-end:allocstall 59
JBOD-4HDD-thresh=1G/ext3-10dd-2-3.1.0+/vmstat-end:allocstall 40
JBOD-4HDD-thresh=1G/ext3-1dd-1-3.1.0+/vmstat-end:allocstall 45
JBOD-4HDD-thresh=1G/ext3-1dd-2-3.1.0+/vmstat-end:allocstall 31
JBOD-4HDD-thresh=1G/ext4-100dd-1-3.1.0+/vmstat-end:allocstall 2022
JBOD-4HDD-thresh=1G/ext4-100dd-2-3.1.0+/vmstat-end:allocstall 1923
JBOD-4HDD-thresh=1G/ext4-10dd-1-3.1.0+/vmstat-end:allocstall 39
JBOD-4HDD-thresh=1G/ext4-10dd-2-3.1.0+/vmstat-end:allocstall 26
JBOD-4HDD-thresh=1G/ext4-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-100dd-1-3.1.0+/vmstat-end:allocstall 1838
JBOD-4HDD-thresh=1G/xfs-100dd-2-3.1.0+/vmstat-end:allocstall 1650
JBOD-4HDD-thresh=1G/xfs-10dd-1-3.1.0+/vmstat-end:allocstall 2294
JBOD-4HDD-thresh=1G/xfs-10dd-2-3.1.0+/vmstat-end:allocstall 2144
JBOD-4HDD-thresh=1G/xfs-1dd-1-3.1.0+/vmstat-end:allocstall 61
JBOD-4HDD-thresh=1G/xfs-1dd-2-3.1.0+/vmstat-end:allocstall 103
JBOD-4HDD-thresh=8G/btrfs-100dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-100dd-2-3.1.0+/vmstat-end:allocstall 49
JBOD-4HDD-thresh=8G/btrfs-10dd-1-3.1.0+/vmstat-end:allocstall 186
JBOD-4HDD-thresh=8G/btrfs-10dd-2-3.1.0+/vmstat-end:allocstall 139
JBOD-4HDD-thresh=8G/btrfs-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-100dd-1-3.1.0+/vmstat-end:allocstall 670
JBOD-4HDD-thresh=8G/ext3-100dd-2-3.1.0+/vmstat-end:allocstall 875
JBOD-4HDD-thresh=8G/ext3-10dd-1-3.1.0+/vmstat-end:allocstall 5
JBOD-4HDD-thresh=8G/ext3-10dd-2-3.1.0+/vmstat-end:allocstall 49
JBOD-4HDD-thresh=8G/ext3-1dd-1-3.1.0+/vmstat-end:allocstall 13
JBOD-4HDD-thresh=8G/ext3-1dd-2-3.1.0+/vmstat-end:allocstall 19
JBOD-4HDD-thresh=8G/ext4-100dd-1-3.1.0+/vmstat-end:allocstall 2784
JBOD-4HDD-thresh=8G/ext4-100dd-2-3.1.0+/vmstat-end:allocstall 1997
JBOD-4HDD-thresh=8G/ext4-10dd-1-3.1.0+/vmstat-end:allocstall 13
JBOD-4HDD-thresh=8G/ext4-10dd-2-3.1.0+/vmstat-end:allocstall 4
JBOD-4HDD-thresh=8G/ext4-1dd-1-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext4-1dd-2-3.1.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/xfs-100dd-1-3.1.0+/vmstat-end:allocstall 11282
JBOD-4HDD-thresh=8G/xfs-100dd-2-3.1.0+/vmstat-end:allocstall 11677
JBOD-4HDD-thresh=8G/xfs-10dd-1-3.1.0+/vmstat-end:allocstall 3848
JBOD-4HDD-thresh=8G/xfs-10dd-2-3.1.0+/vmstat-end:allocstall 3183
JBOD-4HDD-thresh=8G/xfs-1dd-1-3.1.0+/vmstat-end:allocstall 206
JBOD-4HDD-thresh=8G/xfs-1dd-2-3.1.0+/vmstat-end:allocstall 189
wfg@bee /export/writeback/snb% g allocstall JBOD*/*3.2.0+/vmstat-end
JBOD-4HDD-thresh=100M/btrfs-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/btrfs-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext3-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/ext4-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=100M/xfs-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/btrfs-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext3-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/ext4-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=1G/xfs-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/btrfs-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-100dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext3-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext4-100dd-1-3.2.0+/vmstat-end:allocstall 45
JBOD-4HDD-thresh=8G/ext4-100dd-2-3.2.0+/vmstat-end:allocstall 33
JBOD-4HDD-thresh=8G/ext4-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext4-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext4-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/ext4-1dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/xfs-100dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/xfs-100dd-2-3.2.0+/vmstat-end:allocstall 12
JBOD-4HDD-thresh=8G/xfs-10dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/xfs-10dd-2-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/xfs-1dd-1-3.2.0+/vmstat-end:allocstall 0
JBOD-4HDD-thresh=8G/xfs-1dd-2-3.2.0+/vmstat-end:allocstall 0
wfg@bee /export/writeback/snb% g nr_vmscan_write JBOD*/*3.1.0+/vmstat-end
JBOD-4HDD-thresh=100M/btrfs-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 61
JBOD-4HDD-thresh=100M/btrfs-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 97
JBOD-4HDD-thresh=100M/btrfs-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 38
JBOD-4HDD-thresh=100M/btrfs-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 33
JBOD-4HDD-thresh=100M/btrfs-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 13
JBOD-4HDD-thresh=100M/btrfs-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 3
JBOD-4HDD-thresh=100M/ext3-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 11
JBOD-4HDD-thresh=100M/ext3-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 7
JBOD-4HDD-thresh=100M/ext3-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 12
JBOD-4HDD-thresh=100M/ext3-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 26
JBOD-4HDD-thresh=100M/ext3-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 4
JBOD-4HDD-thresh=100M/ext3-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 16
JBOD-4HDD-thresh=100M/ext4-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 19
JBOD-4HDD-thresh=100M/ext4-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 13
JBOD-4HDD-thresh=100M/ext4-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 25
JBOD-4HDD-thresh=100M/ext4-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 36
JBOD-4HDD-thresh=100M/ext4-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 23
JBOD-4HDD-thresh=100M/ext4-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 11
JBOD-4HDD-thresh=100M/xfs-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 1
JBOD-4HDD-thresh=100M/xfs-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 3
JBOD-4HDD-thresh=100M/xfs-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 7
JBOD-4HDD-thresh=100M/xfs-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 1
JBOD-4HDD-thresh=100M/xfs-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 234
JBOD-4HDD-thresh=1G/btrfs-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 166
JBOD-4HDD-thresh=1G/btrfs-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 65
JBOD-4HDD-thresh=1G/btrfs-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 63
JBOD-4HDD-thresh=1G/btrfs-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 8
JBOD-4HDD-thresh=1G/btrfs-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 15
JBOD-4HDD-thresh=1G/ext3-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 46
JBOD-4HDD-thresh=1G/ext3-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 55
JBOD-4HDD-thresh=1G/ext3-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 102
JBOD-4HDD-thresh=1G/ext3-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 49
JBOD-4HDD-thresh=1G/ext3-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 91
JBOD-4HDD-thresh=1G/ext3-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 77
JBOD-4HDD-thresh=1G/ext4-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 1
JBOD-4HDD-thresh=1G/ext4-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 3
JBOD-4HDD-thresh=1G/ext4-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 14
JBOD-4HDD-thresh=1G/ext4-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 3
JBOD-4HDD-thresh=1G/ext4-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 6
JBOD-4HDD-thresh=1G/ext4-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 10
JBOD-4HDD-thresh=1G/xfs-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 5
JBOD-4HDD-thresh=1G/xfs-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 5
JBOD-4HDD-thresh=1G/xfs-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 8
JBOD-4HDD-thresh=1G/xfs-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 2
JBOD-4HDD-thresh=1G/xfs-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 159
JBOD-4HDD-thresh=1G/xfs-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 178
JBOD-4HDD-thresh=8G/btrfs-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 282
JBOD-4HDD-thresh=8G/btrfs-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 203
JBOD-4HDD-thresh=8G/btrfs-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 107
JBOD-4HDD-thresh=8G/btrfs-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 82
JBOD-4HDD-thresh=8G/btrfs-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 19
JBOD-4HDD-thresh=8G/btrfs-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 46
JBOD-4HDD-thresh=8G/ext3-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 288
JBOD-4HDD-thresh=8G/ext3-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 330
JBOD-4HDD-thresh=8G/ext3-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 229
JBOD-4HDD-thresh=8G/ext3-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 227
JBOD-4HDD-thresh=8G/ext3-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 171
JBOD-4HDD-thresh=8G/ext3-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 129
JBOD-4HDD-thresh=8G/ext4-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 13
JBOD-4HDD-thresh=8G/ext4-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 453
JBOD-4HDD-thresh=8G/ext4-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 224
JBOD-4HDD-thresh=8G/ext4-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 14
JBOD-4HDD-thresh=8G/ext4-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 11
JBOD-4HDD-thresh=8G/xfs-100dd-1-3.1.0+/vmstat-end:nr_vmscan_write 7
JBOD-4HDD-thresh=8G/xfs-100dd-2-3.1.0+/vmstat-end:nr_vmscan_write 5
JBOD-4HDD-thresh=8G/xfs-10dd-1-3.1.0+/vmstat-end:nr_vmscan_write 1126
JBOD-4HDD-thresh=8G/xfs-10dd-2-3.1.0+/vmstat-end:nr_vmscan_write 98
JBOD-4HDD-thresh=8G/xfs-1dd-1-3.1.0+/vmstat-end:nr_vmscan_write 252
JBOD-4HDD-thresh=8G/xfs-1dd-2-3.1.0+/vmstat-end:nr_vmscan_write 278
wfg@bee /export/writeback/snb% g nr_vmscan_write JBOD*/*3.2.0+/vmstat-end
JBOD-4HDD-thresh=100M/btrfs-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/btrfs-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/btrfs-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/btrfs-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/btrfs-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/btrfs-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext3-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext3-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext3-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext3-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext3-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext3-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext4-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext4-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext4-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext4-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext4-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/ext4-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=100M/xfs-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/btrfs-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext3-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext3-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext3-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext3-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext3-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext3-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext4-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext4-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext4-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext4-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext4-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/ext4-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/xfs-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/xfs-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/xfs-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/xfs-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/xfs-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=1G/xfs-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/btrfs-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/btrfs-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/btrfs-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/btrfs-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/btrfs-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/btrfs-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext3-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext3-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext3-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext3-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext3-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext3-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/ext4-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/xfs-100dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/xfs-100dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/xfs-10dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/xfs-10dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/xfs-1dd-1-3.2.0+/vmstat-end:nr_vmscan_write 0
JBOD-4HDD-thresh=8G/xfs-1dd-2-3.2.0+/vmstat-end:nr_vmscan_write 0

From: Manuel Krause <manuels-adresse@t-online.de>
To: "Wu, Fengguang" <fengguang.wu@intel.com>
Cc: 
Bcc: 
Subject: Re: Encouraged by Con Kolivas: Your IO-less-dirty-throttling patches v12
Reply-To: 
In-Reply-To: <20111217022028.GA19178@localhost>
user-agent: Mozilla/5.0 (X11; Linux i686; rv:7.0.1) Gecko/20110929 Thunderbird/7.0.1

Hi Fengguang,

On 2011-12-17 03:20, Wu Fengguang wrote:
> Hi Manuel,
>
>> Hi,
>>
>> I'm running an openSUSE 11.4 with a 3.1.4 (non-vanilla) kernel
>> source that is somehow patched by SUSE at first. Upon that I am
>> used to patch the most recent CK and BFQ patches since years.
>>
>> I'm following Con Kolivas' Blog, currently
>> http://ck-hack.blogspot.com/2011/11/310-ck2-bfs-0415.html?showComment=1324079830206#c3565024166985189501
>> (There you'll find many things I'd write in the following. So to
>> speak that's a kind of history.)
>>
>> Some kernels ago my usual workflow broke, as there were too many
>> stalls and hickups when watching a video via vlc at the same time.
>>
>> My "testcase" (as Con named it) is the following:
>> Old system
>> PIII-1400 (Tualatin)
>> SDRAM 2GB (Kingston, highest timings)
>> ASUS-TUV4X, VIA Chipset, 133/33MHz, AGP 4x
>> normally 2 IDE disks @UDMA-100 (now, recently, one failed)
>> reiserfs 3.6 as standard FS
>> swap as partiton on second disk with 4GB (originally, now on
>> first disk).
>> shmfs mounted with 3GB
>>
>> So I have 2GB RAM, 4GB swap and 3GB shmfs. Where shmfs and swap
>> and RAM may interfere.
>
> Yeah, the shmfs looks large.

The original idea behind this setup was: The normal file sizes to 
be decoded are about 400 to 800MB and would fit into the RAM part 
of the overlapping shmfs resulting in a fast processing, what is 
true. Files bigger than that would simply swap out to disk. I 
originally thought that to be as simple as if I decoded directly 
from disk to disk (and so giving the swap partition an extra use 
than to only be a suspend-to-disk area).
But that obviously isn't the case (any more), read below. From 
some kernel version on (that I don't remember) it became worse 
with stuttering, stalling or even hours to wait for the system to 
recover.

>
>>
>> I then decode an encrypted file to /dev/shm (Simple cp makes the
>> same issues without extra CPU utilization). Open it in Avidemux
>> and cut it and copy it back to the original partition (with
>> previously deleting the original file on the later=same target
>> partition).
>
> And it's a bit complex operations. Did you do that _while_ running
> vlc? No wonder vlc is impacted..

Yes, of course! I've found that to be a good test of system 
responsiveness / low latency / advantage of the CK patchset over 
vanilla. Also it's a usual workflow for me. Scrolling a website 
in firefox does show the same stutterings like vlc video 
playback, btw. Watching a video while decoding is just more 
convenient ;-)

>> Whenever the file's size exceeded about 900MB/1GB, whether to be
>> decoded to shm, later to be opened by Avidemux or to be processed
>> in Avidemux at the end, my system began to stall often and for
>> long times. Sometimes for minutes, sometimes for hours. Because
>> of weird swapping behavior. Setting back some vm things like
>> swappiness or dirty_ratio to kernel defaults (against ck2) did
>> not help out.
>>
>
> Yeah, that stress use of your memory can easily lead to a slow
> responding system.

Last night I retested the decoding, now, from and to the same 
partition and there was no loss of desktop responsiveness or 
stuttering in vlc video playback at all (same 1.2GB file as in 
the shmfs test before).

>
>> Yesterday I applied your 11 patches from v12 and they
>> applied+compiled fine. And they seem to work like a charm. I'd
>> consider that as a great effort!
>
> Thanks for trying it out! It's actually a big surprising for me.

What makes you be surprised?

>
> FYI, most of the patches are now in 3.2-rcX and the others are pending
> for 3.3. So you won't need to carry the patches for long time :-)

Nice to hear that, but patching is no problem. Can you tell what 
patches remain pending for 3.3?

>
>> Most of the hickups in vlc video playing (at the same time) are
>> gone now, they are much shorter, when decoding like explained
>> above. Also the recovery times and the overall processing time at
>> all ist much shorter due to much fewer stalls.
>>
>> I know this is no "benchmark" as usual, but it definitely shows
>> that your patches WILL have benefit for normal users.
>
> Thanks for the feedback, I appreciate it a lot! :-)

Feel free to use it as argument in discussions about the 
usefulness of your patches.

If you have any ideas on how to improve my vm experience in my 
setup or experimental patches or hints for tunable variables, I 
would be glad to read from you,

best regards, and cheers, too,

Manuel Krause

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

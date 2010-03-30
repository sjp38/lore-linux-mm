Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E5E3B6B01F5
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 02:32:26 -0400 (EDT)
Subject: Re: [PATCH]vmscan: handle underflow for get_scan_ratio
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20100330150453.8E9F.A69D9226@jp.fujitsu.com>
References: <20100330055304.GA2983@sli10-desk.sh.intel.com>
	 <20100330150453.8E9F.A69D9226@jp.fujitsu.com>
Content-Type: multipart/mixed; boundary="=-M2SdH58dzaiUotI/Nad1"
Date: Tue, 30 Mar 2010 14:32:36 +0800
Message-ID: <1269930756.17240.4.camel@sli10-desk.sh.intel.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>


--=-M2SdH58dzaiUotI/Nad1
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

On Tue, 2010-03-30 at 14:08 +0800, KOSAKI Motohiro wrote:
> Hi
> 
> > Commit 84b18490d1f1bc7ed5095c929f78bc002eb70f26 introduces a regression.
> > With it, our tmpfs test always oom. The test has a lot of rotated anon
> > pages and cause percent[0] zero. Actually the percent[0] is a very small
> > value, but our calculation round it to zero. The commit makes vmscan
> > completely skip anon pages and cause oops.
> > An option is if percent[x] is zero in get_scan_ratio(), forces it
> > to 1. See below patch.
> > But the offending commit still changes behavior. Without the commit, we scan
> > all pages if priority is zero, below patch doesn't fix this. Don't know if
> > It's required to fix this too.
> 
> Can you please post your /proc/meminfo 
attached.
> and reproduce program? I'll digg it.
our test is quite sample. mount tmpfs with double memory size and store several
copies (memory size * 2/G) of kernel in tmpfs, and then do kernel build.
for example, there is 3G memory and then tmpfs size is 6G and there is 6
kernel copy.
> Very unfortunately, this patch isn't acceptable. In past time, vmscan 
> had similar logic, but 1% swap-out made lots bug reports. 
can you elaborate this?
Completely restore previous behavior (do full scan with priority 0) is
ok too.

--=-M2SdH58dzaiUotI/Nad1
Content-Disposition: attachment; filename="meminfo"
Content-Type: text/plain; name="meminfo"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

MemTotal:        3078372 kB
MemFree:           34612 kB
Buffers:             960 kB
Cached:          2577644 kB
SwapCached:        24580 kB
Active:          2125712 kB
Inactive:         541972 kB
Active(anon):    2120276 kB
Inactive(anon):   534696 kB
Active(file):       5436 kB
Inactive(file):     7276 kB
Unevictable:           0 kB
Mlocked:               0 kB
SwapTotal:       6297472 kB
SwapFree:        6184988 kB
Dirty:              1720 kB
Writeback:         24024 kB
AnonPages:         64888 kB
Mapped:             3996 kB
Shmem:           2566004 kB
Slab:             290416 kB
SReclaimable:     113840 kB
SUnreclaim:       176576 kB
KernelStack:        3072 kB
PageTables:         6832 kB
NFS_Unstable:          0 kB
Bounce:                0 kB
WritebackTmp:          0 kB
CommitLimit:     7836656 kB
Committed_AS:    2811564 kB
VmallocTotal:   34359738367 kB
VmallocUsed:      289724 kB
VmallocChunk:   34359444080 kB
HugePages_Total:       0
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB
DirectMap4k:       10240 kB
DirectMap2M:     3127296 kB

--=-M2SdH58dzaiUotI/Nad1--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E60AD8D003B
	for <linux-mm@kvack.org>; Sun, 24 Apr 2011 22:42:29 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id CA8CE3EE0BB
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:42:26 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B58045DE93
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:42:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E9E545DE92
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:42:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A82AE08002
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:42:26 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D90B1E18001
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 11:42:25 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
In-Reply-To: <20110424235928.71af51e0@neptune.home>
References: <20110424202158.45578f31@neptune.home> <20110424235928.71af51e0@neptune.home>
Message-Id: <20110425114429.266A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Mon, 25 Apr 2011 11:42:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruno =?UTF-8?B?UHLDqW1vbnQ=?= <bonbons@linux-vserver.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

> On Sun, 24 April 2011 Bruno PrA(C)mont <bonbons@linux-vserver.org> wrote:
> > On an older system I've been running Gentoo's revdep-rebuild to check
> > for system linking/*.la consistency and after doing most of the work the
> > system starved more or less, just complaining about stuck tasks now and
> > then.
> > Memory usage graph as seen from userspace showed sudden quick increase of
> > memory usage though only a very few MB were swapped out (c.f. attached RRD
> > graph).
> 
> Seems I've hit it once again (though detected before system was fully
> stalled by trying to reclaim memory without success).
> 
> This time it was during simple compiling...
> Gathered info below:
> 
> /proc/meminfo:
> MemTotal:         480660 kB
> MemFree:           64948 kB
> Buffers:           10304 kB
> Cached:             6924 kB
> SwapCached:         4220 kB
> Active:            11100 kB
> Inactive:          15732 kB
> Active(anon):       4732 kB
> Inactive(anon):     4876 kB
> Active(file):       6368 kB
> Inactive(file):    10856 kB
> Unevictable:          32 kB
> Mlocked:              32 kB
> SwapTotal:        524284 kB
> SwapFree:         456432 kB
> Dirty:                80 kB
> Writeback:             0 kB
> AnonPages:          6268 kB
> Mapped:             2604 kB
> Shmem:                 4 kB
> Slab:             250632 kB
> SReclaimable:      51144 kB
> SUnreclaim:       199488 kB   <--- look big as well...
> KernelStack:      131032 kB   <--- what???

KernelStack is used 8K bytes per thread. then, your system should have
16000 threads. but your ps only showed about 80 processes.
Hmm... stack leak?


> PageTables:          920 kB
> NFS_Unstable:          0 kB
> Bounce:                0 kB
> WritebackTmp:          0 kB
> CommitLimit:      764612 kB
> Committed_AS:     132632 kB
> VmallocTotal:     548548 kB
> VmallocUsed:       18500 kB
> VmallocChunk:     525952 kB
> AnonHugePages:         0 kB
> DirectMap4k:       32704 kB
> DirectMap4M:      458752 kB
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

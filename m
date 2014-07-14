Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F2F936B0035
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 07:01:43 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so1762469pad.21
        for <linux-mm@kvack.org>; Mon, 14 Jul 2014 04:01:43 -0700 (PDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp. [192.51.44.36])
        by mx.google.com with ESMTPS id ko1si8902890pbd.115.2014.07.14.04.01.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Jul 2014 04:01:42 -0700 (PDT)
Received: from kw-mxauth.gw.nic.fujitsu.com (unknown [10.0.237.134])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6DE8F3EE0BD
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 20:01:41 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.nic.fujitsu.com [10.0.50.94])
	by kw-mxauth.gw.nic.fujitsu.com (Postfix) with ESMTP id 811BDAC042A
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 20:01:40 +0900 (JST)
Received: from g01jpfmpwyt01.exch.g01.fujitsu.local (g01jpfmpwyt01.exch.g01.fujitsu.local [10.128.193.38])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 29AE41DB8032
	for <linux-mm@kvack.org>; Mon, 14 Jul 2014 20:01:40 +0900 (JST)
Message-ID: <53C3B867.2020005@jp.fujitsu.com>
Date: Mon, 14 Jul 2014 20:00:55 +0900
From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: xfs: two deadlock problems occur when kswapd writebacks XFS pages.
References: <53A0013A.1010100@jp.fujitsu.com> <20140617132609.GI9508@dastard>	<53A15DC7.50001@jp.fujitsu.com> <53A7D6CC.1040605@jp.fujitsu.com> <20140624220530.GD1976@devil.localdomain>
In-Reply-To: <20140624220530.GD1976@devil.localdomain>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com
Cc: linux-mm@kvack.org, xfs@oss.sgi.com

Hi Dave,

Thank you for your comment! and I apologize for my delayed response.

As your comment, I have investigated again the RHEL7 crash dump
why the processes which doing direct memory reclaim are stuck
at shrink_inactive_list(). Then, I found the reason that the processes
and kswapd are trying to free page caches from a zone despite
the number of inactive file pages is very very small (40 pages).
kswapd moved inactive file pages to isolate file pages to free the
pages at shrink_inactive_list(). As the result, NR_INACTIVE_FILE
was 0 and NR_ISOLATED_FILE was 40.
Therefore, no one can increase NR_INACTIVE_FILE or decrease
NR_ISOLATED_FILE, so the system hangs up.
In such situation, we should not try to free inactive file
pages because kswapd and direct memory reclaimer can move inactive
file pages to isolate file pages up to 32 pages.

And, I found why the problems did not happen on the upstream kernel.
The problems did not happen because of the following commit.
---
commit 623762517e2370be3b3f95f4fe08d6c063a49b06
Author: Johannes Weiner <hannes@cmpxchg.org>
Date:   Tue May 6 12:50:07 2014 -0700

     revert "mm: vmscan: do not swap anon pages just because free+file 
is low"
---

Thank you so much!

Masayoshi Mizuma
On Wed, 25 Jun 2014 08:05:30 +1000 Dave Chinner wrote:
> On Mon, Jun 23, 2014 at 04:27:08PM +0900, Masayoshi Mizuma wrote:
>> Hi Dave,
>>
>> (I removed CCing xfs and linux-mm. And I changed your email address
>>   to @redhat.com because this email includes RHEL7 kernel stack traces.)
>
> Please don't do that. There's nothing wrong with posting RHEL7 stack
> traces to public lists (though I'd prefer you to reproduce this
> problem on a 3.15 or 3.16-rc kernel), and breaking the thread of
> discussion makes it impossible to involve the people necessary to
> solve this problem.
>
> I've re-added xfs and linux-mm to the cc list, and taken my redhat
> address off it...
>
> <snip the 3 process back traces>
>
> [looks at sysrq-w output]
>
> kswapd0 is blocked in shrink_inactive_list/congestion_wait().
>
> kswapd1 is blocked waiting for log space from
> shrink_inactive_list().
>
> kthreadd is blocked in shrink_inactive_list/congestion_wait trying
> to fork another process.
>
> xfsaild is in uninterruptible sleep, indicating that there is still
> metadata to be written to push the log tail to it's required target,
> and it will retry again in less than 20ms.
>
> xfslogd is not blocked, indicating the log has not deadlocked
> due to lack of space.
>
> there are lots of timestamp updates waiting for log space.
>
> There is one kworker stuck in data IO completion on an inode lock.
>
> There are several threads blocked on an AGF lock trying to free
> extents.
>
> The bdi writeback thread is blocked waiting for allocation.
>
> A single xfs_alloc_wq kworker is blocked in
> shrink_inactive_list/congestion_wait while trying to read in btree
> blocks for transactional modification. Indicative of memory pressure
> trashing the working set of cached metadata. waiting for memory
> reclaim
> 	- holds agf lock, blocks unlinks
>
> There are 113 (!) blocked sadc processes - why are there so many
> stats gathering processes running? If you stop gathering stats, does
> the problem go away?
>
> There are 54 mktemp processes blocked - what is generating them?
> what filesystem are they actually running on? i.e. which XFS
> filesystem in the system is having log space shortages? And what is
> the xfs_info output of that filesystem i.e. have you simply
> oversubscribed a tiny log and so it crawls along at a very slow
> pace?
>
> All of the blocked processes are on CPUs 0-3 i.e. on node 0, which
> is handled by kswapd0, which is not blocked waiting for log
> space. Hmmm - what is the value of /proc/sys/vm/zone_reclaim_mode?
> If it is not zero, does setting it to zero make the problem go away?
>
> Interestingly enough, for a system under extreme memory pressure,
> don't see any processes blocked waiting for swap space or swap IO.
> Do you have any swap space configured on this machine?  If you
> don't, does the problem go away when you add a swap device?
>
> Overall, I can't see anything that indicates that the filesystem has
> actually hung. I can see it having trouble allocating the memory it
> needs to make forwards progress, but the system itself is not
> deadlocked. Is there any IO being issued when the system is in this
> state? If there is Io being issued, then progress is being made and
> the system is merely slow because of the extreme memory pressure
> generated by the stress test.
>
> If there is not IO being issued, does the system start making
> progress again if you kill one of the memory hogs? i.e. does the
> equivalent of triggering an OOM-kill make the system responsive
> again? If it does, then the filesystem is not hung and the problem
> is that there isn't enough free memory to allow the filesystem to do
> IO and hence allow memory reclaim to make progress. In which case,
> does increasing /proc/sys/vm/min_free_kbytes make the problem go
> away?
>
> Cheers,
>
> Dave.
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

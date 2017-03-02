Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F5186B0387
	for <linux-mm@kvack.org>; Wed,  1 Mar 2017 22:24:15 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j5so70021925pfb.3
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 19:24:15 -0800 (PST)
Received: from out4439.biz.mail.alibaba.com (out4439.biz.mail.alibaba.com. [47.88.44.39])
        by mx.google.com with ESMTP id g200si6271956pfb.262.2017.03.01.19.24.12
        for <linux-mm@kvack.org>;
        Wed, 01 Mar 2017 19:24:14 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <20170228214007.5621-1-hannes@cmpxchg.org> <20170228214007.5621-2-hannes@cmpxchg.org>
In-Reply-To: <20170228214007.5621-2-hannes@cmpxchg.org>
Subject: Re: [PATCH 1/9] mm: fix 100% CPU kswapd busyloop on unreclaimable nodes
Date: Thu, 02 Mar 2017 11:23:55 +0800
Message-ID: <077c01d29304$6caf5d70$460e1850$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Andrew Morton' <akpm@linux-foundation.org>
Cc: 'Jia He' <hejianet@gmail.com>, 'Michal Hocko' <mhocko@suse.cz>, 'Mel Gorman' <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com


On March 01, 2017 5:40 AM Johannes Weiner wrote:
> 
> Jia He reports a problem with kswapd spinning at 100% CPU when
> requesting more hugepages than memory available in the system:
> 
> $ echo 4000 >/proc/sys/vm/nr_hugepages
> 
> top - 13:42:59 up  3:37,  1 user,  load average: 1.09, 1.03, 1.01
> Tasks:   1 total,   1 running,   0 sleeping,   0 stopped,   0 zombie
> %Cpu(s):  0.0 us, 12.5 sy,  0.0 ni, 85.5 id,  2.0 wa,  0.0 hi,  0.0 si,  0.0 st
> KiB Mem:  31371520 total, 30915136 used,   456384 free,      320 buffers
> KiB Swap:  6284224 total,   115712 used,  6168512 free.    48192 cached Mem
> 
>   PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND
>    76 root      20   0       0      0      0 R 100.0 0.000 217:17.29 kswapd3
> 
> At that time, there are no reclaimable pages left in the node, but as
> kswapd fails to restore the high watermarks it refuses to go to sleep.
> 
> Kswapd needs to back away from nodes that fail to balance. Up until
> 1d82de618ddd ("mm, vmscan: make kswapd reclaim in terms of nodes")
> kswapd had such a mechanism. It considered zones whose theoretically
> reclaimable pages it had reclaimed six times over as unreclaimable and
> backed away from them. This guard was erroneously removed as the patch
> changed the definition of a balanced node.
> 
> However, simply restoring this code wouldn't help in the case reported
> here: there *are* no reclaimable pages that could be scanned until the
> threshold is met. Kswapd would stay awake anyway.
> 
> Introduce a new and much simpler way of backing off. If kswapd runs
> through MAX_RECLAIM_RETRIES (16) cycles without reclaiming a single
> page, make it back off from the node. This is the same number of shots
> direct reclaim takes before declaring OOM. Kswapd will go to sleep on
> that node until a direct reclaimer manages to reclaim some pages, thus
> proving the node reclaimable again.
> 
> v2: move MAX_RECLAIM_RETRIES to mm/internal.h (Michal)
> 
> Reported-by: Jia He <hejianet@gmail.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Tested-by: Jia He <hejianet@gmail.com>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

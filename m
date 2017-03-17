Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF476B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 19:20:26 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id y6so130127349pfa.3
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 16:20:26 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id n8si9963842pll.303.2017.03.17.16.20.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Mar 2017 16:20:25 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id 21so16715045pgg.1
        for <linux-mm@kvack.org>; Fri, 17 Mar 2017 16:20:25 -0700 (PDT)
From: Tim Murray <timmurray@google.com>
Subject: [RFC 0/1] add support for reclaiming priorities per mem cgroup
Date: Fri, 17 Mar 2017 16:16:35 -0700
Message-Id: <20170317231636.142311-1-timmurray@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, surenb@google.com, totte@google.com, kernel-team@android.com
Cc: Tim Murray <timmurray@google.com>

Hi all,

I've been working to improve Android's memory management and drop lowmemorykiller from the kernel, and I'd like to get some feedback on a small patch with a lot of side effects. 

Currently, when an Android device is under memory pressure, one of three things will happen from kswapd:

1. Compress an anonymous page to ZRAM.
2. Evict a file page.
3. Kill a process via lowmemorykiller.

The first two are cheap and per-page, the third is relatively cheap in the short term, frees many pages, and may cause power and performance penalties later on when the process has to be started again. For lots of reasons, I'd like a better balance between reclamation and killing on Android.

One of the nice things about Android from an optimization POV is that the execution model is more constrained than a generic Linux machine. There are only a limited number of processes that need to execute quickly for the device to appear to have good performance, and a userspace daemon (called ActivityManagerService) knows exactly what those processes are at any given time. We've made use of that in the past via cpusets and schedtune to limit the CPU resources available to background processes, and I think we can apply the same concept to memory.

This patch adds a new tunable to mem cgroups, memory.priority. A mem cgroup with a non-zero priority will not be eligible for scanning until the scan_control's priority is greater than zero. Once the mem cgroup is eligible for scanning, the priority acts as a bias to reduce the number of pages that should be scanned.

We've seen cases on Android where the global LRU isn't sufficient. For example, notifications in Android are rendered as part of a separate process that runs infrequently. However, when a notification appears and the user slides down the notification tray, we'll often see dropped frames due to page faults if there has been severe memory pressure. There are similar issues with other persistent processes.

The goal on an Android device is to aggressively evict from very low-priority background tasks that are likely to be killed anyway, since this will reduce the likelihood of lowmemorykiller running in the first place. It will still evict some from foreground and persistent processes, but it should help ensure that background processes are effectively reduced to the size of their heaps before evicting from more critical tasks. This should mean fewer background processes end up killed, which should improve performance and power on Android across the board (since it costs significantly less to page things back in than to replay the entirety of application startup).

The follow-on that I'm also experimenting with is how to improve vmpressure such that userspace can have some idea when low-priority memory cgroups are about as small as they can get. The correct time for Android to kill a background process under memory pressure is when there is evidence that a process has to be killed in order to alleviate memory pressure. If the device is below the low memory watermark and we know that there's probably no way to reclaim any more from background processes, then a userspace daemon should kill one or more background processes to fix that. Per-cgroup priority could be the first step toward that information.

I've tested a version of this patch on a Pixel running 3.18 along with an overhauled version of lmkd (the Android userspace lowmemorykiller daemon), and it does seem to work fine. I've ported it forward but have not yet rigorously tested it at TOT, since I don't have an Android test setup running TOT. While I'm getting my tests ported over, I would like some feedback on adding another tunable as well as what the tunable's interface should be--I really don't like the 0-10 priority scheme I have in the patch but I don't have a better idea.

Thanks,
Tim

Tim Murray (1):
  mm, memcg: add prioritized reclaim

 include/linux/memcontrol.h | 20 +++++++++++++++++++-
 mm/memcontrol.c            | 33 +++++++++++++++++++++++++++++++++
 mm/vmscan.c                |  3 ++-
 3 files changed, 54 insertions(+), 2 deletions(-)

-- 
2.12.0.367.g23dc2f6d3c-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

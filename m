Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 02A076B0005
	for <linux-mm@kvack.org>; Thu, 25 Feb 2016 04:23:18 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id g62so18590224wme.0
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:23:17 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id z9si2984488wmg.121.2016.02.25.01.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Feb 2016 01:23:16 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id a4so2307880wme.3
        for <linux-mm@kvack.org>; Thu, 25 Feb 2016 01:23:16 -0800 (PST)
Date: Thu, 25 Feb 2016 10:23:15 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-ID: <20160225092315.GD17573@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>

On Wed 24-02-16 19:47:06, Hugh Dickins wrote:
[...]
> Boot with mem=1G (or boot your usual way, and do something to occupy
> most of the memory: I think /proc/sys/vm/nr_hugepages provides a great
> way to gobble up most of the memory, though it's not how I've done it).
> 
> Make sure you have swap: 2G is more than enough.  Copy the v4.5-rc5
> kernel source tree into a tmpfs: size=2G is more than enough.
> make defconfig there, then make -j20.
> 
> On a v4.5-rc5 kernel that builds fine, on mmotm it is soon OOM-killed.
> 
> Except that you'll probably need to fiddle around with that j20,
> it's true for my laptop but not for my workstation.  j20 just happens
> to be what I've had there for years, that I now see breaking down
> (I can lower to j6 to proceed, perhaps could go a bit higher,
> but it still doesn't exercise swap very much).
> 
> This OOM detection rework significantly lowers the number of jobs
> which can be run in parallel without being OOM-killed. 

This all smells like pre mature OOM because of a high order allocation
(order-2 for fork) which Tetuo has seen already. Sergey Senozhatsky is
reporting order-2 OOMs as well. It is true that what we have in the
mmomt right now is quite fragile if all order-N+ are completely
depleted. That was the case for both Tetsuo and Sergey. I have tried to
mitigate this at least to some degree by
http://lkml.kernel.org/r/20160204133905.GB14425@dhcp22.suse.cz (below
with the full changelog) but I haven't heard back whether it helped
so I haven't posted the official patch yet.

I also suspect that something is not quite right with the compaction and
it gives up too early even though we have quite a lot reclaimable pages.
I do not have any numbers for that because I didn't have a load to
reproduce this problem yet. I will try your setup and see what I can do
about that. It would be great if you could give the patch below a try
and see if it helps.
---

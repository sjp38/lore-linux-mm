Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DED56B03AC
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:26:20 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id p64so12062036oif.0
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:26:20 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 63si724134otb.92.2017.04.19.00.26.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 00:26:19 -0700 (PDT)
Message-Id: <201704190726.v3J7QAiC076509@www262.sakura.ne.jp>
Subject: Re: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke resume
 from s2ram
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Wed, 19 Apr 2017 16:26:10 +0900
References: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp> <20170419071039.GB28263@dhcp22.suse.cz>
In-Reply-To: <20170419071039.GB28263@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

> On Wed 19-04-17 14:41:30, Tetsuo Handa wrote:
> [...]
> > Somebody is waiting forever with cpu_hotplug.lock held?
> 
> Why would that matter for drain_all_pages? It doesn't use
> get_online_cpus since a459eeb7b852 ("mm, page_alloc: do not depend on
> cpu hotplug locks inside the allocator") while ce612879ddc7 ("mm: move
> pcp and lru-pcp draining into single wq") was merged later.
> 

Looking at ce612879ddc7 ("mm: move pcp and lru-pcp draining into single wq"),
we merged "lru-add-drain" (!WQ_FREEZABLE && WQ_MEM_RECLAIM) workqueue and
"vmstat" (WQ_FREEZABLE && WQ_MEM_RECLAIM) workqueue into
"mm_percpu_wq" (WQ_FREEZABLE && WQ_MEM_RECLAIM) workqueue.

-       lru_add_drain_wq = alloc_workqueue("lru-add-drain", WQ_MEM_RECLAIM, 0);
-       vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
+       mm_percpu_wq = alloc_workqueue("mm_percpu_wq",
+                                      WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);

That means "lru-add-drain" became freezable, doesn't it? And this problem
occurs around resume operation where all freezable threads are frozen?
Then, lru_add_drain_per_cpu() cannot be performed due to mm_percpu_wq frozen?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

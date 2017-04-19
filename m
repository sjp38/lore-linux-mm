Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BE7E82806DB
	for <linux-mm@kvack.org>; Wed, 19 Apr 2017 03:57:16 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 6so1598011wra.23
        for <linux-mm@kvack.org>; Wed, 19 Apr 2017 00:57:16 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z63si19515845wmb.23.2017.04.19.00.57.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 19 Apr 2017 00:57:15 -0700 (PDT)
Date: Wed, 19 Apr 2017 09:57:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Re: Re: "mm: move pcp and lru-pcp draining into single wq" broke
 resume from s2ram
Message-ID: <20170419075712.GB29789@dhcp22.suse.cz>
References: <201704190541.v3J5fUE3054131@www262.sakura.ne.jp>
 <20170419071039.GB28263@dhcp22.suse.cz>
 <201704190726.v3J7QAiC076509@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201704190726.v3J7QAiC076509@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux PM list <linux-pm@vger.kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Linux-Renesas <linux-renesas-soc@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Wed 19-04-17 16:26:10, Tetsuo Handa wrote:
> > On Wed 19-04-17 14:41:30, Tetsuo Handa wrote:
> > [...]
> > > Somebody is waiting forever with cpu_hotplug.lock held?
> > 
> > Why would that matter for drain_all_pages? It doesn't use
> > get_online_cpus since a459eeb7b852 ("mm, page_alloc: do not depend on
> > cpu hotplug locks inside the allocator") while ce612879ddc7 ("mm: move
> > pcp and lru-pcp draining into single wq") was merged later.
> > 
> 
> Looking at ce612879ddc7 ("mm: move pcp and lru-pcp draining into single wq"),
> we merged "lru-add-drain" (!WQ_FREEZABLE && WQ_MEM_RECLAIM) workqueue and
> "vmstat" (WQ_FREEZABLE && WQ_MEM_RECLAIM) workqueue into
> "mm_percpu_wq" (WQ_FREEZABLE && WQ_MEM_RECLAIM) workqueue.
> 
> -       lru_add_drain_wq = alloc_workqueue("lru-add-drain", WQ_MEM_RECLAIM, 0);
> -       vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
> +       mm_percpu_wq = alloc_workqueue("mm_percpu_wq",
> +                                      WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);
> 
> That means "lru-add-drain" became freezable, doesn't it? And this problem
> occurs around resume operation where all freezable threads are frozen?
> Then, lru_add_drain_per_cpu() cannot be performed due to mm_percpu_wq frozen?

Ohh, right you are! Very well spotted. I have completely missed
WQ_FREEZABLE there. The following should work
---

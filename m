Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6AD66B0033
	for <linux-mm@kvack.org>; Tue, 21 Nov 2017 10:33:16 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id k126so666227wmd.5
        for <linux-mm@kvack.org>; Tue, 21 Nov 2017 07:33:16 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id t2si3523748edf.176.2017.11.21.07.33.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 21 Nov 2017 07:33:15 -0800 (PST)
Date: Tue, 21 Nov 2017 10:32:57 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, mlock, vmscan: no more skipping pagevecs
Message-ID: <20171121153257.GA23920@cmpxchg.org>
References: <20171104224312.145616-1-shakeelb@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171104224312.145616-1-shakeelb@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <bsingharora@gmail.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, Nicholas Piggin <npiggin@gmail.com>, Dan Williams <dan.j.williams@intel.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Nov 04, 2017 at 03:43:12PM -0700, Shakeel Butt wrote:
> When a thread mlocks an address space backed by file, a new
> page is allocated (assuming file page is not in memory), added
> to the local pagevec (lru_add_pvec), I/O is triggered and the
> thread then sleeps on the page. On I/O completion, the thread
> can wake on a different CPU, the mlock syscall will then sets
> the PageMlocked() bit of the page but will not be able to put
> that page in unevictable LRU as the page is on the pagevec of
> a different CPU. Even on drain, that page will go to evictable
> LRU because the PageMlocked() bit is not checked on pagevec
> drain.
> 
> The page will eventually go to right LRU on reclaim but the
> LRU stats will remain skewed for a long time.
> 
> However, this issue does not happen for anon pages on swap
> because unlike file pages, anon pages are not added to pagevec
> until they have been fully swapped in.

How so? __read_swap_cache_async() is the core function that allocates
the page, and that always puts the page on the pagevec before IO is
initiated.

> Also the fault handler uses vm_flags to set the PageMlocked() bit of
> such anon pages even before returning to mlock() syscall and mlocked
> pages will skip pagevecs and directly be put into unevictable LRU.

Where does the swap fault path set PageMlocked()?

I might just be missing something.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

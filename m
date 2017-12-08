Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0711B6B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 19:29:42 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id a45so4957305wra.14
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 16:29:41 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c15si2639946wra.5.2017.12.07.16.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 16:29:40 -0800 (PST)
Date: Thu, 7 Dec 2017 16:29:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] mm, swap: Fix race between swapoff and some swap
 operations
Message-Id: <20171207162937.6a179063a7c92ecac77e44af@linux-foundation.org>
In-Reply-To: <20171207011426.1633-1-ying.huang@intel.com>
References: <20171207011426.1633-1-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shli@fb.com>, Mel Gorman <mgorman@techsingularity.net>, =?ISO-8859-1?Q?J?= =?ISO-8859-1?Q?=E9r=F4me?= Glisse <jglisse@redhat.com>, Michal Hocko <mhocko@suse.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Jan Kara <jack@suse.cz>, Dave Jiang <dave.jiang@intel.com>, Aaron Lu <aaron.lu@intel.com>

On Thu,  7 Dec 2017 09:14:26 +0800 "Huang, Ying" <ying.huang@intel.com> wrote:

> When the swapin is performed, after getting the swap entry information
> from the page table, the PTL (page table lock) will be released, then
> system will go to swap in the swap entry, without any lock held to
> prevent the swap device from being swapoff.  This may cause the race
> like below,
> 
> CPU 1				CPU 2
> -----				-----
> 				do_swap_page
> 				  swapin_readahead
> 				    __read_swap_cache_async
> swapoff				      swapcache_prepare
>   p->swap_map = NULL		        __swap_duplicate
> 					  p->swap_map[?] /* !!! NULL pointer access */
> 
> Because swap off is usually done when system shutdown only, the race
> may not hit many people in practice.  But it is still a race need to
> be fixed.

swapoff is so rare that it's hard to get motivated about any fix which
adds overhead to the regular codepaths.

Is there something we can do to ensure that all the overhead of this
fix is placed into the swapoff side?  stop_machine() may be a bit
brutal, but a surprising amount of code uses it.  Any other ideas?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

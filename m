Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 66A456B0038
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 16:17:18 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id u138so8668978wmu.19
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 13:17:18 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id j18sor571242wrd.31.2017.10.24.13.17.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 24 Oct 2017 13:17:17 -0700 (PDT)
Date: Wed, 25 Oct 2017 05:17:08 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH -mm] mm, swap: Fix false error message in
 __swp_swapcount()
Message-ID: <20171024201708.GA25022@bgram>
References: <20171024024700.23679-1-ying.huang@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024024700.23679-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Tim Chen <tim.c.chen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, stable@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>

On Tue, Oct 24, 2017 at 10:47:00AM +0800, Huang, Ying wrote:
> From: Ying Huang <ying.huang@intel.com>
> 
> __swp_swapcount() is used in __read_swap_cache_async().  Where the
> invalid swap entry (offset > max) may be supplied during swap
> readahead.  But __swp_swapcount() will print error message for these
> expected invalid swap entry as below, which will make the users
> confusing.
> 
>   swap_info_get: Bad swap offset entry 0200f8a7
> 
> So the swap entry checking code in __swp_swapcount() is changed to
> avoid printing error message for it.  To avoid to duplicate code with
> __swap_duplicate(), a new helper function named
> __swap_info_get_silence() is added and invoked in both places.

It's the problem caused by readahead, not __swap_info_get which is low-end
primitive function. Instead, please fix high-end swapin_readahead to limit
to last valid block as handling to avoid swap header which is special case,
too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

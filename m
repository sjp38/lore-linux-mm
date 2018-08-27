Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id A012E6B42D5
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 18:44:40 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id f13-v6so332546pgs.15
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 15:44:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id cb14-v6si567966plb.178.2018.08.27.15.44.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Aug 2018 15:44:39 -0700 (PDT)
Date: Mon, 27 Aug 2018 15:44:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] swap: Use __try_to_reclaim_swap() in
 free_swap_and_cache()
Message-Id: <20180827154437.f48115fb23cc214b76bee97d@linux-foundation.org>
In-Reply-To: <20180827075535.17406-2-ying.huang@intel.com>
References: <20180827075535.17406-1-ying.huang@intel.com>
	<20180827075535.17406-2-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Ying <ying.huang@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Shaohua Li <shli@kernel.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>

On Mon, 27 Aug 2018 15:55:33 +0800 Huang Ying <ying.huang@intel.com> wrote:

> The code path to reclaim the swap entry in free_swap_and_cache() is
> almost same as that of __try_to_reclaim_swap().  The largest
> difference is just coding style.  So the support to the additional
> requirement of free_swap_and_cache() is added into
> __try_to_reclaim_swap().  free_swap_and_cache() is changed to call
> __try_to_reclaim_swap(), and delete the duplicated code.  This will
> improve code readability and reduce the potential bugs.
> 
> There are 2 functionality differences between __try_to_reclaim_swap()
> and swap entry reclaim code of free_swap_and_cache().
> 
> - free_swap_and_cache() only reclaims the swap entry if the page is
>   unmapped or swap is getting full.  The support has been added into
>   __try_to_reclaim_swap().
> 
> - try_to_free_swap() (called by __try_to_reclaim_swap()) checks
>   pm_suspended_storage(), while free_swap_and_cache() not.  I think
>   this is OK.  Because the page and the swap entry can be reclaimed
>   later eventually.

hm.  Having functions take `mode' arguments which specify their actions
in this manner isn't popular (Linus ;)) but I guess the end result is
somewhat better.

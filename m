Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 643876B0033
	for <linux-mm@kvack.org>; Tue,  3 Oct 2017 18:27:41 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y8so2744408wrd.0
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 15:27:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s63si9439326wmb.56.2017.10.03.15.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 15:27:40 -0700 (PDT)
Date: Tue, 3 Oct 2017 15:27:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm/swap: Fix race conditions in swap_slots cache
 init
Message-Id: <20171003152737.c955053c04ee6ad9f70dc5eb@linux-foundation.org>
In-Reply-To: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
References: <65a9d0f133f63e66bba37b53b2fd0464b7cae771.1500677066.git.tim.c.chen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ying Huang <ying.huang@intel.com>, Wenwei Tao <wenwei.tww@alibaba-inc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Fri, 21 Jul 2017 15:45:00 -0700 Tim Chen <tim.c.chen@linux.intel.com> wrote:

> Memory allocations can happen before the swap_slots cache initialization
> is completed during cpu bring up.  If we are low on memory, we could call
> get_swap_page and access swap_slots_cache before it is fully initialized.
> 
> Add a check in get_swap_page for initialized swap_slots_cache
> to prevent this condition.  Similar check already exists in
> free_swap_slot.  Also annotate the checks to indicate the likely
> condition.
> 
> We also added a memory barrier to make sure that the locks
> initialization are done before the assignment of cache->slots
> and cache->slots_ret pointers. This ensures the assumption
> that it is safe to acquire the slots cache locks and use the slots
> cache when the corresponding cache->slots or cache->slots_ret
> pointers are non null.

I guess that the user-visible effect is "crash on boot on large
machine".  Or something.  Please don't make me guess!

Which kernel version(s) do you believe need this patch, and why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

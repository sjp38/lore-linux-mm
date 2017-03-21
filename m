Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B9AA56B0038
	for <linux-mm@kvack.org>; Tue, 21 Mar 2017 16:42:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c23so328305478pfj.0
        for <linux-mm@kvack.org>; Tue, 21 Mar 2017 13:42:21 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id u5si22488005pgg.140.2017.03.21.13.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Mar 2017 13:42:20 -0700 (PDT)
Message-ID: <1490128938.3567.2.camel@linux.intel.com>
Subject: Re: [PATCH] mm, swap: Remove WARN_ON_ONCE() in free_swap_slot()
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Tue, 21 Mar 2017 16:42:18 -0400
In-Reply-To: <20170320062657.26683-1-ying.huang@intel.com>
References: <20170320062657.26683-1-ying.huang@intel.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@linux.intel.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2017-03-20 at 14:26 +0800, Huang, Ying wrote:
> From: Huang Ying <ying.huang@intel.com>
> 
> Before commit 452b94b8c8c7 ("mm/swap: don't BUG_ON() due to
> uninitialized swap slot cache"), the following bug is reported,
> 
> A  ------------[ cut here ]------------
> A  kernel BUG at mm/swap_slots.c:270!
> A  invalid opcode: 0000 [#1] SMP
> A  CPU: 5 PID: 1745 Comm: (sd-pam) Not tainted 4.11.0-rc1-00243-g24c534bb161b #1
> A  Hardware name: System manufacturer System Product Name/Z170-K, BIOS
> 1803 05/06/2016
> A  RIP: 0010:free_swap_slot+0xba/0xd0
> A  Call Trace:
> A A A swap_free+0x36/0x40
> A A A do_swap_page+0x360/0x6d0
> A A A __handle_mm_fault+0x880/0x1080
> A A A handle_mm_fault+0xd0/0x240
> A A A __do_page_fault+0x232/0x4d0
> A A A do_page_fault+0x20/0x70
> A A A page_fault+0x22/0x30
> A  ---[ end trace aefc9ede53e0ab21 ]---
> 
> This is raised by the BUG_ON(!swap_slot_cache_initialized) in
> free_swap_slot().A A This is incorrect, because even if the swap slots
> cache fails to be initialized, the swap should operate properly
> without the swap slots cache.A A And the use_swap_slot_cache check later
> in the function will protect the uninitialized swap slots cache case.
> 
> In commit 452b94b8c8c7, the BUG_ON() is replaced by WARN_ON_ONCE().
> In the patch, the WARN_ON_ONCE() is removed too.
> 

This replaces my previous patch to replace the BUG_ON.

Acked-by: Tim Chen <tim.c.chen@linux.intel.com>

> Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Tim Chen <tim.c.chen@linux.intel.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
> ---
> A mm/swap_slots.c | 2 --
> A 1 file changed, 2 deletions(-)
> 
> diff --git a/mm/swap_slots.c b/mm/swap_slots.c
> index 7ebb23836f68..b1ccb58ad397 100644
> --- a/mm/swap_slots.c
> +++ b/mm/swap_slots.c
> @@ -267,8 +267,6 @@ int free_swap_slot(swp_entry_t entry)
> A {
> A 	struct swap_slots_cache *cache;
> A 
> -	WARN_ON_ONCE(!swap_slot_cache_initialized);
> -
> A 	cache = &get_cpu_var(swp_slots);
> A 	if (use_swap_slot_cache && cache->slots_ret) {
> A 		spin_lock_irq(&cache->free_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

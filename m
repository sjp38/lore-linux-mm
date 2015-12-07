Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 268836B0258
	for <linux-mm@kvack.org>; Mon,  7 Dec 2015 08:48:15 -0500 (EST)
Received: by wmec201 with SMTP id c201so166283404wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 05:48:14 -0800 (PST)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id ge7si36513892wjc.227.2015.12.07.05.48.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Dec 2015 05:48:13 -0800 (PST)
Received: by wmec201 with SMTP id c201so166282731wme.0
        for <linux-mm@kvack.org>; Mon, 07 Dec 2015 05:48:13 -0800 (PST)
Date: Mon, 7 Dec 2015 14:48:12 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm: Export nr_swap_pages
Message-ID: <20151207134812.GA20782@dhcp22.suse.cz>
References: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1449244734-25733-1-git-send-email-chris@chris-wilson.co.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: intel-gfx@lists.freedesktop.org, "Goel, Akash" <akash.goel@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Fri 04-12-15 15:58:53, Chris Wilson wrote:
> Some modules, like i915.ko, use swappable objects and may try to swap
> them out under memory pressure (via the shrinker). Before doing so, they
> want to check using get_nr_swap_pages() to see if any swap space is
> available as otherwise they will waste time purging the object from the
> device without recovering any memory for the system. This requires the
> nr_swap_pages counter to be exported to the modules.

I guess it should be sufficient to change get_nr_swap_pages into a real
function and export it rather than giving the access to the counter
directly?
 
> Signed-off-by: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: "Goel, Akash" <akash.goel@intel.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: linux-mm@kvack.org
> ---
>  mm/swapfile.c | 6 ++++++
>  1 file changed, 6 insertions(+)
> 
> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 58877312cf6b..2d259fdb2347 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -48,6 +48,12 @@ static sector_t map_swap_entry(swp_entry_t, struct block_device**);
>  DEFINE_SPINLOCK(swap_lock);
>  static unsigned int nr_swapfiles;
>  atomic_long_t nr_swap_pages;
> +/*
> + * Some modules use swappable objects and may try to swap them out under
> + * memory pressure (via the shrinker). Before doing so, they may wish to
> + * check to see if any swap space is available.
> + */
> +EXPORT_SYMBOL_GPL(nr_swap_pages);
>  /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
>  long total_swap_pages;
>  static int least_priority;
> -- 
> 2.6.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

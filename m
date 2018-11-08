Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C5F376B05A9
	for <linux-mm@kvack.org>; Thu,  8 Nov 2018 03:33:00 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f3-v6so6574130edt.11
        for <linux-mm@kvack.org>; Thu, 08 Nov 2018 00:33:00 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g22-v6si1520293ejt.296.2018.11.08.00.32.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Nov 2018 00:32:59 -0800 (PST)
Date: Thu, 8 Nov 2018 09:32:58 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v3 2/4] mm: convert zone->managed_pages to atomic variable
Message-ID: <20181108083258.GP27423@dhcp22.suse.cz>
References: <1541665398-29925-1-git-send-email-arunks@codeaurora.org>
 <1541665398-29925-3-git-send-email-arunks@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1541665398-29925-3-git-send-email-arunks@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: akpm@linux-foundation.org, keescook@chromium.org, khlebnikov@yandex-team.ru, minchan@kernel.org, vbabka@suse.cz, osalvador@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, getarunks@gmail.com

On Thu 08-11-18 13:53:16, Arun KS wrote:
> totalram_pages, zone->managed_pages and totalhigh_pages updates
> are protected by managed_page_count_lock, but readers never care
> about it. Convert these variables to atomic to avoid readers
> potentially seeing a store tear.
> 
> This patch converts zone->managed_pages. Subsequent patches will
> convert totalram_panges, totalhigh_pages and eventually
> managed_page_count_lock will be removed.
> 
> Suggested-by: Michal Hocko <mhocko@suse.com>
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Arun KS <arunks@codeaurora.org>
> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> ---
> Main motivation was that managed_page_count_lock handling was
> complicating things. It was discussed in lenght here,
> https://lore.kernel.org/patchwork/patch/995739/#1181785
> So it seemes better to remove the lock and convert variables
> to atomic, with preventing poteintial store-to-read tearing as
> a bonus.

Do not be afraid to put this into the changelog. It is much better to
have it there in case anybody wonders in future and use git blame rather
than chase an email archive to find it in the foot note. The same
applies to the meta patch.

> Most of the changes are done by below coccinelle script,
> 
> @@
> struct zone *z;
> expression e1;
> @@
> (
> - z->managed_pages = e1
> + atomic_long_set(&z->managed_pages, e1)
> |
> - e1->managed_pages++
> + atomic_long_inc(&e1->managed_pages)
> |
> - z->managed_pages
> + zone_managed_pages(z)
> )
> 
> @@
> expression e,e1;
> @@
> - e->managed_pages += e1
> + atomic_long_add(e1, &e->managed_pages)
> 
> @@
> expression z;
> @@
> - z.managed_pages
> + zone_managed_pages(&z)
> 
> Then, manually apply following change,
> include/linux/mmzone.h
> 
> - unsigned long managed_pages;
> + atomic_long_t managed_pages;
> 
> +static inline unsigned long zone_managed_pages(struct zone *zone)
> +{
> +       return (unsigned long)atomic_long_read(&zone->managed_pages);
> +}
> 
-- 
Michal Hocko
SUSE Labs

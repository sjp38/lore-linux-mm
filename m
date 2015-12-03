Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 839B56B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 05:59:52 -0500 (EST)
Received: by wmec201 with SMTP id c201so20967274wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:59:52 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id v62si49457350wme.73.2015.12.03.02.59.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Dec 2015 02:59:51 -0800 (PST)
Received: by wmec201 with SMTP id c201so20966687wme.0
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:59:51 -0800 (PST)
Date: Thu, 3 Dec 2015 11:59:48 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH]mm:Correctly update number of rotated pages on active
 list.
Message-ID: <20151203105948.GE9264@dhcp22.suse.cz>
References: <20151203100809.GA4544@pradeepkumarubtnb.spreadtrum.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151203100809.GA4544@pradeepkumarubtnb.spreadtrum.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Pradeep Goswami (Pradeep Kumar Goswami)" <Pradeep.Goswami@spreadtrum.com>
Cc: "rebecca@android.com" <rebecca@android.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sanjeev.yadav@spreatrum.com" <sanjeev.yadav@spreatrum.com>

On Thu 03-12-15 10:08:11, Pradeep Goswami (Pradeep Kumar Goswami) wrote:
> This patch corrects the number of pages which are rotated on active list.
> The counter for rotated pages effects the number of pages
> to be scanned on active pages list in  low memory situations.

Why this should be changed?

This seems to be deliberate:
        /*
         * Count referenced pages from currently used mappings as rotated,
         * even though only some of them are actually re-activated.  This
         * helps balance scan pressure between file and anonymous pages in
         * get_scan_count.
         */
        reclaim_stat->recent_rotated[file] += nr_rotated;

What kind of problem are you trying to fix?

> 
> Signed-off-by: Pradeep Goswami <pradeep.goswami@spredtrum.com>
> Cc: Rebecca Schultz Zavin <rebecca@android.com>
> Cc: Vladimir Davydov <vdavydov@parallels.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
> --- a/mm/vmscan.c       2015-11-18 20:55:38.208838142 +0800
> +++ b/mm/vmscan.c       2015-11-19 14:37:31.189838998 +0800
> @@ -1806,7 +1806,6 @@ static void shrink_active_list(unsigned
>  
>                 if (page_referenced(page, 0, sc->target_mem_cgroup,
>                                     &vm_flags)) {
> -                       nr_rotated += hpage_nr_pages(page);
>                         /*  
>                          * Identify referenced, file-backed active pages and 
>                          * give them one more trip around the active list. So
> @@ -1818,6 +1817,7 @@ static void shrink_active_list(unsigned
>                          */  
>                         if ((vm_flags & VM_EXEC) && page_is_file_cache(page)) {
>                                 list_add(&page->lru, &l_active);
> +                               nr_rotated += hpage_nr_pages(page);
>                                 continue;
>                         }   
>                 }   
> 
> Thanks,
> Pradeep.
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

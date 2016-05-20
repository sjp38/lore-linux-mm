Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE266B025E
	for <linux-mm@kvack.org>; Fri, 20 May 2016 09:06:52 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k186so1399292lfe.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:06:52 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id at8si25601035wjc.92.2016.05.20.06.06.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 May 2016 06:06:50 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id s63so14518330wme.2
        for <linux-mm@kvack.org>; Fri, 20 May 2016 06:06:50 -0700 (PDT)
Date: Fri, 20 May 2016 15:06:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, migrate: increment fail count on ENOMEM
Message-ID: <20160520130649.GB5197@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1605191510230.32658@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 19-05-16 15:11:23, David Rientjes wrote:
> If page migration fails due to -ENOMEM, nr_failed should still be
> incremented for proper statistics.
> 
> This was encountered recently when all page migration vmstats showed 0,
> and inferred that migrate_pages() was never called, although in reality
> the first page migration failed because compaction_alloc() failed to find
> a migration target.
> 
> This patch increments nr_failed so the vmstat is properly accounted on
> ENOMEM.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Acked-by: Michal Hocko <mhocko@suse.com>

One question though

> ---
>  mm/migrate.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1171,6 +1171,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  
>  			switch(rc) {
>  			case -ENOMEM:
> +				nr_failed++;
>  				goto out;
>  			case -EAGAIN:
>  				retry++;

Why don't we need also to count also retries?
---
diff --git a/mm/migrate.c b/mm/migrate.c
index 53ab6398e7a2..ef9c5211ae3c 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1190,9 +1190,9 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 			}
 		}
 	}
+out:
 	nr_failed += retry;
 	rc = nr_failed;
-out:
 	if (nr_succeeded)
 		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
 	if (nr_failed)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

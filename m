Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f173.google.com (mail-ea0-f173.google.com [209.85.215.173])
	by kanga.kvack.org (Postfix) with ESMTP id 970536B003B
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 09:42:21 -0500 (EST)
Received: by mail-ea0-f173.google.com with SMTP id o10so349909eaj.32
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 06:42:20 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTP id e48si15019419eeh.29.2013.12.06.06.42.20
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 06:42:20 -0800 (PST)
Message-ID: <52A1E248.1000204@suse.cz>
Date: Fri, 06 Dec 2013 15:42:16 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] mm/migrate: correct return value of migrate_pages()
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 12/06/2013 09:41 AM, Joonsoo Kim wrote:
> migrate_pages() should return number of pages not migrated or error code.
> When unmap_and_move return -EAGAIN, outer loop is re-execution without
> initialising nr_failed. This makes nr_failed over-counted.
>
> So this patch correct it by initialising nr_failed in outer loop.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 3747fcd..1f59ccc 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1102,6 +1102,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>
>   	for(pass = 0; pass < 10 && retry; pass++) {
>   		retry = 0;
> +		nr_failed = 0;
>
>   		list_for_each_entry_safe(page, page2, from, lru) {
>   			cond_resched();
>

If I'm reading the code correctly, unmap_and_move() (and 
unmap_and_move_huge_page() as well) deletes all pages from the 'from' 
list, unless it fails with -EAGAIN. So the only pages you see in 
subsequent passes are those that failed with -EAGAIN and those are not 
counted as nr_failed. So there shouldn't be over-count, but your patch 
could result in under-count.

Perhaps a comment somewhere would clarify this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 762BE6B003A
	for <linux-mm@kvack.org>; Fri,  6 Dec 2013 09:52:09 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id e16so526115qcx.17
        for <linux-mm@kvack.org>; Fri, 06 Dec 2013 06:52:09 -0800 (PST)
Received: from a9-113.smtp-out.amazonses.com (a9-113.smtp-out.amazonses.com. [54.240.9.113])
        by mx.google.com with ESMTP id i9si32286641qce.75.2013.12.06.06.52.08
        for <linux-mm@kvack.org>;
        Fri, 06 Dec 2013 06:52:08 -0800 (PST)
Date: Fri, 6 Dec 2013 14:52:07 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/4] mm/migrate: correct return value of
 migrate_pages()
In-Reply-To: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
Message-ID: <00000142c864eed3-5e3737e5-9262-418a-9341-60b712ae281e-000000@email.amazonses.com>
References: <1386319310-28016-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Joonsoo Kim <js1304@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 6 Dec 2013, Joonsoo Kim wrote:

> migrate_pages() should return number of pages not migrated or error code.
> When unmap_and_move return -EAGAIN, outer loop is re-execution without
> initialising nr_failed. This makes nr_failed over-counted.
>
> So this patch correct it by initialising nr_failed in outer loop.

Well nr_retry is the total number of attempts that got EGAIN. nr_failed is
the total number of failed attempts. You are making nr_failed the number
of pages of the list that have failed to migrated. That syncs with the
description.

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 3747fcd..1f59ccc 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1102,6 +1102,7 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>
>  	for(pass = 0; pass < 10 && retry; pass++) {
>  		retry = 0;
> +		nr_failed = 0;

The initialization of nr_failed and retry earlier is then useless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

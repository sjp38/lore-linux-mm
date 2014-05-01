Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id F0E236B0035
	for <linux-mm@kvack.org>; Thu,  1 May 2014 01:26:01 -0400 (EDT)
Received: by mail-qg0-f44.google.com with SMTP id i50so1524292qgf.17
        for <linux-mm@kvack.org>; Wed, 30 Apr 2014 22:26:01 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n7si12164509qas.194.2014.04.30.22.26.00
        for <linux-mm@kvack.org>;
        Wed, 30 Apr 2014 22:26:01 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch 2/2] mm, compaction: return failed migration target pages back to freelist
Date: Thu,  1 May 2014 01:10:05 -0400
Message-Id: <5361dae9.4781e00a.74f8.ffff8c8eSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <alpine.DEB.2.02.1404301744400.8415@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1404301744110.8415@chino.kir.corp.google.com> <alpine.DEB.2.02.1404301744400.8415@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, vbabka@suse.cz, iamjoonsoo.kim@lge.com, gthelen@google.com, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 30, 2014 at 05:45:27PM -0700, David Rientjes wrote:
> Memory compaction works by having a "freeing scanner" scan from one end of a 
> zone which isolates pages as migration targets while another "migrating scanner" 
> scans from the other end of the same zone which isolates pages for migration.
> 
> When page migration fails for an isolated page, the target page is returned to 
> the system rather than the freelist built by the freeing scanner.  This may 
> require the freeing scanner to continue scanning memory after suitable migration 
> targets have already been returned to the system needlessly.
> 
> This patch returns destination pages to the freeing scanner freelist when page 
> migration fails.  This prevents unnecessary work done by the freeing scanner but 
> also encourages memory to be as compacted as possible at the end of the zone.
> 
> Reported-by: Greg Thelen <gthelen@google.com>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  mm/compaction.c | 17 +++++++++++++++--
>  1 file changed, 15 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -797,6 +797,19 @@ static struct page *compaction_alloc(struct page *migratepage,
>  }
>  
>  /*
> + * This is a migrate-callback that "frees" freepages back to the isolated
> + * freelist.  All pages on the freelist are from the same zone, so there is no
> + * special handling needed for NUMA.
> + */
> +static void compaction_free(struct page *page, unsigned long data)
> +{
> +	struct compact_control *cc = (struct compact_control *)data;
> +
> +	list_add(&page->lru, &cc->freepages);
> +	cc->nr_freepages++;

With this change, migration_page() handles cc->nr_freepages consistently, so
we don't have to run over freelist to update this count in update_nr_listpages()?

I'm not sure if that's also true for cc->nr_migratepages, but if it is,
we can completely remove update_nr_listpages().

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

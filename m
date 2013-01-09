Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id A16516B005A
	for <linux-mm@kvack.org>; Wed,  9 Jan 2013 14:27:02 -0500 (EST)
Received: by mail-da0-f48.google.com with SMTP id k18so903045dae.7
        for <linux-mm@kvack.org>; Wed, 09 Jan 2013 11:27:01 -0800 (PST)
Date: Wed, 9 Jan 2013 11:26:59 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: migrate: Check page_count of THP before migrating
 accounting fix
In-Reply-To: <20130109120447.GB13304@suse.de>
Message-ID: <alpine.LNX.2.00.1301091120580.4818@eggly.anvils>
References: <20130107170815.GO3885@suse.de> <alpine.LNX.2.00.1301081931530.20504@eggly.anvils> <20130109120447.GB13304@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 9 Jan 2013, Mel Gorman wrote:

> As pointed out by Hugh Dickins, "mm: migrate: Check page_count of THP
> before migrating" can leave nr_isolated_anon elevated, correct it. This
> is a fix to mm-migrate-check-page_count-of-thp-before-migrating.patch
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Thanks: to this and the one it's fixing (I expect akpm will merge)

Acked-by: Hugh Dickins <hughd@google.com>

> ---
>  mm/migrate.c |    5 ++++-
>  1 file changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index f466827..c387786 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1689,8 +1689,11 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	if (!isolated || page_count(page) != 2) {
>  		count_vm_events(PGMIGRATE_FAIL, HPAGE_PMD_NR);
>  		put_page(new_page);
> -		if (isolated)
> +		if (isolated) {
>  			putback_lru_page(page);
> +			isolated = 0;
> +			goto out;
> +		}
>  		goto out_keep_locked;
>  	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

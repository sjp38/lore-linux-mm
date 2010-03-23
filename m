Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E38766B01AE
	for <linux-mm@kvack.org>; Tue, 23 Mar 2010 13:24:15 -0400 (EDT)
Date: Tue, 23 Mar 2010 12:22:57 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 02/11] mm,migration: Do not try to migrate unmapped
 anonymous pages
In-Reply-To: <1269347146-7461-3-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1003231221030.10178@router.home>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie> <1269347146-7461-3-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Mar 2010, Mel Gorman wrote:

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 98eaaf2..6eb1efe 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -603,6 +603,19 @@ static int unmap_and_move(new_page_t get_new_page, unsigned long private,
>  	 */
>  	if (PageAnon(page)) {
>  		rcu_read_lock();
> +
> +		/*
> +		 * If the page has no mappings any more, just bail. An
> +		 * unmapped anon page is likely to be freed soon but worse,
> +		 * it's possible its anon_vma disappeared between when
> +		 * the page was isolated and when we reached here while
> +		 * the RCU lock was not held
> +		 */
> +		if (!page_mapcount(page)) {
> +			rcu_read_unlock();
> +			goto uncharge;
> +		}
> +
>  		rcu_locked = 1;
>  		anon_vma = page_anon_vma(page);
>  		atomic_inc(&anon_vma->migrate_refcount);

A way to make this simpler would be to move "rcu_locked = 1" before the
if statement and then do

if (!page_mapcount(page))
	goto rcu_unlock;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

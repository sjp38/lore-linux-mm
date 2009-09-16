Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F0ACF6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 20:08:16 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8G08Hij028211
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 16 Sep 2009 09:08:17 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B549C45DE4F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 09:08:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7871845DE51
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 09:08:16 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 54FECE08001
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 09:08:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E9FB8E38009
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 09:08:15 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] mm: m(un)lock avoid ZERO_PAGE
In-Reply-To: <Pine.LNX.4.64.0909152130260.22199@sister.anvils>
References: <Pine.LNX.4.64.0909152127240.22199@sister.anvils> <Pine.LNX.4.64.0909152130260.22199@sister.anvils>
Message-Id: <20090916090348.DB89.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 16 Sep 2009 09:08:15 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I'm still reluctant to clutter __get_user_pages() with another flag,
> just to avoid touching ZERO_PAGE count in mlock(); though we can add
> that later if it shows up as an issue in practice.
> 
> But when mlocking, we can test page->mapping slightly earlier, to avoid
> the potentially bouncy rescheduling of lock_page on ZERO_PAGE - mlock
> didn't lock_page in olden ZERO_PAGE days, so we might have regressed.
> 
> And when munlocking, it turns out that FOLL_DUMP coincidentally does
> what's needed to avoid all updates to ZERO_PAGE, so use that here also.
> Plus add comment suggested by KAMEZAWA Hiroyuki.
> 
> Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> ---
> 
>  mm/mlock.c |   49 ++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 36 insertions(+), 13 deletions(-)
> 
> --- mm0/mm/mlock.c	2009-09-14 16:34:37.000000000 +0100
> +++ mm1/mm/mlock.c	2009-09-15 17:32:03.000000000 +0100
> @@ -198,17 +198,26 @@ static long __mlock_vma_pages_range(stru
>  		for (i = 0; i < ret; i++) {
>  			struct page *page = pages[i];
>  
> -			lock_page(page);
> -			/*
> -			 * Because we lock page here and migration is blocked
> -			 * by the elevated reference, we need only check for
> -			 * file-cache page truncation.  This page->mapping
> -			 * check also neatly skips over the ZERO_PAGE(),
> -			 * though if that's common we'd prefer not to lock it.
> -			 */
> -			if (page->mapping)
> -				mlock_vma_page(page);
> -			unlock_page(page);
> +			if (page->mapping) {
> +				/*
> +				 * That preliminary check is mainly to avoid
> +				 * the pointless overhead of lock_page on the
> +				 * ZERO_PAGE: which might bounce very badly if
> +				 * there is contention.  However, we're still
> +				 * dirtying its cacheline with get/put_page:
> +				 * we'll add another __get_user_pages flag to
> +				 * avoid it if that case turns out to matter.
> +				 */
> +				lock_page(page);
> +				/*
> +				 * Because we lock page here and migration is
> +				 * blocked by the elevated reference, we need
> +				 * only check for file-cache page truncation.
> +				 */
> +				if (page->mapping)
> +					mlock_vma_page(page);
> +				unlock_page(page);
> +			}
>  			put_page(page);	/* ref from get_user_pages() */
>  		}

Yes, I have similar patch :-)
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

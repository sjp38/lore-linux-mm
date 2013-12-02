Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 747A36B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 17:53:02 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so19103391pdj.16
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 14:53:02 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id qu5si36722701pbc.240.2013.12.02.14.53.00
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 14:53:01 -0800 (PST)
Date: Mon, 2 Dec 2013 14:52:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/9] mm/rmap: make rmap_walk to get the
 rmap_walk_control argument
Message-Id: <20131202145258.9f14767c1190c068becece0d@linux-foundation.org>
In-Reply-To: <1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
References: <1385624926-28883-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1385624926-28883-5-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 28 Nov 2013 16:48:41 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> In each rmap traverse case, there is some difference so that we need
> function pointers and arguments to them in order to handle these
> difference properly.
> 
> For this purpose, struct rmap_walk_control is introduced in this patch,
> and will be extended in following patch. Introducing and extending are
> separate, because it clarify changes.
> 
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -198,7 +198,12 @@ out:
>   */
>  static void remove_migration_ptes(struct page *old, struct page *new)
>  {
> -	rmap_walk(new, remove_migration_pte, old);
> +	struct rmap_walk_control rwc;
> +
> +	memset(&rwc, 0, sizeof(rwc));
> +	rwc.main = remove_migration_pte;
> +	rwc.arg = old;
> +	rmap_walk(new, &rwc);
>  }

It is much neater to do

	struct rmap_walk_control rwc = {
		.main = remove_migration_pte,
		.arg = old,
	};

which will zero out all remaining fields as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

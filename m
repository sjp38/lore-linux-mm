Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DF03B6B0116
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 12:50:02 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8FF6E82C5D2
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 13:09:58 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id YaxgJWnPXBQv for <linux-mm@kvack.org>;
	Wed, 22 Jul 2009 13:09:58 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2ED2482C5D6
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 13:09:46 -0400 (EDT)
Date: Wed, 22 Jul 2009 12:49:44 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [patch 4/4] mm: return boolean from page_has_private()
In-Reply-To: <1248166594-8859-4-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.1.10.0907221220350.3588@gentwo.org>
References: <1248166594-8859-1-git-send-email-hannes@cmpxchg.org> <1248166594-8859-4-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 21 Jul 2009, Johannes Weiner wrote:

> Make page_has_private() return a true boolean value and remove the
> double negations from the two callsites using it for arithmetic.

page_has_private_data()?

Also note that you are adding unecessary double negation to the other
callers. Does the compiler catch that?

> +static inline int page_has_private(struct page *page)
> +{
> +	return !!(page->flags & ((1 << PG_private) | (1 << PG_private_2)));
> +}

Two private bits? How did that happen?

Could we define a PAGE_FLAGS_PRIVATE in page-flags.h?

> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6b368d3..67e2824 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -286,7 +286,7 @@ static inline int page_mapping_inuse(struct page *page)
>
>  static inline int is_page_cache_freeable(struct page *page)
>  {
> -	return page_count(page) - !!page_has_private(page) == 2;
> +	return page_count(page) - page_has_private(page) == 2;

That looks funky and in need of comments.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

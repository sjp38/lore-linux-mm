Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 605666B004A
	for <linux-mm@kvack.org>; Sat, 18 Jun 2011 17:52:47 -0400 (EDT)
Date: Sat, 18 Jun 2011 14:52:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/12] mm: let swap use exceptional entries
Message-Id: <20110618145254.1b333344.akpm@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.00.1106140342330.29206@sister.anvils>
References: <alpine.LSU.2.00.1106140327550.29206@sister.anvils>
	<alpine.LSU.2.00.1106140342330.29206@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 14 Jun 2011 03:43:47 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> --- linux.orig/mm/filemap.c	2011-06-13 13:26:44.430284135 -0700
> +++ linux/mm/filemap.c	2011-06-13 13:27:34.526532556 -0700
> @@ -717,9 +717,12 @@ repeat:
>  		page = radix_tree_deref_slot(pagep);
>  		if (unlikely(!page))
>  			goto out;
> -		if (radix_tree_deref_retry(page))
> +		if (radix_tree_exception(page)) {
> +			if (radix_tree_exceptional_entry(page))
> +				goto out;
> +			/* radix_tree_deref_retry(page) */
>  			goto repeat;
> -
> +		}
>  		if (!page_cache_get_speculative(page))
>  			goto repeat;

All the crap^Wnice changes made to filemap.c really need some comments,
please.  Particularly when they're keyed off the bland-sounding
"radix_tree_exception()".  Apparently they have something to do with
swap, but how is the poor reader to know this?

Also, commenting out a function call might be meaningful information for
Hugh-right-now, but for other people later on, they're just a big WTF.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

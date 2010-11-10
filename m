Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B34416B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 16:04:20 -0500 (EST)
Date: Wed, 10 Nov 2010 13:04:07 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] clean up set_page_dirty()
Message-Id: <20101110130407.f6228a10.akpm@linux-foundation.org>
In-Reply-To: <1289379628-14044-2-git-send-email-lliubbo@gmail.com>
References: <1289379628-14044-1-git-send-email-lliubbo@gmail.com>
	<1289379628-14044-2-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 10 Nov 2010 17:00:28 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> Use TestSetPageDirty() to clean up set_page_dirty().
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/page-writeback.c |    7 ++-----
>  1 files changed, 2 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index e8f5f06..da86224 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1268,11 +1268,8 @@ int set_page_dirty(struct page *page)
>  #endif
>  		return (*spd)(page);
>  	}
> -	if (!PageDirty(page)) {
> -		if (!TestSetPageDirty(page))
> -			return 1;
> -	}
> -	return 0;
> +
> +	return !TestSetPageDirty(page);
>  }
>  EXPORT_SYMBOL(set_page_dirty);

This just undoes the optimisation.

We could do

-		if (!TestSetPageDirty(page))
-			return 1;
+		return !TestSetPageDirty(page);

I suppose.

Or even


		return (!TestSetPageDirty(page) ^ 1);

if we're feeling stupid, and if TestSetPageDirty() reliably returns
1/0, and if that really is superior (by eliminating a test-n-branch).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

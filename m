Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A63846B0093
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 22:27:47 -0500 (EST)
Date: Thu, 11 Nov 2010 11:26:44 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH v2] fix __set_page_dirty_no_writeback() return value
Message-ID: <20101111032644.GB18483@localhost>
References: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kenchen@google.com" <kenchen@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 11:05:54AM +0800, Bob Liu wrote:
> __set_page_dirty_no_writeback() should return true if it actually transitioned
> the page from a clean to dirty state although it seems nobody used its return
> value now.
> 
> Change from v1:
> 	* preserving cacheline optimisation as Andrew pointed out
> 
> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
>  mm/page-writeback.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
> index bf85062..ac7018a 100644
> --- a/mm/page-writeback.c
> +++ b/mm/page-writeback.c
> @@ -1157,8 +1157,10 @@ EXPORT_SYMBOL(write_one_page);
>   */
>  int __set_page_dirty_no_writeback(struct page *page)
>  {
> -	if (!PageDirty(page))
> +	if (!PageDirty(page)) {
>  		SetPageDirty(page);
> +		return 1;
> +	}
>  	return 0;
>  }

It's still racy if not using TestSetPageDirty(). In fact
set_page_dirty() has a default reference implementation:

        if (!PageDirty(page)) {
                if (!TestSetPageDirty(page))
                        return 1;
        }
        return 0;

It seems the return value currently is only tested for doing
balance_dirty_pages_ratelimited(). So not a big problem.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

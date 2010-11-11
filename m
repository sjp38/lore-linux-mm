Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5F0986B0085
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 22:05:33 -0500 (EST)
Date: Wed, 10 Nov 2010 19:02:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] fix __set_page_dirty_no_writeback() return value
Message-Id: <20101110190228.e21fdf36.akpm@linux-foundation.org>
In-Reply-To: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
References: <1289444754-29469-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: fengguang.wu@intel.com, linux-mm@kvack.org, kenchen@google.com
List-ID: <linux-mm.kvack.org>

On Thu, 11 Nov 2010 11:05:54 +0800 Bob Liu <lliubbo@gmail.com> wrote:

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

But that has a race.  If someone else sets PG_Dirty between the test
and the set, this function will incorrectly return 1.

Which is why it should use test_and_set if we're going to do this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

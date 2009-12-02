Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 83BE46007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 09:50:20 -0500 (EST)
Date: Wed, 2 Dec 2009 08:50:10 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 02/24] migrate: page could be locked by hwpoison, dont
 BUG()
In-Reply-To: <20091202043043.840044332@intel.com>
Message-ID: <alpine.DEB.2.00.0912020848300.31731@router.home>
References: <20091202031231.735876003@intel.com> <20091202043043.840044332@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2 Dec 2009, Wu Fengguang wrote:

>  mm/migrate.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- linux-mm.orig/mm/migrate.c	2009-11-02 10:18:45.000000000 +0800
> +++ linux-mm/mm/migrate.c	2009-11-02 10:26:16.000000000 +0800
> @@ -556,7 +556,7 @@ static int move_to_new_page(struct page
>  	 * holding a reference to the new page at this point.
>  	 */
>  	if (!trylock_page(newpage))
> -		BUG();
> +		return -EAGAIN;		/* got by hwpoison */
>
>  	/* Prepare mapping for the new page.*/
>  	newpage->index = page->index;

The error handling code in umap_and_move() assumes that the page is
locked upon return from move_to_new_page() even if it failed.

If you return EAGAIN then it may try to unlock a page that is not
locked.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

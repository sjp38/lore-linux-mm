Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 60DE96B0039
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 04:28:43 -0400 (EDT)
Date: Mon, 3 Jun 2013 17:28:41 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [v4][PATCH 3/6] mm: vmscan: break up __remove_mapping()
Message-ID: <20130603082841.GB2795@blaptop>
References: <20130531183855.44DDF928@viggo.jf.intel.com>
 <20130531183859.F179225E@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130531183859.F179225E@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On Fri, May 31, 2013 at 11:38:59AM -0700, Dave Hansen wrote:
> 
> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> Our goal here is to eventually reduce the number of repetitive
> acquire/release operations on mapping->tree_lock.
> 
> Logically, this patch has two steps:
> 1. rename __remove_mapping() to lock_remove_mapping() since
>    "__" usually means "this us the unlocked version.
> 2. Recreate __remove_mapping() to _be_ the lock_remove_mapping()
>    but without the locks.
> 
> I think this actually makes the code flow around the locking
> _much_ more straighforward since the locking just becomes:
> 
> 	spin_lock_irq(&mapping->tree_lock);
> 	ret = __remove_mapping(mapping, page);
> 	spin_unlock_irq(&mapping->tree_lock);
> 
> One non-obvious part of this patch: the
> 
> 	freepage = mapping->a_ops->freepage;
> 
> used to happen under the mapping->tree_lock, but this patch
> moves it to outside of the lock.  All of the other
> a_ops->freepage users do it outside the lock, and we only
> assign it when we create inodes, so that makes it safe.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Acked-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Minchan Kin <minchan@kernel.org>

Just a nitpick below.

> 
> ---
> 
>  linux.git-davehans/mm/vmscan.c |   43 ++++++++++++++++++++++++-----------------
>  1 file changed, 26 insertions(+), 17 deletions(-)
> 
> diff -puN mm/vmscan.c~make-remove-mapping-without-locks mm/vmscan.c
> --- linux.git/mm/vmscan.c~make-remove-mapping-without-locks	2013-05-30 16:07:51.210104924 -0700
> +++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:51.214105100 -0700
> @@ -450,12 +450,12 @@ static pageout_t pageout(struct page *pa
>   * Same as remove_mapping, but if the page is removed from the mapping, it
>   * gets returned with a refcount of 0.
>   */
> -static int __remove_mapping(struct address_space *mapping, struct page *page)
> +static int __remove_mapping(struct address_space *mapping,
> +			    struct page *page)

Unnecessary change.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

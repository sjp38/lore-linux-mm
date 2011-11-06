Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 775766B0069
	for <linux-mm@kvack.org>; Sun,  6 Nov 2011 17:24:22 -0500 (EST)
Message-Id: <d08817$23rf4p@azsmga001.ch.intel.com>
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH 11/13] mm: extend prefault helpers to fault in more than PAGE_SIZE
In-Reply-To: <1320606840-21132-12-git-send-email-daniel.vetter@ffwll.ch>
References: <1320606840-21132-1-git-send-email-daniel.vetter@ffwll.ch> <1320606840-21132-12-git-send-email-daniel.vetter@ffwll.ch>
Date: Sun, 06 Nov 2011 22:24:13 +0000
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>, intel-gfx <intel-gfx@lists.freedesktop.org>
Cc: linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org

On Sun,  6 Nov 2011 20:13:58 +0100, Daniel Vetter <daniel.vetter@ffwll.ch> wrote:
> drm/i915 wants to read/write more than one page in its fastpath
> and hence needs to prefault more than PAGE_SIZE bytes.
> 
> I've checked the callsites and they all already clamp size when
> calling fault_in_pages_* to the same as for the subsequent
> __copy_to|from_user and hence don't rely on the implicit clamping
> to PAGE_SIZE.
> 
> Also kill a copy&pasted spurious space in both functions while at it.
> 
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@ffwll.ch>
> ---
>  include/linux/pagemap.h |   28 ++++++++++++++++++----------
>  1 files changed, 18 insertions(+), 10 deletions(-)
> 
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index cfaaa69..689527d 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -408,6 +408,7 @@ extern void add_page_wait_queue(struct page *page, wait_queue_t *waiter);
>  static inline int fault_in_pages_writeable(char __user *uaddr, int size)
>  {
>  	int ret;
> +	char __user *end = uaddr + size - 1;
>  
>  	if (unlikely(size == 0))
>  		return 0;
> @@ -416,17 +417,20 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
>  	 * Writing zeroes into userspace here is OK, because we know that if
>  	 * the zero gets there, we'll be overwriting it.
>  	 */
> -	ret = __put_user(0, uaddr);
> +	while (uaddr <= end) {
> +		ret = __put_user(0, uaddr);
> +		if (ret != 0)
> +			return ret;
> +		uaddr += PAGE_SIZE;
> +	}
>  	if (ret == 0) {
> -		char __user *end = uaddr + size - 1;
> -
>  		/*
>  		 * If the page was already mapped, this will get a cache miss
>  		 * for sure, so try to avoid doing it.
>  		 */
> -		if (((unsigned long)uaddr & PAGE_MASK) !=
> +		if (((unsigned long)uaddr & PAGE_MASK) ==
>  				((unsigned long)end & PAGE_MASK))
> -		 	ret = __put_user(0, end);
> +			ret = __put_user(0, end);
>  	}
>  	return ret;

You leave these functions in a worse mess by introducing a false
compiler warning about an uninitialized ret by the now redundant test
against zero, a do{}while loop would be clearer that the original
behaviour is merely extended upon. And please replace the open-coded
offset_in_page().
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 04D4C6B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 17:36:59 -0500 (EST)
Date: Thu, 23 Feb 2012 14:36:58 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-Id: <20120223143658.0e318ce2.akpm@linux-foundation.org>
In-Reply-To: <1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
References: <1329393696-4802-1-git-send-email-daniel.vetter@ffwll.ch>
	<1329393696-4802-2-git-send-email-daniel.vetter@ffwll.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, 16 Feb 2012 13:01:36 +0100
Daniel Vetter <daniel.vetter@ffwll.ch> wrote:

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
> ...
>
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

The callsites in filemap.c are pretty hot paths, which is why this
thing remains explicitly inlined.  I think it would be worth adding a
bit of code here to avoid adding a pointless test-n-branch and larger
cache footprint to read() and write().

A way of doing that is to add another argument to these functions, say
"bool multipage".  Change the code to do

	if (multipage) {
		while (uaddr <= end) {
			...
		}
	}

and change the callsites to pass in constant "true" or "false".  Then
compile it up and manually check that the compiler completely removed
the offending code from the filemap.c callsites.

Wanna have a think about that?  If it all looks OK then please be sure
to add code comments explaining why we did this.

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

Maybe I'm having a dim day, but I don't immediately see why != got
turned into ==.


Once we have this settled I'd suggest that the patch be carried in
whatever-git-tree-needs-it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

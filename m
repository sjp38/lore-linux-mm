Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 221266B002C
	for <linux-mm@kvack.org>; Thu,  1 Mar 2012 15:15:59 -0500 (EST)
Date: Thu, 1 Mar 2012 12:15:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-Id: <20120301121557.0e0fd728.akpm@linux-foundation.org>
In-Reply-To: <1330629779-1449-1-git-send-email-daniel.vetter@ffwll.ch>
References: <20120229153216.8c3ae31d.akpm@linux-foundation.org>
	<1330629779-1449-1-git-send-email-daniel.vetter@ffwll.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu,  1 Mar 2012 20:22:59 +0100
Daniel Vetter <daniel.vetter@ffwll.ch> wrote:

> drm/i915 wants to read/write more than one page in its fastpath
> and hence needs to prefault more than PAGE_SIZE bytes.
> 
> Add new functions in filemap.h to make that possible.
> 
> Also kill a copy&pasted spurious space in both functions while at it.
> 
>
> ...
>
> +/* Multipage variants of the above prefault helpers, useful if more than
> + * PAGE_SIZE of date needs to be prefaulted. These are separate from the above
> + * functions (which only handle up to PAGE_SIZE) to avoid clobbering the
> + * filemap.c hotpaths. */

Like this please:

/*
 * Multipage variants of the above prefault helpers, useful if more than
 * PAGE_SIZE of date needs to be prefaulted. These are separate from the above
 * functions (which only handle up to PAGE_SIZE) to avoid clobbering the
 * filemap.c hotpaths.
 */

and s/date/data/

> +static inline int fault_in_multipages_writeable(char __user *uaddr, int size)
> +{
> +	int ret;
> +	const char __user *end = uaddr + size - 1;
> +
> +	if (unlikely(size == 0))
> +		return 0;
> +
> +	/*
> +	 * Writing zeroes into userspace here is OK, because we know that if
> +	 * the zero gets there, we'll be overwriting it.
> +	 */

Yeah, like that.

> +	while (uaddr <= end) {
> +		ret = __put_user(0, uaddr);
> +		if (ret != 0)
> +			return ret;
> +		uaddr += PAGE_SIZE;
> +	}
> +
> +	/* Check whether the range spilled into the next page. */
> +	if (((unsigned long)uaddr & PAGE_MASK) ==
> +			((unsigned long)end & PAGE_MASK))
> +		ret = __put_user(0, end);
> +
> +	return ret;
> +}
> +
> +static inline int fault_in_multipages_readable(const char __user *uaddr,
> +					       int size)
> +{
> +	volatile char c;
> +	int ret;
> +	const char __user *end = uaddr + size - 1;
> +
> +	if (unlikely(size == 0))
> +		return 0;
> +
> +	while (uaddr <= end) {
> +		ret = __get_user(c, uaddr);
> +		if (ret != 0)
> +			return ret;
> +		uaddr += PAGE_SIZE;
> +	}
> +
> +	/* Check whether the range spilled into the next page. */
> +	if (((unsigned long)uaddr & PAGE_MASK) ==
> +			((unsigned long)end & PAGE_MASK)) {
> +		ret = __get_user(c, end);
> +		(void)c;
> +	}
> +
> +	return ret;
> +}

Please merge it via the DRI tree.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

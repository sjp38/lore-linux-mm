Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 619DB6B002C
	for <linux-mm@kvack.org>; Wed, 29 Feb 2012 18:01:48 -0500 (EST)
Date: Wed, 29 Feb 2012 15:01:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: extend prefault helpers to fault in more than
 PAGE_SIZE
Message-Id: <20120229150146.2cc64fac.akpm@linux-foundation.org>
In-Reply-To: <1330524211-2698-1-git-send-email-daniel.vetter@ffwll.ch>
References: <20120224124003.93780408.akpm@linux-foundation.org>
	<1330524211-2698-1-git-send-email-daniel.vetter@ffwll.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, 29 Feb 2012 15:03:31 +0100
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
> v2: As suggested by Andrew Morton, add a multipage parameter to both
> functions to avoid the additional branch for the pagemap.c hotpath.
> My gcc 4.6 here seems to dtrt and indeed reap these branches where not
> needed.
> 

I don't think this produced a very good result :(

>
> ...
>
> -static inline int fault_in_pages_writeable(char __user *uaddr, int size)
> +static inline int fault_in_pages_writeable(char __user *uaddr, int size,
> +					   bool multipage)
>  {
>  	int ret;
> +	char __user *end = uaddr + size - 1;
>  
>  	if (unlikely(size == 0))
>  		return 0;
> @@ -416,36 +419,46 @@ static inline int fault_in_pages_writeable(char __user *uaddr, int size)
>  	 * Writing zeroes into userspace here is OK, because we know that if
>  	 * the zero gets there, we'll be overwriting it.
>  	 */
> -	ret = __put_user(0, uaddr);
> -	if (ret == 0) {
> -		char __user *end = uaddr + size - 1;
> +	do {
> +		ret = __put_user(0, uaddr);
> +		if (ret != 0)
> +			return ret;
> +		uaddr += PAGE_SIZE;
> +	} while (multipage && uaddr <= end);
>  
> +	if (ret == 0) {
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
>  }

One effect of this change for the filemap.c callsite is that `uaddr'
now gets incremented by PAGE_SIZE.  That happens to not break anything
because we then mask `uaddr' with PAGE_MASK, and if gcc were really
smart, it could remove that addition.  But it's a bit ugly.

Ideally the patch would have no effect upon filemap.o size, but with an
allmodconfig config I'm seeing

   text    data     bss     dec     hex filename
  22876     118    7344   30338    7682 mm/filemap.o	(before)
  22925     118    7392   30435    76e3 mm/filemap.o	(after)

so we are adding read()/write() overhead, and bss mysteriously got larger.

Can we improve on this?  Even if it's some dumb

static inline int fault_in_pages_writeable(char __user *uaddr, int size,
					   bool multipage)
{
	if (multipage) {
		do-this
	} else {
		do-that
	}
}

the code duplication between do-this and do-that is regrettable, but at
least it's all in the same place in the same file, so we won't
accidentally introduce skew later on.

Alternatively, add a separate fault_in_multi_pages_writeable() to
pagemap.h.  I have a bad feeling this is what your original patch did!

(But we *should* be able to make this work!  Why did this version of
the patch go so wrong?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

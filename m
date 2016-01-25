Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f169.google.com (mail-pf0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9AB6B0005
	for <linux-mm@kvack.org>; Mon, 25 Jan 2016 15:16:55 -0500 (EST)
Received: by mail-pf0-f169.google.com with SMTP id e65so87466961pfe.0
        for <linux-mm@kvack.org>; Mon, 25 Jan 2016 12:16:55 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hb8si11424690pac.55.2016.01.25.12.16.54
        for <linux-mm@kvack.org>;
        Mon, 25 Jan 2016 12:16:54 -0800 (PST)
Subject: Re: [kernel-hardening] [RFC][PATCH 3/3] mm/page_poisoning.c: Allow
 for zero poisoning
References: <1453740953-18109-1-git-send-email-labbott@fedoraproject.org>
 <1453740953-18109-4-git-send-email-labbott@fedoraproject.org>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <56A682B5.8000603@intel.com>
Date: Mon, 25 Jan 2016 12:16:53 -0800
MIME-Version: 1.0
In-Reply-To: <1453740953-18109-4-git-send-email-labbott@fedoraproject.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: Laura Abbott <labbott@fedoraproject.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>

Thanks for doing this!  It all looks pretty straightforward.

On 01/25/2016 08:55 AM, Laura Abbott wrote:
> By default, page poisoning uses a poison value (0xaa) on free. If this
> is changed to 0, the page is not only sanitized but zeroing on alloc
> with __GFP_ZERO can be skipped as well. The tradeoff is that detecting
> corruption from the poisoning is harder to detect. This feature also
> cannot be used with hibernation since pages are not guaranteed to be
> zeroed after hibernation.

Ugh, that's a good point about hibernation.  I'm not sure how widely it
gets used but it does look pretty widely enabled in distribution kernels.

Is this something that's fixable?  It seems like we could have the
hibernation code run through and zero all the free lists.  Or, we could
just disable the optimization at runtime when a hibernation is done.

Not that we _have_ to do any of this now, but if a runtime knob (like a
sysctl) could be fun too.  I would be nice for folks to turn it on and
off if they wanted the added security of "real" poisoning vs. the
potential performance boost from this optimization.

> +static inline bool should_zero(void)
> +{
> +	return !IS_ENABLED(CONFIG_PAGE_POISONING_ZERO) ||
> +		!page_poisoning_enabled();
> +}

I wonder if calling this "free_pages_prezeroed()" would make things a
bit more clear when we use it in prep_new_page().

>  static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  								int alloc_flags)
>  {
> @@ -1401,7 +1407,7 @@ static int prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
>  	kernel_map_pages(page, 1 << order, 1);
>  	kasan_alloc_pages(page, order);
>  
> -	if (gfp_flags & __GFP_ZERO)
> +	if (should_zero() && gfp_flags & __GFP_ZERO)
>  		for (i = 0; i < (1 << order); i++)
>  			clear_highpage(page + i);

It's probably also worth pointing out that this can be a really nice
feature to have in virtual machines where memory is being deduplicated.
 As it stands now, the free lists end up with gunk in them and tend not
to be easy to deduplicate.  This patch would fix that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

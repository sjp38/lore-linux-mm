Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id F0B046B0032
	for <linux-mm@kvack.org>; Fri, 15 May 2015 20:03:09 -0400 (EDT)
Received: by wgin8 with SMTP id n8so130801090wgi.0
        for <linux-mm@kvack.org>; Fri, 15 May 2015 17:03:09 -0700 (PDT)
Received: from v094114.home.net.pl (v094114.home.net.pl. [79.96.170.134])
        by mx.google.com with SMTP id y2si5429118wjx.113.2015.05.15.17.03.07
        for <linux-mm@kvack.org>;
        Fri, 15 May 2015 17:03:08 -0700 (PDT)
From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [PATCH v4 1/3] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Date: Sat, 16 May 2015 02:28:22 +0200
Message-ID: <7216052.tCNGRiLFYJ@vostro.rjw.lan>
In-Reply-To: <1431613188-4511-2-git-send-email-anisse@astier.eu>
References: <1431613188-4511-1-git-send-email-anisse@astier.eu> <1431613188-4511-2-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, Pavel Machek <pavel@ucw.cz>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

On Thursday, May 14, 2015 04:19:46 PM Anisse Astier wrote:
> SANITIZE_FREED_PAGES feature relies on having all pages going through
> the free_pages_prepare path in order to be cleared before being used. In
> the hibernate use case, free pages will automagically appear in the
> system without being cleared, left there by the loading kernel.
> 
> This patch will make sure free pages are cleared on resume; when we'll
> enable SANITIZE_FREED_PAGES. We free the pages just after resume because
> we can't do it later: going through any device resume code might
> allocate some memory and invalidate the free pages bitmap.
> 
> Signed-off-by: Anisse Astier <anisse@astier.eu>
> ---
>  kernel/power/hibernate.c |  4 +++-
>  kernel/power/power.h     |  2 ++
>  kernel/power/snapshot.c  | 22 ++++++++++++++++++++++
>  3 files changed, 27 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> index 2329daa..0a73126 100644
> --- a/kernel/power/hibernate.c
> +++ b/kernel/power/hibernate.c
> @@ -305,9 +305,11 @@ static int create_image(int platform_mode)
>  			error);
>  	/* Restore control flow magically appears here */
>  	restore_processor_state();
> -	if (!in_suspend)
> +	if (!in_suspend) {
>  		events_check_enabled = false;
>  
> +		clear_free_pages();

Again, why don't you do that at the swsusp_free() time?

> +	}
>  	platform_leave(platform_mode);
>  
>   Power_up:
> diff --git a/kernel/power/power.h b/kernel/power/power.h
> index ce9b832..6d2d7bf 100644
> --- a/kernel/power/power.h
> +++ b/kernel/power/power.h
> @@ -92,6 +92,8 @@ extern int create_basic_memory_bitmaps(void);
>  extern void free_basic_memory_bitmaps(void);
>  extern int hibernate_preallocate_memory(void);
>  
> +extern void clear_free_pages(void);
> +
>  /**
>   *	Auxiliary structure used for reading the snapshot image data and
>   *	metadata from and writing them to the list of page backup entries
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 5235dd4..2335130 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1032,6 +1032,28 @@ void free_basic_memory_bitmaps(void)
>  	pr_debug("PM: Basic memory bitmaps freed\n");
>  }
>  
> +void clear_free_pages(void)
> +{
> +#ifdef CONFIG_SANITIZE_FREED_PAGES
> +	struct memory_bitmap *bm = free_pages_map;
> +	unsigned long pfn;
> +
> +	if (WARN_ON(!(free_pages_map)))

One paren too many.

> +		return;
> +
> +	memory_bm_position_reset(bm);
> +	pfn = memory_bm_next_pfn(bm);
> +	while (pfn != BM_END_OF_MAP) {
> +		if (pfn_valid(pfn))
> +			clear_highpage(pfn_to_page(pfn));

Is clear_highpage() also fine for non-highmem pages?

> +
> +		pfn = memory_bm_next_pfn(bm);
> +	}
> +	memory_bm_position_reset(bm);
> +	printk(KERN_INFO "PM: free pages cleared after restore\n");
> +#endif /* SANITIZE_FREED_PAGES */
> +}
> +
>  /**
>   *	snapshot_additional_pages - estimate the number of additional pages
>   *	be needed for setting up the suspend image data structures for given
> 

-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

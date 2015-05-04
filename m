Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 46DB06B006E
	for <linux-mm@kvack.org>; Mon,  4 May 2015 17:52:14 -0400 (EDT)
Received: by pdea3 with SMTP id a3so174781628pde.3
        for <linux-mm@kvack.org>; Mon, 04 May 2015 14:52:14 -0700 (PDT)
Received: from r00tworld.com (r00tworld.com. [212.85.137.150])
        by mx.google.com with ESMTPS id xi10si21440797pab.148.2015.05.04.14.52.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 04 May 2015 14:52:13 -0700 (PDT)
From: "PaX Team" <pageexec@freemail.hu>
Date: Mon, 04 May 2015 23:50:13 +0200
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/4] PM / Hibernate: fix SANITIZE_FREED_PAGES
Reply-to: pageexec@freemail.hu
Message-ID: <5547E995.9980.80084D6@pageexec.freemail.hu>
In-reply-to: <1430774218-5311-4-git-send-email-anisse@astier.eu>
References: <1430774218-5311-1-git-send-email-anisse@astier.eu>, <1430774218-5311-4-git-send-email-anisse@astier.eu>
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7BIT
Content-description: Mail message body
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Pavel Machek <pavel@ucw.cz>

On 4 May 2015 at 23:16, Anisse Astier wrote:

> SANITIZE_FREED_PAGES feature relies on having all pages going through
> the free_pages_prepare path in order to be cleared before being used. In
> the hibernate use case, pages will automagically appear in the system
> without being cleared.

is this based on debugging/code reading/discussions with hibernation folks
(i see none of them on CC, added them now) or is it just a brute force attempt
to fix the symptoms? if the former, it'd be nice to share some more details
and have Acks from the code owners.

> This fix will make sure free pages are cleared on resume.
> 
> Signed-off-by: Anisse Astier <anisse@astier.eu>
> ---
>  kernel/power/hibernate.c |  7 ++++++-
>  kernel/power/power.h     |  4 ++++
>  kernel/power/snapshot.c  | 21 +++++++++++++++++++++
>  3 files changed, 31 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
> index 2329daa..3193b9a 100644
> --- a/kernel/power/hibernate.c
> +++ b/kernel/power/hibernate.c
> @@ -305,9 +305,14 @@ static int create_image(int platform_mode)
>  			error);
>  	/* Restore control flow magically appears here */
>  	restore_processor_state();
> -	if (!in_suspend)
> +	if (!in_suspend) {
>  		events_check_enabled = false;
>  
> +#ifdef CONFIG_SANITIZE_FREED_PAGES
> +		clear_free_pages();
> +		printk(KERN_INFO "PM: free pages cleared after restore\n");
> +#endif
> +	}
>  	platform_leave(platform_mode);
>  
>   Power_up:
> diff --git a/kernel/power/power.h b/kernel/power/power.h
> index ce9b832..26b2101 100644
> --- a/kernel/power/power.h
> +++ b/kernel/power/power.h
> @@ -92,6 +92,10 @@ extern int create_basic_memory_bitmaps(void);
>  extern void free_basic_memory_bitmaps(void);
>  extern int hibernate_preallocate_memory(void);
>  
> +#ifdef CONFIG_SANITIZE_FREED_PAGES
> +extern void clear_free_pages(void);
> +#endif
> +
>  /**
>   *	Auxiliary structure used for reading the snapshot image data and
>   *	metadata from and writing them to the list of page backup entries
> diff --git a/kernel/power/snapshot.c b/kernel/power/snapshot.c
> index 5235dd4..673ade1 100644
> --- a/kernel/power/snapshot.c
> +++ b/kernel/power/snapshot.c
> @@ -1032,6 +1032,27 @@ void free_basic_memory_bitmaps(void)
>  	pr_debug("PM: Basic memory bitmaps freed\n");
>  }
>  
> +#ifdef CONFIG_SANITIZE_FREED_PAGES
> +void clear_free_pages(void)
> +{
> +	struct memory_bitmap *bm = free_pages_map;
> +	unsigned long pfn;
> +
> +	if (WARN_ON(!(free_pages_map)))
> +		return;
> +
> +	memory_bm_position_reset(bm);
> +	pfn = memory_bm_next_pfn(bm);
> +	while (pfn != BM_END_OF_MAP) {
> +		if (pfn_valid(pfn))
> +			clear_highpage(pfn_to_page(pfn));
> +
> +		pfn = memory_bm_next_pfn(bm);
> +	}
> +	memory_bm_position_reset(bm);
> +}
> +#endif /* SANITIZE_FREED_PAGES */
> +
>  /**
>   *	snapshot_additional_pages - estimate the number of additional pages
>   *	be needed for setting up the suspend image data structures for given
> -- 
> 1.9.3
> 
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

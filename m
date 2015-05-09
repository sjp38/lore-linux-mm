Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 235996B0038
	for <linux-mm@kvack.org>; Sat,  9 May 2015 11:44:58 -0400 (EDT)
Received: by wief7 with SMTP id f7so55923530wie.0
        for <linux-mm@kvack.org>; Sat, 09 May 2015 08:44:57 -0700 (PDT)
Received: from atrey.karlin.mff.cuni.cz (atrey.karlin.mff.cuni.cz. [195.113.26.193])
        by mx.google.com with ESMTP id cx4si3864566wib.39.2015.05.09.08.44.56
        for <linux-mm@kvack.org>;
        Sat, 09 May 2015 08:44:56 -0700 (PDT)
Date: Sat, 9 May 2015 17:44:55 +0200
From: Pavel Machek <pavel@ucw.cz>
Subject: Re: [PATCH v3 2/4] PM / Hibernate: prepare for SANITIZE_FREED_PAGES
Message-ID: <20150509154455.GA32002@amd>
References: <1430980452-2767-1-git-send-email-anisse@astier.eu>
 <1430980452-2767-3-git-send-email-anisse@astier.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1430980452-2767-3-git-send-email-anisse@astier.eu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anisse Astier <anisse@astier.eu>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Alan Cox <gnomes@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Kees Cook <keescook@chromium.org>, Andi Kleen <andi@firstfloor.org>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, linux-mm@kvack.org, linux-pm@vger.kernel.org, linux-kernel@vger.kernel.org

Hi!

> SANITIZE_FREED_PAGES feature relies on having all pages going through
> the free_pages_prepare path in order to be cleared before being used. In
> the hibernate use case, pages will automagically appear in the system
> without being cleared.
> 
> This patch will make sure free pages are cleared on resume; when we'll
> enable SANITIZE_FREED_PAGES. We free the pages just after resume because
> we can't do it later: going through any device resume code might
> allocate some memory and invalidate the free pages bitmap.
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

Can you move the ifdef and the printk into the clear_free_pages?

This is not performance critical in any way...

Otherwise it looks good to me... if the sanitization is considered
useful. Did it catch some bugs in the past?

Thanks,
									Pavel
-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

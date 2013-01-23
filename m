Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 75F5B6B0005
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 22:12:25 -0500 (EST)
Date: Wed, 23 Jan 2013 14:11:25 +1100
From: paul.szabo@sydney.edu.au
Message-Id: <201301230311.r0N3BPdE032604@como.maths.usyd.edu.au>
Subject: Re: [PATCH] Subtract min_free_kbytes from dirtyable memory
In-Reply-To: <20130123014959.GB2723@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org
Cc: 695182@bugs.debian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Dear Minchan,

> So what's the effect for user?

Sorry I have no idea.

The kernel seems to work well without this patch; or in fact not so
well, PAE crashing with spurious OOM. In my fruitless efforts of
avoiding OOM by sensible choices of sysctl tunables, I noticed that
maybe the treatment of min_free_kbytes was not right. Getting this
right did not help in avoiding OOM.

> It seems you saw old kernel.

Yes I have Debian on my machines. :-)

> Current kernel includes following logic.
> 
> static unsigned long global_dirtyable_memory(void)
> {
>         unsigned long x;
> 
>         x = global_page_state(NR_FREE_PAGES) + global_reclaimable_pages();
>         x -= min(x, dirty_balance_reserve);
> 
>         if (!vm_highmem_is_dirtyable)
>                 x -= highmem_dirtyable_memory(x);
> 
>         return x + 1;   /* Ensure that we never return 0 */
> }
> 
> And dirty_lanace_reserve already includes high_wmark_pages.
> Look at calculate_totalreserve_pages.
> 
> So I think we don't need this patch.
> Thanks.

Presumably, dirty_balance_reserve takes min_free_kbytes into account?
Then I agree that this patch is not needed on those newer kernels.

A question: what is the use or significance of vm_highmem_is_dirtyable?
It seems odd that it would be used in setting limits or threshholds, but
not used in decisions where to put dirty things. Is that so, is that as
should be? What is the recommended setting of highmem_is_dirtyable?

Thanks, Paul

Paul Szabo   psz@maths.usyd.edu.au   http://www.maths.usyd.edu.au/u/psz/
School of Mathematics and Statistics   University of Sydney    Australia

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

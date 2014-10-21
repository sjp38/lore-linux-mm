Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 049D26B0072
	for <linux-mm@kvack.org>; Tue, 21 Oct 2014 11:58:41 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so1617718pdj.13
        for <linux-mm@kvack.org>; Tue, 21 Oct 2014 08:58:41 -0700 (PDT)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id h2si11656341pdk.90.2014.10.21.08.58.40
        for <linux-mm@kvack.org>;
        Tue, 21 Oct 2014 08:58:41 -0700 (PDT)
Date: Tue, 21 Oct 2014 16:58:22 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH] mm/kmemleak: Do not skip stack frames
Message-ID: <20141021155821.GB17528@e104818-lin.cambridge.arm.com>
References: <1413893969-25798-1-git-send-email-thierry.reding@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1413893969-25798-1-git-send-email-thierry.reding@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thierry Reding <thierry.reding@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Tue, Oct 21, 2014 at 01:19:29PM +0100, Thierry Reding wrote:
> From: Thierry Reding <treding@nvidia.com>
> 
> Trying to chase down memory leaks is much easier when the complete stack
> trace is available.
> 
> Signed-off-by: Thierry Reding <treding@nvidia.com>
> ---
> It seems like this was initially set to 1 when merged in commit
> 3c7b4e6b8be4 (kmemleak: Add the base support) and later increased to 2
> in commit fd6789675ebf (kmemleak: Save the stack trace for early
> allocations). Perhaps there was a reason to skip the first few frames,
> but I've certainly found it difficult to find leaks when the stack trace
> doesn't point at the proper location.
> ---
>  mm/kmemleak.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/kmemleak.c b/mm/kmemleak.c
> index 3cda50c1e394..55d9ad0f40d4 100644
> --- a/mm/kmemleak.c
> +++ b/mm/kmemleak.c
> @@ -503,7 +503,7 @@ static int __save_stack_trace(unsigned long *trace)
>  	stack_trace.max_entries = MAX_TRACE;
>  	stack_trace.nr_entries = 0;
>  	stack_trace.entries = trace;
> -	stack_trace.skip = 2;
> +	stack_trace.skip = 0;

The reason for this was to avoid listing some of the kmemleak internals
(kmemleak_alloc -> create_object -> __save_stack_trace). I can see how
inlining of __save_stack_trace() would cause some of the last frames to
be missed. I would still prefer to keep it at 1 rather than 0?

Which architecture are you testing on? What's the additional trace you
get with this patch?

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

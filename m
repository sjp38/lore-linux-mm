Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id C862D6B0298
	for <linux-mm@kvack.org>; Tue,  7 Nov 2017 07:50:58 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id j15so7790602wre.15
        for <linux-mm@kvack.org>; Tue, 07 Nov 2017 04:50:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x5si1220909edj.433.2017.11.07.04.50.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Nov 2017 04:50:57 -0800 (PST)
Date: Tue, 7 Nov 2017 13:50:55 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: Avoid KERN_CONT uses in warn_alloc
Message-ID: <20171107125055.cl5pyp2zwon44x5l@dhcp22.suse.cz>
References: <b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b31236dfe3fc924054fd7842bde678e71d193638.1509991345.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon 06-11-17 10:02:56, Joe Perches wrote:
> KERN_CONT/pr_cont uses should be avoided where possible.
> Use single pr_warn calls instead.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> ---
>  mm/page_alloc.c | 14 ++++++--------
>  1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 536431bf0f0c..82e6d2c914ab 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3275,19 +3275,17 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
>  	if ((gfp_mask & __GFP_NOWARN) || !__ratelimit(&nopage_rs))
>  		return;
>  
> -	pr_warn("%s: ", current->comm);
> -
>  	va_start(args, fmt);
>  	vaf.fmt = fmt;
>  	vaf.va = &args;
> -	pr_cont("%pV", &vaf);
> -	va_end(args);
> -
> -	pr_cont(", mode:%#x(%pGg), nodemask=", gfp_mask, &gfp_mask);
>  	if (nodemask)
> -		pr_cont("%*pbl\n", nodemask_pr_args(nodemask));
> +		pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=%*pbl\n",
> +			current->comm, &vaf, gfp_mask, &gfp_mask,
> +			nodemask_pr_args(nodemask));
>  	else
> -		pr_cont("(null)\n");
> +		pr_warn("%s: %pV, mode:%#x(%pGg), nodemask=(null)\n",
> +			current->comm, &vaf, gfp_mask, &gfp_mask);
> +	va_end(args);
>  
>  	cpuset_print_current_mems_allowed();

I do not like the duplication. It just calls for inconsistencies over
time. Can we instead make %*pbl consume NULL nodemask instead?
Something like the following pseudo patch + the if/else removed.
If this would be possible we could simplify other code as well I think
(at least oom code has to special case NULL nodemask).

What do you think?
---
diff --git a/include/linux/nodemask.h b/include/linux/nodemask.h
index de1c50b93c61..106fac744f49 100644
--- a/include/linux/nodemask.h
+++ b/include/linux/nodemask.h
@@ -104,7 +104,7 @@ extern nodemask_t _unused_nodemask_arg_;
  *
  * Can be used to provide arguments for '%*pb[l]' when printing a nodemask.
  */
-#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp)->bits
+#define nodemask_pr_args(maskp)		MAX_NUMNODES, (maskp) ? (maskp)->bits : NULL
 
 /*
  * The inline keyword gives the compiler room to decide to inline, or
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 1746bae94d41..6f40cf319a76 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -902,6 +902,9 @@ char *bitmap_list_string(char *buf, char *end, unsigned long *bitmap,
 	int cur, rbot, rtop;
 	bool first = true;
 
+	if (!bitmap)
+		return buf;
+
 	/* reused to print numbers */
 	spec = (struct printf_spec){ .base = 10 };
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

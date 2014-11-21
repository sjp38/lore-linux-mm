Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f172.google.com (mail-ie0-f172.google.com [209.85.223.172])
	by kanga.kvack.org (Postfix) with ESMTP id E202A6B0071
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 18:38:35 -0500 (EST)
Received: by mail-ie0-f172.google.com with SMTP id ar1so5960056iec.17
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 15:38:35 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id c20si605747ign.24.2014.11.21.15.38.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Nov 2014 15:38:34 -0800 (PST)
Date: Fri, 21 Nov 2014 15:38:32 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 6/7] mm/page_owner: keep track of page owners
Message-Id: <20141121153832.a9bd6f8b765608cd1c1959a3@linux-foundation.org>
In-Reply-To: <1416557646-21755-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416557646-21755-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1416557646-21755-7-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 21 Nov 2014 17:14:05 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> This is the page owner tracking code which is introduced
> so far ago. It is resident on Andrew's tree, though, nobody
> tried to upstream so it remain as is. Our company uses this feature
> actively to debug memory leak or to find a memory hogger so
> I decide to upstream this feature.
> 
> This functionality help us to know who allocates the page.
> When allocating a page, we store some information about
> allocation in extra memory. Later, if we need to know
> status of all pages, we can get and analyze it from this stored
> information.
> 
> In previous version of this feature, extra memory is statically defined
> in struct page, but, in this version, extra memory is allocated outside
> of struct page. It enables us to turn on/off this feature at boottime
> without considerable memory waste.
> 
> Although we already have tracepoint for tracing page allocation/free,
> using it to analyze page owner is rather complex. We need to enlarge
> the trace buffer for preventing overlapping until userspace program
> launched. And, launched program continually dump out the trace buffer
> for later analysis and it would change system behaviour with more
> possibility rather than just keeping it in memory, so bad for debug.
> 
> Moreover, we can use page_owner feature further for various purposes.
> For example, we can use it for fragmentation statistics implemented in
> this patch. And, I also plan to implement some CMA failure debugging
> feature using this interface.
> 
> I'd like to give the credit for all developers contributed this feature,
> but, it's not easy because I don't know exact history. Sorry about that.
> Below is people who has "Signed-off-by" in the patches in Andrew's tree.
> 
> ...
>
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -884,6 +884,12 @@ bytes respectively. Such letter suffixes can also be entirely omitted.
>  			MTRR settings.  This parameter disables that behavior,
>  			possibly causing your machine to run very slowly.
>  
> +	disable_page_owner
> +			[KNL] Disable to store the information who requests
> +			the page.

How about "Disable storage of the information about who allocated each
page".

It seems odd that we have a disable flag.  Wouldn't it be less
surprising to disable it by default and only enable if the boot option
is provided?

What is the overhead of page_owner if it is runtime-disabled, btw? 
Will it be feasible for lots of people to just leave it enabled in
config and to only turn it on when they want to use it?  That would be
nice.  Please add a paragraph on this point to the changelog and the
yet-to-be-written documentation.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

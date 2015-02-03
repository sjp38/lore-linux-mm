Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 74833900015
	for <linux-mm@kvack.org>; Mon,  2 Feb 2015 19:25:28 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id x19so21532357ier.10
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 16:25:28 -0800 (PST)
Received: from mail-ie0-x22b.google.com (mail-ie0-x22b.google.com. [2607:f8b0:4001:c03::22b])
        by mx.google.com with ESMTPS id ga10si8613493igd.13.2015.02.02.16.25.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 02 Feb 2015 16:25:27 -0800 (PST)
Received: by mail-ie0-f171.google.com with SMTP id tr6so21538360ieb.2
        for <linux-mm@kvack.org>; Mon, 02 Feb 2015 16:25:27 -0800 (PST)
Date: Mon, 2 Feb 2015 16:25:25 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/5] mm/page_alloc.c: Pull out init code from
 build_all_zonelists
In-Reply-To: <1422921016-27618-3-git-send-email-linux@rasmusvillemoes.dk>
Message-ID: <alpine.DEB.2.10.1502021624090.667@chino.kir.corp.google.com>
References: <1422921016-27618-1-git-send-email-linux@rasmusvillemoes.dk> <1422921016-27618-3-git-send-email-linux@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vishnu Pratap Singh <vishnu.ps@samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 3 Feb 2015, Rasmus Villemoes wrote:

> Pulling the code protected by if (system_state == SYSTEM_BOOTING) into
> its own helper allows us to shrink .text a little. This relies on
> build_all_zonelists already having a __ref annotation. Add a comment
> explaining why so one doesn't have to track it down through git log.
> 

I think we should see the .text savings in the changelog to decide whether 
we want a __ref function (granted, with comment) calling an __init 
function in the source code.

> Signed-off-by: Rasmus Villemoes <linux@rasmusvillemoes.dk>
> ---
>  mm/page_alloc.c | 17 ++++++++++++++---
>  1 file changed, 14 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 7633c503a116..c58aa42a3387 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3945,18 +3945,29 @@ static int __build_all_zonelists(void *data)
>  	return 0;
>  }
>  
> +static noinline void __init
> +build_all_zonelists_init(void)
> +{
> +	__build_all_zonelists(NULL);
> +	mminit_verify_zonelist();
> +	cpuset_init_current_mems_allowed();
> +}
> +
>  /*
>   * Called with zonelists_mutex held always
>   * unless system_state == SYSTEM_BOOTING.
> + *
> + * __ref due to (1) call of __meminit annotated setup_zone_pageset
> + * [we're only called with non-NULL zone through __meminit paths] and
> + * (2) call of __init annotated helper build_all_zonelists_init
> + * [protected by SYSTEM_BOOTING].
>   */
>  void __ref build_all_zonelists(pg_data_t *pgdat, struct zone *zone)
>  {
>  	set_zonelist_order();
>  
>  	if (system_state == SYSTEM_BOOTING) {
> -		__build_all_zonelists(NULL);
> -		mminit_verify_zonelist();
> -		cpuset_init_current_mems_allowed();
> +		build_all_zonelists_init();
>  	} else {
>  #ifdef CONFIG_MEMORY_HOTPLUG
>  		if (zone)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7E0CA6B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 04:04:33 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k200so92525919lfg.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:04:33 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id d64si2642183wma.108.2016.04.29.01.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Apr 2016 01:04:32 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id n129so17198251wmn.1
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:04:32 -0700 (PDT)
Date: Fri, 29 Apr 2016 10:04:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] Use existing helper to convert "on/off" to boolean
Message-ID: <20160429080430.GA21977@dhcp22.suse.cz>
References: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1461908824-16129-1-git-send-email-mnghuan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minfei Huang <mnghuan@gmail.com>
Cc: akpm@linux-foundation.org, labbott@fedoraproject.org, rjw@rjwysocki.net, mgorman@techsingularity.net, vbabka@suse.cz, rientjes@google.com, kirill.shutemov@linux.intel.com, iamjoonsoo.kim@lge.com, izumi.taku@jp.fujitsu.com, alexander.h.duyck@redhat.com, hannes@cmpxchg.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 29-04-16 13:47:04, Minfei Huang wrote:
> It's more convenient to use existing function helper to convert string
> "on/off" to boolean.

But kstrtobool in linux-next only does "This routine returns 0 iff the
first character is one of 'Yy1Nn0'" so it doesn't know about on/off.
Or am I missing anything?

> 
> Signed-off-by: Minfei Huang <mnghuan@gmail.com>
> ---
>  lib/kstrtox.c    | 2 +-
>  mm/page_alloc.c  | 9 +--------
>  mm/page_poison.c | 8 +-------
>  3 files changed, 3 insertions(+), 16 deletions(-)
> 
> diff --git a/lib/kstrtox.c b/lib/kstrtox.c
> index d8a5cf6..3c66fc4 100644
> --- a/lib/kstrtox.c
> +++ b/lib/kstrtox.c
> @@ -326,7 +326,7 @@ EXPORT_SYMBOL(kstrtos8);
>   * @s: input string
>   * @res: result
>   *
> - * This routine returns 0 iff the first character is one of 'Yy1Nn0', or
> + * This routine returns 0 if the first character is one of 'Yy1Nn0', or
>   * [oO][NnFf] for "on" and "off". Otherwise it will return -EINVAL.  Value
>   * pointed to by res is updated upon finding a match.
>   */
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 59de90d..d31426d 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -513,14 +513,7 @@ static int __init early_debug_pagealloc(char *buf)
>  {
>  	if (!buf)
>  		return -EINVAL;
> -
> -	if (strcmp(buf, "on") == 0)
> -		_debug_pagealloc_enabled = true;
> -
> -	if (strcmp(buf, "off") == 0)
> -		_debug_pagealloc_enabled = false;
> -
> -	return 0;
> +	return kstrtobool(buf, &_debug_pagealloc_enabled);
>  }
>  early_param("debug_pagealloc", early_debug_pagealloc);
>  
> diff --git a/mm/page_poison.c b/mm/page_poison.c
> index 479e7ea..1eae5fa 100644
> --- a/mm/page_poison.c
> +++ b/mm/page_poison.c
> @@ -13,13 +13,7 @@ static int early_page_poison_param(char *buf)
>  {
>  	if (!buf)
>  		return -EINVAL;
> -
> -	if (strcmp(buf, "on") == 0)
> -		want_page_poisoning = true;
> -	else if (strcmp(buf, "off") == 0)
> -		want_page_poisoning = false;
> -
> -	return 0;
> +	return strtobool(buf, &want_page_poisoning);
>  }
>  early_param("page_poison", early_page_poison_param);
>  
> -- 
> 2.6.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

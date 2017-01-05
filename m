Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f198.google.com (mail-wj0-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 837526B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 10:50:57 -0500 (EST)
Received: by mail-wj0-f198.google.com with SMTP id iq1so60334798wjb.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 07:50:57 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i76si82321122wmh.87.2017.01.05.07.50.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 07:50:56 -0800 (PST)
Date: Thu, 5 Jan 2017 16:50:54 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: add new background defrag option
Message-ID: <20170105155053.GW21618@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
 <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fe83f15e-2d9f-e36c-3a89-ce1a2b39e3ca@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 05-01-17 14:58:47, Vlastimil Babka wrote:
[...]
> I'm not a fan of either name, so I've tried to implement my own
> suggestion. Turns out it was easier than expected, as there's no kernel
> boot option for "defer", just for "enabled", so that particular worry
> was unfounded.
> 
> And personally I think that it's less confusing when one can enable defer
> and madvise together (and not any other combination), than having to dig
> up the difference between "defer" and "background".
> 
> I have only tested the sysfs manipulation, not actual THP, but seems to me
> that alloc_hugepage_direct_gfpmask() already happens to process the flags
> in a way that it works as expected.

IMHO this looks indeed much simpler implementation wise, more consistent
from the semantic point of view and less confusing from the usage POV.
 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 10eedbf14421..cc5ae86169a8 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -150,7 +150,16 @@ static ssize_t triple_flag_store(struct kobject *kobj,
>  				 enum transparent_hugepage_flag deferred,
>  				 enum transparent_hugepage_flag req_madv)
>  {
> -	if (!memcmp("defer", buf,
> +	if (!memcmp("defer madvise", buf,
> +			min(sizeof("defer madvise")-1, count))
> +	    || !memcmp("madvise defer", buf,
> +			min(sizeof("madvise defer")-1, count))) {
> +		if (enabled == deferred)
> +			return -EINVAL;
> +		clear_bit(enabled, &transparent_hugepage_flags);
> +		set_bit(req_madv, &transparent_hugepage_flags);
> +		set_bit(deferred, &transparent_hugepage_flags);
> +	} else if (!memcmp("defer", buf,
>  		    min(sizeof("defer")-1, count))) {
>  		if (enabled == deferred)
>  			return -EINVAL;
> @@ -251,9 +260,12 @@ static ssize_t defrag_show(struct kobject *kobj,
>  {
>  	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
>  		return sprintf(buf, "[always] defer madvise never\n");
> -	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
> -		return sprintf(buf, "always [defer] madvise never\n");
> -	else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags)) {
> +		if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
> +			return sprintf(buf, "always [defer] [madvise] never\n");
> +		else
> +			return sprintf(buf, "always [defer] madvise never\n");
> +	} else if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
>  		return sprintf(buf, "always defer [madvise] never\n");
>  	else
>  		return sprintf(buf, "always defer madvise [never]\n");

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

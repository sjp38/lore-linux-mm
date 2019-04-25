Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1FFCC10F03
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:09:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8AC62218DE
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 12:09:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8AC62218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 248566B0010; Thu, 25 Apr 2019 08:09:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1F5D56B0266; Thu, 25 Apr 2019 08:09:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0E61D6B0269; Thu, 25 Apr 2019 08:09:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A9E5B6B0010
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 08:09:48 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id s21so11566422edd.10
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 05:09:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=sD8RiQWNTfYiU3cl69qlEB717hjmQNk42uCNOsfRkvo=;
        b=Yme8f0WZmC6Z202ge4jFCmIZQp8GpuPDsLHvrWXdwUNgf+lVBHbJPeoXQf6U/97Vy6
         uad/+SaP2AFwWvxM6wt1tdQi0UX2rQENVJuXtzxG2BZCrhytoS14hjVaCnu5gPH4tQZQ
         WNEdfhMe6FkJOX6ZqI2rF6jqoC1gAd/tM44Nxg66K/6eDPxvBSqSCafl2lGTPbFUyS+B
         yeFyzOQBLZYdmq6+OQLhDCqhLCc1bDAaJej1WBEfJfhJ+A8HwlkaD7z4h2RKkeOx7wHc
         CeaUxR5O9UnEAUvnFnwAfOX8J+INh/DLTS3BJxRzFDxLE6Pk0PGTY3oxset9FYqxtrzr
         HwCA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXWVe+9Bx9BEEd1jMX8kReQK6a+tdJvQFOGn700LGI5bnRSxjV1
	r0Kd6qaE+S3jNUUoa2wQu1+I1N4pNgHNMr9c1AIVXImhI+ukYw7ojvF2swwfzL8LLKSDhCO/wMo
	Zc74Aw8nRRhLuqc/0flqKIUg5EFB3btVr/xqSXu0J5nO/6sk0N2POz+oq4by7jMU=
X-Received: by 2002:a50:9797:: with SMTP id e23mr23907398edb.265.1556194188228;
        Thu, 25 Apr 2019 05:09:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxNOGkOTDrjFqg9lnxCBxsQXMVQVIuLWJK47eaTpj2+4p5ydz06Z+Ka7BROpHFaJZpB4oB6
X-Received: by 2002:a50:9797:: with SMTP id e23mr23907350edb.265.1556194187299;
        Thu, 25 Apr 2019 05:09:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556194187; cv=none;
        d=google.com; s=arc-20160816;
        b=ou56yBf+iULj69rlAbcQaePOtrgvDckFSjG2onyaB/fhw+M+fOsMvhvVOsqJN+U978
         4QTxV1iDwCKNiJXK3aftz9Xu9iAer427y+6MrTn+DruT08w8RPLKsHrgfaeJTx29GPNl
         mnzDOjH9qnqtczSDRQvEz3SrAEzMaiJmuo9lojezMAtWaWChfBmDON/b+kkrW5JLry4f
         UN4t2O3mQhrBm93oXqmcDsCcmKK7ITenBQEbaxu3XUz7cqv6+TjQBdqhx3d2fI9BS4vF
         jcGy+zQ6joPbRgIm2TAvS32Ihul7Y14Et/PfNSw9pQU1F3pv2hAYc1z9jE7aqyhkd/jF
         tPvw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=sD8RiQWNTfYiU3cl69qlEB717hjmQNk42uCNOsfRkvo=;
        b=jsxwlIt2cBElq2Y3qqBYW4aCtm5LjSf9Yrcp1dVxA3k5xJvSKEhsqWTN+xuwx0whvk
         euD78TC8v6AWqSCo1JaKQxdj81o7tkPnOLQLhzBSrbcAx1YGfUWQiystxRjquDPe39sY
         4R7is7ndB0W3rgYkPM3pGf1kk6kWW59kAdphK4vBxRzphGdw3380dTQo1aYUtkeI8WqU
         M2TJxTy6zdBuZEKPHVb9Y9XJORqQcoG2zJGsJVzqzyCvWtPEIDYXTiKHs3Bl9x3viwjH
         63L30PxhiwvIiKJdyy9LwSz4bQnc0c8QG7XAZmF/mCk/RvDDSEAprhBgBrYpcdpLQLf6
         4nDw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b31si907730edd.251.2019.04.25.05.09.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 05:09:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 5EF19AD45;
	Thu, 25 Apr 2019 12:09:46 +0000 (UTC)
Date: Thu, 25 Apr 2019 14:09:45 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/Kconfig: update "Memory Model" help text
Message-ID: <20190425120945.GB1144@dhcp22.suse.cz>
References: <1556188531-20728-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1556188531-20728-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu 25-04-19 13:35:31, Mike Rapoport wrote:
> The help describing the memory model selection is outdated. It still says
> that SPARSEMEM is experimental and DISCONTIGMEM is a preferred over
> SPARSEMEM.
> 
> Update the help text for the relevant options:
> * add a generic help for the "Memory Model" prompt
> * add description for FLATMEM
> * reduce the description of DISCONTIGMEM and add a deprecation note
> * prefer SPARSEMEM over DISCONTIGMEM
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/Kconfig | 48 +++++++++++++++++++++++-------------------------
>  1 file changed, 23 insertions(+), 25 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 25c71eb8a7db..8f7ae4d71b77 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -11,23 +11,24 @@ choice
>  	default DISCONTIGMEM_MANUAL if ARCH_DISCONTIGMEM_DEFAULT
>  	default SPARSEMEM_MANUAL if ARCH_SPARSEMEM_DEFAULT
>  	default FLATMEM_MANUAL
> +	help
> +	  This option allows you to change some of the ways that
> +	  Linux manages its memory internally. Most users will
> +	  only have one option here selected by the architecture
> +	  configuration. This is normal.
>  
>  config FLATMEM_MANUAL
>  	bool "Flat Memory"
>  	depends on !(ARCH_DISCONTIGMEM_ENABLE || ARCH_SPARSEMEM_ENABLE) || ARCH_FLATMEM_ENABLE
>  	help
> -	  This option allows you to change some of the ways that
> -	  Linux manages its memory internally.  Most users will
> -	  only have one option here: FLATMEM.  This is normal
> -	  and a correct option.
> -
> -	  Some users of more advanced features like NUMA and
> -	  memory hotplug may have different options here.
> -	  DISCONTIGMEM is a more mature, better tested system,
> -	  but is incompatible with memory hotplug and may suffer
> -	  decreased performance over SPARSEMEM.  If unsure between
> -	  "Sparse Memory" and "Discontiguous Memory", choose
> -	  "Discontiguous Memory".
> +	  This option is best suited for non-NUMA systems with
> +	  flat address space. The FLATMEM is the most efficient
> +	  system in terms of performance and resource consumption
> +	  and it is the best option for smaller systems.
> +
> +	  For systems that have holes in their physical address
> +	  spaces and for features like NUMA and memory hotplug,
> +	  choose "Sparse Memory"
>  
>  	  If unsure, choose this option (Flat Memory) over any other.
>  
> @@ -38,29 +39,26 @@ config DISCONTIGMEM_MANUAL
>  	  This option provides enhanced support for discontiguous
>  	  memory systems, over FLATMEM.  These systems have holes
>  	  in their physical address spaces, and this option provides
> -	  more efficient handling of these holes.  However, the vast
> -	  majority of hardware has quite flat address spaces, and
> -	  can have degraded performance from the extra overhead that
> -	  this option imposes.
> +	  more efficient handling of these holes.
>  
> -	  Many NUMA configurations will have this as the only option.
> +	  Although "Discontiguous Memory" is still used by several
> +	  architectures, it is considered deprecated in favor of
> +	  "Sparse Memory".
>  
> -	  If unsure, choose "Flat Memory" over this option.
> +	  If unsure, choose "Sparse Memory" over this option.
>  
>  config SPARSEMEM_MANUAL
>  	bool "Sparse Memory"
>  	depends on ARCH_SPARSEMEM_ENABLE
>  	help
>  	  This will be the only option for some systems, including
> -	  memory hotplug systems.  This is normal.
> +	  memory hot-plug systems.  This is normal.
>  
> -	  For many other systems, this will be an alternative to
> -	  "Discontiguous Memory".  This option provides some potential
> -	  performance benefits, along with decreased code complexity,
> -	  but it is newer, and more experimental.
> +	  This option provides efficient support for systems with
> +	  holes is their physical address space and allows memory
> +	  hot-plug and hot-remove.
>  
> -	  If unsure, choose "Discontiguous Memory" or "Flat Memory"
> -	  over this option.
> +	  If unsure, choose "Flat Memory" over this option.
>  
>  endchoice
>  
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs


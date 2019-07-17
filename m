Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EBADC76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:43:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D1C0E2173E
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 21:43:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D1C0E2173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4E4476B0005; Wed, 17 Jul 2019 17:43:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 494086B0006; Wed, 17 Jul 2019 17:43:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 383F88E0001; Wed, 17 Jul 2019 17:43:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DE58C6B0005
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 17:43:54 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v7so12691440wrt.6
        for <linux-mm@kvack.org>; Wed, 17 Jul 2019 14:43:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=R6yzRFKjLNutBbjBCce/hhZ9RyUPFUpEfUfseQ58zYg=;
        b=t33a+vwm4qgAUGGBmsqz7ooQbE6lT9eiHxNE/rSp9nC3lZZrNLQioWaHOQEYh/8nZC
         UZ1lXdQCFMpJaJhsUBS3fGgfDgiZw15lI6zg9yYOGmE/jilTJWFrydJil2X9bn3mJFvH
         stecKv9EU6Blm6VK3T8r43ntbcGIY1sklLOJfe13bV2wmQ3Lj8XrlBqbt9rzuOrJ1oy1
         kPG+drmf3x68TrSbVdlz0kKIlnfYkOk+F+SHOSVn2U6zC10d1h4H/zjyzUmtvdHiS29b
         /CpqYZ7+HVkaYIZpyqWW+RsAt8VTJAOgjMftE/8G0vIppP9968NCDjNp77L9dOTHT0SH
         EZtw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAWhvuJyFUsWxYltdV0gvG0t26x1+oHoijV+/Feb8yfzEMh9F5Uf
	XYCxI5h+CTeT3IU5JIT0m4dlmwW6LoYgBGaVDzykLSDf2KApPkU9KvYXOpROFFcf9bFK9y/tGUv
	jslc1qzAmpM7/mC/8DzY9UEfs3H7vM9iQTJ42Hv1YByIkkzlInih7UZ5cMq1Qv21i1A==
X-Received: by 2002:a05:6000:118a:: with SMTP id g10mr43900877wrx.175.1563399834491;
        Wed, 17 Jul 2019 14:43:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxan89FAGvPsBgESSIGYi+kuZNgYSu6BoBFrReGw6YZSDdCBHJ1o/HRKXRgDpnJbwJj34mI
X-Received: by 2002:a05:6000:118a:: with SMTP id g10mr43900851wrx.175.1563399833747;
        Wed, 17 Jul 2019 14:43:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563399833; cv=none;
        d=google.com; s=arc-20160816;
        b=poQXXe04NbdEgGLxUHaeYYKuH52OLeKDfpcgDGQ7nJoxbVmbkA6AeIbzAGokeW5f5y
         IthpqEKTVqlI+4aGvYBWHPmcNv3MH0LG7/AQpDxltqAyr+i52vc7ViAVYTUbf6kGEB5N
         SdbYVyhgPNSK9JHniiElIqy4IXnHyUL9aMx7LtUoRXltgALe2bkEFbGW41Sdy9Mk7DHe
         9DelQBLRl6/X+gybCbzH76terr3cJKNqilT6WFi3zzKtoa5XNcuZDiGQimM7CYZe10N7
         5XUIqX4g9vXtNgV8OwSpnV8Zud79CKKng5oJms/xNZLMMt1Bozae4MSugspsH6bLS5VX
         veGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=R6yzRFKjLNutBbjBCce/hhZ9RyUPFUpEfUfseQ58zYg=;
        b=Cl/l7RfAE19j9NUhYUrFud6ogyq4huDLJeL/PZKKv478Kyj2nU807/sjo0sZkRJO5I
         hNC850Mxs1R3wrY7RopxbkaFCdwjfI9w1LEpFsDEy9+VKPzCfGqZ8SMeu6n2/YGnBTEn
         BSBEwSdOwkjvmteahRScV+9cgEuY9lHHH9lj22kXCBkREZgrVkoNld1jfLfjO2TMYD7M
         lIlY27sRR2EPLukoQ9a1ij0TotuJJyTaJoOy5kDv36wPCK6X4xViIl5zQsB1u0zAeuEn
         w9nNuyjh2ZUHdwZB3tPqyVhe6G4v8L23zKBb4vUtGgd6xHCQhPAUtYtObp7fKM+p0OFA
         UJGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id y16si20482234wmc.177.2019.07.17.14.43.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Wed, 17 Jul 2019 14:43:53 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from pd9ef1cb8.dip0.t-ipconnect.de ([217.239.28.184] helo=nanos)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hnriC-0005hz-EP; Wed, 17 Jul 2019 23:43:44 +0200
Date: Wed, 17 Jul 2019 23:43:43 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <joro@8bytes.org>
cc: Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
In-Reply-To: <20190717071439.14261-3-joro@8bytes.org>
Message-ID: <alpine.DEB.2.21.1907172337590.1778@nanos.tec.linutronix.de>
References: <20190717071439.14261-1-joro@8bytes.org> <20190717071439.14261-3-joro@8bytes.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Linutronix-Spam-Score: -1.0
X-Linutronix-Spam-Level: -
X-Linutronix-Spam-Status: No , -1.0 points, 5.0 required,  ALL_TRUSTED=-1,SHORTCIRCUIT=-0.0001
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Jul 2019, Joerg Roedel wrote:

> From: Joerg Roedel <jroedel@suse.de>
> 
> With huge-page ioremap areas the unmappings also need to be
> synced between all page-tables. Otherwise it can cause data
> corruption when a region is unmapped and later re-used.
> 
> Make the vmalloc_sync_one() function ready to sync
> unmappings.
> 
> Fixes: 5d72b4fba40ef ('x86, mm: support huge I/O mapping capability I/F')
> Signed-off-by: Joerg Roedel <jroedel@suse.de>
> ---
>  arch/x86/mm/fault.c | 7 ++++---
>  1 file changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
> index 4a4049f6d458..d71e167662c3 100644
> --- a/arch/x86/mm/fault.c
> +++ b/arch/x86/mm/fault.c
> @@ -194,11 +194,12 @@ static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
>  
>  	pmd = pmd_offset(pud, address);
>  	pmd_k = pmd_offset(pud_k, address);
> -	if (!pmd_present(*pmd_k))
> -		return NULL;
>  
> -	if (!pmd_present(*pmd))
> +	if (pmd_present(*pmd) ^ pmd_present(*pmd_k))
>  		set_pmd(pmd, *pmd_k);
> +
> +	if (!pmd_present(*pmd_k))
> +		return NULL;
>  	else
>  		BUG_ON(pmd_pfn(*pmd) != pmd_pfn(*pmd_k));

So in case of unmap, this updates only the first entry in the pgd_list
because vmalloc_sync_all() will break out of the iteration over pgd_list
when NULL is returned from vmalloc_sync_one().

I'm surely missing something, but how is that supposed to sync _all_ page
tables on unmap as the changelog claims?

Thanks,

	tglx


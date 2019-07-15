Return-Path: <SRS0=FHqE=VM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66649C76191
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 37A27206B8
	for <linux-mm@archiver.kernel.org>; Mon, 15 Jul 2019 13:08:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 37A27206B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linutronix.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3FD86B0006; Mon, 15 Jul 2019 09:08:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BF0D46B0007; Mon, 15 Jul 2019 09:08:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A91926B0008; Mon, 15 Jul 2019 09:08:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 576AF6B0006
	for <linux-mm@kvack.org>; Mon, 15 Jul 2019 09:08:26 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id f9so8855882wrq.14
        for <linux-mm@kvack.org>; Mon, 15 Jul 2019 06:08:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:in-reply-to:message-id:references:user-agent
         :mime-version;
        bh=IY7Ys6bCsiGP1PJT/lqyz3wq4bjj1DQURlQTsFI+2L0=;
        b=lYkdhTlTqsv2nQYGLzMP/BGQe0t3WcqzscVipN3fw8c6/sQ7LRVfkKCcM2a6VK5NFN
         w1gAaW7arQwX7OVUTh8J1Q9U3/ve5Y5mxadkkcc/4wG4TiJeUndivPQx54ahAw6dSfs3
         VGJb+VmY9YvttuGICoPLX6XCmZxlZ+SsExTtqs6l2QYWeoO3HESVxKsQ8nZkZ7deqxQX
         l71yjvgQTMTpspGzXAtnOvN8BjoWSWCf38HpHmdHQipit8vAXC+r/qkGAzZjaRxdgFa5
         V3+oA1wtcRdZgw+EIgT1s9dR04arwrkEwhslWTPbIxVmstr9NeGog+DfblOm012dBt8q
         cs7A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
X-Gm-Message-State: APjAAAVyI+28bxU+kl7q9/PcvgASX5RZrlrjJ8pbEC4bSM6ig01S8tSd
	KgIMcOHGxi5vgXOeFsfhuuWFki9+zkEkwLyrTPJsB9zJezZjsc3YzkWE6xnVPORKmpNLDUV2rqt
	BkPD+vb14bAvAcegPRTkDWuwcCEuV49T6h9FJnh7QTlBkYH56WGbe4qbtzS7jkl+8lw==
X-Received: by 2002:a1c:e710:: with SMTP id e16mr25440034wmh.38.1563196105886;
        Mon, 15 Jul 2019 06:08:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwePIKIT30+upV93O737F6kCi0KDikkrtDsLIGYm6+qVfiExo0qNRfjAT0w2KLzlaaQkUm2
X-Received: by 2002:a1c:e710:: with SMTP id e16mr25439978wmh.38.1563196105060;
        Mon, 15 Jul 2019 06:08:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563196105; cv=none;
        d=google.com; s=arc-20160816;
        b=TDV6CUzOJl9gKyswUqJa+3kqMOjlF86paHIroyT54APo3klscQvKinoQxTko5s0Q3f
         xVHnGmFPrl73WVt9KgqRAG29sdQFML4oNvu67N3Kz/aHGeYJ3x8UlscJEBD54qlqxWB4
         /zpWm3wDCsLwcBKzfrC9287C+l91YHcVtJz/SaR4X9sZnrd2IW2WYGEcRk7yVrDI92z0
         AoZh5YtAUVffDCKabDhJQu7X1+Szc/d874hIE1VRv/avL5xxQ7n5p6kGiZaV9mfm+Puj
         iXB+xbKL1DIIPJz2sNbEHlrH1pZfAS/nTy9+2RJX4O8C7Gf3VlNdSiISyMp2avSa8egu
         adQw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:references:message-id:in-reply-to:subject
         :cc:to:from:date;
        bh=IY7Ys6bCsiGP1PJT/lqyz3wq4bjj1DQURlQTsFI+2L0=;
        b=gRk537cR7bs8TdBO0G2pDsjEjqc1czqY9wCE/jKnfXXiEjaCSzcU1T2LS3FlGGHNJV
         r4m1/h5qSRrEdicnBfPguk/o5igxMbLsdw3LRo9Q1lZ0nOOawTnkpFHQ1HwpiVzEZcA+
         Rz081096PHKIVKfCVqQ1Q5z3RjCqD0JSfz52fc6a9Zt4R7LAwn9EMkvhC1IuU/tn1RU9
         o2JK1zsdV9hllLujA4dgk6+kR3En2v5I7HXyhK34mGDUPCwnGRUQyuqj543kR+KC38GV
         8b5xGm9yjxbGQy36myOnM3OxMsrVZVBYPRfyZbvBjAXaW4FbdaNbmif6OU6kIJraeFre
         ISIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a0a:51c0:0:12e:550::1])
        by mx.google.com with ESMTPS id r24si14030119wmc.11.2019.07.15.06.08.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 15 Jul 2019 06:08:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) client-ip=2a0a:51c0:0:12e:550::1;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of tglx@linutronix.de designates 2a0a:51c0:0:12e:550::1 as permitted sender) smtp.mailfrom=tglx@linutronix.de
Received: from [5.158.153.52] (helo=nanos.tec.linutronix.de)
	by Galois.linutronix.de with esmtpsa (TLS1.2:DHE_RSA_AES_256_CBC_SHA256:256)
	(Exim 4.80)
	(envelope-from <tglx@linutronix.de>)
	id 1hn0iE-0006Iz-UA; Mon, 15 Jul 2019 15:08:15 +0200
Date: Mon, 15 Jul 2019 15:08:14 +0200 (CEST)
From: Thomas Gleixner <tglx@linutronix.de>
To: Joerg Roedel <joro@8bytes.org>
cc: Dave Hansen <dave.hansen@linux.intel.com>, 
    Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, 
    Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, 
    Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, 
    linux-mm@kvack.org, Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 2/3] x86/mm: Sync also unmappings in vmalloc_sync_one()
In-Reply-To: <20190715110212.18617-3-joro@8bytes.org>
Message-ID: <alpine.DEB.2.21.1907151504190.1722@nanos.tec.linutronix.de>
References: <20190715110212.18617-1-joro@8bytes.org> <20190715110212.18617-3-joro@8bytes.org>
User-Agent: Alpine 2.21 (DEB 202 2017-01-01)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jul 2019, Joerg Roedel wrote:

> From: Joerg Roedel <jroedel@suse.de>
> 
> With huge-page ioremap areas the unmappings also need to be
> synced between all page-tables. Otherwise it can cause data
> corruption when a region is unmapped and later re-used.
> 
> Make the vmalloc_sync_one() function ready to sync
> unmappings.
> 
> Signed-off-by: Joerg Roedel <jroedel@suse.de>

Lacks a Fixes tag methinks.

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

It took me a while to understand what this is doing. Can we please have a
comment here?

> +
> +	if (!pmd_present(*pmd_k))
> +		return NULL;

Thanks,

	tglx


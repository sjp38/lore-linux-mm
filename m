Return-Path: <SRS0=4gxf=RO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65BA3C43381
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 16:32:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 169C521734
	for <linux-mm@archiver.kernel.org>; Mon, 11 Mar 2019 16:32:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=joelfernandes.org header.i=@joelfernandes.org header.b="UiFtWTE1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 169C521734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=joelfernandes.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DB898E0003; Mon, 11 Mar 2019 12:32:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88AC18E0002; Mon, 11 Mar 2019 12:32:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A30E8E0003; Mon, 11 Mar 2019 12:32:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 543FC8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 12:32:37 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id 35so5708559qty.12
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 09:32:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=pyQXcLatuiGi/bo6uxJQUtm3dUmwK7WB5Ls/qmNHhso=;
        b=eLsG138nUj9xm3KBFQndCeK9ipNBPsnUHhQ78N/ipjxlLQLWWwt2boha411IfJciOt
         Gc/84JmOEUQ4iQO2xu5gDSYvGxLXdV17HcWanKdbpOg5L3EcKRTrXltRWoI7MollF1Ks
         eKRZlHcoZAr8ODZOR0h6l9bu3PLwSaUyMGDBeqtX1wLB4ye3ljTEtCH+5upzT/71bTCW
         3Vmv6jcT5cnQI2Ly5dHtQ/tM6u8mNnpu2Sg/D0KuqC2rdReKy8IEKqWcQtEaDlXlXDSC
         qq+TpCQwP3S9/73GlhqPbFTrI7tNDs1pIspSwo6hqm4VkU3tPTlj676Xx6Ov+89jKoUo
         RJCQ==
X-Gm-Message-State: APjAAAVXiv+Gzicjbg1Y9mRLMsm08hwSlE/nXgKmBoO4NtwGdGY028lw
	Yickkvn0GQPLQRwPjOjmDAV6uSAg7jejYa5BKcLucvWdF5fSgeSnt5ucN5ftEvIXooQGwQXZGfz
	BMBu8tSd0PBz3bO6kFqsvdNPWvMne9elomEI8iPQCww2H60/3KjHxdj9HRBGgmeevZwCGLIZLJn
	3wl+EquZa5UeY+kidvVVRZcOohYqizfSJ9jwbXm/B21tiai2UDmgdJT4gDSEgXng+JqS1iTKgOw
	jTzhiWjXWYNs8XsHEB9hRjABoV9wuFv/qN+2eeJt1dfVtijMaQ5nGA/hkWBd5XHTk8eZVzVQZ3s
	glNZ3i6hF5sS/JOboqJrk6IcZO4wTqqNZg8jqSzaPtqBfZrNh2BKJbrqCxx6zGWjEWSuD4N+Ieu
	h
X-Received: by 2002:a0c:b88d:: with SMTP id y13mr26274314qvf.202.1552321957045;
        Mon, 11 Mar 2019 09:32:37 -0700 (PDT)
X-Received: by 2002:a0c:b88d:: with SMTP id y13mr26274247qvf.202.1552321955961;
        Mon, 11 Mar 2019 09:32:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552321955; cv=none;
        d=google.com; s=arc-20160816;
        b=oiJ8uJlrYkrhvobM+QJ2njVcukppTWHvu73TLs3zmnPuHgPcXUGZf2/pMsvviszBua
         14RuFsF9hdgzFYWhjnfgVifRB2RODRWq2FjTYuzAlBfI3+/ts7ZC5UvA8Yks64xF4DyW
         V8L/xLFjlppbJju2/mFwQua9/Ek+gLN+JFtEYIrbhEdCfyfCHl4NtaGuIty9KBLvbc+v
         kmJcM5/2hWHEQl41xSLPmKVPAsMPQ0Tc1hp3kZvZRQlx+OfFdr5GWy02WE2DQ10bT1rM
         CDVCdEedWrJF2f3y9ckvROB7k2es1g6Ry7X2GLGD+Bz/1pZyBk7iNBBZJLRXcS1QymuV
         NUsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=pyQXcLatuiGi/bo6uxJQUtm3dUmwK7WB5Ls/qmNHhso=;
        b=Fx3PpeC+0iwJ2MYjOiOojUawjVx1+RIPZwTFHRaurlZ01iU/+i4pQfieXeaSbnLrmW
         IjBo+Flhe3IVQ0QkiI/GFyhvKHcLFFX6HsEA+r8sXVQf1GZSy5tqDKLA8lctaCRgbKV6
         XjGELKHLPfXrUynN6cs3/bXjgmJzrcRgvXgkL821QfupFeuWDFgByIjCu05EvDKYz4JL
         8uChfBELb8FIysQU9QaPLd6eSQwgm4fNZt4kHNwE1LvnnRrccovZtEnZ+K69kmiBER0p
         PdlrCDmJ+q0tzBNcN/1vYWqyTaTMVAAnaNtVNGl4inQadOdXvyGuoX+oFkqPQCtbnLRR
         Ssow==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=UiFtWTE1;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 23sor3560336qkk.117.2019.03.11.09.32.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 09:32:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@joelfernandes.org header.s=google header.b=UiFtWTE1;
       spf=pass (google.com: domain of joel@joelfernandes.org designates 209.85.220.65 as permitted sender) smtp.mailfrom=joel@joelfernandes.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=joelfernandes.org; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=pyQXcLatuiGi/bo6uxJQUtm3dUmwK7WB5Ls/qmNHhso=;
        b=UiFtWTE1bEHCF2u3/E+AHCJsZr1xHyCgmuO83rSAJ75cHRKVt7ZV7WFfEifuAI5DAg
         JEHST3DheMpzW9st3pHb2jWx/2NzQeFxTxZ3x6eUFokWc1vhDU4RTGQQohR4PNKiuJMx
         mnPqswekcDWQ/SHL6b7Nm97cSTd/UZOu6mPNY=
X-Google-Smtp-Source: APXvYqxC/RiGc1suxXWZsaP2ROw/MyYAIx55Y8nZU9zXj9fZPIx0Tp4vCZU3eG8qbd82nyJDKL4R5g==
X-Received: by 2002:ae9:e901:: with SMTP id x1mr25640741qkf.124.1552321955265;
        Mon, 11 Mar 2019 09:32:35 -0700 (PDT)
Received: from localhost ([2620:0:1004:1100:cca9:fccc:8667:9bdc])
        by smtp.gmail.com with ESMTPSA id e4sm4037396qta.84.2019.03.11.09.32.33
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Mar 2019 09:32:34 -0700 (PDT)
Date: Mon, 11 Mar 2019 12:32:33 -0400
From: Joel Fernandes <joel@joelfernandes.org>
To: Sultan Alsawaf <sultan@kerneltoast.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>,
	Todd Kjos <tkjos@android.com>, Martijn Coenen <maco@android.com>,
	Christian Brauner <christian@brauner.io>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org,
	devel@driverdev.osuosl.org, linux-mm@kvack.org,
	Suren Baghdasaryan <surenb@google.com>,
	Tim Murray <timmurray@google.com>, mhocko@kernel.org,
	vbabka@suse.cz, hannes@cmpxchg.org
Subject: Re: [RFC] simple_lmk: Introduce Simple Low Memory Killer for Android
Message-ID: <20190311163233.GA34252@google.com>
References: <20190310203403.27915-1-sultan@kerneltoast.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190310203403.27915-1-sultan@kerneltoast.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 10, 2019 at 01:34:03PM -0700, Sultan Alsawaf wrote:
[...]
>  
>  	/* Perform scheduler related setup. Assign this task to a CPU. */
>  	retval = sched_fork(clone_flags, p);
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3eb01dedf..fd0d697c6 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -67,6 +67,7 @@
>  #include <linux/lockdep.h>
>  #include <linux/nmi.h>
>  #include <linux/psi.h>
> +#include <linux/simple_lmk.h>
>  
>  #include <asm/sections.h>
>  #include <asm/tlbflush.h>
> @@ -967,6 +968,11 @@ static inline void __free_one_page(struct page *page,
>  		}
>  	}
>  
> +#ifdef CONFIG_ANDROID_SIMPLE_LMK
> +	if (simple_lmk_page_in(page, order, migratetype))
> +		return;
> +#endif
> +
>  	list_add(&page->lru, &zone->free_area[order].free_list[migratetype]);
>  out:
>  	zone->free_area[order].nr_free++;
> @@ -4427,6 +4433,13 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
>  	if (costly_order && !(gfp_mask & __GFP_RETRY_MAYFAIL))
>  		goto nopage;
>  
> +#ifdef CONFIG_ANDROID_SIMPLE_LMK
> +	page = simple_lmk_oom_alloc(order, ac->migratetype);
> +	if (page)
> +		prep_new_page(page, order, gfp_mask, alloc_flags);
> +	goto got_pg;
> +#endif
> +

Hacking generic MM code with Android-specific callback is probably a major
issue with your patch. Also I CC'd -mm maintainers and lists since your patch
touches page_alloc.c. Always run get_maintainer.pl before sending a patch. I
added them this time.

Have you looked at the recent PSI work that Suren and Johannes have been
doing [1]?  As I understand, userspace lmkd may be migrated to use that at some
point.  Suren can provide more details. I am sure AOSP contributions to make
LMKd better by using the PSI backend would be appreciated. Please consider
collaborating on that and help out, thanks. Check the cover-letter of that
patch [1] where LMKd is mentioned.

thanks,

 - Joel

[1] https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1951257.html


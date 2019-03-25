Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E44A4C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:15:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A78262075E
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 22:15:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A78262075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 457AD6B0003; Mon, 25 Mar 2019 18:15:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 408536B0006; Mon, 25 Mar 2019 18:15:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F7BC6B0007; Mon, 25 Mar 2019 18:15:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id EEF9F6B0003
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 18:15:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id go14so778354plb.0
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 15:15:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iVuT+lYcoUaVMyAChoWCndx9VaxL3ncU3MQZzxI4tv8=;
        b=pOJqfjSBN13yMUaKbJpdkPsuFZvCKnBPD+/U0SC3F9a/4Xnh6sIYjqRBPG65dLgqxG
         eG0ZDXYRYUeJ7rqv4BcQ9T/kRqfZ0JHDBdUiVKKZUSYOJWBtAtoxerDQrpJ7RXkBGzW3
         zsv7NNjy0Lq6nu6WK0bO3DOb1mHLHf1oPUt+mXaHIdKlMcLoWJOiR1SpvHIKcvlBdajK
         SxJVAPtkUe7b5fHyKKA+iKNtvJRqtDUIzRxWn/KCHa4mDyMu/thfZYUtPUetGJPvPmr2
         76Xj82WpzAlFnWCgsXPhjekZ1lBjH0ISPu9cogWTV+P64qumaAtkcMNB+cCN1ML04xC9
         hB/g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAWhoVsdYQ1e8hJEFn5luliXYeUHqKQ8ShGUU3/3ZxlGgNpLT/lp
	53GR/Ow1VGcCilLA75HNXTUs3NDk9zf7MpHO0MtldjhlLtgEnHw3oetN92asklDUnIiH+4Nc/KP
	BAe1nYYaU42JKST9g+FA2+P/6E6y/w+OwM81+ULp0H4RrrU0G5+lQNbm+60v7Jv7JhA==
X-Received: by 2002:a17:902:282b:: with SMTP id e40mr27438258plb.111.1553552144637;
        Mon, 25 Mar 2019 15:15:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxIBn4BO6f8txBpwc4O5RGbvY/NwjJq+HR4g5u2JIdPYucDAuwiNKm7NgFkXAutpsPehRfe
X-Received: by 2002:a17:902:282b:: with SMTP id e40mr27438203plb.111.1553552143937;
        Mon, 25 Mar 2019 15:15:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553552143; cv=none;
        d=google.com; s=arc-20160816;
        b=lDoDXDpuGQ3BzVEF2j+BPAtOiqwAYXL2nbdIkubc1jpd9o/sYmko/AIYVPXEj7ZAuR
         6FgzOmPz+9ORj4Gh0ON22CUCh/IvSpNHx7x4uLN35wvabQWNY6FKY1m8CaUi6PnFcVMA
         bqCWDJDLkG8xIAJMwg0lXaXO7B0p9SQFTcrAovW5ZdRkvBb/ZYsKn3KA4w1gFaIKF1PK
         0SDWTdKA2O5dwc/R3x25eVjDpahgHvjRaKFrjsiaojRaNzhFcrrdhlVrmBW9XQH4IHmE
         pMXLLDOpznbXrQMhKKvKNrgDZ3Eh5lU3cCsa5JDImWd3McxCYbqaQy1C/nQ5FbYAxy2G
         LgyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=iVuT+lYcoUaVMyAChoWCndx9VaxL3ncU3MQZzxI4tv8=;
        b=y49soUIFEy5PwRaT4DRQC03MEu6b9QLTcAxGJZ44Z2UC0EwFotqf5vaXFY1NIl3QZs
         k+sBFy4OhDgUZOOkJlrHouNBxZicH3sQ6USFjcsgFBoJtqiH3W8LJxpJsfQxHR+NhMxg
         xOyniL6rEbpm5Hq/IrH3c2saiFbVxt2K/rid6Ug5pEGkaY1NttsJeB0Vov50j34r6h8G
         gAAgsYc2akaqh+6ALp0iiVrVSHFGwntd8oFOxDVH1UIB7SOMhH4mvykb+3WNQgWISJTN
         y0p6j4Gg6pU4Pt0HnKNnkUWY0xrIP5pCJVr9idkDqvvWK+SyedMOrWtuXITkj3uj7GLe
         EsSw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id az1si13220576plb.9.2019.03.25.15.15.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 15:15:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from akpm3.svl.corp.google.com (unknown [104.133.8.65])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 5980BAF5;
	Mon, 25 Mar 2019 22:15:43 +0000 (UTC)
Date: Mon, 25 Mar 2019 15:15:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Yue Hu <zbestahu@gmail.com>
Cc: iamjoonsoo.kim@lge.com, labbott@redhat.com, rppt@linux.vnet.ibm.com,
 rdunlap@infradead.org, linux-mm@kvack.org, huyue2@yulong.com, Anshuman
 Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH] mm/cma: Fix crash on CMA allocation if bitmap
 allocation fails
Message-Id: <20190325151541.15350b039239ee9b331f3922@linux-foundation.org>
In-Reply-To: <20190325081309.6004-1-zbestahu@gmail.com>
References: <20190325081309.6004-1-zbestahu@gmail.com>
X-Mailer: Sylpheed 3.7.0 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 25 Mar 2019 16:13:09 +0800 Yue Hu <zbestahu@gmail.com> wrote:

> From: Yue Hu <huyue2@yulong.com>
> 
> A previous commit f022d8cb7ec7 ("mm: cma: Don't crash on allocation
> if CMA area can't be activated") fixes the crash issue when activation
> fails via setting cma->count as 0, same logic exists if bitmap
> allocation fails.
> 
> --- a/mm/cma.c
> +++ b/mm/cma.c
> @@ -106,8 +106,10 @@ static int __init cma_activate_area(struct cma *cma)
>  
>  	cma->bitmap = kzalloc(bitmap_size, GFP_KERNEL);
>  
> -	if (!cma->bitmap)
> +	if (!cma->bitmap) {
> +		cma->count = 0;
>  		return -ENOMEM;
> +	}
>  
>  	WARN_ON_ONCE(!pfn_valid(pfn));
>  	zone = page_zone(pfn_to_page(pfn));

I'm unsure whether this is needed.

kmalloc() within __init code is generally considered to be a "can't
fail".

If this was the only issue then I guess I'd take the patch if only for
documentation/clarity purposes.  But cma_areas[] is in bss and is
guaranteed to be all-zeroes, so I suspect this bug is a can't-happen. 
And we could revert f022d8cb7ec7 if we could be bothered (I can't).



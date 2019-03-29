Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5008C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 13:56:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8FFD320651
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 13:56:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="iJkMOYRB";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="iJkMOYRB"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8FFD320651
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2FB396B000D; Fri, 29 Mar 2019 09:56:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A9396B000E; Fri, 29 Mar 2019 09:56:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 197D36B0010; Fri, 29 Mar 2019 09:56:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id D2DD96B000D
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 09:56:05 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id e12so1704151pgh.2
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 06:56:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:dmarc-filter
         :subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=eJBAwmC5eJLWZCM/0i32Ur4T07JwPNfg3BEL6xwmQqI=;
        b=kY/jKJYE0CLdvJHRABMCizbrURm6gEP88fDvwAyvkzWGcFGEWgCzoSa9JoY33fB2LU
         i3XAAugDErCM2DOv2Nku5Skhe0zhy7p2oGvh9vgqK6yirI5r0/cJCxstVjND5dADT9uy
         Xe6yB6Gi6JW6OdudBi9Pm1aidT3ZRRhOcZmmSsyhMGBOzT3CxK+k8dpBaEEO9hsABjnS
         lDLWLE7dUkTUjyt3T0X23AJSgRZfIgaf4ooJEekDEO74mrSiffTCYuT6/3b/DIcefwCb
         Do9V2ImKeL7TUX7YdM7bXXQIhaFLpv2Gq9R7TO4GYlI/Syplvh0PO5bt6pfBYg3KgjZZ
         smsw==
X-Gm-Message-State: APjAAAXuccNNDDApWqr7pWHPsQ3UG8OW7n3+dtq//8mVCCyN6Z0afjmP
	mG3W0DZ/Y0Ca3BZWMKQppXiUn+uiB7PqRhsMH1+uQfW+8y2ajHws441Hy6tMU6bKIerG0ir1wfy
	QCzvsJkfMAr5BQFoNT69+ui4YfwCyXnsl2b0ipH3zToRUZxGYHcmIlIaojC1TL9T4Rg==
X-Received: by 2002:a65:5286:: with SMTP id y6mr2049199pgp.79.1553867764998;
        Fri, 29 Mar 2019 06:56:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyj+vdJ1EZNrSxt+XbdPi2y0vhDBwWzW8Y3d8k19zvmLPZo6qOUMSC404PSUKqAO4PXYuIw
X-Received: by 2002:a65:5286:: with SMTP id y6mr2049157pgp.79.1553867764283;
        Fri, 29 Mar 2019 06:56:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553867764; cv=none;
        d=google.com; s=arc-20160816;
        b=NEhS7JZWjQx/3kcvuxKGMd/gdiSBIeCEndRYMk16brQlH23i3q42ZWYTl6xGUhBmbw
         Jvi3PZjyXM0ImFQHOo+/spBQk0h8FckOrwEyyXytn8fuoMag1cIwg6zj4lSQGi9xoREy
         fm4rEy9fcWYH1z0RE5KJuZFRNnP+M8mzJC1/LSQ1MUGgeFx1Y0ykCZPKGAVdlsT043fz
         iYu9DuexRz8VyfEyRpkrz6nXi3tCev2uEsAdGLNtb40ehSK8mbwPvWEycRg52DSZqIBL
         SI4jeObvIRrWMbJnKscNwXXC4cUAkU9G14EZ112DeIMVCbxZfKju1umCPgza6p5TxWZA
         wnMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dmarc-filter:dkim-signature:dkim-signature;
        bh=eJBAwmC5eJLWZCM/0i32Ur4T07JwPNfg3BEL6xwmQqI=;
        b=POYv5vsm3kr5/teFjcehFTrOWubpu5F2SRgwt7t88IbM08eI1yXS2gHyij0qLxAxdw
         UEAxMuYiSLX6SETqrlUwSieuCJ6hBfjMHBnPo3ag87qyMqDF29bXSByzduiafgxEFk4C
         sJWECQ82XppQt3g+MDvXTfRKh1zbGEnyiUCFkC+uiwkuWqoIo5q7txvEHMpORfpsvKPF
         NIfiAU7t8Yx79zx4jUdoGCYvX6aMdpC/di4bbgN8CvX0xOzayM1SgE6n7MZsgoqsuHGk
         zBP3s6150JHBA207+IXftehtbEedmfXRN87YN+Qa2ycePNKKgj3vSmXOGPc3J4iWfI5+
         WaNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=iJkMOYRB;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=iJkMOYRB;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id c18si1805103pfi.198.2019.03.29.06.56.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 06:56:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) client-ip=198.145.29.96;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=iJkMOYRB;
       dkim=pass header.i=@codeaurora.org header.s=default header.b=iJkMOYRB;
       spf=pass (google.com: domain of mojha@codeaurora.org designates 198.145.29.96 as permitted sender) smtp.mailfrom=mojha@codeaurora.org
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id E74D16079C; Fri, 29 Mar 2019 13:56:03 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553867763;
	bh=cnNB3qaJHM8BWoA+KLPu416FHg8Km0nQ8IFlokqnLFQ=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=iJkMOYRB+0mbTBjFI1QThShFIy5Zyc53/U11ovPbnbc7xOB/8wVpQL/8G8nAkx4ZL
	 J2DMcFvaHC6YsDCQ6Kzaw9oq+YFEMfkYaCOAiDcZKjb9vH/Iy8FbEbtkwOxCdzSxIq
	 dKaG/t+NZ+rOMwb7dITbbBL7HSN6+B85ESzThgQc=
Received: from [10.204.79.83] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: mojha@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id B01A760735;
	Fri, 29 Mar 2019 13:55:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1553867763;
	bh=cnNB3qaJHM8BWoA+KLPu416FHg8Km0nQ8IFlokqnLFQ=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=iJkMOYRB+0mbTBjFI1QThShFIy5Zyc53/U11ovPbnbc7xOB/8wVpQL/8G8nAkx4ZL
	 J2DMcFvaHC6YsDCQ6Kzaw9oq+YFEMfkYaCOAiDcZKjb9vH/Iy8FbEbtkwOxCdzSxIq
	 dKaG/t+NZ+rOMwb7dITbbBL7HSN6+B85ESzThgQc=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org B01A760735
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=mojha@codeaurora.org
Subject: Re: [PATCH v1] mm: balloon: drop unused function stubs
To: David Hildenbrand <david@redhat.com>, linux-kernel@vger.kernel.org
Cc: Konstantin Khlebnikov <koct9i@gmail.com>,
 Pankaj Gupta <pagupta@redhat.com>, Andrew Morton
 <akpm@linux-foundation.org>, "Michael S . Tsirkin" <mst@redhat.com>,
 linux-mm@kvack.org
References: <20190329122649.28404-1-david@redhat.com>
From: Mukesh Ojha <mojha@codeaurora.org>
Message-ID: <931b7a25-94c9-5a13-423e-27ef41655603@codeaurora.org>
Date: Fri, 29 Mar 2019 19:25:54 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190329122649.28404-1-david@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 3/29/2019 5:56 PM, David Hildenbrand wrote:
> These are leftovers from the pre-"general non-lru movable page" era.
>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>   include/linux/balloon_compaction.h | 15 ---------------
>   1 file changed, 15 deletions(-)


Reviewed-by: Mukesh Ojha <mojha@codeaurora.org>

Cheers,
-Mukesh

>
> diff --git a/include/linux/balloon_compaction.h b/include/linux/balloon_compaction.h
> index f111c780ef1d..f31521dcb09a 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -151,21 +151,6 @@ static inline void balloon_page_delete(struct page *page)
>   	list_del(&page->lru);
>   }
>   
> -static inline bool __is_movable_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool balloon_page_movable(struct page *page)
> -{
> -	return false;
> -}
> -
> -static inline bool isolated_balloon_page(struct page *page)
> -{
> -	return false;
> -}
> -
>   static inline bool balloon_page_isolate(struct page *page)
>   {
>   	return false;


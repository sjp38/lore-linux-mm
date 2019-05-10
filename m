Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58D6AC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 20:13:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFB5A2182B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 20:13:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFB5A2182B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D81E6B0003; Fri, 10 May 2019 16:13:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 688E06B0005; Fri, 10 May 2019 16:13:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59DFC6B0006; Fri, 10 May 2019 16:13:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3616C6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 16:13:37 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id n39so7462128qtn.0
        for <linux-mm@kvack.org>; Fri, 10 May 2019 13:13:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=A1Ka4GG4oBpfFecP+ND1+lkuq7j2xoZhpngo3CO45kI=;
        b=XZVkkZ+IUbxuFFPmSv2JLMe8pdJ4SEDvCxDncc2GQMTj2ZkLfsAeKnyJ6JkJYe1e1W
         VPbiIoNRZqC4UdsAIvgoMP9KxyTADew8sg/3oiI7s4PHuAwwK48jUDemlcTfBF0MaM1M
         yk5BdxcqbMnwVTSK78te7HGCnD3WrEA08YUjE1XyGyKaKwDAfzaWNECTeeBnMyGv6DcV
         7yN5UcjMvQcStkQXpeASeoWe78wwVvWEhnLyed1sIfCCalI3eeNa3Ugm+6vyRVFw5eJe
         qwzmyUkgd1ndowH1PxZzWfpgox6BAEExM+uJxd0b2m4s1fgYJWyl7e4g0liCM9I75Nyq
         H2jg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVFiRFCkXQTdjflfma9lo51g1mwQK1Lk2xyoC4AfNFz1eh6aJ3l
	xTrpktTl7hjZPFKNIQlClErauGfWoIs0KNuvpa5okgMQmafUP5v6s3BTsrC4URF5/0IQBaEakEJ
	2HmKfpLMWfltCI2xIlbv8WVQvvB71/WQKJ/3IYn5Td2q0skLhW+MDGZzBGufIu61mXQ==
X-Received: by 2002:ae9:f203:: with SMTP id m3mr10440793qkg.317.1557519216972;
        Fri, 10 May 2019 13:13:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2CKSyZwX8wpnofj2IkaWcB3XlWK1fnZS9uxReVVc3TdgIS3ZGRnVLVjDT0xv9WjQNk6Az
X-Received: by 2002:ae9:f203:: with SMTP id m3mr10440746qkg.317.1557519216271;
        Fri, 10 May 2019 13:13:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557519216; cv=none;
        d=google.com; s=arc-20160816;
        b=Oi/IAcelzDLr3wt3f6YuRrkFIFF+VJUFl1Hgo04WNzuO1REtsT98Ndb6brS2uN7yei
         mSTAc4/E38ZdkkE2xwqgnxfitE37yQmtIWiLKQqsNW31nQ9LnngpGoZc0N9vKPEssP5n
         JwBYbT4hkB+Ke8gLfkfUXbkwaOlGLxOUQHeDdiLflXEqe+127tlV5DIQAL5b/6rPq0iN
         lG9ltuagVwsJQxW4gMLFRJBgc676PtrOWsr2rv6a8ALRWHtDE+2lH7gwpIipdBt1lXQ6
         vcU4n/gABQss+eKJaqid5gg+GpHECZsGtF2dDdtVaUrgW3YMq1YmqrwMfO3oUE4mlss9
         UPEQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=A1Ka4GG4oBpfFecP+ND1+lkuq7j2xoZhpngo3CO45kI=;
        b=Ao3stDdNARfjg5OChYTbyk8+mb9xmLjN0RPTXxvmh2CJR92zYFZ6NksbSGsXrVJoe4
         lARr34UrnoFvIW1j3PPhpxDW9NUSdjnGje/8puvuE9auGS2OqY2ZSyoCwFAmeHhRx50X
         FY/aLllNGRoyw6b+Qd/ntes+A0RVeXUzKBRpYNa+7H/xLxQNjoaexYJJEvGKE97RP8d9
         9+K6fqTAdalkp/MUxsA+bjDTnkTeul+Xqm+dSGkhPY6Umjq/bgJ1uUHN2dV6hTFekPv5
         AdBhkA1AuEZymEeIXEjmHTd0Zv7JESPytjU08ECf9Y8Ez4m6sNfk2raOOQENhQhOLwQu
         95rA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q18si732722qtn.324.2019.05.10.13.13.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 13:13:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 79FDD307D913;
	Fri, 10 May 2019 20:13:35 +0000 (UTC)
Received: from redhat.com (ovpn-124-97.rdu2.redhat.com [10.10.124.97])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 360161A267;
	Fri, 10 May 2019 20:13:34 +0000 (UTC)
Date: Fri, 10 May 2019 16:13:32 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "alex.deucher@amd.com" <alex.deucher@amd.com>,
	"airlied@gmail.com" <airlied@gmail.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"Yang, Philip" <Philip.Yang@amd.com>
Subject: Re: [PATCH 1/2] mm/hmm: support automatic NUMA balancing
Message-ID: <20190510201331.GF4507@redhat.com>
References: <20190510195258.9930-1-Felix.Kuehling@amd.com>
 <20190510195258.9930-2-Felix.Kuehling@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190510195258.9930-2-Felix.Kuehling@amd.com>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Fri, 10 May 2019 20:13:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 07:53:23PM +0000, Kuehling, Felix wrote:
> From: Philip Yang <Philip.Yang@amd.com>
> 
> While the page is migrating by NUMA balancing, HMM failed to detect this
> condition and still return the old page. Application will use the new
> page migrated, but driver pass the old page physical address to GPU,
> this crash the application later.
> 
> Use pte_protnone(pte) to return this condition and then hmm_vma_do_fault
> will allocate new page.
> 
> Signed-off-by: Philip Yang <Philip.Yang@amd.com>

Reviewed-by: Jérôme Glisse <jglisse@redhat.com>

> ---
>  mm/hmm.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/hmm.c b/mm/hmm.c
> index 75d2ea906efb..b65c27d5c119 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -554,7 +554,7 @@ static int hmm_vma_handle_pmd(struct mm_walk *walk,
>  
>  static inline uint64_t pte_to_hmm_pfn_flags(struct hmm_range *range, pte_t pte)
>  {
> -	if (pte_none(pte) || !pte_present(pte))
> +	if (pte_none(pte) || !pte_present(pte) || pte_protnone(pte))
>  		return 0;
>  	return pte_write(pte) ? range->flags[HMM_PFN_VALID] |
>  				range->flags[HMM_PFN_WRITE] :
> -- 
> 2.17.1
> 


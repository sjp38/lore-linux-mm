Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9CF6C48BD6
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:39:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 547BB21852
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 04:39:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=c-s.fr header.i=@c-s.fr header.b="ez22xSXe"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 547BB21852
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=c-s.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C79F36B0003; Thu, 27 Jun 2019 00:39:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C28B88E0003; Thu, 27 Jun 2019 00:39:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AEF748E0002; Thu, 27 Jun 2019 00:39:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id 61BF26B0003
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 00:39:26 -0400 (EDT)
Received: by mail-wr1-f72.google.com with SMTP id b6so513333wrp.21
        for <linux-mm@kvack.org>; Wed, 26 Jun 2019 21:39:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:to:cc:references:from
         :message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=uSip90CjY6ipnPCboMIzCTf6R15j8iY2klqsFQRuFHo=;
        b=NTIqS2h1upRQwPqfyLWRbGJnCG5++y5R7xNOzlUGsDcKILtT6TH5bGA7pLwxChQ1t2
         PVyMWZhdv9LjaSe5LQxfwY7uT0sKxksxG1BLRVImlickVFJfrQ2MUBP3eFK+j2plYxbQ
         lEUY7ZghNdls41xsYIymvMZ2M7CNScWUCqcG9A/9Z3CvYx/xdjzvGXUhK5mKUbNHT0UL
         FxYzpjldAely08+j1dz4c1fgoBGSmIAmzn3nhCOh8Y/8JMTmDEPpO5IS+4OG7m5XfRhe
         ljFgtinTUew6TtCkQO5w9ej5YkOLZIRqj5XaWIjBawf6TurGr914LbXTbBBs6HH2tXle
         JHnQ==
X-Gm-Message-State: APjAAAWx32i/SXMo77yiOjGeIexS2ql1OcvU004pc0OMYSTNu4DPoIyz
	Bw7tPA9JtwfGNkFcKkLIEvi/x+E5RL3eU79MebbHQfSAnycKzeFCyn2Z8JI3/Bdai8tWmg5j+e2
	n/2DfnxKpFFhGUY16AH0zonJPwxGxHumyXBSoAWLDF0RbqMyJex7davVx8OmHzI5c5g==
X-Received: by 2002:a7b:cae9:: with SMTP id t9mr1477488wml.126.1561610365822;
        Wed, 26 Jun 2019 21:39:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzM+LP0SDdAtOlJgDuCO7cpCsJI8fOsTD6L6vPosHWLTDVZm2h+DElEZ4r1bqeiNMF6vywW
X-Received: by 2002:a7b:cae9:: with SMTP id t9mr1477445wml.126.1561610365014;
        Wed, 26 Jun 2019 21:39:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561610365; cv=none;
        d=google.com; s=arc-20160816;
        b=doICe3EtFRGadZ5oYP/LLtz/OrcH2yZQC40S2aGVYGST8oi/j2/kqVogMY0pYk4tYf
         JvU1pS2A2BWYroigt3PPbhBygoad6bE1Kiqltk7eclQu3CS2SXzA6pu/QooPp911AcSL
         kYcs8b7D7U6WYVjDnCYUxc4WUz5RxDnKiZ7YgfhKP7Q387cos74eX3+QB0lokjEbCt7l
         0Ae3YiiV1Eqy3VJAYg4dSgRAV06lhot+B9dWlCUexJ77xkDz/wyTtQhVUr9SnjX8S2Vc
         V3wgoge5YH1S9m+CkBULyGa4Ul1FEbytSkJj1IMcHyuO5ElvOrUqqTISO5WYlw5sXkBL
         VXCw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject
         :dkim-signature;
        bh=uSip90CjY6ipnPCboMIzCTf6R15j8iY2klqsFQRuFHo=;
        b=NJx2lLAXVnBIz4RU8a7TPKycTgg2LMHQ/Swf568BPGFfRv0fBY++jV4zyPDeiEqghr
         +Z503Oewr6tdHm6hJd75hDCOvV/zLi76YldWdsGFS2h3k4sa70aqfj2dQynmPOkMhXwt
         OVHaZiRbseNzCjmXJvjuSU9KU8PcZcLL2eKg5QSdI26KTicXGp7xHw5qj8WIFGYFUJC2
         bOnt54BS0Pbwi7TSPmIbWwWVCBh+vrAfOfyuFyipMedTuCe0dBSqYNtieSSESCswchmb
         H/QPRkJjezuq07GvjBAp3EZnPBK7a3EpE0DCpUAq6FPYT0OHjJy/cml72WmhR9PMYpqN
         xEXA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ez22xSXe;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id s16si379861wme.188.2019.06.26.21.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jun 2019 21:39:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) client-ip=93.17.236.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@c-s.fr header.s=mail header.b=ez22xSXe;
       spf=pass (google.com: domain of christophe.leroy@c-s.fr designates 93.17.236.30 as permitted sender) smtp.mailfrom=christophe.leroy@c-s.fr
Received: from localhost (mailhub1-int [192.168.12.234])
	by localhost (Postfix) with ESMTP id 45Z6cW3zXvz9v0bT;
	Thu, 27 Jun 2019 06:39:23 +0200 (CEST)
Authentication-Results: localhost; dkim=pass
	reason="1024-bit key; insecure key"
	header.d=c-s.fr header.i=@c-s.fr header.b=ez22xSXe; dkim-adsp=pass;
	dkim-atps=neutral
X-Virus-Scanned: Debian amavisd-new at c-s.fr
Received: from pegase1.c-s.fr ([192.168.12.234])
	by localhost (pegase1.c-s.fr [192.168.12.234]) (amavisd-new, port 10024)
	with ESMTP id Pv5yZBePPNWY; Thu, 27 Jun 2019 06:39:23 +0200 (CEST)
Received: from messagerie.si.c-s.fr (messagerie.si.c-s.fr [192.168.25.192])
	by pegase1.c-s.fr (Postfix) with ESMTP id 45Z6cW2gw5z9v0bS;
	Thu, 27 Jun 2019 06:39:23 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=c-s.fr; s=mail;
	t=1561610363; bh=uSip90CjY6ipnPCboMIzCTf6R15j8iY2klqsFQRuFHo=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=ez22xSXenyJafd/cBfOrYvcLgLb3L9QoeannzXvtRfqULrpeEdFu+LempOs+0fZbS
	 SN2CHGt29XHhtCvT4IUW/MwhSHlxG7dhGGSOLadHGbbbX6IuWOiO0g8hxJRKQfdbIk
	 7xeaz24HM3SZHQ1Yv5C73jVUNwkMDZNCgg6T3oJY=
Received: from localhost (localhost [127.0.0.1])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id 278B98B780;
	Thu, 27 Jun 2019 06:39:24 +0200 (CEST)
X-Virus-Scanned: amavisd-new at c-s.fr
Received: from messagerie.si.c-s.fr ([127.0.0.1])
	by localhost (messagerie.si.c-s.fr [127.0.0.1]) (amavisd-new, port 10023)
	with ESMTP id paYZo5xhpiac; Thu, 27 Jun 2019 06:39:24 +0200 (CEST)
Received: from pc17473vm.idsi0.si.c-s.fr (unknown [192.168.4.90])
	by messagerie.si.c-s.fr (Postfix) with ESMTP id A027F8B77F;
	Thu, 27 Jun 2019 06:39:23 +0200 (CEST)
Subject: Re: [PATCH] powerpc/64s/radix: Define arch_ioremap_p4d_supported()
To: Anshuman Khandual <anshuman.khandual@arm.com>, linux-mm@kvack.org
Cc: Stephen Rothwell <sfr@canb.auug.org.au>, linux-kernel@vger.kernel.org,
 Nicholas Piggin <npiggin@gmail.com>, linux-next@vger.kernel.org,
 Paul Mackerras <paulus@samba.org>,
 "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
 Andrew Morton <akpm@linux-foundation.org>, linuxppc-dev@lists.ozlabs.org
References: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
From: Christophe Leroy <christophe.leroy@c-s.fr>
Message-ID: <f32fbb6c-0600-991a-6d1a-72670c27c8de@c-s.fr>
Date: Thu, 27 Jun 2019 04:38:50 +0000
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1561555260-17335-1-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 06/26/2019 01:21 PM, Anshuman Khandual wrote:
> Recent core ioremap changes require HAVE_ARCH_HUGE_VMAP subscribing archs
> provide arch_ioremap_p4d_supported() failing which will result in a build
> failure like the following.
> 
> ld: lib/ioremap.o: in function `.ioremap_huge_init':
> ioremap.c:(.init.text+0x3c): undefined reference to
> `.arch_ioremap_p4d_supported'
> 
> This defines a stub implementation for arch_ioremap_p4d_supported() keeping
> it disabled for now to fix the build problem.
> 
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
> Cc: Nicholas Piggin <npiggin@gmail.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: linuxppc-dev@lists.ozlabs.org
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-next@vger.kernel.org
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Add a Fixes: tag ? For instance:

Fixes: d909f9109c30 ("powerpc/64s/radix: Enable HAVE_ARCH_HUGE_VMAP")

Christophe

> ---
> This has been just build tested and fixes the problem reported earlier.
> 
>   arch/powerpc/mm/book3s64/radix_pgtable.c | 5 +++++
>   1 file changed, 5 insertions(+)
> 
> diff --git a/arch/powerpc/mm/book3s64/radix_pgtable.c b/arch/powerpc/mm/book3s64/radix_pgtable.c
> index 8904aa1..c81da88 100644
> --- a/arch/powerpc/mm/book3s64/radix_pgtable.c
> +++ b/arch/powerpc/mm/book3s64/radix_pgtable.c
> @@ -1124,6 +1124,11 @@ void radix__ptep_modify_prot_commit(struct vm_area_struct *vma,
>   	set_pte_at(mm, addr, ptep, pte);
>   }
>   
> +int __init arch_ioremap_p4d_supported(void)
> +{
> +	return 0;
> +}
> +
>   int __init arch_ioremap_pud_supported(void)
>   {
>   	/* HPT does not cope with large pages in the vmalloc area */
> 


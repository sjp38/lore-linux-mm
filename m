Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96912C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:41:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4B683247A7
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:41:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="scIwGBKI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4B683247A7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E21406B026F; Mon,  3 Jun 2019 17:41:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DAC816B0270; Mon,  3 Jun 2019 17:41:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C4ADB6B0272; Mon,  3 Jun 2019 17:41:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0C66B0270
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:41:42 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x16so29336865edm.16
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:41:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:reply-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=yhLYhpx5r94UcNbu2SZQmZBVQeUmPq6PVimIkeEn7pk=;
        b=GR3Etawt/vsJV4bspPVbN5flZYa2L25Ja8Uccycz+m2Ut/292+4JCs/uhsbYVIl2zn
         Kv16G734jg94YmigPK0wbge0wnprbdG+tu9mhZy13C8hdnMs+aN/UD+rkNBG4PVSTqAY
         372iR3f0DL2YEmud5DfUU6uZAFa6IG7N27TgJUrBatiMQEJgsK+u/6YmlW0jHHJ8GLCV
         uFbfI+EJ98K03l6WsshHdzZwqi1fQ0pD32bZoi9CaZVRcijlx8Tb6hPga7HRmlhfw2bE
         HI7i3hx8kFTm4KJTT8Wu7jWg2z4gGXJSEWJ6ALs3AMCAPgoFLBzjouobNwdUE7C6R5ju
         jxUg==
X-Gm-Message-State: APjAAAXo45VQ6QVEdcotgvXfOrHKuFjzAqSLd2ESpQ89I791zMkUiiCr
	RemCOht9Unqg6tslc7HsZDL+AzwbovTl7Rd/QLc3qEcNn87JiBYxu5tLqb1TpTjghWTjPOgEVMz
	kmdJZtD/gBHNpM6bz97Df0thR+SuxHUqZ7APvpSjELvfIsvZEodaENYuE4wbeQMbFTg==
X-Received: by 2002:a50:95ae:: with SMTP id w43mr3033562eda.115.1559598101826;
        Mon, 03 Jun 2019 14:41:41 -0700 (PDT)
X-Received: by 2002:a50:95ae:: with SMTP id w43mr3033510eda.115.1559598101112;
        Mon, 03 Jun 2019 14:41:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559598101; cv=none;
        d=google.com; s=arc-20160816;
        b=xOP3lv2dL7JIdYYx7NDwe84NXjjM70eA4iYMLGUzP3DboRS4Kg5dVQ2fLTB5jzjJ/e
         HVYzxJaHxY5UjSsO1htKQhi/lGeeYc2VdorePGbCHGIJ0vV/TmFEtQbMxDTDeYk9hG09
         O0h2dmn57qjJztox/MYCrPfTm2/8tHCj+htHEEDneW6r2WCXX2CmI6KIwDTuO1aaF3K8
         2vblvIvw6raTHIbsn4g3ExMbGchhHSnaDqFFFg83EF7JMasBLWr4+aZcWZl8CH3Prlse
         QOLKeUCzEtrTrHmeZIgooxmfmVDwKheSTYbVf7UegEgKOFP4H+ROcZtmORuJL4xJPJiI
         jG/Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :reply-to:message-id:subject:cc:to:from:date:dkim-signature;
        bh=yhLYhpx5r94UcNbu2SZQmZBVQeUmPq6PVimIkeEn7pk=;
        b=P5HS9lKMOeFBPoncgB/byt2rlLEK2Os2iMzx1vIXzjSqnVR/Ay6nie7mkZ6Wr7Yfmc
         E9w53iAd3Yvz4ALMcMv6zP7fSqNVJY42F0ttVzGt1Whz6bXyeRxgbp9li3PhqUVdRLEy
         OWVc8MwKkJVD+aUVcgkssFMTR6jPXACEDLIcmGeRJdxt7PYLKOmQSTCXQPwECPUw70hB
         mRw5kxUcYLx5PpIkCzl2mywRfcYXsmOWMV7dfCyMtiFTJ2V/n9pVUaXuxKfltI+PiA6M
         3Ah/v89IgQdhV6IAaleo44qy25iKR7SCrPDaKWzsGnyc769qYU00PdjRf0CMrPVBzkM8
         DtrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=scIwGBKI;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w1sor4970721ejf.54.2019.06.03.14.41.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 14:41:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=scIwGBKI;
       spf=pass (google.com: domain of richard.weiyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=richard.weiyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:reply-to:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=yhLYhpx5r94UcNbu2SZQmZBVQeUmPq6PVimIkeEn7pk=;
        b=scIwGBKI357lkVXW52kw03XCI4+Ae6ho42noCT0DWTtPRkLPw37gVYJBmgatjte/fr
         txxL6xswgG2bwv4dcBi9ilccueJ2EbcEKZtiqgVr0w/zR7p00TQxQ68X081DlJksiVJp
         bQq/Q6WuN9RqstqJonmfHCKtiFMA7q9w/UyTa+NDl7ayqnpxpJkR/MsE/cnrEjpN5UnF
         pDmYt0I6nf0M8NtJy0pn3MNogc07CPwCXpJcmFU/YcoTOESdyv+YzC8Zd1MT32D8/vBb
         qcdBZinoMMfM8+8dbAMFVV623Db3nfb+VmQu9rZFXZf1rykogdgYpXDWtPbozhqhF8So
         ROsg==
X-Google-Smtp-Source: APXvYqwCMUWcithGJqx45+EgRmxCCI6sjYqisr91FRxovWqn6/a/0IS0IDUQUvDAHCpQkkCQxu0u/A==
X-Received: by 2002:a17:907:20d0:: with SMTP id qq16mr14587748ejb.244.1559598100632;
        Mon, 03 Jun 2019 14:41:40 -0700 (PDT)
Received: from localhost ([185.92.221.13])
        by smtp.gmail.com with ESMTPSA id e45sm4208929edb.12.2019.06.03.14.41.39
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 03 Jun 2019 14:41:39 -0700 (PDT)
Date: Mon, 3 Jun 2019 21:41:39 +0000
From: Wei Yang <richard.weiyang@gmail.com>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	linux-ia64@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org, linux-sh@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, akpm@linux-foundation.org,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Igor Mammedov <imammedo@redhat.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Jun Yao <yaojun8558363@gmail.com>, Yu Zhao <yuzhao@google.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: Re: [PATCH v3 04/11] arm64/mm: Add temporary arch_remove_memory()
 implementation
Message-ID: <20190603214139.mercn5hol2yyfl2s@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-5-david@redhat.com>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 27, 2019 at 01:11:45PM +0200, David Hildenbrand wrote:
>A proper arch_remove_memory() implementation is on its way, which also
>cleanly removes page tables in arch_add_memory() in case something goes
>wrong.

Would this be better to understand?

    removes page tables created in arch_add_memory

>
>As we want to use arch_remove_memory() in case something goes wrong
>during memory hotplug after arch_add_memory() finished, let's add
>a temporary hack that is sufficient enough until we get a proper
>implementation that cleans up page table entries.
>
>We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
>patches.
>
>Cc: Catalin Marinas <catalin.marinas@arm.com>
>Cc: Will Deacon <will.deacon@arm.com>
>Cc: Mark Rutland <mark.rutland@arm.com>
>Cc: Andrew Morton <akpm@linux-foundation.org>
>Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
>Cc: Chintan Pandya <cpandya@codeaurora.org>
>Cc: Mike Rapoport <rppt@linux.ibm.com>
>Cc: Jun Yao <yaojun8558363@gmail.com>
>Cc: Yu Zhao <yuzhao@google.com>
>Cc: Robin Murphy <robin.murphy@arm.com>
>Cc: Anshuman Khandual <anshuman.khandual@arm.com>
>Signed-off-by: David Hildenbrand <david@redhat.com>
>---
> arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
> 1 file changed, 19 insertions(+)
>
>diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
>index a1bfc4413982..e569a543c384 100644
>--- a/arch/arm64/mm/mmu.c
>+++ b/arch/arm64/mm/mmu.c
>@@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
> 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
> 			   restrictions);
> }
>+#ifdef CONFIG_MEMORY_HOTREMOVE
>+void arch_remove_memory(int nid, u64 start, u64 size,
>+			struct vmem_altmap *altmap)
>+{
>+	unsigned long start_pfn = start >> PAGE_SHIFT;
>+	unsigned long nr_pages = size >> PAGE_SHIFT;
>+	struct zone *zone;
>+
>+	/*
>+	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
>+	 * adding fails). Until then, this function should only be used
>+	 * during memory hotplug (adding memory), not for memory
>+	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
>+	 * unlocked yet.
>+	 */
>+	zone = page_zone(pfn_to_page(start_pfn));

Compared with arch_remove_memory in x86. If altmap is not NULL, zone will be
retrieved from page related to altmap. Not sure why this is not the same?

>+	__remove_pages(zone, start_pfn, nr_pages, altmap);
>+}
>+#endif
> #endif
>-- 
>2.20.1

-- 
Wei Yang
Help you, Help me


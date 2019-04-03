Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13320C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B50AA21473
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:30:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B50AA21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5104E6B000C; Wed,  3 Apr 2019 05:30:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C1506B000D; Wed,  3 Apr 2019 05:30:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 387916B000E; Wed,  3 Apr 2019 05:30:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 173266B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 05:30:43 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id b1so16144409qtk.11
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 02:30:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:organization:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding;
        bh=O/5mglGY5JLnYZNDOOCFbP+3nrAZCGRsKzbJHwtuMO4=;
        b=PbJIBkHuUFEGXKkdcLAAZgOIkk+nhcTFOctKIT2OlXTRyAXaISitzCz609cpOelZZe
         QsHyDjk8qfZQb+dIvAwh/BCAPhfXlY3wBv+33KQs36P36JhZe7g0K3jUACOUdzKESXYT
         5ApaDUtEoLN47KRzx2Kqw4yGSrcNog/GaL7EXqGmRLK1KTeBoS9rhwRLbjNgQZTL5Mss
         xnNq8QD2CwEHEc0WbGKTj8+3mL90EJfsLcLSny6yb5arqmgYAvHvQeLv/kIRbS6H2Zaq
         KiJq52ybM1Tn07Dgg4KZht3Ndtg9AGs9+J/X1jRwKLEWOpcJDVinDuaf9DP0Cy3f0orM
         zpCw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWhG4Sc3D7+blM+sXAKdqTIsxa7HlvsCt0gcg3YZTm5i81PHxEQ
	5vwn8Uyead1jVnPzfKaf4qw3N93zKutELE3wPKpXH4uus5Z9uNbcjL6eEXYSwMBK6QIDpQJntjU
	Z0I8J4gcOuzLDYJMB/LXceL1kJKZSV0URMiFCv23tyatB67QCISC5EWU0OxVh6puOaA==
X-Received: by 2002:a05:620a:13e7:: with SMTP id h7mr60200017qkl.269.1554283842819;
        Wed, 03 Apr 2019 02:30:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytZ9cSC9J257EjG8o0LXzqsLoZYsRlJHSKf+F3d+ojhtonXfcN4hdOue2dW/6Jbfupk/p8
X-Received: by 2002:a05:620a:13e7:: with SMTP id h7mr60199976qkl.269.1554283842056;
        Wed, 03 Apr 2019 02:30:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554283842; cv=none;
        d=google.com; s=arc-20160816;
        b=GugoRl/fhFcaPoWVXJcXQblTDXFbQBynUJfF7aO6Va2KHUvGc/QrRn2gQeMmVUlR67
         LRljG5eRZ5MzBFlLIehx6qWJTs1GSqhky6L6ruOuQniZmfv0sKHIzoITcBBbmfSEINbv
         YkL56lNHb7OMto4zvrDyU6paZ9xtB/eVJ7we2mS1l+EQfHDQLF/FBWJLAaEOeTu8yoIV
         teX6PedjTxortjuLZqZu0kT5zQMiiaNTGGawS7BCwY+7c1VRnacM2DyudrbyFNCp7mW0
         pIeQBD4C8of0riVIbRc7fSD9D4YOWDH0qi/SiHoeZU+VilnLi5Q7XPh6J4FLdYwj3/xz
         Wj3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:organization:autocrypt:openpgp:from
         :references:cc:to:subject;
        bh=O/5mglGY5JLnYZNDOOCFbP+3nrAZCGRsKzbJHwtuMO4=;
        b=mNW3d8L3kjeeZv6dvRdQIG/hX9BCiMS/1NsZeM8OCQMfeJadBqm1jcstdnlyi5/ecM
         /ayDH73AqhadvZAeiW3nrFcSVt8REAHSgKw+WHkjWaRV8MvA2BaSg200L+rke59DVQuB
         XcaI83C3d4H6UNUxrPV1KsxPqqu01YjN38SHl4sisb+I/qVR211SfHik1kM+og4pDMTL
         B5WuHbIYFf71ZW0XanniGAViIaETTD/0+0+bc6DjeeW+Tn2otE2yot1GcBT/S777h7OE
         crpi5GMkoGrmP8Wd0dWnQDCMQaFZkQe+owH7d2igKNJ0mcssMoAuctukJQSbqsIuJMBU
         aEYg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m31si4505009qvg.182.2019.04.03.02.30.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 02:30:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of david@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=david@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id EAD9583F42;
	Wed,  3 Apr 2019 09:30:40 +0000 (UTC)
Received: from [10.36.117.246] (ovpn-117-246.ams2.redhat.com [10.36.117.246])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 38E331001DD3;
	Wed,  3 Apr 2019 09:30:37 +0000 (UTC)
Subject: Re: [PATCH 5/6] mm/memremap: Rename and consolidate SECTION_SIZE
To: Anshuman Khandual <anshuman.khandual@arm.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
 catalin.marinas@arm.com
Cc: mhocko@suse.com, mgorman@techsingularity.net, james.morse@arm.com,
 mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
 arunks@codeaurora.org, dan.j.williams@intel.com, osalvador@suse.de,
 logang@deltatee.com, pasha.tatashin@oracle.com, cai@lca.pw
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-6-git-send-email-anshuman.khandual@arm.com>
From: David Hildenbrand <david@redhat.com>
Openpgp: preference=signencrypt
Autocrypt: addr=david@redhat.com; prefer-encrypt=mutual; keydata=
 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
 SE+xAvmumFBY
Organization: Red Hat GmbH
Message-ID: <55055b27-96a1-2a6e-a976-c6e1c7388959@redhat.com>
Date: Wed, 3 Apr 2019 11:30:36 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <1554265806-11501-6-git-send-email-anshuman.khandual@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 03 Apr 2019 09:30:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 03.04.19 06:30, Anshuman Khandual wrote:
> From: Robin Murphy <robin.murphy@arm.com>
> 
> Enabling ZONE_DEVICE (through ARCH_HAS_ZONE_DEVICE) for arm64 reveals that
> memremap's internal helpers for sparsemem sections conflict with arm64's
> definitions for hugepages which inherit the name of "sections" from earlier
> versions of the ARM architecture.
> 
> Disambiguate memremap by propagating sparsemem's PA_ prefix, to clarify
> that these values are in terms of addresses rather than PFNs (and
> because it's a heck of a lot easier than changing all the arch code).
> SECTION_MASK is unused, so it can just go. While here consolidate single
> instance of PA_SECTION_SIZE from mm/hmm.c as well.
> 
> [anshuman: Consolidated mm/hmm.c instance and updated the commit message]
> 
> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
> ---
>  include/linux/mmzone.h |  1 +
>  kernel/memremap.c      | 10 ++++------
>  mm/hmm.c               |  2 --
>  3 files changed, 5 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index fba7741..ed7dd27 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1081,6 +1081,7 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>   * PFN_SECTION_SHIFT		pfn to/from section number
>   */
>  #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
> +#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
>  #define PFN_SECTION_SHIFT	(SECTION_SIZE_BITS - PAGE_SHIFT)
>  
>  #define NR_MEM_SECTIONS		(1UL << SECTIONS_SHIFT)
> diff --git a/kernel/memremap.c b/kernel/memremap.c
> index a856cb5..dda1367 100644
> --- a/kernel/memremap.c
> +++ b/kernel/memremap.c
> @@ -14,8 +14,6 @@
>  #include <linux/hmm.h>
>  
>  static DEFINE_XARRAY(pgmap_array);
> -#define SECTION_MASK ~((1UL << PA_SECTION_SHIFT) - 1)
> -#define SECTION_SIZE (1UL << PA_SECTION_SHIFT)
>  
>  #if IS_ENABLED(CONFIG_DEVICE_PRIVATE)
>  vm_fault_t device_private_entry_fault(struct vm_area_struct *vma,
> @@ -98,8 +96,8 @@ static void devm_memremap_pages_release(void *data)
>  		put_page(pfn_to_page(pfn));
>  
>  	/* pages are dead and unused, undo the arch mapping */
> -	align_start = res->start & ~(SECTION_SIZE - 1);
> -	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
> +	align_start = res->start & ~(PA_SECTION_SIZE - 1);
> +	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
>  		- align_start;
>  
>  	nid = page_to_nid(pfn_to_page(align_start >> PAGE_SHIFT));
> @@ -154,8 +152,8 @@ void *devm_memremap_pages(struct device *dev, struct dev_pagemap *pgmap)
>  	if (!pgmap->ref || !pgmap->kill)
>  		return ERR_PTR(-EINVAL);
>  
> -	align_start = res->start & ~(SECTION_SIZE - 1);
> -	align_size = ALIGN(res->start + resource_size(res), SECTION_SIZE)
> +	align_start = res->start & ~(PA_SECTION_SIZE - 1);
> +	align_size = ALIGN(res->start + resource_size(res), PA_SECTION_SIZE)
>  		- align_start;
>  	align_end = align_start + align_size - 1;
>  
> diff --git a/mm/hmm.c b/mm/hmm.c
> index fe1cd87..ef9e4e6 100644
> --- a/mm/hmm.c
> +++ b/mm/hmm.c
> @@ -33,8 +33,6 @@
>  #include <linux/mmu_notifier.h>
>  #include <linux/memory_hotplug.h>
>  
> -#define PA_SECTION_SIZE (1UL << PA_SECTION_SHIFT)
> -
>  #if IS_ENABLED(CONFIG_HMM_MIRROR)
>  static const struct mmu_notifier_ops hmm_mmu_notifier_ops;
>  
> 

Reviewed-by: David Hildenbrand <david@redhat.com>

-- 

Thanks,

David / dhildenb


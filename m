Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4569BC0650E
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:48:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 055A02053B
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 12:48:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 055A02053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A06C46B0006; Mon,  1 Jul 2019 08:48:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B82C8E0003; Mon,  1 Jul 2019 08:48:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8CEED8E0002; Mon,  1 Jul 2019 08:48:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f80.google.com (mail-ed1-f80.google.com [209.85.208.80])
	by kanga.kvack.org (Postfix) with ESMTP id 4054E6B0006
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 08:48:12 -0400 (EDT)
Received: by mail-ed1-f80.google.com with SMTP id i9so16767363edr.13
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 05:48:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=FWFHLEgXAwZyHnduMfur4d50bMeZGwi4UgUyPe2mriQ=;
        b=gjhVyTNp0e0bZ7CQz7l6rVtn+bgkn2yMqHDlav2pz+ouI68ZCgEOU2FTs/odSvNvnG
         ljY0sWof/V99d/Z1j0UpRts7mUvjFsVWAeOxK+aKBwRcKSlVblehLFm6ks1X56nXaM1v
         yJnDNdLSroCUIqmACAz89AB1TY9I/LA2Da4SmHAa9BHEV/bVDiyd31w5lzpH8qXHm9xn
         Saa7w/7Unn1mQ/qRWf/JQUFK6Tylyg45Ece33m2TDAL8JpWbHJhR39O7WgVRX2iqHzB8
         gHPvo2yT0YAwtAPh68nbORstL/np7p+FPA5FA21ESnK03clcamATxo5t7fJYgp0SBiYI
         //ZA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAXNgps1msjDPaXXm7jJLS+zjwE+G8gi4Db8PZh6KNeMKH89TZFO
	an3uqRAC2heAQf1p4XvPlcB7gt+s81oSoEU8zMzPs8ffow3Zt4YKsmwN4JgBynTEVcCGhheOO1a
	x3izelzHRQRxl+RweX2CXNZjryVHPiljuvBUf/Msv5rY2p17W3Y81pLsPxd7kgOA=
X-Received: by 2002:a17:906:4d89:: with SMTP id s9mr22680600eju.160.1561985291833;
        Mon, 01 Jul 2019 05:48:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7pCws3LQ57ils6SCUG/ZEUCnHNWTunFr/A3fFQwf58LNC9thcysxipYRWYmuqsEoPUkCm
X-Received: by 2002:a17:906:4d89:: with SMTP id s9mr22680545eju.160.1561985291050;
        Mon, 01 Jul 2019 05:48:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561985291; cv=none;
        d=google.com; s=arc-20160816;
        b=amqcOqwmuasaY/7JBPfjjVP9lpOJeItGl5UghdSb2gsw3Wb9qay+pMsqO64N8Q9DoW
         nrdT0RGwvyzKosig8e66TbZTb7EcQLnkBH+GUaKWnymaOuhROwwuwbMeKu+L9jVOdi9I
         ij9mQmiK6pH/YEkiF8/G0PeRnmseMkrus4H55X+pcEtofa0kMbAD2x0o70EzNKegUuCh
         4iCZc27AEZBbzeqkMBt/m4yheGtV8g4+rgm/x+TvPkk1Blobe31UJKJwvklxXpKeEGCy
         qF0I08DuM/h6uZxpT4fS2bVldLaGsyCfagDoY0Be8SYTxYNfAwIlzxD+I6eYzmGJdvqu
         H05Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=FWFHLEgXAwZyHnduMfur4d50bMeZGwi4UgUyPe2mriQ=;
        b=NobrvJBcHQjrYop3ojeDgypbkg4TMICJ+47eJ5daYxrGYB/UnH1Knhb4+KG0tsozXy
         sVwivT6ZCcsSkabfjppSFanu4A4IBPBS7tmTPWkG9MzJaTCbP0UmvbW0cCi9p+ZCI7i8
         dibm+1UuruJxhvHMCN+dJjL4WLw8WMht0L6yV9CTEd8lK0gYUf8OC06tPlzgyc4d9GHv
         tI+HNLkAWBDuXWjWUHMUKc2ggsaLtIfd+vduPct4PHsDTA2hOMf34Eih+/KI/qREUpvV
         D3aYGIg8KVQbwFqey2dFksxeV+LDi/NMrT/DNhhz5TVhYExJdmM4iizEf/zUN2X/IML2
         M2bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e54si8393919eda.324.2019.07.01.05.48.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 05:48:11 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80FCEAF2C;
	Mon,  1 Jul 2019 12:48:10 +0000 (UTC)
Date: Mon, 1 Jul 2019 14:48:09 +0200
From: Michal Hocko <mhocko@kernel.org>
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
Message-ID: <20190701124809.GV6376@dhcp22.suse.cz>
References: <20190527111152.16324-1-david@redhat.com>
 <20190527111152.16324-5-david@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190527111152.16324-5-david@redhat.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 27-05-19 13:11:45, David Hildenbrand wrote:
> A proper arch_remove_memory() implementation is on its way, which also
> cleanly removes page tables in arch_add_memory() in case something goes
> wrong.
> 
> As we want to use arch_remove_memory() in case something goes wrong
> during memory hotplug after arch_add_memory() finished, let's add
> a temporary hack that is sufficient enough until we get a proper
> implementation that cleans up page table entries.
> 
> We will remove CONFIG_MEMORY_HOTREMOVE around this code in follow up
> patches.

I would drop this one as well (like s390 counterpart).
 
> Cc: Catalin Marinas <catalin.marinas@arm.com>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
> Cc: Chintan Pandya <cpandya@codeaurora.org>
> Cc: Mike Rapoport <rppt@linux.ibm.com>
> Cc: Jun Yao <yaojun8558363@gmail.com>
> Cc: Yu Zhao <yuzhao@google.com>
> Cc: Robin Murphy <robin.murphy@arm.com>
> Cc: Anshuman Khandual <anshuman.khandual@arm.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  arch/arm64/mm/mmu.c | 19 +++++++++++++++++++
>  1 file changed, 19 insertions(+)
> 
> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> index a1bfc4413982..e569a543c384 100644
> --- a/arch/arm64/mm/mmu.c
> +++ b/arch/arm64/mm/mmu.c
> @@ -1084,4 +1084,23 @@ int arch_add_memory(int nid, u64 start, u64 size,
>  	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
>  			   restrictions);
>  }
> +#ifdef CONFIG_MEMORY_HOTREMOVE
> +void arch_remove_memory(int nid, u64 start, u64 size,
> +			struct vmem_altmap *altmap)
> +{
> +	unsigned long start_pfn = start >> PAGE_SHIFT;
> +	unsigned long nr_pages = size >> PAGE_SHIFT;
> +	struct zone *zone;
> +
> +	/*
> +	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
> +	 * adding fails). Until then, this function should only be used
> +	 * during memory hotplug (adding memory), not for memory
> +	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
> +	 * unlocked yet.
> +	 */
> +	zone = page_zone(pfn_to_page(start_pfn));
> +	__remove_pages(zone, start_pfn, nr_pages, altmap);
> +}
> +#endif
>  #endif
> -- 
> 2.20.1

-- 
Michal Hocko
SUSE Labs


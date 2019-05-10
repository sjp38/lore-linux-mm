Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6801EC04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:30:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 255AE2177B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 13:30:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 255AE2177B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A51076B0285; Fri, 10 May 2019 09:30:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A00866B0286; Fri, 10 May 2019 09:30:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8C85C6B0287; Fri, 10 May 2019 09:30:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3940A6B0285
	for <linux-mm@kvack.org>; Fri, 10 May 2019 09:30:34 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h12so4096515edl.23
        for <linux-mm@kvack.org>; Fri, 10 May 2019 06:30:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:mime-version
         :content-transfer-encoding:date:from:to:cc:subject:in-reply-to
         :references:message-id:user-agent;
        bh=TYBk+Rq+Na5znds3ZP5xKpycNPoACGu8V5I9AZwu5cI=;
        b=O6NDpoFtAibgAjcG/8g+rNh8Y3/1F6bib3dz+Trey2eyzxqVUe+KfHTqh3e5NyBJL6
         nYqA6UxVkIp9NQ+HD4ngyFT/lNg1VNC49NJ6BcPHUE//x5cUbpt+iopINFtrnl6MF2oC
         1znV/Dvy0DPMPSMSY7oHbXOmflKylEwLiYsD4jpMXChX5zkpZoGYRSMpBdlud6tlnHR6
         f+U1hdkXiMEyBWPjffqhZq6VzB7Y4pYT1707I9CSO+/AZTkZB8cUw9W3xsOs1RaEvdiC
         mtDNZZlew5edjtlfon521L5sOCahv9TYE+ZMJ7XJTvujmTjx9puyO3s4if7wThISOzYt
         KffA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXFrgc/9z1oxOfGL8zud8zq5fpkHC98wM45Uf563k/R8+iFIZbH
	zxp9SgqqF88RpHN+KM3CWooLrG7P0k+Pf3pHhaOWxmyVwSLilMrg/CzVILOS+BYlDfhyOFMlzTK
	h12kSkClI28EDxLkBefGyzdTDCR9nRqS1efe0v6BttGQ/Qk3WykcBypky0rvjGl4q3w==
X-Received: by 2002:a50:908a:: with SMTP id c10mr10819072eda.226.1557495033790;
        Fri, 10 May 2019 06:30:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxoCEpgMYBOgRYWFUBtN9wdSAnWWx0DaSykNngpR1Jw3SXe1EOAKlKJajx2SlgmaoWdRnmN
X-Received: by 2002:a50:908a:: with SMTP id c10mr10818935eda.226.1557495032668;
        Fri, 10 May 2019 06:30:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557495032; cv=none;
        d=google.com; s=arc-20160816;
        b=NQVwbOFI/hs3j+sbA89FkEgrdx1Ot0tXxx1Frqd+8i6KX1Hg2jFO9lqvwc78EyJvcY
         QE9HgsgKixcYl2quULry/XKMbBvdOuXIZ79sun/LAasMNuYM+UQ2QhL0jOpaVpRLU99j
         u+9wskoyB743emCV3+oFtpE3lkSLDROlkm8heMNuzVge9tcf2jca2bfb6IoUI9FUyZtc
         A+MmANswVv9mOTnBL6BxKUboT9Coh2hDduXNOwF2Eyr/3i/uGbBKWrtDmSwNFVbU4pQ4
         Ok5B1DF41u6G7PBh+EL7tPj4b5Ee1vv1X6uBr7VYGIgi56Hrk3Ouo5WRn2SdGO86N9Cv
         X4Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:message-id:references:in-reply-to:subject:cc:to:from
         :date:content-transfer-encoding:mime-version;
        bh=TYBk+Rq+Na5znds3ZP5xKpycNPoACGu8V5I9AZwu5cI=;
        b=Rke3a9AewTme9mxVqsITczPxSCOkSHAuei0L41ya36yJ3o6+WdHzmqitSCMM7TEVSV
         eoXfcJL6cEZ8et2rDb8tCQE6yMGUA5r56vP0iR+U2C609NuKBa6oQJoggXLVImjW232s
         oR4cSK2zWYNYgGU2pLdu2yEBZ7gGcZFKqLzASiR7zsVZ9Y4zsYmkcEvfyE8JverMoW6R
         5EALBqNC5Hzd3Z+3KCIN5TGCyYrJBppoJQA0y5Ov2qoG5THrBqbFwfWJteM+0cNuwspU
         RyGjvrjo28FrGeCHyPKgRh3o4lCnlKGTJeaUe3LklISlAt0kkXpBWQdSZkzNERGgX5uC
         4CHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g3si2941127ejp.288.2019.05.10.06.30.32
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 May 2019 06:30:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 80EB7AEEC;
	Fri, 10 May 2019 13:30:31 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Fri, 10 May 2019 15:30:29 +0200
From: osalvador@suse.de
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>, Vlastimil
 Babka <vbabka@suse.cz>, Logan Gunthorpe <logang@deltatee.com>, Pavel
 Tatashin <pasha.tatashin@soleen.com>, Benjamin Herrenschmidt
 <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael
 Ellerman <mpe@ellerman.id.au>, linux-nvdimm@lists.01.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org, owner-linux-mm@kvack.org
Subject: Re: [PATCH v8 01/12] mm/sparsemem: Introduce struct mem_section_usage
In-Reply-To: <155718597192.130019.7128788290111464258.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <155718596657.130019.17139634728875079809.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155718597192.130019.7128788290111464258.stgit@dwillia2-desk3.amr.corp.intel.com>
Message-ID: <dd7b53bd986d79a94ac0b08e32336e44@suse.de>
X-Sender: osalvador@suse.de
User-Agent: Roundcube Webmail
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-05-07 01:39, Dan Williams wrote:
> Towards enabling memory hotplug to track partial population of a
> section, introduce 'struct mem_section_usage'.
> 
> A pointer to a 'struct mem_section_usage' instance replaces the 
> existing
> pointer to a 'pageblock_flags' bitmap. Effectively it adds one more
> 'unsigned long' beyond the 'pageblock_flags' (usemap) allocation to
> house a new 'subsection_map' bitmap.  The new bitmap enables the memory
> hot{plug,remove} implementation to act on incremental sub-divisions of 
> a
> section.
> 
> The default SUBSECTION_SHIFT is chosen to keep the 'subsection_map' no
> larger than a single 'unsigned long' on the major architectures.
> Alternatively an architecture can define ARCH_SUBSECTION_SHIFT to
> override the default PMD_SHIFT. Note that PowerPC needs to use
> ARCH_SUBSECTION_SHIFT to workaround PMD_SHIFT being a non-constant
> expression on PowerPC.
> 
> The primary motivation for this functionality is to support platforms
> that mix "System RAM" and "Persistent Memory" within a single section,
> or multiple PMEM ranges with different mapping lifetimes within a 
> single
> section. The section restriction for hotplug has caused an ongoing saga
> of hacks and bugs for devm_memremap_pages() users.
> 
> Beyond the fixups to teach existing paths how to retrieve the 'usemap'
> from a section, and updates to usemap allocation path, there are no
> expected behavior changes.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Cc: Oscar Salvador <osalvador@suse.de>
> Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
> Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> Cc: Paul Mackerras <paulus@samba.org>
> Cc: Michael Ellerman <mpe@ellerman.id.au>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  arch/powerpc/include/asm/sparsemem.h |    3 +
>  include/linux/mmzone.h               |   48 +++++++++++++++++++-
>  mm/memory_hotplug.c                  |   18 ++++----
>  mm/page_alloc.c                      |    2 -
>  mm/sparse.c                          |   81 
> +++++++++++++++++-----------------
>  5 files changed, 99 insertions(+), 53 deletions(-)
> 
> diff --git a/arch/powerpc/include/asm/sparsemem.h
> b/arch/powerpc/include/asm/sparsemem.h
> index 3192d454a733..1aa3c9303bf8 100644
> --- a/arch/powerpc/include/asm/sparsemem.h
> +++ b/arch/powerpc/include/asm/sparsemem.h
> @@ -10,6 +10,9 @@
>   */
>  #define SECTION_SIZE_BITS       24
> 
> +/* Reflect the largest possible PMD-size as the subsection-size 
> constant */
> +#define ARCH_SUBSECTION_SHIFT 24
> +

I guess this is done because PMD_SHIFT is defined at runtime rather at 
compile time,
right?


>  #endif /* CONFIG_SPARSEMEM */
> 
>  #ifdef CONFIG_MEMORY_HOTPLUG
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 70394cabaf4e..ef8d878079f9 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1160,6 +1160,44 @@ static inline unsigned long
> section_nr_to_pfn(unsigned long sec)
>  #define SECTION_ALIGN_UP(pfn)	(((pfn) + PAGES_PER_SECTION - 1) &
> PAGE_SECTION_MASK)
>  #define SECTION_ALIGN_DOWN(pfn)	((pfn) & PAGE_SECTION_MASK)
> 
> +/*
> + * SUBSECTION_SHIFT must be constant since it is used to declare
> + * subsection_map and related bitmaps without triggering the 
> generation
> + * of variable-length arrays. The most natural size for a subsection 
> is
> + * a PMD-page. For architectures that do not have a constant PMD-size
> + * ARCH_SUBSECTION_SHIFT can be set to a constant max size, or 
> otherwise
> + * fallback to 2MB.
> + */
> +#if defined(ARCH_SUBSECTION_SHIFT)
> +#define SUBSECTION_SHIFT (ARCH_SUBSECTION_SHIFT)
> +#elif defined(PMD_SHIFT)
> +#define SUBSECTION_SHIFT (PMD_SHIFT)
> +#else
> +/*
> + * Memory hotplug enabled platforms avoid this default because they
> + * either define ARCH_SUBSECTION_SHIFT, or PMD_SHIFT is a constant, 
> but
> + * this is kept as a backstop to allow compilation on
> + * !ARCH_ENABLE_MEMORY_HOTPLUG archs.
> + */
> +#define SUBSECTION_SHIFT 21
> +#endif
> +
> +#define PFN_SUBSECTION_SHIFT (SUBSECTION_SHIFT - PAGE_SHIFT)
> +#define PAGES_PER_SUBSECTION (1UL << PFN_SUBSECTION_SHIFT)
> +#define PAGE_SUBSECTION_MASK ((~(PAGES_PER_SUBSECTION-1)))
> +
> +#if SUBSECTION_SHIFT > SECTION_SIZE_BITS
> +#error Subsection size exceeds section size
> +#else
> +#define SUBSECTIONS_PER_SECTION (1UL << (SECTION_SIZE_BITS - 
> SUBSECTION_SHIFT))
> +#endif

On powerpc, SUBSECTIONS_PER_SECTION will equal 1 (so one big section), 
is that to be expected?
Will subsection_map_init handle this right?



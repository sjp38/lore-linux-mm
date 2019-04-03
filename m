Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86F98C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:26:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 400AB20830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 09:26:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 400AB20830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2C706B000C; Wed,  3 Apr 2019 05:26:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD92F6B000D; Wed,  3 Apr 2019 05:26:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC8816B000E; Wed,  3 Apr 2019 05:26:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6C70B6B000C
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 05:26:49 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id m32so7246423edd.9
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 02:26:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=f25rm1ONVLtMjth1BSWkFBZwflnIyxQ8+XdUsg5dnME=;
        b=kZhqzjHKLIlo/6pMFLsZZ04qQxeSJ0EvWPt0CyE+Jee7sRk+IiGQ9ZTqRmnDCxLw8W
         gc5BdJyHZbtpJg/Y3h+JEkm7SR84Hgttuq//ls1bSRdXieOFho9bIWkmAYh+PrmOLRG8
         pTm7oESyoGxSDcjRNXhNu/T6/A0LuL9aFus7W0ryc2ZWkgsCJtzu+jUa9oxXxXbg0YtJ
         qjqwwq7KuPCVllaF/l7fhqbC+3PdU5L25BKAb4UC5LiDOATqjwj4/zAwkhk4xMH+bFTG
         nCEZb16w33ZAMuN1VOYYmejUMFq2D9mTsv1O4rBr4WTsJnpjxBUvqtEfAsbmuu6mfZFQ
         g0EA==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAWPNm0zRBkbQgNNSEdaseNjgjNu+QJT78jKy6EdIsm1wHyVGIrb
	7J8QWhuXK42KWmu/Ab/w7zaDfzcacoTaNHdhQprEiyEnZFqHdqfTgieZQ9Vjh/RPM1u5SpBUdvP
	RtM/O4TR3Kqyv7JlevSMjQ44c1ecwQOLGKy6OYg28igPXEm9JUPRFeG5pZ4IYNe8=
X-Received: by 2002:a17:906:708d:: with SMTP id b13mr40836834ejk.120.1554283608935;
        Wed, 03 Apr 2019 02:26:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzRc14qIOea69ykwDvJ7Dfo2sDiBthddObcmnhuhhqIaB2jNooZSOG4Y01ZnKXTwgaqmTbi
X-Received: by 2002:a17:906:708d:: with SMTP id b13mr40836792ejk.120.1554283607944;
        Wed, 03 Apr 2019 02:26:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554283607; cv=none;
        d=google.com; s=arc-20160816;
        b=uYwHjoy1IHvM8X36xdGkFqtQVEIWe+uv6RBxUrk8KBjnFyZVpHS3F3f6PxvrUKQBUW
         CkCCJ5E5tYLNMZBeYuIh14eeGlqvOhRKkYRzKqUlJByU5abhq8Dz80eAprieuUH8BD3T
         mUGW4ExpuzgSpsXftk8BpK3WCkBU7zp2Y55cWINGYKv63/kJUtCSFMMsAQ2c7S66MsMn
         FgYZluOV0MRRMT/c5Yaxk0gQ4HA8GSt7OaGH358rRdzSdKmajFsHkfoG+/0gZjftxqqH
         PVkgRfnF0B0qxEvtZw4dNZs01bgbQ0YBn4GvC9KpYzVX+X7j+1BNO1/hAYJBIt/jdJoY
         BTIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=f25rm1ONVLtMjth1BSWkFBZwflnIyxQ8+XdUsg5dnME=;
        b=uCc6T9b6ne7959xsP0UIfqGTR4TK+JyPHeMjyingxEY0ZGrzDhTF+toOTkNV+YCyp2
         HjmhLn8MNh7/znsAkeiQvxtcHZdiGUxeX2pfCeTSt4rDsPIj4QTRRci7WXZZ3s6ETE2K
         LPlk4dj5NbKKBtPz5EkvOy3gf3xy+mZDrXGMM/Ve/j7r8bpzcHViORTfZReK+j20yfXN
         7CD9uBlgv/4/bTU4oyoQ7O/n0nYCQ8rjt2mkA4r/GFfE/9lx+XAb6hsJcQmvrpvCYQCy
         L5bL4345wSldWGR/bPlzHoKA1S/rajUS8v6LOUgNrb6KNL98FVHH0CXsKEFCawUq1C4P
         WJ+w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l1si2721959edn.23.2019.04.03.02.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Apr 2019 02:26:47 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id E3EE1AD62;
	Wed,  3 Apr 2019 09:26:46 +0000 (UTC)
Date: Wed, 3 Apr 2019 11:26:44 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mgorman@techsingularity.net,
	james.morse@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
	cpandya@codeaurora.org, arunks@codeaurora.org,
	dan.j.williams@intel.com, osalvador@suse.de, logang@deltatee.com,
	pasha.tatashin@oracle.com, david@redhat.com, cai@lca.pw
Subject: Re: [PATCH 5/6] mm/memremap: Rename and consolidate SECTION_SIZE
Message-ID: <20190403092644.GH15605@dhcp22.suse.cz>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-6-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554265806-11501-6-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed 03-04-19 10:00:05, Anshuman Khandual wrote:
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

Agreed. mremap shouldn't have redefined SECTION_SIZE in the first place.
This just adds a confusion.

> Signed-off-by: Robin Murphy <robin.murphy@arm.com>
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Acked-by: Michal Hocko <mhocko@suse.com>

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
> -- 
> 2.7.4
> 

-- 
Michal Hocko
SUSE Labs


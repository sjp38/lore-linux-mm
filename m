Return-Path: <SRS0=RcsE=S3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7C70C43219
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 14:43:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A12012081C
	for <linux-mm@archiver.kernel.org>; Thu, 25 Apr 2019 14:43:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A12012081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BBF076B0003; Thu, 25 Apr 2019 10:43:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B92D76B0005; Thu, 25 Apr 2019 10:43:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A37586B0006; Thu, 25 Apr 2019 10:43:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6607C6B0003
	for <linux-mm@kvack.org>; Thu, 25 Apr 2019 10:43:39 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l13so14521853pgp.3
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 07:43:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3BsmjSW1Ew9VxV27JLqXrd6TtR+GWM6ZUAqugTKz1WY=;
        b=rbiPhan8M6B/DXKasMPDakLyoFMdDrA2pz8f0wqmNB3b9CwjgZ9UQpxcBim9iucjWs
         nzxt48MXybec4PIdjlnD8KF4DTTxtgJhFhiXSRAadsKTPsFe+nsI0XQbwho1ePadkDUo
         uzfgQLeGlblQK3JHbc+ZFhfOcpj6a0GcaIZZt3nUpYtXHFnhC7j06aPFbN3bROzAfVhI
         J6CsWxnJ0X49ZFk0p4/JVUe2t3hgr/S9qxadbFhxlvIt612BcDOIQsZXZI2TnBy3VV6t
         G3upzm9dYha7r/RHKOGXWiCY0c7rfZqPtiDmV3DhNNa1ZwaUjeCIZdcpUwSWmz4D0FfG
         NueA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAVqQALQt9BHaxkzjIDWCI/QozYm6zWeWme2wQVHr6DMjMNxuT5g
	ZiPRKf/Q1wu6WIK1HnvilcUayznceAL18RPkWuD8bSz4WKlK6tDg2vG34yNkPAmN/DTVpqBQRN6
	34xV8kW5RPDVC+Q+CthJD9h+NWQu64K5DJ54VZsKppZ035XVZszTheS39+Y+S6jl1gA==
X-Received: by 2002:aa7:9813:: with SMTP id e19mr18179937pfl.159.1556203419022;
        Thu, 25 Apr 2019 07:43:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9cq3HxRPCIabJkRnCBK/xTkTu/RHSFYqQjOTaPXq7ixgqwW31KCYTlqM77h8GbFPCqowL
X-Received: by 2002:aa7:9813:: with SMTP id e19mr18179858pfl.159.1556203418193;
        Thu, 25 Apr 2019 07:43:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556203418; cv=none;
        d=google.com; s=arc-20160816;
        b=0OU2imH7c017yudvjD1k5KqCTrTCqbShS/3IYs5Tjy3rjDvqLgRkdkMP7ntDhRgqYU
         RDLCBb5y8tZqLWNuUuqr9IwZ+4Rmap1CoOzIQcVaQjvZHq+WdMEuUGzhYsw82Kw30EMU
         38ePyFrlDOyRKFVs/3I5VZwNJYbkgukCj4cAau7CXFeuQORtuJqVYkDS8CGF+4C05+Rw
         TqWaVAfmOMsK15m47EbA1P8wlt/ScRlMieUjhbsHmhd5+1mu7dLNilrR3iq9qs6LgF3g
         cwz4paE03NBxMDXqrUwiMy6Uo50Ld0yhGnsV3e1Hfng9wlHtDurt+bVCQpU7MtEuAaBV
         nsoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id;
        bh=3BsmjSW1Ew9VxV27JLqXrd6TtR+GWM6ZUAqugTKz1WY=;
        b=SaLBD3oRU0gl92U76xdWihiIcURWDj7qCizADkBT7ZO9QOa7u0dfilaiSXDTiJ9O+o
         rOcssrTI2ipXYvxvvmhQxzb0qVJlQwpiF22DGX8SbTAUXJwkric2yjwfP5qXlbIHlqJt
         RY6MAlRCFnUG/D3SF+X5WMsE41HpGF6yRQyvT2nQO1jUyqd1jy6P8yzNFenvpMjIyoeA
         hBvsjSw2KQUd+aVUDK4DEpZYsPys6rSsNO2ULTORWcs9wBb6pRmutiVc1GHB5nTbpDpx
         yBRehx/XSZix1vJg0R+AKjRofUGGlGQl6C2mEXFemRigA4+tpL6Z7NAyC9Gah02VHi/z
         bbng==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g123si22201603pfc.58.2019.04.25.07.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 07:43:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 9078BAEF6;
	Thu, 25 Apr 2019 14:43:32 +0000 (UTC)
Message-ID: <1556203394.3587.4.camel@suse.de>
Subject: Re: [PATCH v6 03/12] mm/sparsemem: Add helpers track active
 portions of a section at boot
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>, akpm@linux-foundation.org
Cc: Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Logan
 Gunthorpe <logang@deltatee.com>, linux-mm@kvack.org,
 linux-nvdimm@lists.01.org,  linux-kernel@vger.kernel.org, david@redhat.com
Date: Thu, 25 Apr 2019 16:43:14 +0200
In-Reply-To: <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
References: 
	<155552633539.2015392.2477781120122237934.stgit@dwillia2-desk3.amr.corp.intel.com>
	 <155552635098.2015392.5460028594173939000.stgit@dwillia2-desk3.amr.corp.intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.26.1 
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2019-04-17 at 11:39 -0700, Dan Williams wrote:
> Prepare for hot{plug,remove} of sub-ranges of a section by tracking a
> section active bitmask, each bit representing 2MB (SECTION_SIZE
> (128M) /
> map_active bitmask length (64)). If it turns out that 2MB is too
> large
> of an active tracking granularity it is trivial to increase the size
> of
> the map_active bitmap.
> 
> The implications of a partially populated section is that pfn_valid()
> needs to go beyond a valid_section() check and read the sub-section
> active ranges from the bitmask.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
Hi Dan,

I am still going through the patchset but:
 
> +static unsigned long section_active_mask(unsigned long pfn,
> +		unsigned long nr_pages)
> +{
> +	int idx_start, idx_size;
> +	phys_addr_t start, size;
> +
> +	if (!nr_pages)
> +		return 0;
> +
> +	start = PFN_PHYS(pfn);
> +	size = PFN_PHYS(min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK)));

We already picked the lowest value in section_active_init, didn't we?
This min() operations seems redundant to me here.

> +	size = ALIGN(size, SECTION_ACTIVE_SIZE);
> +
> +	idx_start = section_active_index(start);
> +	idx_size = section_active_index(size);
> +
> +	if (idx_size == 0)
> +		return -1;
> +	return ((1UL << idx_size) - 1) << idx_start;
> +}
> +
> +void section_active_init(unsigned long pfn, unsigned long nr_pages)
> +{
> +	int end_sec = pfn_to_section_nr(pfn + nr_pages - 1);
> +	int i, start_sec = pfn_to_section_nr(pfn);
> +
> +	if (!nr_pages)
> +		return;
> +
> +	for (i = start_sec; i <= end_sec; i++) {
> +		struct mem_section *ms;
> +		unsigned long mask;
> +		unsigned long pfns;

s/pfns/nr_pfns/ instead?

> +		pfns = min(nr_pages, PAGES_PER_SECTION
> +				- (pfn & ~PAGE_SECTION_MASK));
> +		mask = section_active_mask(pfn, pfns);
> +
> +		ms = __nr_to_section(i);
> +		pr_debug("%s: sec: %d mask: %#018lx\n", __func__, i,
> mask);
> +		ms->usage->map_active = mask;
> +
> +		pfn += pfns;
> +		nr_pages -= pfns;
> +	}
> +}

Although the code is not very complicated, it could use some comments
here and there I think.

> +
>  /* Record a memory area against a node. */
>  void __init memory_present(int nid, unsigned long start, unsigned
> long end)
>  {
> 
-- 
Oscar Salvador
SUSE L3


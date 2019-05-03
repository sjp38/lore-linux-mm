Return-Path: <SRS0=Y66U=TD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 796B0C04AAA
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 08:06:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 42D17208C3
	for <linux-mm@archiver.kernel.org>; Fri,  3 May 2019 08:06:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 42D17208C3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2DF36B0003; Fri,  3 May 2019 04:06:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7EB6B0005; Fri,  3 May 2019 04:06:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BCDAB6B0007; Fri,  3 May 2019 04:06:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 74C9C6B0003
	for <linux-mm@kvack.org>; Fri,  3 May 2019 04:06:28 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n23so3026710edv.9
        for <linux-mm@kvack.org>; Fri, 03 May 2019 01:06:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=E+YDejno2v3ET9BsZclTkNa1GEbE/4iS3+76FubSs3Q=;
        b=oH6LqYO8NFX+6NVPK6W9gq0KwO/uKOr0DgvffS9kWh+mjtzJhJGZySypeV85mjNjas
         D+C52eCkzJyNoMqlKtWITUs5qLLpTESwKZcOvXzXfJ5GPXfwpV67KQ5NUuooSpv4kV2h
         xSml5kHoKjzTk4KDYqf5IxMZ8EXlQwrjK2Tr5qxxSBkRZ1c3BAPAbkPdpNyimNhQCmws
         2681e49zGUj/ZKkfvChLJOvDnVPEqE6c9rZLdu2j13OfzoZVTAjtm82l/R9wo6oPBbGm
         gdKrWrgN1Q4/s212tIlFhTXJ0aa5Qra74PYD2JuFCyyLgkpKdywmsN8sdka8OFKI1cD7
         zdYQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAWauhtOptLxe6+niEAbzwB/+vMlfM3F1KcKVVFDemAKtGz4pfEf
	6HshBucWgovgMV/bDi5grglT/L6HQe5+N1F/Im9YmF4iyVx3W54KVLENAjC+KhlmuC5QL438u2x
	WHJDM8hpu06Roo+uu3AWWq/WFDH4EjpG1K6evuvjqX5ET1qzIDiHbq0B4E++nWYuC3Q==
X-Received: by 2002:a50:89f9:: with SMTP id h54mr4978114edh.222.1556870787779;
        Fri, 03 May 2019 01:06:27 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwF0tIyCiZlBuo91KKWmknRpu22grgYcQX7CBgjs6rykbJ7OJ7QLypGNKmdr+l1DU6GxZIe
X-Received: by 2002:a50:89f9:: with SMTP id h54mr4978050edh.222.1556870787016;
        Fri, 03 May 2019 01:06:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556870787; cv=none;
        d=google.com; s=arc-20160816;
        b=GckaUEmMwQmdC3dZjhvEJKkfddQmiGTB3CJn6vTUzdA3R6bC8W+eKMZ1G2mN/RhfYq
         MAPS6RUa+fPnpygQACkBaIuwpKJbuqOXdb+1x/oWXVsviQIgzmOOpWmdibLfk0a/3fj1
         xqjudthUbX03hzpAuCxfG7EF5W0oOjWd1VMNytJNEBsRaNNFG7kRaazkPrMB41nSvlyo
         Cft47XMz1jnEyqAVJnJaiAV+bB6M3ca/H9CKhFKuea2+/n1oQvciPmcjZrDEqBx/and8
         sf5d+IyVo1RGg9W4A8jwDE5kdpPZf2aa+YEFbqjlbuwQhaEPsGpLMpbTXXrlE+CNI0Ox
         5bjQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=E+YDejno2v3ET9BsZclTkNa1GEbE/4iS3+76FubSs3Q=;
        b=SQUFSqvL/XZLQXAfOxD4ji6vsFbD6RByi2T8CCYrT3Z2KPXN4wfu0s3jnHVOUcc5hR
         w5+pz9LSEK8V8vRv9H9wF12A67wjI5AjCRS08ISApjdRMZHe5TkdocSZqJmPZAxLIEK8
         NkdImaZJP93esHuIWs0kx09i8b/+xPgGV+PO8hWjs4qqLzRt7SQMTYCk3u4f93xtL1qh
         THTSB+e2DAXcXUMBjf4PcsSCCHJ/NjzWt0jvx3OX70rbnzrWzwWB2FZakkbX2xxPhTKp
         m+vbdJayVRinWdjvG6WsAhIohGBmid/JVFKpzYfPlIucYoGC5IlKCyyB2to3K49YCPaI
         znGw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u47si1045628edm.352.2019.05.03.01.06.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 May 2019 01:06:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.220.15 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 690BDAC4F;
	Fri,  3 May 2019 08:06:26 +0000 (UTC)
Date: Fri, 3 May 2019 10:06:23 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: akpm@linux-foundation.org, Michal Hocko <mhocko@suse.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Logan Gunthorpe <logang@deltatee.com>, linux-nvdimm@lists.01.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 02/12] mm/sparsemem: Introduce common definitions for
 the size and mask of a section
Message-ID: <20190503080622.GD15740@linux>
References: <155677652226.2336373.8700273400832001094.stgit@dwillia2-desk3.amr.corp.intel.com>
 <155677653274.2336373.11220321059915670288.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <155677653274.2336373.11220321059915670288.stgit@dwillia2-desk3.amr.corp.intel.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 01, 2019 at 10:55:32PM -0700, Dan Williams wrote:
> Up-level the local section size and mask from kernel/memremap.c to
> global definitions.  These will be used by the new sub-section hotplug
> support.
> 
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jérôme Glisse <jglisse@redhat.com>
> Cc: Logan Gunthorpe <logang@deltatee.com>
> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> ---
>  include/linux/mmzone.h |    2 ++
>  kernel/memremap.c      |   10 ++++------
>  mm/hmm.c               |    2 --
>  3 files changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f0bbd85dc19a..6726fc175b51 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -1134,6 +1134,8 @@ static inline unsigned long early_pfn_to_nid(unsigned long pfn)
>   * PFN_SECTION_SHIFT		pfn to/from section number
>   */
>  #define PA_SECTION_SHIFT	(SECTION_SIZE_BITS)
> +#define PA_SECTION_SIZE		(1UL << PA_SECTION_SHIFT)
> +#define PA_SECTION_MASK		(~(PA_SECTION_SIZE-1))

As discussed here [1], we do not need the new PA_SECTION_MASK if we work with
pfns/pages directly, so I'd drop it if you go that way.

Besides that:

Reviewed-by: Oscar Salvador <osalvador@suse.de>

[1] https://patchwork.kernel.org/patch/10926047/

-- 
Oscar Salvador
SUSE L3


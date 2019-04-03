Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 588BDC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:45:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1D76320830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 08:45:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D76320830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9C6D46B0008; Wed,  3 Apr 2019 04:45:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99E4C6B000A; Wed,  3 Apr 2019 04:45:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B36B6B000C; Wed,  3 Apr 2019 04:45:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 406D26B0008
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 04:45:14 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so7138687edo.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 01:45:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=EAEql048vzeKUcBnMgRBNvcOe50hTmDaoR6fZn19O84=;
        b=JW+3ryTX1sexa0mIxCmlkiAw7TyJ+y1y8si9at0pBoF5PtPp82vYmVyN2p5A4TjL3x
         /kz2u5EzRUnHrcvN2QHsI4oC6G5XR2Qpo9xhY/c4jTN8pTY/zKgAIqZ2T+SintSAWBkw
         fO7Y/R2FRLqzjsKQhKAJ1jRoWESF4UTbg+Srtx945tqXcsCWO4fUn96w7U0egUWVlZ/9
         5ASPOBfsHCQJwhsEtQ7s2AfSpld2sQ1GYHo9GAqXFOdJtLTJ5LtVy1C7lShBAx2/grKW
         rPVlXvf+8wF11UDnQ4uIBUnUXWcczNb9sDW8sCM+Xi8+Chbf0B8bUHz8S5lAbfIwO6tC
         CSfw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAXgyGZvHP8d5w2c7PDT793KbPSqtb3dOgjeAwKG1rbk+Oj1gzwU
	l5zOtDTlQwBb7hPY3fMUmG/82vFYZtyIMZicrPb+netKunzWNjkWW3XxTrj3VuegmmeSfT1oeI6
	5FPErCdfnLWlPH0MGy20cpNeJs3ntT57ENN5wUMw9dLwOBKh+Kc4i2vMp6vrzURfSyQ==
X-Received: by 2002:a50:b113:: with SMTP id k19mr50918434edd.31.1554281113848;
        Wed, 03 Apr 2019 01:45:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwj1StnBMpjoPuRcOQRRwJXWWJU1FHVRLSuMqFxKd8wmMYXmDbBuaJ45yQm0jq54ONiwIp9
X-Received: by 2002:a50:b113:: with SMTP id k19mr50918393edd.31.1554281113087;
        Wed, 03 Apr 2019 01:45:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554281113; cv=none;
        d=google.com; s=arc-20160816;
        b=kXTlnqqFKLG7JznTVIJvqcSddJ+1qnsC1oezYnD05wwtOa/UgFgm3Dio8t7eHYdK74
         qNowikiu0Owr7ySPW9+C/0jszZI2AE2S++4B2pRqcc34nxg8yy2SXaUzmUZQO+FfOK0E
         DUr0SF09rwONJiDWr+hseyKEmNiE3cYx5exuicmkgDiehR9aoHrK6puXOYfBhjmLCFx1
         Uy4ATS/uBygSqBLmO/KLJ1X7WbNp3PA2dC0AIvmAtzVXMwxnFcTRTSw2k7e1v7PIm2Ox
         v1nelM1NhwtPK3Elv21tkYQcf9VGiWwJ4jsyV2MKdwYlTgwt8G7UFiIwWuoywSvLfQND
         /RVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=EAEql048vzeKUcBnMgRBNvcOe50hTmDaoR6fZn19O84=;
        b=OVvu7Ih28g+cOeiiqHXIzSBwV3rEIHvrC2eV+lajXgF+GF/L+m3dRb6Zm89v4wQGcr
         WEWzynrQ/NIfCZZ7r8rY5gvqY+B3jPdjwfIuhLZZgtojZYeJVTo1ox+YVze1T9tQ9Wzd
         c7sbSXMGgGV1D9CwmjyrxZjIZ8LDy/phn+G51iPQx1299vYYfXf+W2MOV16EGpfBiUbX
         7Kk3eOeyteT7LcsdddYNSL5Zy470v8UZxOngdxt1DvHZV7kLI0K+cZRiXKVRwO7i72CY
         Zn0I3ts1ZGDSq4aVNvBno9/xFYytN0vrsgAZa8qd3bb06PvmvlHxcOvbh4xEeP4CNvyX
         6p/Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (charybdis-ext.suse.de. [195.135.221.2])
        by mx.google.com with ESMTP id r3si125702eda.229.2019.04.03.01.45.12
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 01:45:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 76BCC47E5; Wed,  3 Apr 2019 10:45:12 +0200 (CEST)
Date: Wed, 3 Apr 2019 10:45:12 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-mm@kvack.org, akpm@linux-foundation.org, will.deacon@arm.com,
	catalin.marinas@arm.com, mhocko@suse.com,
	mgorman@techsingularity.net, james.morse@arm.com,
	mark.rutland@arm.com, robin.murphy@arm.com, cpandya@codeaurora.org,
	arunks@codeaurora.org, dan.j.williams@intel.com,
	logang@deltatee.com, pasha.tatashin@oracle.com, david@redhat.com,
	cai@lca.pw
Subject: Re: [PATCH 4/6] mm/hotplug: Reorder arch_remove_memory() call in
 __remove_memory()
Message-ID: <20190403084512.otsvifwxuycoe5dn@d104.suse.de>
References: <1554265806-11501-1-git-send-email-anshuman.khandual@arm.com>
 <1554265806-11501-5-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554265806-11501-5-git-send-email-anshuman.khandual@arm.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 03, 2019 at 10:00:04AM +0530, Anshuman Khandual wrote:
> Re-ordering arch_remove_memory() with memblock_[free|remove] solves the
> problem on arm64 as pfn_valid() behaves correctly and returns positive
> as memblock for the address range still exists. arch_remove_memory()
> removes applicable memory sections from zone with __remove_pages() and
> tears down kernel linear mapping. Removing memblock regions afterwards
> is consistent.
> 
> Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>

Yes, I cannot see a way of those two colliding with each other, and
a testing on my box did not raise anything spooky either.

Reviewed-by: Oscar Salvador <osalvador@suse.de>

> ---
>  mm/memory_hotplug.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 0082d69..71d0d79 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1872,11 +1872,10 @@ void __ref __remove_memory(int nid, u64 start, u64 size)
>  
>  	/* remove memmap entry */
>  	firmware_map_remove(start, start + size, "System RAM");
> +	arch_remove_memory(nid, start, size, NULL);
>  	memblock_free(start, size);
>  	memblock_remove(start, size);
>  
> -	arch_remove_memory(nid, start, size, NULL);
> -
>  	try_offline_node(nid);
>  
>  	mem_hotplug_done();
> -- 
> 2.7.4
> 

-- 
Oscar Salvador
SUSE L3


Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C424CC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:06:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7DE2E2147C
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 15:06:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7DE2E2147C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 15E5A8E0003; Tue, 12 Mar 2019 11:06:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 10DAD8E0002; Tue, 12 Mar 2019 11:06:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F3DC28E0003; Tue, 12 Mar 2019 11:06:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id A063C8E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 11:06:06 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id u2so1236549edm.1
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 08:06:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=NEI+AKx/9QZTXNcTwFpmeZODUaYDB3D9cokv8oOjJ6w=;
        b=gFfnAhKhvdCV5ntOG6k62hWmOHzlj/XBby9K/jQJtERYMd6xptxU8wrXRwydoeP/MA
         dcNy/+fDbdTAaGZkCHIJsj8f9a2dqL0Y91s4BVcwPs+zBSoaqIFL5ePqjkKtY+1PmzsV
         bRstrbGxuxSOWai/QI875YNzs7qDXWDmdoXLzbzBdAOzPQelZkzxBp9QetMArNrU0V0k
         ko8CjLr/Z8KqMtTen0FWWkBpTgE1RcZZrJcsu+js4JDcFCmCHZRZT8QTGLtXnNr78MSO
         UDCVFGKVezDkh4WMnkHChy1qc6YvFiJGgQxQDFVbE0wGUhv1vLrXMf8iMw/zLu8iYOvB
         sjuw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAV1M5UqwYYRpGCIlDFYFzJ5PiMDyfpZ1GfhQhk8bMVh/g1sHPLQ
	rhDcCknj6WsCHGzdecdRZ78p0+GVV2XpVTuZwYQudqQ3eT/9Gtu+qqQu64Np1iucTQGOh+12S3V
	lg+VOEOnd6S7IrfDq3YyEVzvXm4UraW8z/wy/ou/TQ/yRWuIs00UEsCemLDotRlA=
X-Received: by 2002:aa7:d944:: with SMTP id l4mr3689910eds.146.1552403166228;
        Tue, 12 Mar 2019 08:06:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy/NHEI9HAJzygVX2hVLvUYzFwjuhADHljgduKlgBp5Z5dRoOHO0NljgWPdU3xN3wsIk+eu
X-Received: by 2002:aa7:d944:: with SMTP id l4mr3689856eds.146.1552403165365;
        Tue, 12 Mar 2019 08:06:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552403165; cv=none;
        d=google.com; s=arc-20160816;
        b=SAHJtrIVTS2X68pKJPtfMzem3d9YkNlzm1LDWlzSIomV1ZlGs9VC6fjHIVN/8hyoI7
         7kuG4QYikpSJjKlPork/jYxvHVE31wokKlb47vk5O035tMXotxyGeLBcliWCcMcZrwFK
         ZmjflINRDSzYeDhlsVg8a2ajOw7xXoVBuPHBn3nm+t55r8yhI4GILxOmr6vqewmKuTTp
         chCI1z/y6L0I6K/RIgJ6UcyABdh4J12eD/rsKH/prvQ0ZoCLGunkS8HJUujJ8Lt3+tjM
         fQp81YbL5Lpqt3OOpeT8Gz36FDQ/kXud079jir2pJZJx54twZ7zvhbJ1YZqa7EATl3de
         lLdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=NEI+AKx/9QZTXNcTwFpmeZODUaYDB3D9cokv8oOjJ6w=;
        b=BUnVQ2LaFaFHrlut7dojRIly7e8cPtkrQtje2LOktOLMJO0Rj1Jpo3GZLLTCn5R7EJ
         dMT85gC9UGSl+AwgKxPMxKwzYDXYQTu0xrcevsl5jlp5y/NTja6wgzAldXfeLq1bO7u0
         q+uctNFVM+6uRxgcjRknv9BkfFlKH+w13KmI49MeZkj8TucFK4aIQ5HGTQN4HXE+b6j9
         MIZElWyWsTtiicoocfeV/427E3ppw/Ay8l7/PK5rc8mGWeRWlKAdotiaA2+HUilAncyO
         oOnCOU5NGElpJ8GsLTeLNMToQutT5+7JCN1uIhK2YprHbgdDYTZGqK/cgyQTRi3L4CPy
         2J7w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6si1469217eja.76.2019.03.12.08.06.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 08:06:05 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id B9D05B168;
	Tue, 12 Mar 2019 15:06:04 +0000 (UTC)
Date: Tue, 12 Mar 2019 16:06:04 +0100
From: Michal Hocko <mhocko@kernel.org>
To: Qian Cai <cai@lca.pw>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [RESEND PATCH] mm/hotplug: don't reset pagetype flags for offline
Message-ID: <20190312150604.GT5721@dhcp22.suse.cz>
References: <20190310200102.88014-1-cai@lca.pw>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190310200102.88014-1-cai@lca.pw>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun 10-03-19 16:01:02, Qian Cai wrote:
> The commit f1dd2cd13c4b ("mm, memory_hotplug: do not associate hotadded
> memory to zones until online") introduced move_pfn_range_to_zone() which
> calls memmap_init_zone() during onlining a memory block.
> memmap_init_zone() will reset pagetype flags and makes migrate type to
> be MOVABLE.
> 
> However, in __offline_pages(), it also call undo_isolate_page_range()
> after offline_isolated_pages() to do the same thing. Due to
> the commit 2ce13640b3f4 ("mm: __first_valid_page skip over offline
> pages") changed __first_valid_page() to skip offline pages,
> undo_isolate_page_range() here just waste CPU cycles looping around the
> offlining PFN range while doing nothing, because __first_valid_page()
> will return NULL as offline_isolated_pages() has already marked all
> memory sections within the pfn range as offline via
> offline_mem_sections().
> 
> Also, after calling the "useless" undo_isolate_page_range() here, it
> reaches the point of no returning by notifying MEM_OFFLINE. Those pages
> will be marked as MIGRATE_MOVABLE again once onlining. In addition, fix
> an incorrect comment along the way.
> 
> Signed-off-by: Qian Cai <cai@lca.pw>

Well spotted. Thanks!

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memory_hotplug.c | 2 --
>  mm/sparse.c         | 2 +-
>  2 files changed, 1 insertion(+), 3 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 6b05576fb4ec..46017040b2f8 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1655,8 +1655,6 @@ static int __ref __offline_pages(unsigned long start_pfn,
>  	/* Ok, all of our target is isolated.
>  	   We cannot do rollback at this point. */
>  	offline_isolated_pages(start_pfn, end_pfn);
> -	/* reset pagetype flags and makes migrate type to be MOVABLE */
> -	undo_isolate_page_range(start_pfn, end_pfn, MIGRATE_MOVABLE);
>  	/* removal success */
>  	adjust_managed_page_count(pfn_to_page(start_pfn), -offlined_pages);
>  	zone->present_pages -= offlined_pages;
> diff --git a/mm/sparse.c b/mm/sparse.c
> index 77a0554fa5bd..b3771f35a0ed 100644
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -556,7 +556,7 @@ void online_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  }
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
> -/* Mark all memory sections within the pfn range as online */
> +/* Mark all memory sections within the pfn range as offline */
>  void offline_mem_sections(unsigned long start_pfn, unsigned long end_pfn)
>  {
>  	unsigned long pfn;
> -- 
> 2.17.2 (Apple Git-113)

-- 
Michal Hocko
SUSE Labs


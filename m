Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 455C5C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:57:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 029572147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 12:57:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 029572147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CDD68E0013; Wed, 20 Feb 2019 07:57:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 67C3F8E0002; Wed, 20 Feb 2019 07:57:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56BC78E0013; Wed, 20 Feb 2019 07:57:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2D838E0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 07:57:38 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i22so4195349eds.20
        for <linux-mm@kvack.org>; Wed, 20 Feb 2019 04:57:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=UdmFF6QHBE7gEZc4YEZjG+pB5k6ijL3qn2s3PQROWAE=;
        b=Tn3EVFoajBgn2icAWFwud9mmr10PqaJyKNzqL861TwMpiwQHBIsjeiNZETzZcZyUaP
         TOliRTA9uFJ4oVYJ7B5uOLnYXsqyH07RixKuRbEd5hu3EzzButm1JfaUhCpSwNC0O9rB
         emROrw6yTjbDiemvrsnuhVKE4QsNp2fqRs6T6tirF5lMYijGeJxa+3t2N2WFJZhhDJ/g
         a4tBTDTJb/n4YX6TSuyRhPlk40PFCB1I69QAftFSuyUChpry5qNkFwSdGfqOIU+pt9oK
         YsZwfgcbw45W+P0c9GXDDlD8U7yh1mUUeav6X0lcmUtGMKifQE/dkVaTDusCZVXEtWf1
         g9BQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: AHQUAuaysyUnCoSOVh9ugSUKhHacEtioBFmOCGU5eo5kUlaHDshg2JyW
	7JVAIW39teupNFR9MPnJQhWD0NSs1gxYCrMSsie58AcomamMGZ9I9B0+i62n4y4N4F5OIM+1tW1
	ksKYMMSf6HwXGiIvCLnLDVzR7w3koBhqAWYKjOzFlhxbPfwn9XjzWHkhTpo5wg2k=
X-Received: by 2002:a50:ba8c:: with SMTP id x12mr9775819ede.230.1550667458435;
        Wed, 20 Feb 2019 04:57:38 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbSVyRDGNsyYe68rXx2SGIJy6oigU3ecIuiSSCUh4snPVnNTEdQIbsIiZLXOslQMucR4oy5
X-Received: by 2002:a50:ba8c:: with SMTP id x12mr9775778ede.230.1550667457353;
        Wed, 20 Feb 2019 04:57:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550667457; cv=none;
        d=google.com; s=arc-20160816;
        b=zS3+qCxEYN5+qNR3m+vYHWroXYvPSkU5b6vptwAqc+TxH29UAXgqg2wzzdx0hLF7Uf
         0FoSKq9zWDBzd2K9pplprU+z3jbwXtYbFt1qSNMbTcg/rP8jsMrkks6BZ82VgqoNVvDP
         9Bvd/6Z6A9YQexnvBMkdP69UN4ntzM/xxj8k/1/xzwhgxu8uvM4J/XU3CIFWTAG89H7X
         wmuaYJYcZ2oXouAbXXyfgH5P22a9Q6/4sDHCcvrmv3oGNzrEE7vYowkjz53isMu6c61r
         3PXnNdHseP9IBCuhoa08xnsJT4U3HjytKCE7NsKU0J4qjRUFypAkCks8+OgFC3SHQ5h6
         kj4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=UdmFF6QHBE7gEZc4YEZjG+pB5k6ijL3qn2s3PQROWAE=;
        b=tcnMruxdIjeXontcvJ/YFArs75xtLSFp+6T1Es+DnCx2WB6tTd01KqGjR8iEpLDlFg
         PK1stHYGQoFvdFfW4hdxnxGPxAxHxoejch2hpPagguXFrjkAnme6Iy9ewnG112tHCtFd
         QOu+lK6CrEmrIR7O9T4abL0SiyViTXRvLMUjsCh32Wg68SF+Xuc3bTHI8bW8/0+9/Onc
         SpNBc6v/YfoSFQzdmtEFsRgB1A7XeCM+FhfJoZsTXb9Rb55fJMOzqM4GsNG0gCsTVzPI
         gYUh0TGtgJRRhwk2kL43TTl7cQO8hvrw8QCSJFSKE6Wkjso4/Cwq0sTjqP+KNnNsxk1C
         dj4Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si7670550edp.248.2019.02.20.04.57.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Feb 2019 04:57:37 -0800 (PST)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id D3C32AF82;
	Wed, 20 Feb 2019 12:57:36 +0000 (UTC)
Date: Wed, 20 Feb 2019 13:57:32 +0100
From: Michal Hocko <mhocko@kernel.org>
To: kernel test robot <rong.a.chen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Oscar Salvador <OSalvador@suse.com>, linux-mm@kvack.org,
	LKML <linux-kernel@vger.kernel.org>, lkp@01.org
Subject: Re: [RFC PATCH] mm, memory_hotplug: fix off-by-one in
 is_pageblock_removable
Message-ID: <20190220125732.GB4525@dhcp22.suse.cz>
References: <20190218052823.GH29177@shao2-debian>
 <20190218181544.14616-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218181544.14616-1-mhocko@kernel.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Rong Chen,
coudl you double check this indeed fixes the issue for you please?

On Mon 18-02-19 19:15:44, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Rong Chen has reported the following boot crash
> [   40.305212] PGD 0 P4D 0
> [   40.308255] Oops: 0000 [#1] PREEMPT SMP PTI
> [   40.313055] CPU: 1 PID: 239 Comm: udevd Not tainted 5.0.0-rc4-00149-gefad4e4 #1
> [   40.321348] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-1 04/01/2014
> [   40.330813] RIP: 0010:page_mapping+0x12/0x80
> [   40.335709] Code: 5d c3 48 89 df e8 0e ad 02 00 85 c0 75 da 89 e8 5b 5d c3 0f 1f 44 00 00 53 48 89 fb 48 8b 43 08 48 8d 50 ff a8 01 48 0f 45 da <48> 8b 53 08 48 8d 42 ff 83 e2 01 48 0f 44 c3 48 83 38 ff 74 2f 48
> [   40.356704] RSP: 0018:ffff88801fa87cd8 EFLAGS: 00010202
> [   40.362714] RAX: ffffffffffffffff RBX: fffffffffffffffe RCX: 000000000000000a
> [   40.370798] RDX: fffffffffffffffe RSI: ffffffff820b9a20 RDI: ffff88801e5c0000
> [   40.378830] RBP: 6db6db6db6db6db7 R08: ffff88801e8bb000 R09: 0000000001b64d13
> [   40.386902] R10: ffff88801fa87cf8 R11: 0000000000000001 R12: ffff88801e640000
> [   40.395033] R13: ffffffff820b9a20 R14: ffff88801f145258 R15: 0000000000000001
> [   40.403138] FS:  00007fb2079817c0(0000) GS:ffff88801dd00000(0000) knlGS:0000000000000000
> [   40.412243] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> [   40.418846] CR2: 0000000000000006 CR3: 000000001fa82000 CR4: 00000000000006a0
> [   40.426951] Call Trace:
> [   40.429843]  __dump_page+0x14/0x2c0
> [   40.433947]  is_mem_section_removable+0x24c/0x2c0
> [   40.439327]  removable_show+0x87/0xa0
> [   40.443613]  dev_attr_show+0x25/0x60
> [   40.447763]  sysfs_kf_seq_show+0xba/0x110
> [   40.452363]  seq_read+0x196/0x3f0
> [   40.456282]  __vfs_read+0x34/0x180
> [   40.460233]  ? lock_acquire+0xb6/0x1e0
> [   40.464610]  vfs_read+0xa0/0x150
> [   40.468372]  ksys_read+0x44/0xb0
> [   40.472129]  ? do_syscall_64+0x1f/0x4a0
> [   40.476593]  do_syscall_64+0x5e/0x4a0
> [   40.480809]  ? trace_hardirqs_off_thunk+0x1a/0x1c
> [   40.486195]  entry_SYSCALL_64_after_hwframe+0x49/0xbe
> 
> and bisected it down to efad4e475c31 ("mm, memory_hotplug:
> is_mem_section_removable do not pass the end of a zone"). The reason for
> the crash is that the mapping is garbage for poisoned (uninitialized) page.
> This shouldn't happen as all pages in the zone's boundary should be
> initialized. Later debugging revealed that the actual problem is an
> off-by-one when evaluating the end_page. start_pfn + nr_pages resp.
> zone_end_pfn refers to a pfn after the range and as such it might belong
> to a differen memory section. This along with CONFIG_SPARSEMEM then
> makes the loop condition completely bogus because a pointer arithmetic
> doesn't work for pages from two different sections in that memory model.
> 
> Fix the issue by reworking is_pageblock_removable to be pfn based and
> only use struct page where necessary. This makes the code slightly
> easier to follow and we will remove the problematic pointer arithmetic
> completely.
> 
> Fixes: efad4e475c31 ("mm, memory_hotplug: is_mem_section_removable do not pass the end of a zone")
> Reported-by: <rong.a.chen@intel.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory_hotplug.c | 27 +++++++++++++++------------
>  1 file changed, 15 insertions(+), 12 deletions(-)
> 
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 124e794867c5..1ad28323fb9f 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1188,11 +1188,13 @@ static inline int pageblock_free(struct page *page)
>  	return PageBuddy(page) && page_order(page) >= pageblock_order;
>  }
>  
> -/* Return the start of the next active pageblock after a given page */
> -static struct page *next_active_pageblock(struct page *page)
> +/* Return the pfn of the start of the next active pageblock after a given pfn */
> +static unsigned long next_active_pageblock(unsigned long pfn)
>  {
> +	struct page *page = pfn_to_page(pfn);
> +
>  	/* Ensure the starting page is pageblock-aligned */
> -	BUG_ON(page_to_pfn(page) & (pageblock_nr_pages - 1));
> +	BUG_ON(pfn & (pageblock_nr_pages - 1));
>  
>  	/* If the entire pageblock is free, move to the end of free page */
>  	if (pageblock_free(page)) {
> @@ -1200,16 +1202,16 @@ static struct page *next_active_pageblock(struct page *page)
>  		/* be careful. we don't have locks, page_order can be changed.*/
>  		order = page_order(page);
>  		if ((order < MAX_ORDER) && (order >= pageblock_order))
> -			return page + (1 << order);
> +			return pfn + (1 << order);
>  	}
>  
> -	return page + pageblock_nr_pages;
> +	return pfn + pageblock_nr_pages;
>  }
>  
> -static bool is_pageblock_removable_nolock(struct page *page)
> +static bool is_pageblock_removable_nolock(unsigned long pfn)
>  {
> +	struct page *page = pfn_to_page(pfn);
>  	struct zone *zone;
> -	unsigned long pfn;
>  
>  	/*
>  	 * We have to be careful here because we are iterating over memory
> @@ -1232,13 +1234,14 @@ static bool is_pageblock_removable_nolock(struct page *page)
>  /* Checks if this range of memory is likely to be hot-removable. */
>  bool is_mem_section_removable(unsigned long start_pfn, unsigned long nr_pages)
>  {
> -	struct page *page = pfn_to_page(start_pfn);
> -	unsigned long end_pfn = min(start_pfn + nr_pages, zone_end_pfn(page_zone(page)));
> -	struct page *end_page = pfn_to_page(end_pfn);
> +	unsigned long end_pfn, pfn;
> +
> +	end_pfn = min(start_pfn + nr_pages,
> +			zone_end_pfn(page_zone(pfn_to_page(start_pfn))));
>  
>  	/* Check the starting page of each pageblock within the range */
> -	for (; page < end_page; page = next_active_pageblock(page)) {
> -		if (!is_pageblock_removable_nolock(page))
> +	for (pfn = start_pfn; pfn < end_pfn; pfn = next_active_pageblock(pfn)) {
> +		if (!is_pageblock_removable_nolock(pfn))
>  			return false;
>  		cond_resched();
>  	}
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs


Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8DD1CC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:17:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48FB82147C
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 12:17:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48FB82147C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CA53D6B0003; Wed, 27 Mar 2019 08:17:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C54106B0006; Wed, 27 Mar 2019 08:17:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B6A406B0007; Wed, 27 Mar 2019 08:17:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 62F816B0003
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 08:17:13 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z98so6642441ede.3
        for <linux-mm@kvack.org>; Wed, 27 Mar 2019 05:17:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=jDXwrRuMFP3kmTVdufkZfzmKD0qmbnEEiidDad6kIuk=;
        b=cA4rt2gNkKpyVT+uSW3qOEq9t128ZKyz+782YM0kv1H9DIgXLlmFTyolLbsUSjTkyB
         LszTNF1ZWRBe9M9Ud3UCEVrV9X7YboSW7xup7VH/v5BD+yUOqsizIc6p8mucEXD7W6jZ
         f1tre6NRzRT+iFkVXK6XFttRaQ5+NZH8DEfMZt6yMWwMiGJoGKm95CA1Tex5koJJxMhn
         o1dSCy86JHuZjy1/5KWCJinOuDsJMIvgeAvu6fOwiJpX9I/sbMiKk6K2wDO1zncpZiJE
         lyLfPOZOdbLG3LbGCXTzyankPsxBBli/Zz4bkVMRiZN42AAm/DSxOEZoZRLvlGj6jmge
         dptA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAXBUdBAgmBfNH7SuGmGYUojy4Q5r0DKny3ZJTUpUk5Eqlkt8zQO
	khsZkcYhZUZ2DUpH2E1paS2wxcK/KMJJT4gbcd3bAvqZxF8vWG3eRoPvD8ilmTx5+6GciDkzZjm
	INKyi3wmE7Z1e+KDBn1fvexKk1JB1hSwr6x8F1xPQS/xWB1f0T6OLrtajow39xzkMSA==
X-Received: by 2002:a50:cccc:: with SMTP id b12mr24299182edj.94.1553689032930;
        Wed, 27 Mar 2019 05:17:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzy2GhChaMcOfpfIfZFzfTElPayhHktGNgnBxFLfzUvC8yFhzVcLVbLwN4VkDStmzVAs4jC
X-Received: by 2002:a50:cccc:: with SMTP id b12mr24299131edj.94.1553689031839;
        Wed, 27 Mar 2019 05:17:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553689031; cv=none;
        d=google.com; s=arc-20160816;
        b=0xBzGtvMOt0TXmvrSo/KXr+cUUIqyukavtCtDn3ta64Bzd8rXfMQvvuKTbQUBsBlzj
         aqKEvWGU3uh0c7Xo8KvVvS3ixF9tgnNwpP860z9NG2Fo4+BNdX8LefyMKm0FbgrmP5Rf
         FZWJ0cE5D1pp1KX7vbfGRVABl1E6qQdvqDBOJppYMKw0TYl3YAwFmThwlExrjNnxVjTU
         fphy8NQZAKmEUFo/I4Ii6qxbk0FfzQbTNyCe4JbKjd/3D/NAvTous6NBottmz1gwyqgC
         XE1e7oO4WQKdgvXn9Rz8+y24I3sD3QC6hgcOaGpCeVKdbgb/jXAEZno74F45SekjAbag
         Bq4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=jDXwrRuMFP3kmTVdufkZfzmKD0qmbnEEiidDad6kIuk=;
        b=pxbthdomahY5tPocGVjTenvcxoxxzhHFxfA2yJDFm83VXc+otN/aCAg8w29v91yS5S
         2f5pUcUYdjHsux0+LfxpSHdZZ8utxCGbV/VFPvjrH9fLtuczMB4Yd44fbBqhLBXSyycG
         AOJSdr6/1NwTZVGZjiiEvM2yzH/8Xh8uvkISFkgA3i5YT4lY13Jhxc4PH/KKov/xi4va
         r1TzOCwZAVygopVVR7yPQHkYILytrfuqAvRcZX/3AiJagrS+7zpYSubSSCeIo3HRw0FP
         g8+dQnpG39xnTUk10rqfOx0XjKQ9MMbY2tOxRz7Pbf22n5an9hdDUfQgewymvSyN9HGZ
         /4Tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y15si588148edm.325.2019.03.27.05.17.11
        for <linux-mm@kvack.org>;
        Wed, 27 Mar 2019 05:17:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 57E14374;
	Wed, 27 Mar 2019 05:17:10 -0700 (PDT)
Received: from [10.162.40.146] (p8cg001049571a15.blr.arm.com [10.162.40.146])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0DDA23F557;
	Wed, 27 Mar 2019 05:17:07 -0700 (PDT)
Subject: Re: [PATCH] Correct zone boundary handling when resetting pageblock
 skip hints
To: Mel Gorman <mgorman@techsingularity.net>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>,
 Daniel Jordan <daniel.m.jordan@oracle.com>, Qian Cai <cai@lca.pw>,
 linux-mm@kvack.org, vbabka@suse.cz, linux-kernel@vger.kernel.org
References: <20190327085424.GL3189@techsingularity.net>
From: Anshuman Khandual <anshuman.khandual@arm.com>
Message-ID: <084b92cd-94e9-f8e5-cce1-862d984c8eac@arm.com>
Date: Wed, 27 Mar 2019 17:47:06 +0530
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:52.0) Gecko/20100101
 Thunderbird/52.9.1
MIME-Version: 1.0
In-Reply-To: <20190327085424.GL3189@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 03/27/2019 02:24 PM, Mel Gorman wrote:
> Mikhail Gavrilo reported the following bug being triggered in a Fedora
> kernel based on 5.1-rc1 but it is relevant to a vanilla kernel.
> 
>  kernel: page dumped because: VM_BUG_ON_PAGE(PagePoisoned(p))
>  kernel: ------------[ cut here ]------------
>  kernel: kernel BUG at include/linux/mm.h:1021!
>  kernel: invalid opcode: 0000 [#1] SMP NOPTI
>  kernel: CPU: 6 PID: 116 Comm: kswapd0 Tainted: G         C        5.1.0-0.rc1.git1.3.fc31.x86_64 #1
>  kernel: Hardware name: System manufacturer System Product Name/ROG STRIX X470-I GAMING, BIOS 1201 12/07/2018
>  kernel: RIP: 0010:__reset_isolation_pfn+0x244/0x2b0
>  kernel: Code: fe 06 e8 0f 8e fc ff 44 0f b6 4c 24 04 48 85 c0 0f 85 dc fe ff ff e9 68 fe ff ff 48 c7 c6 58 b7 2e 8c 4c 89 ff e8 0c 75 00 00 <0f> 0b 48 c7 c6 58 b7 2e 8c e8 fe 74 00 00 0f 0b 48 89 fa 41 b8 01
>  kernel: RSP: 0018:ffff9e2d03f0fde8 EFLAGS: 00010246
>  kernel: RAX: 0000000000000034 RBX: 000000000081f380 RCX: ffff8cffbddd6c20
>  kernel: RDX: 0000000000000000 RSI: 0000000000000006 RDI: ffff8cffbddd6c20
>  kernel: RBP: 0000000000000001 R08: 0000009898b94613 R09: 0000000000000000
>  kernel: R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000100000
>  kernel: R13: 0000000000100000 R14: 0000000000000001 R15: ffffca7de07ce000
>  kernel: FS:  0000000000000000(0000) GS:ffff8cffbdc00000(0000) knlGS:0000000000000000
>  kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>  kernel: CR2: 00007fc1670e9000 CR3: 00000007f5276000 CR4: 00000000003406e0
>  kernel: Call Trace:
>  kernel:  __reset_isolation_suitable+0x62/0x120
>  kernel:  reset_isolation_suitable+0x3b/0x40
>  kernel:  kswapd+0x147/0x540
>  kernel:  ? finish_wait+0x90/0x90
>  kernel:  kthread+0x108/0x140
>  kernel:  ? balance_pgdat+0x560/0x560
>  kernel:  ? kthread_park+0x90/0x90
>  kernel:  ret_from_fork+0x27/0x50
> 
> He bisected it down to commit e332f741a8dd ("mm, compaction: be selective
> about what pageblocks to clear skip hints"). The problem is that the patch
> in question was sloppy with respect to the handling of zone boundaries. In
> some instances, it was possible for PFNs outside of a zone to be examined
> and if those were not properly initialised or poisoned then it would
> trigger the VM_BUG_ON. This patch corrects the zone boundary issues when
> resetting pageblock skip hints and Mikhail reported that the bug did not
> trigger after 30 hours of testing.
> 
> Fixes: e332f741a8dd ("mm, compaction: be selective about what pageblocks to clear skip hints")
> Reported-and-tested-by: Mikhail Gavrilov <mikhail.v.gavrilov@gmail.com>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/compaction.c | 27 +++++++++++++++++----------
>  1 file changed, 17 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index f171a83707ce..b4930bf93c8a 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -242,6 +242,7 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>  							bool check_target)
>  {
>  	struct page *page = pfn_to_online_page(pfn);
> +	struct page *block_page;
>  	struct page *end_page;
>  	unsigned long block_pfn;
>  
> @@ -267,20 +268,26 @@ __reset_isolation_pfn(struct zone *zone, unsigned long pfn, bool check_source,
>  	    get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
>  		return false;
>  
> +	/* Ensure the start of the pageblock or zone is online and valid */
> +	block_pfn = pageblock_start_pfn(pfn);
> +	block_page = pfn_to_online_page(max(block_pfn, zone->zone_start_pfn));
> +	if (block_page) {
> +		page = block_page;
> +		pfn = block_pfn;
> +	}
> +
> +	/* Ensure the end of the pageblock or zone is online and valid */
> +	block_pfn += pageblock_nr_pages;
> +	block_pfn = min(block_pfn, zone_end_pfn(zone) - 1);
> +	end_page = pfn_to_online_page(block_pfn);
> +	if (!end_page)
> +		return false;

Should not we check zone against page_zone() from both start and end page here.


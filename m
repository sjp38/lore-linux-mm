Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_NEOMUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78459C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:57:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 321C5204EC
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:57:15 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 321C5204EC
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9AA96B0277; Tue,  2 Apr 2019 10:57:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C47EE6B0278; Tue,  2 Apr 2019 10:57:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B38B66B0279; Tue,  2 Apr 2019 10:57:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 545686B0277
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 10:57:14 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id p5so6027460edh.2
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 07:57:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=g4PQf3qV6RZaTVxBeCHS03DIVl34mMa1dwn5XtzjWco=;
        b=FV+LZVg97wP6KoW9e5hMAqbVhIUjE4SHryH3WZwd4WchqctAN7XiY2SXOaL1wH6ZHt
         eMU+L3+hyTyM8vsUjzchR1j6ORXTqOv+FDKEeM6V4lGafuNmr6YlOB8IyM3fsHJOKo7J
         M+cNRSV5s4l2YtZWyeEbZQUoa0hQbor3MBainQLGG4EZh21KZb9DVaK5n+E7GlAjXUky
         bBz6H+w8Ep7X/lvWeVyOK0bEprC4Tifjhl4Ml2SNnOTpkKRuiKD9bifQVgkXU5cBo7ZE
         3y5OsYB4jbMKysPVJhovrJyi+Dqq2UeVafiOl40JSf7J62fCU053td+AuzMfzPrY5DpO
         mv9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAU7H0+kHorwQY4aZ+lRzj0KMfPUVq8l81qA3B+wBfQ/u+EUaINp
	Pk2ojLuYd3QDRFidcYvyubdCi5+dZhzMEEFbVluOiFHiM7fTn/Dsg3IBzWP82xAkBSkEIgBdvNY
	PRV5vH1eK2M0cTHZYx0lvN3ibiDnyv3UmsFiE/6sOmm+VuShfQo9bc8fVreiWOdrT9g==
X-Received: by 2002:aa7:c5c4:: with SMTP id h4mr35530448eds.19.1554217033899;
        Tue, 02 Apr 2019 07:57:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy5Rp8u5FW0tHjyptvfX0oPljQmqf/QoKVmahgD3psGzu5cjGxyW97FcgBs8I22EOehOiMI
X-Received: by 2002:aa7:c5c4:: with SMTP id h4mr35530368eds.19.1554217032608;
        Tue, 02 Apr 2019 07:57:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554217032; cv=none;
        d=google.com; s=arc-20160816;
        b=EV9Yv5uKiItUY3BAD/dQBNYvMFJSNixjOtCRLCf2l79/Yy4dYbbZPaFc0EVf/A/7Ng
         lOxKSoriV4iE3tcY0andBUqCdTTm+ivho999RGiaTLRLlavZlEziQpIB1AzmIoyRjCmB
         4gdyQWzL31mbZecxB7B2nKqScBba/2rQ1RFqdL2hykSOvslMBxfCgUyUBFfAEhvnVV9d
         ndmmsI2/kAeoeRoB7EzhEIiuf1t14sZZP/+9fcMvY/wFK9DqZnsBmBh1X7yGi74+3S1a
         mxqJBb/N/va1PhB0aB9Eu3Vb2DAPRwM9S0AzDti7ROG5T8uqXaIgtD6xQqurBPn5t70F
         VBJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=g4PQf3qV6RZaTVxBeCHS03DIVl34mMa1dwn5XtzjWco=;
        b=ucX9z9/XZ6FA6T9CKfhWC76OjqZLIU113CR9kX5lK65Y/kDJLiwNo5zWUYz/QkYCAp
         K6NhBnYnatsHr/DiKEkIKcJXb/vmBmbKm9erRFWNKQqyriuU5g/g3TvECfhckRmChf1x
         onKqNRcYc3E1FV3BEXrMUZh6iqZlqlMYqEMMxYey6uTEEo3hywznD7XXULBEK6gM4+5X
         Un1WBhM+Cha46WhFMPbA0mtDCHSLEkMhr/zzVdeOdqw/PXJI/suSxUlzmU26i8FyKyJL
         E6zdxfL9COohaFc0JWCh4QK+eVWpAJKtrZYrADXMnB8D6WrdldkuuL6o47FPY3btc9/b
         MsTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [195.135.221.2])
        by mx.google.com with ESMTP id q20si1049802ejb.114.2019.04.02.07.57.12
        for <linux-mm@kvack.org>;
        Tue, 02 Apr 2019 07:57:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) client-ip=195.135.221.2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of osalvador@suse.de designates 195.135.221.2 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id AF0D947C7; Tue,  2 Apr 2019 16:57:11 +0200 (CEST)
Date: Tue, 2 Apr 2019 16:57:11 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Linxu Fang <fanglinxu@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz,
	pavel.tatashin@microsoft.com, linux-mm@kvack.org
Subject: Re: [PATCH] mem-hotplug: fix node spanned pages when we have a node
 with only zone_movable
Message-ID: <20190402145708.7b2xp3cc72vqqlzl@d104.suse.de>
References: <1554178276-10372-1-git-send-email-fanglinxu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554178276-10372-1-git-send-email-fanglinxu@huawei.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 02, 2019 at 12:11:16PM +0800, Linxu Fang wrote:
> commit <342332e6a925> ("mm/page_alloc.c: introduce kernelcore=mirror
> option") and series patches rewrote the calculation of node spanned
> pages.
> commit <e506b99696a2> (mem-hotplug: fix node spanned pages when we have a
> movable node), but the current code still has problems,
> when we have a node with only zone_movable and the node id is not zero,
> the size of node spanned pages is double added.
> That's because we have an empty normal zone, and zone_start_pfn or
> zone_end_pfn is not between arch_zone_lowest_possible_pfn and
> arch_zone_highest_possible_pfn, so we need to use clamp to constrain the
> range just like the commit <96e907d13602> (bootmem: Reimplement
> __absent_pages_in_range() using for_each_mem_pfn_range()).

So, let me see if I understood this correctly:

When calling zone_spanned_pages_in_node() for any node which is not node 0,

> *zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> *zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];

will actually set zone_start_pfn/zone_end_pfn to the values from node0's
ZONE_NORMAL?

So we use clamp to actually check if such values fall within what node1's
memory spans, and ignore them otherwise?

Btw, mem-hotplug does not hit this path anymore.


> 
> e.g.
> Zone ranges:
>   DMA      [mem 0x0000000000001000-0x0000000000ffffff]
>   DMA32    [mem 0x0000000001000000-0x00000000ffffffff]
>   Normal   [mem 0x0000000100000000-0x000000023fffffff]
> Movable zone start for each node
>   Node 0: 0x0000000100000000
>   Node 1: 0x0000000140000000
> Early memory node ranges
>   node   0: [mem 0x0000000000001000-0x000000000009efff]
>   node   0: [mem 0x0000000000100000-0x00000000bffdffff]
>   node   0: [mem 0x0000000100000000-0x000000013fffffff]
>   node   1: [mem 0x0000000140000000-0x000000023fffffff]
> 
> node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
> node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
> node 0 Normal	spanned:0	present:0	absent:0
> node 0 Movable	spanned:0x40000 present:0x40000 absent:0
> On node 0 totalpages(node_present_pages): 1048446
> node_spanned_pages:1310719
> node 1 DMA	spanned:0	    present:0		absent:0
> node 1 DMA32	spanned:0	    present:0		absent:0
> node 1 Normal	spanned:0x100000    present:0x100000	absent:0
> node 1 Movable	spanned:0x100000    present:0x100000	absent:0
> On node 1 totalpages(node_present_pages): 2097152
> node_spanned_pages:2097152
> Memory: 6967796K/12582392K available (16388K kernel code, 3686K rwdata,
> 4468K rodata, 2160K init, 10444K bss, 5614596K reserved, 0K
> cma-reserved)
> 
> It shows that the current memory of node 1 is double added.
> After this patch, the problem is fixed.
> 
> node 0 DMA	spanned:0xfff   present:0xf9e   absent:0x61
> node 0 DMA32	spanned:0xff000 present:0xbefe0	absent:0x40020
> node 0 Normal	spanned:0	present:0	absent:0
> node 0 Movable	spanned:0x40000 present:0x40000 absent:0
> On node 0 totalpages(node_present_pages): 1048446
> node_spanned_pages:1310719
> node 1 DMA	spanned:0	    present:0		absent:0
> node 1 DMA32	spanned:0	    present:0		absent:0
> node 1 Normal	spanned:0	    present:0		absent:0
> node 1 Movable	spanned:0x100000    present:0x100000	absent:0
> On node 1 totalpages(node_present_pages): 1048576
> node_spanned_pages:1048576
> memory: 6967796K/8388088K available (16388K kernel code, 3686K rwdata,
> 4468K rodata, 2160K init, 10444K bss, 1420292K reserved, 0K
> cma-reserved)
> 
> Signed-off-by: Linxu Fang <fanglinxu@huawei.com>
> ---
>  mm/page_alloc.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3eb01de..5cd0cb2 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6233,13 +6233,15 @@ static unsigned long __init zone_spanned_pages_in_node(int nid,
>  					unsigned long *zone_end_pfn,
>  					unsigned long *ignored)
>  {
> +	unsigned long zone_low = arch_zone_lowest_possible_pfn[zone_type];
> +	unsigned long zone_high = arch_zone_highest_possible_pfn[zone_type];
>  	/* When hotadd a new node from cpu_up(), the node should be empty */
>  	if (!node_start_pfn && !node_end_pfn)
>  		return 0;
>  
>  	/* Get the start and end of the zone */
> -	*zone_start_pfn = arch_zone_lowest_possible_pfn[zone_type];
> -	*zone_end_pfn = arch_zone_highest_possible_pfn[zone_type];
> +	*zone_start_pfn = clamp(node_start_pfn, zone_low, zone_high);
> +	*zone_end_pfn = clamp(node_end_pfn, zone_low, zone_high);
>  	adjust_zone_range_for_zone_movable(nid, zone_type,
>  				node_start_pfn, node_end_pfn,
>  				zone_start_pfn, zone_end_pfn);
> -- 
> 1.8.5.6
> 
> 

-- 
Oscar Salvador
SUSE L3


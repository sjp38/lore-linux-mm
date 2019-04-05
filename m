Return-Path: <SRS0=BJvi=SH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 175EFC4360F
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 12:54:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D2A9520855
	for <linux-mm@archiver.kernel.org>; Fri,  5 Apr 2019 12:54:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D2A9520855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CE8E6B0269; Fri,  5 Apr 2019 08:54:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57C5F6B026A; Fri,  5 Apr 2019 08:54:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 46ACE6B026B; Fri,  5 Apr 2019 08:54:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E8E5C6B0269
	for <linux-mm@kvack.org>; Fri,  5 Apr 2019 08:54:35 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so3205066edo.5
        for <linux-mm@kvack.org>; Fri, 05 Apr 2019 05:54:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=3CAYcQSK5slfPWqZ7uarhOjxrFvQq+s+S9dj1KY74t8=;
        b=AuvxCAXGOu0yNzO47Eqa75Wf9E1S/qNUWW8MC5x3RRSuRBgUjm52Q1bCARhjhS3ojw
         fid/VpIDRfMktZdQREFWAQVNTxcqUw6H7E1aH8iHlciZQWs5zA6Rm7TmdZGD/PZNkE4b
         zUUbUbnlH8iK2SCr6++HNth0QbyVC1BzzeV+VYhdoFlDhLOKBlMfY8R6wv2IgLpCX8CF
         wjrlaoh17oJREnDWllPOl3jbSd5UM5v9cdpdM+8t3cIhWBcBQrJU5fxBMpL4LE2DhqXk
         aB+qrW660w4oV4P69TsytEu5O4aDi1E3veHpJHJNADmmsaGa9yVTDNuBc8cRwqSwyX9d
         +NEw==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
X-Gm-Message-State: APjAAAUUFlzUYxMgW/RBcFZPkDFpkpXX5ccfn+w16kHq1DvUJId7Dy54
	LVGJET1wkom3W2jfqDoZmh/FZWrwQiQx454h6fHsFJEBS6zPfh8at4yS0zlrX0SU8UH9rEqeZYF
	1ZGPduuzRIN5qQUh8UtAguaiN97D/BwAB/0nwC0ZVjbFG8i798NwRMFnbCdwMX/M=
X-Received: by 2002:a50:ac07:: with SMTP id v7mr8055562edc.119.1554468875483;
        Fri, 05 Apr 2019 05:54:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyen3TDNmMb0ZdwLfyxoX+EEN2FAj+OdFScTbakZRaTkN6WyzNzOx0QG+S37TMX4OQo7oLp
X-Received: by 2002:a50:ac07:: with SMTP id v7mr8055498edc.119.1554468874177;
        Fri, 05 Apr 2019 05:54:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554468874; cv=none;
        d=google.com; s=arc-20160816;
        b=jTSxn2kmhl6C+jSw8WABfp+03aZUTN6EppiEkX9JWt2mV2r2I6L0hoO/+34vkmVWpi
         sFCkdLybJw3VJli/F+90FZL/zi9bRL0k9TUmlDKsYJRqZAqE01a9Tg1YJpR1F0PftUxN
         M+41H/0tlQxfeHqgWydPr9h/U5dL9BlPlnf7Wu0hyBX7cKH8R0pNZG8PqBekZo5mc+QT
         5mADLQ6r+yZ7niKtR/NuX1m0s5NdS/03oJbJgQzYUtoICo0YDdIyixUOQFXEwRSS4YGG
         RQI+3pc7TZeCK0cxvezhqWwv3yQPQVHcHu7y3DPfatR5KT843im6tpgPU3Aj18cYmf+1
         niug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=3CAYcQSK5slfPWqZ7uarhOjxrFvQq+s+S9dj1KY74t8=;
        b=mjZl/HgN/CqZk3REHJUhc6A4kV8tI97nC6B6dIP3v9SXKKLW3zWwlnge1U51FDlL/Z
         Mex/iesjld4p2bx+eASUc5zPXniFQvu6C0N67y4h8qtGRlZD/NY6zN+rIm1s8ETnCV3t
         Uqh3rvKCOdTo48kI8M3SmY4V0XHZ9ScKzdVnVBbzvjPMGw+YaYRhHSNepK/dqtj39mPE
         2LHmv1AREIM90h7GoVuW8a/vx2d6UBVXRc1WVtDeJYKX4I9o7LzE/aT1qJhfTDssjzgs
         WC5frK7ozGciaplrZnpxSUnvrr2oZsYHZLhIV2goZgGwQ5IBoBGTv2wwpln6JAIOaJBf
         iwyw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: from suse.de (nat.nue.novell.com. [2620:113:80c0:5::2222])
        by mx.google.com with ESMTP id u3si650641edp.137.2019.04.05.05.54.33
        for <linux-mm@kvack.org>;
        Fri, 05 Apr 2019 05:54:34 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) client-ip=2620:113:80c0:5::2222;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning osalvador@suse.de does not designate 2620:113:80c0:5::2222 as permitted sender) smtp.mailfrom=osalvador@suse.de
Received: by suse.de (Postfix, from userid 1000)
	id 1E0A94841; Fri,  5 Apr 2019 14:54:32 +0200 (CEST)
Date: Fri, 5 Apr 2019 14:54:32 +0200
From: Oscar Salvador <osalvador@suse.de>
To: Linxu Fang <fanglinxu@huawei.com>
Cc: akpm@linux-foundation.org, mhocko@suse.com, vbabka@suse.cz,
	pavel.tatashin@microsoft.com, linux-mm@kvack.org
Subject: Re: [PATCH V2] mm: fix node spanned pages when we have a node with
 only zone_movable
Message-ID: <20190405125430.vawudxjcxhbarseg@d104.suse.de>
References: <1554370704-18268-1-git-send-email-fanglinxu@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1554370704-18268-1-git-send-email-fanglinxu@huawei.com>
User-Agent: NeoMutt/20170421 (1.8.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 04, 2019 at 05:38:24PM +0800, Linxu Fang wrote:
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

Uhmf, I have to confess that this whole thing about kernelcore and movablecore
makes me head spin.

I agree that clamping the range to the node's start_pfn/end_pfn is the right
thing to do.

On the other hand, I cannot figure out why these two statements from
zone_spanned_pages_in_node() do not help in setting the right values.

*zone_end_pfn = min(*zone_end_pfn, node_end_pfn);
*zone_start_pfn = max(*zone_start_pfn, node_start_pfn);

If I take one of your examples:

Node 0:
node_start_pfn=1        node_end_pfn=2822144
DMA      zone_low=1        zone_high=4096
DMA32    zone_low=4096     zone_high=1048576
Normal   zone_low=1048576  zone_high=7942144
Movable  zone_low=0        zone_high=0

*zone_end_pfn should be set to 2822144, and so zone_end_pfn - zone_start_pfn
should return the right value?
Or is it because we have the wrong values before calling
adjust_zone_range_for_zone_movable() and the whole thing gets messed up there?

Please, note that the patch looks correct to me, I just want to understand
why those two statements do not help here.

-- 
Oscar Salvador
SUSE L3


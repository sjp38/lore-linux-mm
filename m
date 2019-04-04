Return-Path: <SRS0=kGB6=SG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CE58FC4360F
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:14:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 69EC6206B7
	for <linux-mm@archiver.kernel.org>; Thu,  4 Apr 2019 19:14:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69EC6206B7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE3496B000E; Thu,  4 Apr 2019 15:14:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A93B06B0266; Thu,  4 Apr 2019 15:14:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 981FD6B0269; Thu,  4 Apr 2019 15:14:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 623166B000E
	for <linux-mm@kvack.org>; Thu,  4 Apr 2019 15:14:32 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id h69so2347730pfd.21
        for <linux-mm@kvack.org>; Thu, 04 Apr 2019 12:14:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NHNRQ+F6GVxR5RIawXqd7WODiGIxiDW7kwRh2xAeMSw=;
        b=NaZrZGUnX1AQoWCUGLnp/2NNidz8CLkLle9hKKL75gaaywldteDyLkNvqPIE5r053X
         EI7frxN9lhAdOYagf0fDkjyuLdF+UvXr2zkqAUgrdRVFklXOg+9bbDmQeGAunl/6r8l8
         4orpQBCkYM1S5qVsywpVFiKoSTFzmnxaFtvMJlWeZd0pzrtB7/OGkGm7OVhLV/6kKbIU
         S2wdd+6M1lawdSXwq+v8EnJcP9qCsv/D8MtAWgp8tYYwyevFXjmlux4FdwZkalW3nkhq
         Hk6CY/r7FielU9UDkEMUBRMkTuhHlykoJ4QJ4rTWgV7RQPMQm066MqzkUJ3I7RIpQMgD
         Ya1w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
X-Gm-Message-State: APjAAAXtaX9eSdgHSo/qPDIxpB1hQr1My7dmR935WTufP9YhXkCiPgWG
	UwSnqcUok5KZCwCBZEYgurLkHp5q5fWpt4DPkNPEkiG3y5Mkk2OrVsAJ3K73gdD0uB9B3Z4GEbj
	Klfp/h97d0VlODY2S0exh5n6fJgIDZz4hWMvEiUnIDV4DxT4J5PHZriN5MjSP9EIyUg==
X-Received: by 2002:a63:ce50:: with SMTP id r16mr4554349pgi.89.1554405271956;
        Thu, 04 Apr 2019 12:14:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwA5VN/zZSldtWZCGBMIWNNqDV5JFzI6EpFnhm+nimPtzk3h9HWxT2Wx15y+9+K3jzN1VQ7
X-Received: by 2002:a63:ce50:: with SMTP id r16mr4554268pgi.89.1554405271048;
        Thu, 04 Apr 2019 12:14:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554405271; cv=none;
        d=google.com; s=arc-20160816;
        b=Oj59gsopjxHQ0h6eZe5ChhilWGMQIO2Czvf7o4XHj5QVgCquMqTki1NwxNr48Mxk7L
         chql4SBtKUHBJ5CnwV0MSyF/4cCEbEMZnoGUtQW67k6Mpy1vBOukSdyXCCTjGj639X4G
         cZMNkQkmlYiQW+krRBDr1cV/YgFp9NzyPltcULACkKefcnEFDKCaBUA7qo78MKjXLu1L
         CiMSJUNalHVvjs3zK3qbHAGwvGI+s60u8htd8opx+m+uGRzv+YZ6jLM0U+QBYvdbDSDM
         DztueM2HYOidU5t6tbd6RqgkAvf+1BPOoCRw1H43MWkbhnPovM2obrFqJaEVqaj20JUR
         MbTw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date;
        bh=NHNRQ+F6GVxR5RIawXqd7WODiGIxiDW7kwRh2xAeMSw=;
        b=qMqCVzhiYYPdtvmumdIXbdBKXNMWlch/wNv9/8xggdVA9yf7A/MHU7XHUuOaAe+jxb
         8N6axO5TPCYADbqvv5iWku0gTavAhjfs6p8YHdM/Fu0vxRd3SdcM7ligB9u+flmHpV2w
         4NocrYWWUHktDX7jz6D8nnA6VlOespYEsNQ43EDyUjX02/JsdYigOsGYmZfFCbLcwvLF
         AyIQaoDZ9WIFkm0iGBFsGv08swLYcNqG4rypwjVmu3mBk0S0aKzzkehYWFoKjWnn0Ur4
         eBJed173ve75zizR41PTpvltepesAlAe9q7lIedqdr7VJ7McvD7musz2VG+r/BczvYb6
         oD0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z8si16562763pgu.217.2019.04.04.12.14.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Apr 2019 12:14:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) client-ip=140.211.169.12;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 140.211.169.12 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	by mail.linuxfoundation.org (Postfix) with ESMTPSA id 141DF1DFF;
	Thu,  4 Apr 2019 19:14:30 +0000 (UTC)
Date: Thu, 4 Apr 2019 12:14:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Linxu Fang <fanglinxu@huawei.com>
Cc: <mhocko@suse.com>, <vbabka@suse.cz>, <pavel.tatashin@microsoft.com>,
 <osalvador@suse.de>, <linux-mm@kvack.org>
Subject: Re: [PATCH V2] mm: fix node spanned pages when we have a node with
 only zone_movable
Message-Id: <20190404121427.0959934dbce398b242b6e67e@linux-foundation.org>
In-Reply-To: <1554370704-18268-1-git-send-email-fanglinxu@huawei.com>
References: <1554370704-18268-1-git-send-email-fanglinxu@huawei.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 4 Apr 2019 17:38:24 +0800 Linxu Fang <fanglinxu@huawei.com> wrote:

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

How does this differ from the previous version you sent?


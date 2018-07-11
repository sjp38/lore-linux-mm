Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id C54A46B026B
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 06:49:48 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id b185-v6so30689121qkg.19
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 03:49:48 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id j23-v6si18580514qtj.7.2018.07.11.03.49.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 03:49:48 -0700 (PDT)
Date: Wed, 11 Jul 2018 18:49:44 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180711104944.GG1969@MiWiFi-R3L-srv>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711104158.GE2070@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Fan <fanc.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, douly.fnst@cn.fujitsu.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net

On 07/11/18 at 06:41pm, Baoquan He wrote:
 
> Hmm, it's an issue, worth fixing it. Otherwise the size of
> movable area will be smaller than we expect when add "kernel_core="
> or "movable_core=".
> 
> Add a check in find_zone_movable_pfns_for_nodes(), and use min() to get
> the starting address of movable area between aligned '_etext'
> and start_pfn. It will go to label 'restart' to calculate the 2nd round
> if not satisfiled. 
> 
> Hi Chao,
> 
> Could you check if below patch works for you?
> 
> 
> From ab6e47c6a78d1a4ccb577b995b7b386f3149732f Mon Sep 17 00:00:00 2001
> From: Baoquan He <bhe@redhat.com>
> Date: Wed, 11 Jul 2018 18:30:04 +0800
> Subject: [PATCH] mm, page_alloc: find movable zone after kernel text
> 
> In find_zone_movable_pfns_for_nodes(), when try to find the starting
> PFN movable zone begins in each node, kernel text position is not
> considered. KASLR may put kernel after which movable zone begins.
> 
> Fix it by finding movable zone after kernel text.
> 
> Signed-off-by: Baoquan He <bhe@redhat.com>
> ---
>  mm/page_alloc.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 1521100..fe346b4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6678,6 +6678,8 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  			unsigned long size_pages;
>  
>  			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
> +			/* KASLR may put kernel after 'start_pfn', start after kernel */
> +			start_pfn = max(start_pfn, PAGE_ALIGN(_etext));

Sorry, I used wrong function.

Please try this one:

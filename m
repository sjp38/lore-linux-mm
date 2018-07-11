Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5057B6B026E
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 08:42:01 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d25-v6so26612932qtp.10
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 05:42:01 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s5-v6si999748qki.111.2018.07.11.05.42.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 05:42:00 -0700 (PDT)
Date: Wed, 11 Jul 2018 20:41:55 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: Bug report about KASLR and ZONE_MOVABLE
Message-ID: <20180711124155.GH1969@MiWiFi-R3L-srv>
References: <20180711094244.GA2019@localhost.localdomain>
 <20180711104158.GE2070@MiWiFi-R3L-srv>
 <20180711104944.GG1969@MiWiFi-R3L-srv>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180711104944.GG1969@MiWiFi-R3L-srv>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chao Fan <fanc.fnst@cn.fujitsu.com>, akpm@linux-foundation.org, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, x86@kernel.org, yasu.isimatu@gmail.com, keescook@chromium.org, indou.takao@jp.fujitsu.com, caoj.fnst@cn.fujitsu.com, douly.fnst@cn.fujitsu.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net

On 07/11/18 at 06:49pm, Baoquan He wrote:
> On 07/11/18 at 06:41pm, Baoquan He wrote:
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 1521100..fe346b4 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -6678,6 +6678,8 @@ static void __init find_zone_movable_pfns_for_nodes(void)
> >  			unsigned long size_pages;
> >  
> >  			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
> > +			/* KASLR may put kernel after 'start_pfn', start after kernel */
> > +			start_pfn = max(start_pfn, PAGE_ALIGN(_etext));
> 
> Sorry, I used wrong function.
> 
> Please try this one:
> 
> From 005435407a331ecf2803e5ebfdc44b8f5f8f9748 Mon Sep 17 00:00:00 2001
> From: Baoquan He <bhe@redhat.com>
> Date: Wed, 11 Jul 2018 18:30:04 +0800
> Subject: [PATCH v2] mm, page_alloc: find movable zone after kernel text
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
> index 1521100..17584cc 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -6678,6 +6678,8 @@ static void __init find_zone_movable_pfns_for_nodes(void)
>  			unsigned long size_pages;
>  
>  			start_pfn = max(start_pfn, zone_movable_pfn[nid]);
> +			/* KASLR may put kernel after 'start_pfn', start after kernel */
> +			start_pfn = max(start_pfn, PFN_UP(_etext));

It's wrong again, NACK, have posted v3 in this thread.

>  			if (start_pfn >= end_pfn)
>  				continue;
>  
> -- 
> 2.1.0
> 

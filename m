Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 56DAC6B0007
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:14:16 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so1591177pfn.13
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:14:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id l21-v6si5148299pfk.321.2018.06.27.14.14.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 14:14:14 -0700 (PDT)
Date: Wed, 27 Jun 2018 14:14:12 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Message-Id: <20180627141412.00c0b23d2eb5f9475a76d833@linux-foundation.org>
In-Reply-To: <e0f4426d-1b7c-e590-aae0-e8f7ae3bb948@suse.cz>
References: <20180622162841.25114-1-mhocko@kernel.org>
	<6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
	<20180626100416.a3ff53f5c4aac9fae954e3f6@linux-foundation.org>
	<20180627073420.GD32348@dhcp22.suse.cz>
	<e0f4426d-1b7c-e590-aae0-e8f7ae3bb948@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed, 27 Jun 2018 09:50:01 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> On 06/27/2018 09:34 AM, Michal Hocko wrote:
> > On Tue 26-06-18 10:04:16, Andrew Morton wrote:
> > 
> > And as I've argued before the code would be wrong regardless. We would
> > leak the memory or worse touch somebody's else kmap without knowing
> > that.  So we have a choice between a mem leak, data corruption k or a
> > silent fixup. I would prefer the last option. And blowing up on a BUG
> > is not much better on something that is easily fixable. I am not really
> > convinced that & ~__GFP_HIGHMEM is something to lose sleep over.
> 
> Maybe put the fixup into a "#ifdef CONFIG_HIGHMEM" block and then modern
> systems won't care? In that case it could even be if (WARN_ON_ONCE(...))
> so future cases with wrong expectations would become known.
> 

The more I think about it, the more I like the VM_BUG_ON.

Look, if I was reviewing code which did

	page = alloc_page(__GFP_HIGHMEM);
	addr = page_to_virt(page);

I would say "that's a bug, you forgot to kmap the page".

And any code which does __get_free_pages(__GFP_HIGHMEM) is just as
buggy: it's requesting the virtual address of a high page without
having kmapped it.  Core MM shouldn't be silently kludging around the
bug by restricting the caller to using lowmem pages.

Maybe the caller really does want to use highmem, in which case the caller
should be using alloc_page(__GFP_HIGHMEM) and kmap().  Because core MM
detects and reports this bug, the developer will fix it.

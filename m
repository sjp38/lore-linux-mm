Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 296966B0006
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 17:24:26 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y13-v6so1582584edq.2
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 14:24:26 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w14-v6si2722330edf.73.2018.06.27.14.24.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 14:24:24 -0700 (PDT)
Date: Wed, 27 Jun 2018 23:24:21 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Message-ID: <20180627212421.GY32348@dhcp22.suse.cz>
References: <20180622162841.25114-1-mhocko@kernel.org>
 <6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
 <20180626100416.a3ff53f5c4aac9fae954e3f6@linux-foundation.org>
 <20180627073420.GD32348@dhcp22.suse.cz>
 <e0f4426d-1b7c-e590-aae0-e8f7ae3bb948@suse.cz>
 <20180627141412.00c0b23d2eb5f9475a76d833@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627141412.00c0b23d2eb5f9475a76d833@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed 27-06-18 14:14:12, Andrew Morton wrote:
> On Wed, 27 Jun 2018 09:50:01 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
> 
> > On 06/27/2018 09:34 AM, Michal Hocko wrote:
> > > On Tue 26-06-18 10:04:16, Andrew Morton wrote:
> > > 
> > > And as I've argued before the code would be wrong regardless. We would
> > > leak the memory or worse touch somebody's else kmap without knowing
> > > that.  So we have a choice between a mem leak, data corruption k or a
> > > silent fixup. I would prefer the last option. And blowing up on a BUG
> > > is not much better on something that is easily fixable. I am not really
> > > convinced that & ~__GFP_HIGHMEM is something to lose sleep over.
> > 
> > Maybe put the fixup into a "#ifdef CONFIG_HIGHMEM" block and then modern
> > systems won't care? In that case it could even be if (WARN_ON_ONCE(...))
> > so future cases with wrong expectations would become known.
> > 
> 
> The more I think about it, the more I like the VM_BUG_ON.
> 
> Look, if I was reviewing code which did
> 
> 	page = alloc_page(__GFP_HIGHMEM);
> 	addr = page_to_virt(page);
> 
> I would say "that's a bug, you forgot to kmap the page".
> 
> And any code which does __get_free_pages(__GFP_HIGHMEM) is just as
> buggy: it's requesting the virtual address of a high page without
> having kmapped it.  Core MM shouldn't be silently kludging around the
> bug by restricting the caller to using lowmem pages.

I would argue that internal kernel APIs should trust their callers.
Panicing with an unknown context is about the worst way to teach
developers how to use the API properly. Because it will be end users
seeing an outage. So I would simply not care beyond documenting the
expectation. If we want to be more careful then fix it up. If you
disagree then just drop the patch. I do not insist so much to spend much
more time on something I thought was quite obvious. BUG_ON for an inpropoer
API usage is considered harmful for quite a long time by now. I do not
see why this would be any different.

-- 
Michal Hocko
SUSE Labs

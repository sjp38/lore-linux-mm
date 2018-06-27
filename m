Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1AEF26B0010
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:39:39 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c8-v6so1056071edr.16
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 00:39:39 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f56-v6si1769451edf.435.2018.06.27.00.39.37
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 27 Jun 2018 00:39:38 -0700 (PDT)
Date: Wed, 27 Jun 2018 09:39:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: drop VM_BUG_ON from __get_free_pages
Message-ID: <20180627073936.GE32348@dhcp22.suse.cz>
References: <20180622162841.25114-1-mhocko@kernel.org>
 <6886dee0-3ac4-ef5d-3597-073196c81d88@suse.cz>
 <20180626100416.a3ff53f5c4aac9fae954e3f6@linux-foundation.org>
 <20180627073420.GD32348@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180627073420.GD32348@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, JianKang Chen <chenjiankang1@huawei.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, xieyisheng1@huawei.com, guohanjun@huawei.com, wangkefeng.wang@huawei.com

On Wed 27-06-18 09:34:20, Michal Hocko wrote:
> On Tue 26-06-18 10:04:16, Andrew Morton wrote:
[...]
> > Really, the changelog isn't right.  There *is* a real reason to blow
> > up.  Effectively the caller is attempting to obtain the virtual address
> > of a highmem page without having kmapped it first.  That's an outright
> > bug.
> 
> And as I've argued before the code would be wrong regardless. We would
> leak the memory or worse touch somebody's else kmap without knowing
> that.  So we have a choice between a mem leak, data corruption k or a
> silent fixup. I would prefer the last option. And blowing up on a BUG
> is not much better on something that is easily fixable. I am not really
> convinced that & ~__GFP_HIGHMEM is something to lose sleep over.

It's been some time since I've checked that changelog and you are right
it should contain all the above so the changelog should be:

"
There is no real reason to blow up just because the caller doesn't know
that __get_free_pages cannot return highmem pages. Simply fix that up
silently. Even if we have some confused users such a fixup will not be
harmful.

On the other hand an incorrect usage can lead to either a memory leak
or worse a memory corruption when the allocated page hashes to an
already kmaped page. Most workloads run with CONFIG_DEBUG_VM disabled so
the assert wouldn't help.
"
-- 
Michal Hocko
SUSE Labs

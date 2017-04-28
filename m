Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5EFBE6B02F4
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 03:45:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d79so2696393wmi.8
        for <linux-mm@kvack.org>; Fri, 28 Apr 2017 00:45:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h27si5458763wrb.1.2017.04.28.00.45.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Apr 2017 00:45:55 -0700 (PDT)
Date: Fri, 28 Apr 2017 09:45:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: RFC: post-init-read-only protection for data allocated
 dynamically
Message-ID: <20170428074540.GB9399@dhcp22.suse.cz>
References: <3eba3df7-6694-5c47-48f4-30088845035b@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3eba3df7-6694-5c47-48f4-30088845035b@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: linux-mm@kvack.org

On Fri 21-04-17 11:30:04, Igor Stoppa wrote:
> Hello,
> 
> I am looking for a mechanism to protect the kernel data which is allocated
> dynamically during system initialization and is later-on accessed only for
> reads.
> 
> The functionality would be, in spirit, like the __read_only modifier, which
> can be used to mark static data as read-only, in the post-init phase. Only,
> it would apply to dynamically allocated data.
> 
> I couldn't find any such feature (did I miss it?), so I started looking at
> what could be the best way to introduce it.
> 
> The static post-init write protection is achieved by placing all the data
> into a page-aligned segment and then protecting the page from writes, using
> the MMU, once the data is in its final state.
> 
> In my case, as example, I want to protect the SE Linux policy database,
> after the set of policy has been loaded from file.
> SE Linux uses fairly complex data structures, which are allocated
> dynamically, depending on what rules/policy are loaded into it.
> 
> If I knew upfront, roughly, which sizes will be requested and how many
> requests will happen, for each size, I could use multiple pools of objects.
> However, I cannot assume upfront to know these parameters, because it's very
> likely that the set of policies & rules will evolve.
> 
> I would also like to extend the write protection to other data structures,
> which means I would probably end up writing another memory allocator, if I
> started to generate on-demand object pools.

What is the expected life time of those objects? Are they ever freed? If
yes are they freed at once or some might outlive others?

> The alternative I'm considering is that, if I were to add a new memory zone
> (let's call it LOCKABLE), I could piggy back on the existing infrastructure
> for memory allocation.

No, please no new memory zones! This doesn't look like a good fit
anyway. I believe you need an allocator on top of the page allocator
which manages kernel page tables on top of pools of pages. You really do
not care about where the page is placed physically. I am not sure how
much you can reuse from the SL.B object management because that highly
depends on the life time of objects.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

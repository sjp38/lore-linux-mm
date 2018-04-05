Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BADC56B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 11:32:45 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k44so13790613wrc.3
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:32:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k9si5713352wrk.429.2018.04.05.08.32.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Apr 2018 08:32:44 -0700 (PDT)
Date: Thu, 5 Apr 2018 17:32:40 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405153240.GO6312@dhcp22.suse.cz>
References: <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
 <20180404062340.GD6312@dhcp22.suse.cz>
 <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
 <20180405142749.GL6312@dhcp22.suse.cz>
 <20180405151359.GB28128@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405151359.GB28128@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Joel Fernandes <joelaf@google.com>, Steven Rostedt <rostedt@goodmis.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu 05-04-18 08:13:59, Matthew Wilcox wrote:
> On Thu, Apr 05, 2018 at 04:27:49PM +0200, Michal Hocko wrote:
> > On Thu 05-04-18 07:22:58, Matthew Wilcox wrote:
> > > On Wed, Apr 04, 2018 at 09:12:52PM -0700, Joel Fernandes wrote:
> > > > On Wed, Apr 4, 2018 at 7:58 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > > > > I still don't get why you want RETRY_MAYFAIL.  You know that tries
> > > > > *harder* to allocate memory than plain GFP_KERNEL does, right?  And
> > > > > that seems like the exact opposite of what you want.
> 
> Argh.  The comment confused me.  OK, now I've read the source and
> understand that GFP_KERNEL | __GFP_RETRY_MAYFAIL tries exactly as hard
> as GFP_KERNEL *except* that it won't cause OOM itself.  But any other
> simultaneous GFP_KERNEL allocation without __GFP_RETRY_MAYFAIL will
> cause an OOM.  (And that's why we're having a conversation)

Well, I can udnerstand how this can be confusing. The all confusion
boils down to the small-never-fails semantic we have. So all reclaim
modificators (__GFP_NOFAIL, __GFP_RETRY_MAYFAIL, __GFP_NORETRY) only
modify the _default_ behavior.

> That's a problem because we have places in the kernel that call
> kv[zm]alloc(very_large_size, GFP_KERNEL), and that will turn into vmalloc,
> which will do the exact same thing, only it will trigger OOM all by itself
> (assuming the largest free chunk of address space in the vmalloc area
> is larger than the amount of free memory).

well, hardcoded GFP_KERNEL from vmalloc guts is yet another, ehm,
herritage that you are not so proud of.
 
> I considered an alloc_page_array(), but that doesn't fit well with the
> design of the ring buffer code.  We could have:
> 
> struct page *alloc_page_list_node(int nid, gfp_t gfp_mask, unsigned long nr);
> 
> and link the allocated pages together through page->lru.
> 
> We could also have a GFP flag that says to only succeed if we're further
> above the existing watermark than normal.  __GFP_LOW (==ALLOC_LOW),
> if you like.  That would give us the desired behaviour of trying all of
> the reclaim methods that GFP_KERNEL would, but not being able to exhaust
> all the memory that GFP_KERNEL allocations would take.

Well, I would be really careful with yet another gfp mask. They are so
incredibly hard to define properly and then people kinda tend to screw
your best intentions with their usecases ;)
Failing on low wmark is very close to __GFP_NORETRY or even
__GFP_NOWAIT, btw. So let's try to not overthink this...
-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E827E6B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 11:14:04 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 91-v6so6498939plf.6
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 08:14:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u12-v6si5697557plz.287.2018.04.05.08.14.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 08:14:03 -0700 (PDT)
Date: Thu, 5 Apr 2018 08:13:59 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405151359.GB28128@bombadil.infradead.org>
References: <20180403135607.GC5501@dhcp22.suse.cz>
 <CAGWkznH-yfAu=fMo1YWU9zo-DomHY8YP=rw447rUTgzvVH4RpQ@mail.gmail.com>
 <20180404062340.GD6312@dhcp22.suse.cz>
 <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
 <20180405142749.GL6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405142749.GL6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joel Fernandes <joelaf@google.com>, Steven Rostedt <rostedt@goodmis.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 05, 2018 at 04:27:49PM +0200, Michal Hocko wrote:
> On Thu 05-04-18 07:22:58, Matthew Wilcox wrote:
> > On Wed, Apr 04, 2018 at 09:12:52PM -0700, Joel Fernandes wrote:
> > > On Wed, Apr 4, 2018 at 7:58 PM, Matthew Wilcox <willy@infradead.org> wrote:
> > > > I still don't get why you want RETRY_MAYFAIL.  You know that tries
> > > > *harder* to allocate memory than plain GFP_KERNEL does, right?  And
> > > > that seems like the exact opposite of what you want.

Argh.  The comment confused me.  OK, now I've read the source and
understand that GFP_KERNEL | __GFP_RETRY_MAYFAIL tries exactly as hard
as GFP_KERNEL *except* that it won't cause OOM itself.  But any other
simultaneous GFP_KERNEL allocation without __GFP_RETRY_MAYFAIL will
cause an OOM.  (And that's why we're having a conversation)

That's a problem because we have places in the kernel that call
kv[zm]alloc(very_large_size, GFP_KERNEL), and that will turn into vmalloc,
which will do the exact same thing, only it will trigger OOM all by itself
(assuming the largest free chunk of address space in the vmalloc area
is larger than the amount of free memory).

I considered an alloc_page_array(), but that doesn't fit well with the
design of the ring buffer code.  We could have:

struct page *alloc_page_list_node(int nid, gfp_t gfp_mask, unsigned long nr);

and link the allocated pages together through page->lru.

We could also have a GFP flag that says to only succeed if we're further
above the existing watermark than normal.  __GFP_LOW (==ALLOC_LOW),
if you like.  That would give us the desired behaviour of trying all of
the reclaim methods that GFP_KERNEL would, but not being able to exhaust
all the memory that GFP_KERNEL allocations would take.

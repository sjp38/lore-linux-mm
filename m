Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C46796B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 12:15:09 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so19677821plf.1
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 09:15:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a12-v6si6908514plt.606.2018.04.05.09.15.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Apr 2018 09:15:08 -0700 (PDT)
Date: Thu, 5 Apr 2018 09:15:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v1] kernel/trace:check the val against the available mem
Message-ID: <20180405161501.GD28128@bombadil.infradead.org>
References: <20180404062340.GD6312@dhcp22.suse.cz>
 <20180404101149.08f6f881@gandalf.local.home>
 <20180404142329.GI6312@dhcp22.suse.cz>
 <20180404114730.65118279@gandalf.local.home>
 <20180405025841.GA9301@bombadil.infradead.org>
 <CAJWu+oqP64QzvPM6iHtzowek6s4p+3rb7WDXs1z51mwW-9mLbA@mail.gmail.com>
 <20180405142258.GA28128@bombadil.infradead.org>
 <20180405142749.GL6312@dhcp22.suse.cz>
 <20180405151359.GB28128@bombadil.infradead.org>
 <20180405153240.GO6312@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180405153240.GO6312@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Joel Fernandes <joelaf@google.com>, Steven Rostedt <rostedt@goodmis.org>, Zhaoyang Huang <huangzhaoyang@gmail.com>, Ingo Molnar <mingo@kernel.org>, LKML <linux-kernel@vger.kernel.org>, kernel-patch-test@lists.linaro.org, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>

On Thu, Apr 05, 2018 at 05:32:40PM +0200, Michal Hocko wrote:
> On Thu 05-04-18 08:13:59, Matthew Wilcox wrote:
> > Argh.  The comment confused me.  OK, now I've read the source and
> > understand that GFP_KERNEL | __GFP_RETRY_MAYFAIL tries exactly as hard
> > as GFP_KERNEL *except* that it won't cause OOM itself.  But any other
> > simultaneous GFP_KERNEL allocation without __GFP_RETRY_MAYFAIL will
> > cause an OOM.  (And that's why we're having a conversation)
> 
> Well, I can udnerstand how this can be confusing. The all confusion
> boils down to the small-never-fails semantic we have. So all reclaim
> modificators (__GFP_NOFAIL, __GFP_RETRY_MAYFAIL, __GFP_NORETRY) only
> modify the _default_ behavior.

Now that I understand the flag, I'll try to write a more clear
explanation.

> > That's a problem because we have places in the kernel that call
> > kv[zm]alloc(very_large_size, GFP_KERNEL), and that will turn into vmalloc,
> > which will do the exact same thing, only it will trigger OOM all by itself
> > (assuming the largest free chunk of address space in the vmalloc area
> > is larger than the amount of free memory).
> 
> well, hardcoded GFP_KERNEL from vmalloc guts is yet another, ehm,
> herritage that you are not so proud of.

Certainly not, but that's not what I'm concerned about; I'm concerned
about the allocation of the pages, not the allocation of the array
containing the page pointers.

> > We could also have a GFP flag that says to only succeed if we're further
> > above the existing watermark than normal.  __GFP_LOW (==ALLOC_LOW),
> > if you like.  That would give us the desired behaviour of trying all of
> > the reclaim methods that GFP_KERNEL would, but not being able to exhaust
> > all the memory that GFP_KERNEL allocations would take.
> 
> Well, I would be really careful with yet another gfp mask. They are so
> incredibly hard to define properly and then people kinda tend to screw
> your best intentions with their usecases ;)
> Failing on low wmark is very close to __GFP_NORETRY or even
> __GFP_NOWAIT, btw. So let's try to not overthink this...

Oh, indeed.  We must be able to clearly communicate to users when they
should use this flag.  I have in mind something like this:

 * __GFP_HIGH indicates that the caller is high-priority and that granting
 *   the request is necessary before the system can make forward progress.
 *   For example, creating an IO context to clean pages.
 *
 * __GFP_LOW indicates that the caller is low-priority and that it should
 *   not be allocated pages that would cause the system to get into an
 *   out-of-memory situation.  For example, allocating multiple individual
 *   pages in order to satisfy a larger request.

I think this should actually replace __GFP_RETRY_MAYFAIL.  It makes sense
to a user: "This is a low priority GFP_KERNEL allocation".  I doubt there's
one kernel hacker in a hundred who could explain what GFP_RETRY_MAYFAIL
does, exactly, and I'm not just saying that because I got it wrong ;-)

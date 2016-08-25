Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 690B76B026B
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:32:10 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 1so27913862wmz.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:32:10 -0700 (PDT)
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com. [74.125.82.47])
        by mx.google.com with ESMTPS id v20si12511987wju.50.2016.08.25.00.32.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 00:32:09 -0700 (PDT)
Received: by mail-wm0-f47.google.com with SMTP id o80so57496826wme.1
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 00:32:09 -0700 (PDT)
Date: Thu, 25 Aug 2016 09:32:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: what is the purpose of SLAB and SLUB
Message-ID: <20160825073207.GE4230@dhcp22.suse.cz>
References: <1471458050-29622-1-git-send-email-aruna.ramakrishna@oracle.com>
 <20160818115218.GJ30162@dhcp22.suse.cz>
 <20160823021303.GB17039@js1304-P5Q-DELUXE>
 <20160823153807.GN23577@dhcp22.suse.cz>
 <8760qr8orh.fsf@tassilo.jf.intel.com>
 <alpine.DEB.2.20.1608242302290.1837@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1608242302290.1837@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Aruna Ramakrishna <aruna.ramakrishna@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Jiri Slaby <jslaby@suse.cz>

On Wed 24-08-16 23:10:03, Christoph Lameter wrote:
> On Tue, 23 Aug 2016, Andi Kleen wrote:
> 
> > Why would you stop someone from working on SLAB if they want to?
> >
> > Forcibly enforcing a freeze on something can make sense if you're
> > in charge of a team to conserve resources, but in Linux the situation is
> > very different.
> 
> I agree and frankly having multiple allocators is something good.
> Features that are good in one are copied to the other and enhanced in the
> process. I think this has driven code development quite a bit.
> 
> Every allocator has a different basic approach to storage layout and
> synchronization which determines performance in various usage scenarios.
> The competition of seeing if the developer that is a fan of one can come
> up with a way to make performance better or storage use more effective in
> a situation where another shows better numbers is good.

I can completely see how having multiple allocators (schedulers etc...)
can be good as a playground. But how are users supposed to chose when
we do not help them with any documentation. Most benchmarks which are
referred to (e.g. SLUB doesn't work so well with the networking
workloads) might be really outdated and that just feeds the cargo cult.
Look, I am not suggesting removing SLAB (or SLUB) I am just really
looking to understand for their objectives and which users they target. 
Because as of now, most users are using whatever is the default (SLUB
for some and never documented reason) or what their distributions come
up with. This means that we have quite a lot of code which only few
people understand deeply. Some features which are added on top need much
more testing to cover both allocators or we are risking subtle
regressions.

> There may be more creative ways of coming up with new ways of laying out
> storage in the future and I would like to have the flexibility in the
> kernel to explore those if necessary with additional variations.

Flexibility is always good but there comes a maintenance burden. Both
should be weighed properly.

> The more common code we can isolate the easier it will become to just try
> out a new layout and a new form of serialization to see if it provides
> advantages.

Sure, but even after attempts to make some code common we are still at
$ wc -l mm/slab.c mm/slub.c 
	4479 mm/slab.c
	5727 mm/slub.c
	10206 total

quite a lot, don't you think?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

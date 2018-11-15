Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id BA8836B0006
	for <linux-mm@kvack.org>; Thu, 15 Nov 2018 03:10:12 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c53so876593edc.9
        for <linux-mm@kvack.org>; Thu, 15 Nov 2018 00:10:12 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j35si3254835ede.153.2018.11.15.00.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Nov 2018 00:10:11 -0800 (PST)
Date: Thu, 15 Nov 2018 09:10:06 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [mm PATCH v5 0/7] Deferred page init improvements
Message-ID: <20181115081006.GC23831@dhcp22.suse.cz>
References: <154145268025.30046.11742652345962594283.stgit@ahduyck-desk1.jf.intel.com>
 <20181114150742.GZ23419@dhcp22.suse.cz>
 <9e8218eb-80bf-fc02-ae56-42ccfddb572e@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9e8218eb-80bf-fc02-ae56-42ccfddb572e@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Duyck <alexander.h.duyck@linux.intel.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org, linux-nvdimm@lists.01.org, davem@davemloft.net, pavel.tatashin@microsoft.com, mingo@kernel.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, dave.jiang@intel.com, rppt@linux.vnet.ibm.com, willy@infradead.org, vbabka@suse.cz, khalid.aziz@oracle.com, ldufour@linux.vnet.ibm.com, mgorman@techsingularity.net, yi.z.zhang@linux.intel.com

On Wed 14-11-18 16:50:23, Alexander Duyck wrote:
> 
> 
> On 11/14/2018 7:07 AM, Michal Hocko wrote:
> > On Mon 05-11-18 13:19:25, Alexander Duyck wrote:
> > > This patchset is essentially a refactor of the page initialization logic
> > > that is meant to provide for better code reuse while providing a
> > > significant improvement in deferred page initialization performance.
> > > 
> > > In my testing on an x86_64 system with 384GB of RAM and 3TB of persistent
> > > memory per node I have seen the following. In the case of regular memory
> > > initialization the deferred init time was decreased from 3.75s to 1.06s on
> > > average. For the persistent memory the initialization time dropped from
> > > 24.17s to 19.12s on average. This amounts to a 253% improvement for the
> > > deferred memory initialization performance, and a 26% improvement in the
> > > persistent memory initialization performance.
> > > 
> > > I have called out the improvement observed with each patch.
> > 
> > I have only glanced through the code (there is a lot of the code to look
> > at here). And I do not like the code duplication and the way how you
> > make the hotplug special. There shouldn't be any real reason for that
> > IMHO (e.g. why do we init pfn-at-a-time in early init while we do
> > pageblock-at-a-time for hotplug). I might be wrong here and the code
> > reuse might be really hard to achieve though.
> 
> Actually it isn't so much that hotplug is special. The issue is more that
> the non-hotplug case is special in that you have to perform a number of
> extra checks for things that just aren't necessary for the hotplug case.

Can we hide those behind a helper (potentially with a jump label if
necessary) and still share a large part of the code? Also this code is
quite old and maybe we are overzealous with the early checks. Do we
really need them. Why should be early boot memory any different from the
hotplug. The only exception I can see should really be deferred
initialization check.

> If anything I would probably need a new iterator that would be able to take
> into account all the checks for the non-hotplug case and then provide ranges
> of PFNs to initialize.
> 
> > I am also not impressed by new iterators because this api is quite
> > complex already. But this is mostly a detail.
> 
> Yeah, the iterators were mostly an attempt at hiding some of the complexity.
> Being able to break a loop down to just an iterator provding the start of
> the range and the number of elements to initialize is pretty easy to
> visualize, or at least I thought so.

I am not against hiding the complexity. I am mostly concerned that we
have too many of those iterators. Maybe we can reuse existing ones in
some way. If that is not really possible or it would make even more mess
then fair enough and go with new ones.

> > Thing I do not like is that you keep microptimizing PageReserved part
> > while there shouldn't be anything fundamental about it. We should just
> > remove it rather than make the code more complex. I fell more and more
> > guilty to add there actually.
> 
> I plan to remove it, but don't think I can get to it in this patch set.

What I am trying to argue is that we should simply drop the
__SetPageReserved as an independent patch prior to this whole series.
As I've mentioned earlier, I have added this just to be sure and part of
that was that __add_section has set the reserved bit. This is no longer
the case since d0dc12e86b31 ("mm/memory_hotplug: optimize memory
hotplug").

Nobody should really depend on that because struct pages are in
undefined state after __add_pages and they should get fully initialized
after move_pfn_range_to_zone.

If you really insist on setting the reserved bit then it really has to
happen much sooner than it is right now. So I do not really see any
point in doing so. Sure there are some pfn walkers that really need to
do pfn_to_online_page because pfn_valid is not sufficient but that is
largely independent on any optimization work in this area.

I am sorry if I haven't been clear about that before. Does it make more
sense to you now?

P.S.
There is always that tempting thing to follow the existing code and
tweak it for a new purpose. This approach, however, adds more and more
complex code on top of something that might be wrong or stale already.
I have seen that in MM code countless times and I have contributed to
that myself. I am sorry to push back on this so hard but this code is
a mess and any changes to make it more optimal should really make sure
the foundations are solid before. Been there done that, not a huge fun
but that is the price for having basically unmaintained piece of code
that random usecases stop by and do what they need without ever
following up later.
-- 
Michal Hocko
SUSE Labs

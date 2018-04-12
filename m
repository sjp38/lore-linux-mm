Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7515D6B0009
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:46:57 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p12so2985405pfn.13
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:46:57 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k4-v6si3464924pls.4.2018.04.12.07.46.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 07:46:56 -0700 (PDT)
Date: Thu, 12 Apr 2018 16:46:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180412144651.GI23400@dhcp22.suse.cz>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412115217.GC23400@dhcp22.suse.cz>
 <20180412143826.GA30714@castle.DHCP.thefacebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180412143826.GA30714@castle.DHCP.thefacebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Thu 12-04-18 15:38:33, Roman Gushchin wrote:
> On Thu, Apr 12, 2018 at 01:52:17PM +0200, Michal Hocko wrote:
> > On Thu 12-04-18 08:52:52, Vlastimil Babka wrote:
> > > On 04/11/2018 03:56 PM, Roman Gushchin wrote:
> > > > On Wed, Apr 11, 2018 at 03:16:08PM +0200, Vlastimil Babka wrote:
> > [...]
> > > >> With that in mind, can we at least for now put the (manually maintained)
> > > >> byte counter in a variable that's not directly exposed via /proc/vmstat,
> > > >> and then when printing nr_slab_reclaimable, simply add the value
> > > >> (divided by PAGE_SIZE), and when printing nr_slab_unreclaimable,
> > > >> subtract the same value. This way we would be simply making the existing
> > > >> counters more precise, in line with their semantics.
> > > > 
> > > > Idk, I don't like the idea of adding a counter outside of the vm counters
> > > > infrastructure, and I definitely wouldn't touch the exposed
> > > > nr_slab_reclaimable and nr_slab_unreclaimable fields.
> > 
> > Why?
> 
> Both nr_slab_reclaimable and nr_slab_unreclaimable have a very simple
> meaning: they are numbers of pages used by corresponding slab caches.

Right, but if names are reclaimable then they should end up in the
reclaimable slabs and to be accounted as such. Objects themselves are
not sufficient to reclaim the accounted memory.

> In the answer to the very first version of this patchset
> Andrew suggested to generalize the idea to allow further
> accounting of non-kmalloc() allocations.
> I like the idea, even if don't have a good example right now.

Well, I have to disagree here. It sounds completely ad-hoc without
a reasoable semantic. Or how does it help users when they do not know
what is the indirect dependency and how to trigger it.

> The problem with external names existed for many years before
> we've accidentally hit it, so if we don't have other examples
> right now, it doesn't mean that we wouldn't have them in the future.
> 
> > 
> > > We would be just making the reported values more precise wrt reality.
> > 
> > I was suggesting something similar in an earlier discussion. I am not
> > really happy about the new exposed counter either. It is just arbitrary
> > by name yet very specific for this particular usecase.
> > 
> > What is a poor user supposed to do with the new counter? Can this be
> > used for any calculations?
> 
> For me the most important part is to fix the overcommit logic, because it's
> a real security and production issue.

Sure, the problem is ugly. Not the first one when the unaccounted kernel
allocation can eat a lot of memory. We have many other such. The usual
answer was to use kmemcg accounting.

-- 
Michal Hocko
SUSE Labs

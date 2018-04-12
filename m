Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA9896B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:39:18 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id o8so3061933wra.12
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:39:18 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id h2si809869edi.469.2018.04.12.07.39.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 07:39:17 -0700 (PDT)
Date: Thu, 12 Apr 2018 15:38:33 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180412143826.GA30714@castle.DHCP.thefacebook.com>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412115217.GC23400@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180412115217.GC23400@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Thu, Apr 12, 2018 at 01:52:17PM +0200, Michal Hocko wrote:
> On Thu 12-04-18 08:52:52, Vlastimil Babka wrote:
> > On 04/11/2018 03:56 PM, Roman Gushchin wrote:
> > > On Wed, Apr 11, 2018 at 03:16:08PM +0200, Vlastimil Babka wrote:
> [...]
> > >> With that in mind, can we at least for now put the (manually maintained)
> > >> byte counter in a variable that's not directly exposed via /proc/vmstat,
> > >> and then when printing nr_slab_reclaimable, simply add the value
> > >> (divided by PAGE_SIZE), and when printing nr_slab_unreclaimable,
> > >> subtract the same value. This way we would be simply making the existing
> > >> counters more precise, in line with their semantics.
> > > 
> > > Idk, I don't like the idea of adding a counter outside of the vm counters
> > > infrastructure, and I definitely wouldn't touch the exposed
> > > nr_slab_reclaimable and nr_slab_unreclaimable fields.
> 
> Why?

Both nr_slab_reclaimable and nr_slab_unreclaimable have a very simple
meaning: they are numbers of pages used by corresponding slab caches.

In the answer to the very first version of this patchset
Andrew suggested to generalize the idea to allow further
accounting of non-kmalloc() allocations.
I like the idea, even if don't have a good example right now.

The problem with external names existed for many years before
we've accidentally hit it, so if we don't have other examples
right now, it doesn't mean that we wouldn't have them in the future.

> 
> > We would be just making the reported values more precise wrt reality.
> 
> I was suggesting something similar in an earlier discussion. I am not
> really happy about the new exposed counter either. It is just arbitrary
> by name yet very specific for this particular usecase.
> 
> What is a poor user supposed to do with the new counter? Can this be
> used for any calculations?

For me the most important part is to fix the overcommit logic, because it's
a real security and production issue. Adjusting MemAvailable is important too.

I really open here for any concrete suggestions on how to do it without exporting
of a new value, and without adding too much complexity to the code
(e.g. skipping this particular mm counter on printing will be quite messy).

Thanks!

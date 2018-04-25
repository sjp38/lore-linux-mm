Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9BD426B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 13:23:39 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a124so16549914qkb.19
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 10:23:39 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id x35-v6si5744425qtc.158.2018.04.25.10.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 10:23:38 -0700 (PDT)
Date: Wed, 25 Apr 2018 18:23:04 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180425172258.GA8052@castle>
References: <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
 <20180412145702.GB30714@castle.DHCP.thefacebook.com>
 <CAOaiJ-=JtFWNPqdtf+5uim0-LcPE9zSDZmocAa_6K3yGpW2fCQ@mail.gmail.com>
 <69b4dcd8-1925-e0e8-d9b4-776f3405b769@codeaurora.org>
 <20180425125211.GB3410@castle>
 <db71bf8f-0c76-e304-25c3-d22f1e0d71e5@suse.cz>
 <20180425164845.GA7223@castle>
 <7fc2986e-b867-eb32-9124-d10ef6c1a3a3@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <7fc2986e-b867-eb32-9124-d10ef6c1a3a3@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Vijayanand Jitta <vjitta@codeaurora.org>, vinayak menon <vinayakm.list@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Wed, Apr 25, 2018 at 07:02:42PM +0200, Vlastimil Babka wrote:
> On 04/25/2018 06:48 PM, Roman Gushchin wrote:
> > On Wed, Apr 25, 2018 at 05:47:26PM +0200, Vlastimil Babka wrote:
> >> On 04/25/2018 02:52 PM, Roman Gushchin wrote:
> >>> On Wed, Apr 25, 2018 at 09:19:29AM +0530, Vijayanand Jitta wrote:
> >>>>>>>> Idk, I don't like the idea of adding a counter outside of the vm counters
> >>>>>>>> infrastructure, and I definitely wouldn't touch the exposed
> >>>>>>>> nr_slab_reclaimable and nr_slab_unreclaimable fields.
> >>>>>>>
> >>>>>>> We would be just making the reported values more precise wrt reality.
> >>>>>>
> >>>>>> It depends on if we believe that only slab memory can be reclaimable
> >>>>>> or not. If yes, this is true, otherwise not.
> >>>>>>
> >>>>>> My guess is that some drivers (e.g. networking) might have buffers,
> >>>>>> which are reclaimable under mempressure, and are allocated using
> >>>>>> the page allocator. But I have to look closer...
> >>>>>>
> >>>>>
> >>>>> One such case I have encountered is that of the ION page pool. The page pool
> >>>>> registers a shrinker. When not in any memory pressure page pool can go high
> >>>>> and thus cause an mmap to fail when OVERCOMMIT_GUESS is set. I can send
> >>>>> a patch to account ION page pool pages in NR_INDIRECTLY_RECLAIMABLE_BYTES.
> >>
> >> FYI, we have discussed this at LSF/MM and agreed to try the kmalloc
> >> reclaimable caches idea. The existing counter could then remain for page
> >> allocator users such as ION. It's a bit weird to have it in bytes and
> >> not pages then, IMHO. What if we hid it from /proc/vmstat now so it
> >> doesn't become ABI, and later convert it to page granularity and expose
> >> it under a name such as "nr_other_reclaimable" ?
> > 
> > I've nothing against hiding it from /proc/vmstat, as long as we keep
> > the counter in place and the main issue resolved.
> 
> Sure.
> 
> > Maybe it's better to add nr_reclaimable = nr_slab_reclaimable + nr_other_reclaimable,
> > which will have a simpler meaning that nr_other_reclaimable (what is other?).
> 
> "other" can be changed, sure. nr_reclaimable is possible if we change
> slab to adjust that counter as well - vmstat code doesn't support
> arbitrary calculations when printing.

Sure, but even just hiding a value isn't that easy now.
So we have to touch the vmstat printing code anyway.

Thanks!

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 705216B0008
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 09:57:03 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v191so1168266wmd.1
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 06:57:03 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r14si1471662edm.281.2018.04.11.06.57.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 06:57:02 -0700 (PDT)
Date: Wed, 11 Apr 2018 14:56:31 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180411135624.GA24260@castle.DHCP.thefacebook.com>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Wed, Apr 11, 2018 at 03:16:08PM +0200, Vlastimil Babka wrote:
> [+CC linux-api]
> 
> On 03/05/2018 02:37 PM, Roman Gushchin wrote:
> > This patch introduces a concept of indirectly reclaimable memory
> > and adds the corresponding memory counter and /proc/vmstat item.
> > 
> > Indirectly reclaimable memory is any sort of memory, used by
> > the kernel (except of reclaimable slabs), which is actually
> > reclaimable, i.e. will be released under memory pressure.
> > 
> > The counter is in bytes, as it's not always possible to
> > count such objects in pages. The name contains BYTES
> > by analogy to NR_KERNEL_STACK_KB.
> > 
> > Signed-off-by: Roman Gushchin <guro@fb.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: linux-fsdevel@vger.kernel.org
> > Cc: linux-kernel@vger.kernel.org
> > Cc: linux-mm@kvack.org
> > Cc: kernel-team@fb.com
> 
> Hmm, looks like I'm late and this user-visible API change was just
> merged. But it's for rc1, so we can still change it, hopefully?
> 
> One problem I see with the counter is that it's in bytes, but among
> counters that use pages, and the name doesn't indicate it.

Here I just followed "nr_kernel_stack" path, which is measured in kB,
but this is not mentioned in the field name.

> Then, I don't
> see why users should care about the "indirectly" part, as that's just an
> implementation detail. It is reclaimable and that's what matters, right?
> (I also wanted to complain about lack of Documentation/... update, but
> looks like there's no general file about vmstat, ugh)

I agree, that it's a bit weird, and it's probably better to not expose
it at all; but this is how all vm counters work. We do expose them all
in /proc/vmstat. A good number of them is useless until you are not a
mm developer, so it's arguable more "debug info" rather than "api".
It's definitely not a reason to make them messy.
Does "nr_indirectly_reclaimable_bytes" look better to you?

> 
> I also kind of liked the idea from v1 rfc posting that there would be a
> separate set of reclaimable kmalloc-X caches for these kind of
> allocations. Besides accounting, it should also help reduce memory
> fragmentation. The right variant of cache would be detected via
> __GFP_RECLAIMABLE.

Well, the downside is that we have to introduce X new caches
just for this particular problem. I'm not strictly against the idea,
but not convinced that it's much better.

> 
> With that in mind, can we at least for now put the (manually maintained)
> byte counter in a variable that's not directly exposed via /proc/vmstat,
> and then when printing nr_slab_reclaimable, simply add the value
> (divided by PAGE_SIZE), and when printing nr_slab_unreclaimable,
> subtract the same value. This way we would be simply making the existing
> counters more precise, in line with their semantics.

Idk, I don't like the idea of adding a counter outside of the vm counters
infrastructure, and I definitely wouldn't touch the exposed
nr_slab_reclaimable and nr_slab_unreclaimable fields.
We do have some stats in /proc/slabinfo, /proc/meminfo and /sys/kernel/slab
and I think that we should keep it consistent.

Thanks!

> 
> Thoughts?
> Vlastimil
> 
> > ---
> >  include/linux/mmzone.h | 1 +
> >  mm/vmstat.c            | 1 +
> >  2 files changed, 2 insertions(+)
> > 
> > diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> > index e09fe563d5dc..15e783f29e21 100644
> > --- a/include/linux/mmzone.h
> > +++ b/include/linux/mmzone.h
> > @@ -180,6 +180,7 @@ enum node_stat_item {
> >  	NR_VMSCAN_IMMEDIATE,	/* Prioritise for reclaim when writeback ends */
> >  	NR_DIRTIED,		/* page dirtyings since bootup */
> >  	NR_WRITTEN,		/* page writings since bootup */
> > +	NR_INDIRECTLY_RECLAIMABLE_BYTES, /* measured in bytes */
> >  	NR_VM_NODE_STAT_ITEMS
> >  };
> >  
> > diff --git a/mm/vmstat.c b/mm/vmstat.c
> > index 40b2db6db6b1..b6b5684f31fe 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -1161,6 +1161,7 @@ const char * const vmstat_text[] = {
> >  	"nr_vmscan_immediate_reclaim",
> >  	"nr_dirtied",
> >  	"nr_written",
> > +	"nr_indirectly_reclaimable",
> >  
> >  	/* enum writeback_stat_item counters */
> >  	"nr_dirty_threshold",
> > 
> 

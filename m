Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 088E86B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 10:57:34 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id u9so3976599qtg.2
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 07:57:34 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j64si4840150qte.443.2018.04.12.07.57.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 07:57:32 -0700 (PDT)
Date: Thu, 12 Apr 2018 15:57:03 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH 1/3] mm: introduce NR_INDIRECTLY_RECLAIMABLE_BYTES
Message-ID: <20180412145702.GB30714@castle.DHCP.thefacebook.com>
References: <20180305133743.12746-1-guro@fb.com>
 <20180305133743.12746-2-guro@fb.com>
 <08524819-14ef-81d0-fa90-d7af13c6b9d5@suse.cz>
 <20180411135624.GA24260@castle.DHCP.thefacebook.com>
 <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <46dbe2a5-e65f-8b72-f835-0210bc445e52@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Linux API <linux-api@vger.kernel.org>

On Thu, Apr 12, 2018 at 08:52:52AM +0200, Vlastimil Babka wrote:
> On 04/11/2018 03:56 PM, Roman Gushchin wrote:
> > On Wed, Apr 11, 2018 at 03:16:08PM +0200, Vlastimil Babka wrote:
> >> [+CC linux-api]
> >>
> >> On 03/05/2018 02:37 PM, Roman Gushchin wrote:
> >>> This patch introduces a concept of indirectly reclaimable memory
> >>> and adds the corresponding memory counter and /proc/vmstat item.
> >>>
> >>> Indirectly reclaimable memory is any sort of memory, used by
> >>> the kernel (except of reclaimable slabs), which is actually
> >>> reclaimable, i.e. will be released under memory pressure.
> >>>
> >>> The counter is in bytes, as it's not always possible to
> >>> count such objects in pages. The name contains BYTES
> >>> by analogy to NR_KERNEL_STACK_KB.
> >>>
> >>> Signed-off-by: Roman Gushchin <guro@fb.com>
> >>> Cc: Andrew Morton <akpm@linux-foundation.org>
> >>> Cc: Alexander Viro <viro@zeniv.linux.org.uk>
> >>> Cc: Michal Hocko <mhocko@suse.com>
> >>> Cc: Johannes Weiner <hannes@cmpxchg.org>
> >>> Cc: linux-fsdevel@vger.kernel.org
> >>> Cc: linux-kernel@vger.kernel.org
> >>> Cc: linux-mm@kvack.org
> >>> Cc: kernel-team@fb.com
> >>
> >> Hmm, looks like I'm late and this user-visible API change was just
> >> merged. But it's for rc1, so we can still change it, hopefully?
> >>
> >> One problem I see with the counter is that it's in bytes, but among
> >> counters that use pages, and the name doesn't indicate it.
> > 
> > Here I just followed "nr_kernel_stack" path, which is measured in kB,
> > but this is not mentioned in the field name.
> 
> Oh, didn't know. Bad example to follow :P
> 
> >> Then, I don't
> >> see why users should care about the "indirectly" part, as that's just an
> >> implementation detail. It is reclaimable and that's what matters, right?
> >> (I also wanted to complain about lack of Documentation/... update, but
> >> looks like there's no general file about vmstat, ugh)
> > 
> > I agree, that it's a bit weird, and it's probably better to not expose
> > it at all; but this is how all vm counters work. We do expose them all
> > in /proc/vmstat. A good number of them is useless until you are not a
> > mm developer, so it's arguable more "debug info" rather than "api".
> 
> Yeah the problem is that once tools start rely on them, they fall under
> the "do not break userspace" rule, however we call them. So being
> cautious and conservative can't hurt.
> 
> > It's definitely not a reason to make them messy.
> > Does "nr_indirectly_reclaimable_bytes" look better to you?
> 
> It still has has the "indirecly" part and feels arbitrary :/
> 
> >>
> >> I also kind of liked the idea from v1 rfc posting that there would be a
> >> separate set of reclaimable kmalloc-X caches for these kind of
> >> allocations. Besides accounting, it should also help reduce memory
> >> fragmentation. The right variant of cache would be detected via
> >> __GFP_RECLAIMABLE.
> > 
> > Well, the downside is that we have to introduce X new caches
> > just for this particular problem. I'm not strictly against the idea,
> > but not convinced that it's much better.
> 
> Maybe we can find more cases that would benefit from it. Heck, even slab
> itself allocates some management structures from the generic kmalloc
> caches, and if they are used for reclaimable caches, they could be
> tracked as reclaimable as well.

This is a good catch!

> 
> >>
> >> With that in mind, can we at least for now put the (manually maintained)
> >> byte counter in a variable that's not directly exposed via /proc/vmstat,
> >> and then when printing nr_slab_reclaimable, simply add the value
> >> (divided by PAGE_SIZE), and when printing nr_slab_unreclaimable,
> >> subtract the same value. This way we would be simply making the existing
> >> counters more precise, in line with their semantics.
> > 
> > Idk, I don't like the idea of adding a counter outside of the vm counters
> > infrastructure, and I definitely wouldn't touch the exposed
> > nr_slab_reclaimable and nr_slab_unreclaimable fields.
> 
> We would be just making the reported values more precise wrt reality.

It depends on if we believe that only slab memory can be reclaimable
or not. If yes, this is true, otherwise not.

My guess is that some drivers (e.g. networking) might have buffers,
which are reclaimable under mempressure, and are allocated using
the page allocator. But I have to look closer...

> > We do have some stats in /proc/slabinfo, /proc/meminfo and /sys/kernel/slab
> > and I think that we should keep it consistent.
> 
> Right, meminfo would be adjusted the same. slabinfo doesn't indicate
> which caches are reclaimable, so there will be no change.
> /sys/kernel/slab/cache/reclaim_account does, but I doubt anything will
> break.

It also can be found out of the corresponding directory name in sysfs:
$ ls -la /sys/kernel/slab/dentr*
lrwxrwxrwx. 1 root root 0 Apr 11 14:45 /sys/kernel/slab/dentry -> :aA-0000192
                                                                   ^
						this is the "reclaimable" flag
Not saying that something will break.

Thanks!

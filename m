Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E7CE86B0254
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 20:33:21 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so79066442pdb.1
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 17:33:21 -0700 (PDT)
Received: from mail-pd0-x22a.google.com (mail-pd0-x22a.google.com. [2607:f8b0:400e:c02::22a])
        by mx.google.com with ESMTPS id ks7si5733548pab.99.2015.07.28.17.33.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 17:33:20 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so79072101pdr.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 17:33:20 -0700 (PDT)
Date: Tue, 28 Jul 2015 17:33:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
In-Reply-To: <55B1DF11.8070100@suse.cz>
Message-ID: <alpine.DEB.2.10.1507281711250.12378@chino.kir.corp.google.com>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <alpine.DEB.2.10.1507091439100.17177@chino.kir.corp.google.com> <55AE0AFE.8070200@suse.cz> <alpine.DEB.2.10.1507211549380.3833@chino.kir.corp.google.com>
 <55AFB569.90702@suse.cz> <alpine.DEB.2.10.1507221509520.24115@chino.kir.corp.google.com> <55B0B175.9090306@suse.cz> <alpine.DEB.2.10.1507231358470.31024@chino.kir.corp.google.com> <55B1DF11.8070100@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Fri, 24 Jul 2015, Vlastimil Babka wrote:

> > Two issues I want to bring up:
> > 
> >   (1) do non-thp configs benefit from periodic compaction?
> > 
> >       In my experience, no, but perhaps there are other use cases where
> >       this has been a pain.  The primary candidates, in my opinion,
> >       would be the networking stack and slub.  Joonsoo reports having to
> >       workaround issues with high-order slub allocations being too
> >       expensive.  I'm not sure that would be better served by periodic
> >       compaction, but it seems like a candidate for background compaction.
> 
> Yes hopefully a proactive background compaction would serve them enough.
> 
> >       This is why my rfc tied periodic compaction to khugepaged, and we
> >       have strong evidence that this helps thp and cpu utilization.  For
> >       periodic compaction to be possible outside of thp, we'd need a use
> >       case for it.
> > 
> >   (2) does kcompactd have to be per-node?
> > 
> >       I don't see the immediate benefit since direct compaction can
> >       already scan remote memory and migrate it, khugepaged can do the
> 
> It can work remotely, but it's slower.
> 
> >       same.  Is there evidence that suggests that a per-node kcompactd
> >       is significantly better than a single kthread?  I think others
> >       would be more receptive of a single kthread addition.
> 
> I think it's simpler design wrt waking up the kthread for the desired node,
> and self-tuning any sleeping depending on per-node pressure. It also matches
> the design of kswapd. And IMHO machines with many memory nodes should
> naturally have also many CPU's to cope with the threads, so it should all
> scale well.
> 

I see your "proactive background compaction" as my "periodic compaction" 
:)  And I agree with your comment that we should be careful about defining 
the API so it can be easily extended in the future.

I see the two mechanisms different enough that they need to be defined 
separately: periodic compaction that would be done at certain intervals 
regardless of fragmentation or allocation failures to keep fragmentation 
low, and background compaction that would be done when a zone reaches a 
certain fragmentation index for high orders, similar to extfrag_threshold, 
or an allocation failure.

Per-node kcompactd threads we agree would be optimal, so let's try to see 
if we can make that work.

What do you think about the following?

 - add vm.compact_period_secs to define the number of seconds between
   full compactions on each node.  This compaction would reset the
   pageblock skip heuristic and be synchronous.  It would default to 900
   based only on our evidence that 15m period compaction helps increase
   our cpu utilization for khugepaged; it is arbitrary and I'd happily
   change it if someone has a better suggestion.  Changing it to 0 would
   disable periodic compaction (we don't anticipate anybody will ever
   want kcompactd threads will take 100% of cpu on each node).  We can
   stagger this over all nodes to avoid all kcompactd threads working at
   the same time.

 - add vm.compact_background_extfrag_threshold to define the extfrag
   threshold when kcompactd should start doing sync_light migration
   in the background without resetting the pageblock skip heuristic.
   The threshold is defined at PAGE_ALLOC_COSTLY_ORDER and is halved
   for each order higher so that very high order allocations don't
   trigger it.  To reduce overhead, this can be checked only in the
   slowpath.

I'd also like to talk about compacting of mlocked memory and limit it to 
only periodic compaction so that we aren't constantly incurring minor 
faults when not expected.

How does this sound?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

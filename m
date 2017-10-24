Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id D85C66B0033
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 08:25:31 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k15so11668334wrc.1
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 05:25:31 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 31si129941wri.328.2017.10.24.05.25.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 05:25:30 -0700 (PDT)
Date: Tue, 24 Oct 2017 14:25:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171024122526.3kmabkcbmj4johli@dhcp22.suse.cz>
References: <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
 <20171020021329.GB10438@js1304-P5Q-DELUXE>
 <20171020055922.x2mj6j66obmp52da@dhcp22.suse.cz>
 <20171020065014.GA11145@js1304-P5Q-DELUXE>
 <20171020070220.t4o573zymgto5kmi@dhcp22.suse.cz>
 <20171023052309.GB23082@js1304-P5Q-DELUXE>
 <20171023081009.7fyz3gfrmurvj635@dhcp22.suse.cz>
 <20171024044423.GA31424@js1304-P5Q-DELUXE>
 <fdb6b325-8de8-b809-81eb-c164736d6a58@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <fdb6b325-8de8-b809-81eb-c164736d6a58@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 24-10-17 10:12:58, Vlastimil Babka wrote:
> On 10/24/2017 06:44 AM, Joonsoo Kim wrote:
> >>> I'm not sure what is the confusing semantic you mentioned. I think
> >>> that set_migratetype_isolate() has confusing semantic and should be
> >>> fixed since making the pageblock isolated doesn't need to check if
> >>> there is unmovable page or not. Do you think that
> >>> set_migratetype_isolate() need to check it? If so, why?
> >>
> >> My intuitive understanding of set_migratetype_isolate is that it either
> >> suceeds and that means that the given pfn range can be isolated for the
> >> given type of allocation (be it movable or cma). No new pages will be
> >> allocated from this range to allow converging into a free range in a
> >> finit amount of time. At least this is how the hotplug code would like
> >> to use it and I suppose that the alloc_contig_range would like to
> >> guarantee the same to not rely on a fixed amount of migration attempts.
> > 
> > Yes, alloc_contig_range() also want to guarantee the similar thing.
> > Major difference between them is 'given pfn range'. memory hotplug
> > works by pageblock unit but alloc_contig_range() doesn't.
> > alloc_contig_range() works by the page unit. However, there is no easy
> > way to isolate individual page so it uses pageblock isolation
> > regardless of 'given pfn range'. In this case, checking movability of
> > all pages on the pageblock would cause the problem as I mentioned
> > before.
> 
> I couldn't look too closely yet, but do I understand correctly that the
> *potential* problem (because as you say there are no such
> alloc_contig_range callers) you are describing is not newly introduced
> by Michal's series? Then his patch fixing the introduced regression
> should be enough for now, and further improvements could be posted on
> top, and not vice versa? Please don't take it wrong, I agree the current
> state is a bit of a mess and improvements are welcome. Also it seems to
> me that Michal is right, and there's nothing preventing
> alloc_contig_range() to allocate from CMA pageblocks for non-CMA
> purposes (likely not movable), and that should be also fixed?

OK, it seems I understand Joonsoo's concern more now. And I agree with
Vlastimil, that it is better to plug the immediate regression with a
minimal patch and discuss general improvements of the pfn based
allocator separatelly. There are more things to clear up there,
including the proper API (alloc_contig_range is just too low level for
anybody to use) as well as the MIGRATE_* flags usage (e.g. I am not
really sure GB pages usage of MIGRATE_MOVABLE is really correct).
alloc_contig_range looks like an internal CMA function which has been
(ab)used for a different purpose to me rather than a well thought
through interface. MAP_CONTIG discussion has shown some interest in
an API for large allocations so I _believe_ we should think that through
befire we grow more unexpected users.

I am definitely willing to help there.

Is that something you would agree with Joonsoo?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C62266B025F
	for <linux-mm@kvack.org>; Thu, 26 Oct 2017 03:41:32 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t188so1810381pfd.20
        for <linux-mm@kvack.org>; Thu, 26 Oct 2017 00:41:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b2si2960556pgt.268.2017.10.26.00.41.31
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Oct 2017 00:41:31 -0700 (PDT)
Date: Thu, 26 Oct 2017 09:41:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171026074128.ip66zog7ar2bjbb6@dhcp22.suse.cz>
References: <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
 <20171020021329.GB10438@js1304-P5Q-DELUXE>
 <20171020055922.x2mj6j66obmp52da@dhcp22.suse.cz>
 <20171020065014.GA11145@js1304-P5Q-DELUXE>
 <20171020070220.t4o573zymgto5kmi@dhcp22.suse.cz>
 <20171023052309.GB23082@js1304-P5Q-DELUXE>
 <20171023081009.7fyz3gfrmurvj635@dhcp22.suse.cz>
 <20171024044423.GA31424@js1304-P5Q-DELUXE>
 <fdb6b325-8de8-b809-81eb-c164736d6a58@suse.cz>
 <20171026024707.GA11791@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171026024707.GA11791@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 26-10-17 11:47:07, Joonsoo Kim wrote:
> On Tue, Oct 24, 2017 at 10:12:58AM +0200, Vlastimil Babka wrote:
> > On 10/24/2017 06:44 AM, Joonsoo Kim wrote:
> > >>> I'm not sure what is the confusing semantic you mentioned. I think
> > >>> that set_migratetype_isolate() has confusing semantic and should be
> > >>> fixed since making the pageblock isolated doesn't need to check if
> > >>> there is unmovable page or not. Do you think that
> > >>> set_migratetype_isolate() need to check it? If so, why?
> > >>
> > >> My intuitive understanding of set_migratetype_isolate is that it either
> > >> suceeds and that means that the given pfn range can be isolated for the
> > >> given type of allocation (be it movable or cma). No new pages will be
> > >> allocated from this range to allow converging into a free range in a
> > >> finit amount of time. At least this is how the hotplug code would like
> > >> to use it and I suppose that the alloc_contig_range would like to
> > >> guarantee the same to not rely on a fixed amount of migration attempts.
> > > 
> > > Yes, alloc_contig_range() also want to guarantee the similar thing.
> > > Major difference between them is 'given pfn range'. memory hotplug
> > > works by pageblock unit but alloc_contig_range() doesn't.
> > > alloc_contig_range() works by the page unit. However, there is no easy
> > > way to isolate individual page so it uses pageblock isolation
> > > regardless of 'given pfn range'. In this case, checking movability of
> > > all pages on the pageblock would cause the problem as I mentioned
> > > before.
> > 
> > I couldn't look too closely yet, but do I understand correctly that the
> > *potential* problem (because as you say there are no such
> > alloc_contig_range callers) you are describing is not newly introduced
> > by Michal's series? Then his patch fixing the introduced regression
> 
> This potential problem exists there before Michal's series if the
> migratetype of the target pageblock isn't MIGRATE_MOVABLE or MIGRATE_CMA.
> However, his series enlarges this potential problem surface. It
> would be the problem now even if the migratetype of the target
> pageblock is MIGRATE_MOVABLE.
> 
> > should be enough for now, and further improvements could be posted on
> > top, and not vice versa? Please don't take it wrong, I agree the current
> > state is a bit of a mess and improvements are welcome. Also it seems to
> 
> I'm not very sensitive that which patch is applied first. I can do
> rebase. But, IMHO, correct applying order is my patch first and then
> Michal's series.
> 
> Anyway, Michal, feel free to do what you think correct.

If you do not mind I would rather go with the simple patch first and
then build on top of that. For two reasons 1) it documents the CMA
requirement and 2) there do not seem to be any real users affected by
the issue you are seeing right now. And 3) I really believe
alloc_contig_range needs a deeper thought to be usable in more general
contexts.

> > me that Michal is right, and there's nothing preventing
> > alloc_contig_range() to allocate from CMA pageblocks for non-CMA
> > purposes (likely not movable), and that should be also fixed?
> 
> I noticed the problem you mentioned now and, yes, it should be fixed.
> My patch will naturally fixes this issue, too.

I really do not see how.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

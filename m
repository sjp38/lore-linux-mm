Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B13A6B0253
	for <linux-mm@kvack.org>; Tue, 24 Oct 2017 03:44:41 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v78so13659738pgb.18
        for <linux-mm@kvack.org>; Tue, 24 Oct 2017 00:44:41 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j12si6054705pgq.115.2017.10.24.00.44.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 24 Oct 2017 00:44:39 -0700 (PDT)
Date: Tue, 24 Oct 2017 09:44:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171024074436.563sn3hfa5png3jt@dhcp22.suse.cz>
References: <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
 <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
 <20171020021329.GB10438@js1304-P5Q-DELUXE>
 <20171020055922.x2mj6j66obmp52da@dhcp22.suse.cz>
 <20171020065014.GA11145@js1304-P5Q-DELUXE>
 <20171020070220.t4o573zymgto5kmi@dhcp22.suse.cz>
 <20171023052309.GB23082@js1304-P5Q-DELUXE>
 <20171023081009.7fyz3gfrmurvj635@dhcp22.suse.cz>
 <20171024044423.GA31424@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171024044423.GA31424@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 24-10-17 13:44:23, Joonsoo Kim wrote:
> On Mon, Oct 23, 2017 at 10:10:09AM +0200, Michal Hocko wrote:
[...]
> > My intuitive understanding of set_migratetype_isolate is that it either
> > suceeds and that means that the given pfn range can be isolated for the
> > given type of allocation (be it movable or cma). No new pages will be
> > allocated from this range to allow converging into a free range in a
> > finit amount of time. At least this is how the hotplug code would like
> > to use it and I suppose that the alloc_contig_range would like to
> > guarantee the same to not rely on a fixed amount of migration attempts.
> 
> Yes, alloc_contig_range() also want to guarantee the similar thing.
> Major difference between them is 'given pfn range'. memory hotplug
> works by pageblock unit but alloc_contig_range() doesn't.
> alloc_contig_range() works by the page unit. However, there is no easy
> way to isolate individual page so it uses pageblock isolation
> regardless of 'given pfn range'.

I am still confused. So when is it safe to isolate a page from the CMA
pageblock for something that is not a CMA allocation request? Don't we
lose a CMA guanratee that way? 

[...]
> > That being said, I would much rather see MIGRATE_CMA case special cased
> > than duplicate the already confusing API but I will not insist of
> > course.
> 
> Okay. I atteach the patch. Andrew, could you revert Michal's series
> and apply this patch first? Perhaps, Michal will resend his series on
> top of this one.

I am not convinced about this approach but I will not argue about the
patch though. If this is seen as a right way forward, I will rebase
my patches on top.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

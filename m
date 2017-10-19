Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5FB3E6B0261
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 08:21:24 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g10so2813578wrg.6
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 05:21:24 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u12si11632827wre.448.2017.10.19.05.21.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 05:21:22 -0700 (PDT)
Date: Thu, 19 Oct 2017 14:21:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171019122118.y6cndierwl2vnguj@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171019025111.GA3852@js1304-P5Q-DELUXE>
 <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
 <20171019073355.GA4486@js1304-P5Q-DELUXE>
 <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019082041.5zudpqacaxjhe4gw@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 19-10-17 10:20:41, Michal Hocko wrote:
> On Thu 19-10-17 16:33:56, Joonsoo Kim wrote:
> > On Thu, Oct 19, 2017 at 09:15:03AM +0200, Michal Hocko wrote:
> > > On Thu 19-10-17 11:51:11, Joonsoo Kim wrote:
> [...]
> > > > Hello,
> > > > 
> > > > This patch will break the CMA user. As you mentioned, CMA allocation
> > > > itself isn't migrateable. So, after a single page is allocated through
> > > > CMA allocation, has_unmovable_pages() will return true for this
> > > > pageblock. Then, futher CMA allocation request to this pageblock will
> > > > fail because it requires isolating the pageblock.
> > > 
> > > Hmm, does this mean that the CMA allocation path depends on
> > > has_unmovable_pages to return false here even though the memory is not
> > > movable? This sounds really strange to me and kind of abuse of this
> > 
> > Your understanding is correct. Perhaps, abuse or wrong function name.
> >
> > > function. Which path is that? Can we do the migrate type test theres?
> > 
> > alloc_contig_range() -> start_isolate_page_range() ->
> > set_migratetype_isolate() -> has_unmovable_pages()
> 
> I see. It seems that the CMA and memory hotplug have a very different
> view on what should happen during isolation.
>  
> > We can add one argument, 'XXX' to set_migratetype_isolate() and change
> > it to check migrate type rather than has_unmovable_pages() if 'XXX' is
> > specified.
> 
> Can we use the migratetype argument and do the special thing for
> MIGRATE_CMA? Like the following diff?

And with the full changelog.
---

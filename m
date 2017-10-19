Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9CAEA6B0033
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 03:15:09 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 76so5167193pfr.3
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 00:15:09 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f24si8712082pfk.415.2017.10.19.00.15.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Oct 2017 00:15:08 -0700 (PDT)
Date: Thu, 19 Oct 2017 09:15:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171019071503.e7w5fo35lsq6ca54@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <20171019025111.GA3852@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171019025111.GA3852@js1304-P5Q-DELUXE>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, Michael Ellerman <mpe@ellerman.id.au>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 19-10-17 11:51:11, Joonsoo Kim wrote:
> On Fri, Oct 13, 2017 at 02:00:12PM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > Michael has noticed that the memory offline tries to migrate kernel code
> > pages when doing
> >  echo 0 > /sys/devices/system/memory/memory0/online
> > 
> > The current implementation will fail the operation after several failed
> > page migration attempts but we shouldn't even attempt to migrate
> > that memory and fail right away because this memory is clearly not
> > migrateable. This will become a real problem when we drop the retry loop
> > counter resp. timeout.
> > 
> > The real problem is in has_unmovable_pages in fact. We should fail if
> > there are any non migrateable pages in the area. In orther to guarantee
> > that remove the migrate type checks because MIGRATE_MOVABLE is not
> > guaranteed to contain only migrateable pages. It is merely a heuristic.
> > Similarly MIGRATE_CMA does guarantee that the page allocator doesn't
> > allocate any non-migrateable pages from the block but CMA allocations
> > themselves are unlikely to migrateable. Therefore remove both checks.
> 
> Hello,
> 
> This patch will break the CMA user. As you mentioned, CMA allocation
> itself isn't migrateable. So, after a single page is allocated through
> CMA allocation, has_unmovable_pages() will return true for this
> pageblock. Then, futher CMA allocation request to this pageblock will
> fail because it requires isolating the pageblock.

Hmm, does this mean that the CMA allocation path depends on
has_unmovable_pages to return false here even though the memory is not
movable? This sounds really strange to me and kind of abuse of this
function. Which path is that? Can we do the migrate type test theres?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

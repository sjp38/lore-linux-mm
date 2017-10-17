Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 76F206B0038
	for <linux-mm@kvack.org>; Tue, 17 Oct 2017 08:03:21 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y39so708089wrd.17
        for <linux-mm@kvack.org>; Tue, 17 Oct 2017 05:03:21 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o17si6647071wme.34.2017.10.17.05.03.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 17 Oct 2017 05:03:20 -0700 (PDT)
Date: Tue, 17 Oct 2017 14:03:18 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] mm: drop migrate type checks from has_unmovable_pages
Message-ID: <20171017120318.rers7zga3cnirt4i@dhcp22.suse.cz>
References: <20171013115835.zaehapuucuzl2vlv@dhcp22.suse.cz>
 <20171013120013.698-1-mhocko@kernel.org>
 <871sm2j92j.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871sm2j92j.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Reza Arbab <arbab@linux.vnet.ibm.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, qiuxishi@huawei.com, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 17-10-17 22:41:08, Michael Ellerman wrote:
> Michal Hocko <mhocko@kernel.org> writes:
> 
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
> >
> > Reported-by: Michael Ellerman <mpe@ellerman.id.au>
> > Signed-off-by: Michal Hocko <mhocko@suse.com>
> 
> Thanks, that works for me.
> 
> Tested-by: Michael Ellerman <mpe@ellerman.id.au>

Thanks a lot Michael!

Andrew, could you add these two patches and merge them before
mm-memory_hotplug-do-not-fail-offlining-too-early.patch? Or should I
rather repost the full series (including 2 already merged patches?
again?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

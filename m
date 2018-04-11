Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC0D6B0003
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 15:43:32 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id y7-v6so1812542plh.7
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 12:43:32 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e17si1174085pgr.475.2018.04.11.12.43.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 12:43:31 -0700 (PDT)
Date: Wed, 11 Apr 2018 21:43:26 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: shmem: enable thp migration (Re: [PATCH v1] mm:
 consider non-anonymous thp as unmovable page)
Message-ID: <20180411194326.GN23400@dhcp22.suse.cz>
References: <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
 <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
 <20180405160317.GP6312@dhcp22.suse.cz>
 <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
 <20180411092611.GE23400@dhcp22.suse.cz>
 <20180411122739.25d1700099222eb647b0c620@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180411122739.25d1700099222eb647b0c620@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed 11-04-18 12:27:39, Andrew Morton wrote:
> On Wed, 11 Apr 2018 11:26:11 +0200 Michal Hocko <mhocko@kernel.org> wrote:
> 
> > On Fri 06-04-18 03:07:11, Naoya Horiguchi wrote:
> > > >From e31ec037701d1cc76b26226e4b66d8c783d40889 Mon Sep 17 00:00:00 2001
> > > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Date: Fri, 6 Apr 2018 10:58:35 +0900
> > > Subject: [PATCH] mm: enable thp migration for shmem thp
> > > 
> > > My testing for the latest kernel supporting thp migration showed an
> > > infinite loop in offlining the memory block that is filled with shmem
> > > thps.  We can get out of the loop with a signal, but kernel should
> > > return with failure in this case.
> > > 
> > > What happens in the loop is that scan_movable_pages() repeats returning
> > > the same pfn without any progress. That's because page migration always
> > > fails for shmem thps.
> > > 
> > > In memory offline code, memory blocks containing unmovable pages should
> > > be prevented from being offline targets by has_unmovable_pages() inside
> > > start_isolate_page_range().
> > >
> > > So it's possible to change migratability
> > > for non-anonymous thps to avoid the issue, but it introduces more complex
> > > and thp-specific handling in migration code, so it might not good.
> > > 
> > > So this patch is suggesting to fix the issue by enabling thp migration
> > > for shmem thp. Both of anon/shmem thp are migratable so we don't need
> > > precheck about the type of thps.
> > > 
> > > Fixes: commit 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early")
> > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > Cc: stable@vger.kernel.org # v4.15+
> > 
> > I do not really feel qualified to give my ack but this is the right
> > approach for the fix. We simply do expect that LRU pages are migrateable
> > as well as zone_movable pages.
> > 
> > Andrew, do you plan to take it (with Kirill's ack).
> > 
> 
> Sure.  What happened with "Michal's fix in another email"
> (https://lkml.kernel.org/r/20180406051452.GB23467@hori1.linux.bs1.fc.nec.co.jp)?

I guess you meant http://lkml.kernel.org/r/20180405190405.GS6312@dhcp22.suse.cz

Well, that would be a workaround in case we didn't have a proper fix. It
is much simpler but it wouldn't make backporting to older kernels any
easier because it depends on other non-trivial changes you already have
in your tree. So having a full THP pagecache migration support is
preferred of course.

-- 
Michal Hocko
SUSE Labs

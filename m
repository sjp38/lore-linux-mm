Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DA8D16B0007
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 15:27:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p189so1305303pfp.1
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 12:27:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id j21si1178948pga.34.2018.04.11.12.27.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 12:27:40 -0700 (PDT)
Date: Wed, 11 Apr 2018 12:27:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: shmem: enable thp migration (Re: [PATCH v1] mm:
 consider non-anonymous thp as unmovable page)
Message-Id: <20180411122739.25d1700099222eb647b0c620@linux-foundation.org>
In-Reply-To: <20180411092611.GE23400@dhcp22.suse.cz>
References: <20180403083451.GG5501@dhcp22.suse.cz>
	<20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
	<20180405085927.GC6312@dhcp22.suse.cz>
	<20180405122838.6a6b35psizem4tcy@node.shutemov.name>
	<20180405124830.GJ6312@dhcp22.suse.cz>
	<20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
	<20180405150547.GN6312@dhcp22.suse.cz>
	<20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
	<20180405160317.GP6312@dhcp22.suse.cz>
	<20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
	<20180411092611.GE23400@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, 11 Apr 2018 11:26:11 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> On Fri 06-04-18 03:07:11, Naoya Horiguchi wrote:
> > >From e31ec037701d1cc76b26226e4b66d8c783d40889 Mon Sep 17 00:00:00 2001
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Fri, 6 Apr 2018 10:58:35 +0900
> > Subject: [PATCH] mm: enable thp migration for shmem thp
> > 
> > My testing for the latest kernel supporting thp migration showed an
> > infinite loop in offlining the memory block that is filled with shmem
> > thps.  We can get out of the loop with a signal, but kernel should
> > return with failure in this case.
> > 
> > What happens in the loop is that scan_movable_pages() repeats returning
> > the same pfn without any progress. That's because page migration always
> > fails for shmem thps.
> > 
> > In memory offline code, memory blocks containing unmovable pages should
> > be prevented from being offline targets by has_unmovable_pages() inside
> > start_isolate_page_range().
> >
> > So it's possible to change migratability
> > for non-anonymous thps to avoid the issue, but it introduces more complex
> > and thp-specific handling in migration code, so it might not good.
> > 
> > So this patch is suggesting to fix the issue by enabling thp migration
> > for shmem thp. Both of anon/shmem thp are migratable so we don't need
> > precheck about the type of thps.
> > 
> > Fixes: commit 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early")
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Cc: stable@vger.kernel.org # v4.15+
> 
> I do not really feel qualified to give my ack but this is the right
> approach for the fix. We simply do expect that LRU pages are migrateable
> as well as zone_movable pages.
> 
> Andrew, do you plan to take it (with Kirill's ack).
> 

Sure.  What happened with "Michal's fix in another email"
(https://lkml.kernel.org/r/20180406051452.GB23467@hori1.linux.bs1.fc.nec.co.jp)?

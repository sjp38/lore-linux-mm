Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 80D7C6B0006
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 07:17:21 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id u5so7710936wrc.23
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 04:17:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u59sor2325082edc.9.2018.04.10.04.17.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Apr 2018 04:17:20 -0700 (PDT)
Date: Tue, 10 Apr 2018 14:16:32 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: shmem: enable thp migration (Re: [PATCH v1] mm:
 consider non-anonymous thp as unmovable page)
Message-ID: <20180410111632.xtrxmop7p5v2mopj@node.shutemov.name>
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
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Michal Hocko <mhocko@kernel.org>, Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri, Apr 06, 2018 at 03:07:11AM +0000, Naoya Horiguchi wrote:
> Hi everyone,
> 
> On Thu, Apr 05, 2018 at 06:03:17PM +0200, Michal Hocko wrote:
> > On Thu 05-04-18 18:55:51, Kirill A. Shutemov wrote:
> > > On Thu, Apr 05, 2018 at 05:05:47PM +0200, Michal Hocko wrote:
> > > > On Thu 05-04-18 16:40:45, Kirill A. Shutemov wrote:
> > > > > On Thu, Apr 05, 2018 at 02:48:30PM +0200, Michal Hocko wrote:
> > > > [...]
> > > > > > RIght, I confused the two. What is the proper layer to fix that then?
> > > > > > rmap_walk_file?
> > > > > 
> > > > > Maybe something like this? Totally untested.
> > > > 
> > > > This looks way too complex. Why cannot we simply split THP page cache
> > > > during migration?
> > > 
> > > This way we unify the codepath for archictures that don't support THP
> > > migration and shmem THP.
> > 
> > But why? There shouldn't be really nothing to prevent THP (anon or
> > shemem) to be migratable. If we cannot migrate it at once we can always
> > split it. So why should we add another thp specific handling all over
> > the place?
> 
> If thp migration works fine for shmem, we can keep anon/shmem thp to
> be migratable and we don't need any ad-hoc workaround.
> So I wrote a patch to enable it.
> This patch does not change any shmem specific code, so I think that
> it works for file thp (not only shmem,) but I don't test it yet.
> 
> Thanks,
> Naoya Horiguchi
> -----
> From e31ec037701d1cc76b26226e4b66d8c783d40889 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 6 Apr 2018 10:58:35 +0900
> Subject: [PATCH] mm: enable thp migration for shmem thp
> 
> My testing for the latest kernel supporting thp migration showed an
> infinite loop in offlining the memory block that is filled with shmem
> thps.  We can get out of the loop with a signal, but kernel should
> return with failure in this case.
> 
> What happens in the loop is that scan_movable_pages() repeats returning
> the same pfn without any progress. That's because page migration always
> fails for shmem thps.
> 
> In memory offline code, memory blocks containing unmovable pages should
> be prevented from being offline targets by has_unmovable_pages() inside
> start_isolate_page_range(). So it's possible to change migratability
> for non-anonymous thps to avoid the issue, but it introduces more complex
> and thp-specific handling in migration code, so it might not good.
> 
> So this patch is suggesting to fix the issue by enabling thp migration
> for shmem thp. Both of anon/shmem thp are migratable so we don't need
> precheck about the type of thps.
> 
> Fixes: commit 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # v4.15+

This looks sane to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

As, yeah, as you mentioned down the thread it's not a stable material

-- 
 Kirill A. Shutemov

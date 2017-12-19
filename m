Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id C86956B025F
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:07:56 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id u16so14495832pfh.7
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:07:56 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g9si10893715plo.675.2017.12.19.04.07.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 04:07:55 -0800 (PST)
Date: Tue, 19 Dec 2017 13:07:53 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 0/3] mm: unclutter THP migration
Message-ID: <20171219120753.GL2787@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208161559.27313-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

Are there any more comments here? It seems the initial reaction wasn't
all that bad and so I would like to post this with RFC dropped.

On Fri 08-12-17 17:15:56, Michal Hocko wrote:
> On Thu 07-12-17 15:34:01, Michal Hocko wrote:
> > On Thu 07-12-17 22:10:47, Zi Yan wrote:
> [...]
> > > I agree with you that we should try to migrate all tail pages if the THP
> > > needs to be split. But this might not be compatible with "getting
> > > migration results" in unmap_and_move(), since a caller of
> > > migrate_pages() may want to know the status of each page in the
> > > migration list via int **result in get_new_page() (e.g.
> > > new_page_node()). The caller has no idea whether a THP in its migration
> > > list will be split or not, thus, storing migration results might be
> > > quite tricky if tail pages are added into the migration list.
> > 
> > Ouch. I wasn't aware of this "beauty". I will try to wrap my head around
> > this code and think about what to do about it. Thanks for point me to
> > it.
> 
> OK, so was staring at this yesterday and concluded that the current
> implementation of do_move_page_to_node_array is unfixable to work with
> split_thp_page_list in migrate_pages. So I've reimplemented it to not
> use the quite ugly fixed sized batching. Instead I am using dynamic
> batching based on the same node request. See the patch 1 for more
> details about implementation. This will allow us to remove the quite
> ugly 'int **reason' from the allocation callback as well. This is patch
> 2 and patch 3 is finally the thp migration code.
> 
> Diffstat is quite supportive for this cleanup.
>  include/linux/migrate.h        |   7 +-
>  include/linux/page-isolation.h |   3 +-
>  mm/compaction.c                |   3 +-
>  mm/huge_memory.c               |   6 +
>  mm/internal.h                  |   1 +
>  mm/memory_hotplug.c            |   5 +-
>  mm/mempolicy.c                 |  40 +----
>  mm/migrate.c                   | 350 ++++++++++++++++++-----------------------
>  mm/page_isolation.c            |   3 +-
>  9 files changed, 177 insertions(+), 241 deletions(-)
> 
> Does anybody see any issues with this approach?
> 
> On a side note:
> There are some semantic issues I have encountered on the way but I am
> not addressing them here. E.g. trying to move THP tail pages will result
> in either success or EBUSY (the later one more likely once we isolate
> head from the LRU list). Hugetlb reports EACCESS on tail pages.
> Some errors are reported via status parameter but migration failures are
> not even though the original `reason' argument suggests there was an
> intention to do so. From a quick look into git history this never
> worked. I have tried to keep the semantic unchanged.
> 
> Then there is a relatively minor thing that the page isolation might
> fail because of pages not being on the LRU - e.g. because they are
> sitting on the per-cpu LRU caches. Easily fixable.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

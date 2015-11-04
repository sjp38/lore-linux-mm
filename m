Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 367BB6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 10:01:27 -0500 (EST)
Received: by wmeg8 with SMTP id g8so112907223wme.0
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 07:01:26 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bx4si472891wjc.56.2015.11.04.07.01.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Nov 2015 07:01:25 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 0/5] page_owner improvements for debugging
Date: Wed,  4 Nov 2015 16:00:56 +0100
Message-Id: <1446649261-27122-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Minchan Kim <minchan@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>

Hi,

I know it's merge window, but this might potentially help us with some
outstanding bugs if page_owner was enabled e.g. for trinity runs, so here
you go.

Patch 1 is a bug fix, patch 2 reduces page_owner overhead when compiled in
but not enabled on boot. Patch 3 is something I suggested before [1] and it
was deemed a good idea, that the page_owner info should follow the page during
migration. Patch 4 allows us again to know that a migration happened and for
which reason.

Patch 5 will hopefully help us when debugging, as it makes all the info be
printed as part of e.g. VM_BUG_ON_PAGE(). Until now it was only accessible via
/sys file.

Patches are based on today's -next. Hugh's migration patches caused conflicts
for patches 3 and 4 when rebasing from 4.3.

[1] https://lkml.org/lkml/2015/7/23/47

Vlastimil Babka (5):
  mm, page_owner: print migratetype of a page, not pageblock
  mm, page_owner: convert page_owner_inited to static key
  mm, page_owner: copy page owner info during migration
  mm, page_owner: track last migrate reason
  mm, page_owner: dump page owner info from dump_page()

 Documentation/vm/page_owner.txt |  9 +++---
 include/linux/page_ext.h        |  1 +
 include/linux/page_owner.h      | 50 ++++++++++++++++++++++++---------
 mm/debug.c                      |  2 ++
 mm/migrate.c                    | 11 ++++++--
 mm/page_owner.c                 | 61 +++++++++++++++++++++++++++++++++++++----
 mm/vmstat.c                     |  2 +-
 7 files changed, 110 insertions(+), 26 deletions(-)

-- 
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

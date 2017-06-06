Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2F8406B0292
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 10:07:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id s4so11452979wrc.15
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 07:07:02 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id o92si36194153eda.52.2017.06.06.07.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 07:07:01 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <e55bf483-e9f5-30ec-7e88-1298778bc0b1@suse.cz>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
 <e55bf483-e9f5-30ec-7e88-1298778bc0b1@suse.cz>
Message-ID: <149675795783.14666.10554838566926041673@mail.alporthouse.com>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Date: Tue, 06 Jun 2017 15:05:57 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

Quoting Vlastimil Babka (2017-06-06 13:30:15)
> On 06/06/2017 02:14 PM, Michal Hocko wrote:
> > On Tue 06-06-17 13:04:36, Chris Wilson wrote:
> >> Similar in principle to the treatment of get_user_pages, pages that
> >> i915.ko acquires from shmemfs are not immediately reclaimable and so
> >> should be excluded from the mm accounting and vmscan until they have
> >> been returned to the system via shrink_slab/i915_gem_shrink. By moving
> >> the unreclaimable pages off the inactive anon lru, not only should
> >> vmscan be improved by avoiding walking unreclaimable pages, but the
> >> system should also have a better idea of how much memory it can reclaim
> >> at that moment in time.
> > =

> > That is certainly desirable. Peter has proposed a generic pin_page (or
> > similar) API. What happened with it? I think it would be a better
> > approach than (ab)using mlock API. I am also not familiar with the i915
> > code to be sure that using lock_page is really safe here. I think that
> > all we need is to simply move those pages in/out to/from unevictable LRU
> > list on pin/unpining.
> =

> Hmm even when on unevictable list, the pages were still allocated as
> MOVABLE, while pinning prevents them from being migrated, so it doesn't
> play well with compaction/grouping by mobility/CMA etc. Addressing that
> would be more useful IMHO, and e.g. one of the features envisioned for
> the pinning API was to first migrate the pinned pages out of movable
> zones and CMA/MOVABLE pageblocks.

Whilst today i915 doesn't take part in compaction, we do have
plans/patches for enabling migratepage. It would be nice not to nip that
in the bud.
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

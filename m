Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 101F36B0279
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 13:47:48 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id z5so62315586qta.12
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 10:47:48 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h42si36419482qtc.247.2017.06.06.10.47.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 10:47:47 -0700 (PDT)
Date: Tue, 6 Jun 2017 13:47:43 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Message-ID: <20170606174743.GA13998@redhat.com>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
 <e55bf483-e9f5-30ec-7e88-1298778bc0b1@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <e55bf483-e9f5-30ec-7e88-1298778bc0b1@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

On Tue, Jun 06, 2017 at 02:30:15PM +0200, Vlastimil Babka wrote:
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
> > 
> > That is certainly desirable. Peter has proposed a generic pin_page (or
> > similar) API. What happened with it? I think it would be a better
> > approach than (ab)using mlock API. I am also not familiar with the i915
> > code to be sure that using lock_page is really safe here. I think that
> > all we need is to simply move those pages in/out to/from unevictable LRU
> > list on pin/unpining.
> 
> Hmm even when on unevictable list, the pages were still allocated as
> MOVABLE, while pinning prevents them from being migrated, so it doesn't
> play well with compaction/grouping by mobility/CMA etc. Addressing that
> would be more useful IMHO, and e.g. one of the features envisioned for
> the pinning API was to first migrate the pinned pages out of movable
> zones and CMA/MOVABLE pageblocks.

Cost would be high, GPU dataset can be big (giga byte range) so i don't
see copying out of MOVABLE as something sane to do here. Maybe we can
reuse the lru pointer to store a pointer to function and metadata so that
who ever pin a page provide a way to unpin it through this function.

Issue then is how to handle double pin (ie when 2 different driver want
to pin same page).

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

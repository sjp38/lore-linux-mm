Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B4D466B03C0
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 08:35:30 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j22so83261465qtj.15
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 05:35:30 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id 86si21184644qkv.36.2017.06.06.05.35.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 05:35:29 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20170606121418.GM1189@dhcp22.suse.cz>
References: <20170606120436.8683-1-chris@chris-wilson.co.uk>
 <20170606121418.GM1189@dhcp22.suse.cz>
Message-ID: <149675247191.14666.5385909547703846037@mail.alporthouse.com>
Subject: Re: [RFC] mm,drm/i915: Mark pinned shmemfs pages as unevictable
Date: Tue, 06 Jun 2017 13:34:31 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Matthew Auld <matthew.auld@intel.com>, Dave Hansen <dave.hansen@intel.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>

Quoting Michal Hocko (2017-06-06 13:14:18)
> On Tue 06-06-17 13:04:36, Chris Wilson wrote:
> > Similar in principle to the treatment of get_user_pages, pages that
> > i915.ko acquires from shmemfs are not immediately reclaimable and so
> > should be excluded from the mm accounting and vmscan until they have
> > been returned to the system via shrink_slab/i915_gem_shrink. By moving
> > the unreclaimable pages off the inactive anon lru, not only should
> > vmscan be improved by avoiding walking unreclaimable pages, but the
> > system should also have a better idea of how much memory it can reclaim
> > at that moment in time.
> =

> That is certainly desirable. Peter has proposed a generic pin_page (or
> similar) API. What happened with it? I think it would be a better
> approach than (ab)using mlock API. I am also not familiar with the i915
> code to be sure that using lock_page is really safe here. I think that
> all we need is to simply move those pages in/out to/from unevictable LRU
> list on pin/unpining.

With respect to i915, we may not be the sole owner of the page at the
point where we call shmem_read_mapping_page_gfp() as it can mmapped or
accessed directly via the mapping internally. It is just at this point
we know that the page will not be returned to the system until we have
finished using it with the GPU.

An API that didn't assume the page was locked or require exclusive
ownership would be needed for random driver usage like i915.ko
-Chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

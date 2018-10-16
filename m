Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com [209.85.128.69])
	by kanga.kvack.org (Postfix) with ESMTP id BD3F76B0006
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 14:31:56 -0400 (EDT)
Received: by mail-wm1-f69.google.com with SMTP id y14-v6so12877659wmd.1
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 11:31:56 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [109.228.58.192])
        by mx.google.com with ESMTPS id n10-v6si11115898wrp.273.2018.10.16.11.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 11:31:55 -0700 (PDT)
Content-Type: text/plain; charset="utf-8"
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
From: Chris Wilson <chris@chris-wilson.co.uk>
In-Reply-To: <20181016182155.GW18839@dhcp22.suse.cz>
References: <20181016174300.197906-1-vovoy@chromium.org>
 <20181016174300.197906-3-vovoy@chromium.org>
 <20181016182155.GW18839@dhcp22.suse.cz>
Message-ID: <153971466599.22931.16793398326492316920@skylake-alporthouse-com>
Subject: Re: [PATCH 2/2] drm/i915: Mark pinned shmemfs pages as unevictable
Date: Tue, 16 Oct 2018 19:31:06 +0100
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>, Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, akpm@linux-foundation.org, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org

Quoting Michal Hocko (2018-10-16 19:21:55)
> On Wed 17-10-18 01:43:00, Kuo-Hsin Yang wrote:
> > The i915 driver use shmemfs to allocate backing storage for gem objects.
> > These shmemfs pages can be pinned (increased ref count) by
> > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > wastes a lot of time scanning these pinned pages. Mark these pinned
> > pages as unevictable to speed up vmscan.
> =

> I would squash the two patches into the single one. One more thing
> though. One more thing to be careful about here. Unless I miss something
> such a page is not migrateable so it shouldn't be allocated from a
> movable zone. Does mapping_gfp_constraint contains __GFP_MOVABLE? If
> yes, we want to drop it as well. Other than that the patch makes sense
> with my very limited knowlege of the i915 code of course.

They are not migrateable today. But we have proposed hooking up
.migratepage and setting __GFP_MOVABLE which would then include unlocking
the mapping at migrate time.

Fwiw, the shmem_unlock_mapping() call feels quite expensive, almost
nullifying the advantage gained from not walking the lists in reclaim.
I'll have better numbers in a couple of days.
-Chris

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id DBE9B6B0008
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 15:13:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id e5-v6so14855768eda.4
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 12:13:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b11-v6si3295012edj.131.2018.10.16.12.13.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 12:13:54 -0700 (PDT)
Date: Tue, 16 Oct 2018 21:13:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] drm/i915: Mark pinned shmemfs pages as unevictable
Message-ID: <20181016191350.GA18839@dhcp22.suse.cz>
References: <20181016174300.197906-1-vovoy@chromium.org>
 <20181016174300.197906-3-vovoy@chromium.org>
 <20181016182155.GW18839@dhcp22.suse.cz>
 <153971466599.22931.16793398326492316920@skylake-alporthouse-com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <153971466599.22931.16793398326492316920@skylake-alporthouse-com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>
Cc: Kuo-Hsin Yang <vovoy@chromium.org>, linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, akpm@linux-foundation.org, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org

On Tue 16-10-18 19:31:06, Chris Wilson wrote:
> Quoting Michal Hocko (2018-10-16 19:21:55)
> > On Wed 17-10-18 01:43:00, Kuo-Hsin Yang wrote:
> > > The i915 driver use shmemfs to allocate backing storage for gem objects.
> > > These shmemfs pages can be pinned (increased ref count) by
> > > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > > wastes a lot of time scanning these pinned pages. Mark these pinned
> > > pages as unevictable to speed up vmscan.
> > 
> > I would squash the two patches into the single one. One more thing
> > though. One more thing to be careful about here. Unless I miss something
> > such a page is not migrateable so it shouldn't be allocated from a
> > movable zone. Does mapping_gfp_constraint contains __GFP_MOVABLE? If
> > yes, we want to drop it as well. Other than that the patch makes sense
> > with my very limited knowlege of the i915 code of course.
> 
> They are not migrateable today. But we have proposed hooking up
> .migratepage and setting __GFP_MOVABLE which would then include unlocking
> the mapping at migrate time.

if the mapping_gfp doesn't include __GFP_MOVABLE today then there is no
issue I've had in mind.
-- 
Michal Hocko
SUSE Labs

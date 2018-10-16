Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FAD46B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 14:22:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a12-v6so14417812eda.8
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 11:22:00 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m19-v6si10607828edd.178.2018.10.16.11.21.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 11:21:59 -0700 (PDT)
Date: Tue, 16 Oct 2018 20:21:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/2] drm/i915: Mark pinned shmemfs pages as unevictable
Message-ID: <20181016182155.GW18839@dhcp22.suse.cz>
References: <20181016174300.197906-1-vovoy@chromium.org>
 <20181016174300.197906-3-vovoy@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181016174300.197906-3-vovoy@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, akpm@linux-foundation.org, chris@chris-wilson.co.uk, peterz@infradead.org, dave.hansen@intel.com, corbet@lwn.net, hughd@google.com, joonas.lahtinen@linux.intel.com, marcheu@chromium.org, hoegsberg@chromium.org

On Wed 17-10-18 01:43:00, Kuo-Hsin Yang wrote:
> The i915 driver use shmemfs to allocate backing storage for gem objects.
> These shmemfs pages can be pinned (increased ref count) by
> shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> wastes a lot of time scanning these pinned pages. Mark these pinned
> pages as unevictable to speed up vmscan.

I would squash the two patches into the single one. One more thing
though. One more thing to be careful about here. Unless I miss something
such a page is not migrateable so it shouldn't be allocated from a
movable zone. Does mapping_gfp_constraint contains __GFP_MOVABLE? If
yes, we want to drop it as well. Other than that the patch makes sense
with my very limited knowlege of the i915 code of course.
-- 
Michal Hocko
SUSE Labs

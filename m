Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id ED3EF6B000D
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 08:05:45 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id x14-v6so3203622edr.7
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 05:05:45 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s28-v6si1372299edd.159.2018.11.05.05.05.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 05:05:44 -0800 (PST)
Date: Mon, 5 Nov 2018 14:05:44 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v4] mm, drm/i915: mark pinned shmemfs pages as unevictable
Message-ID: <20181105130544.GJ4361@dhcp22.suse.cz>
References: <20181105111348.182492-1-vovoy@chromium.org>
 <20181105130209.GI4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105130209.GI4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kuo-Hsin Yang <vovoy@chromium.org>
Cc: linux-kernel@vger.kernel.org, intel-gfx@lists.freedesktop.org, linux-mm@kvack.org, Chris Wilson <chris@chris-wilson.co.uk>, Joonas Lahtinen <joonas.lahtinen@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>

On Mon 05-11-18 14:02:09, Michal Hocko wrote:
> On Mon 05-11-18 19:13:48, Kuo-Hsin Yang wrote:
> > The i915 driver uses shmemfs to allocate backing storage for gem
> > objects. These shmemfs pages can be pinned (increased ref count) by
> > shmem_read_mapping_page_gfp(). When a lot of pages are pinned, vmscan
> > wastes a lot of time scanning these pinned pages. In some extreme case,
> > all pages in the inactive anon lru are pinned, and only the inactive
> > anon lru is scanned due to inactive_ratio, the system cannot swap and
> > invokes the oom-killer. Mark these pinned pages as unevictable to speed
> > up vmscan.
> > 
> > Export pagevec API check_move_unevictable_pages().
> 
> Thanks for reworking the patch. This looks much more to my taste. At
> least the mm part. I haven't really looked at the the drm part.

One side note. Longterm we probably want a better pinning API. It would
hide this LRU manipulation implementation detail + enforce some limiting
and provide a good way that the pin is longterm. People are working on
this already but it is a PITA and long time to get there.
-- 
Michal Hocko
SUSE Labs

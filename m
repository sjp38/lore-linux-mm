Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BCF86B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 08:05:09 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so229936161pac.6
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 05:05:09 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id c5si32061113pgi.131.2016.10.18.05.05.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 18 Oct 2016 05:05:08 -0700 (PDT)
Message-ID: <1476792301.3117.14.camel@linux.intel.com>
Subject: Re: [Intel-gfx] [PATCH v4 2/2] drm/i915: Make GPU pages movable
From: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Date: Tue, 18 Oct 2016 15:05:01 +0300
In-Reply-To: <1459775891-32442-2-git-send-email-chris@chris-wilson.co.uk>
References: <1459775891-32442-1-git-send-email-chris@chris-wilson.co.uk>
	 <1459775891-32442-2-git-send-email-chris@chris-wilson.co.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chris Wilson <chris@chris-wilson.co.uk>, intel-gfx@lists.freedesktop.org
Cc: linux-mm@kvack.org, Akash Goel <akash.goel@intel.com>, Hugh Dickins <hughd@google.com>, Sourab Gupta <sourab.gupta@intel.com>

On ma, 2016-04-04 at 14:18 +0100, Chris Wilson wrote:
> From: Akash Goel <akash.goel@intel.com>
> 
> On a long run of more than 2-3 days, physical memory tends to get
> fragmented severely, which considerably slows down the system. In such a
> scenario, the shrinker is also unable to help as lack of memory is not
> the actual problem, since it has been observed that there are enough free
> pages of 0 order. This also manifests itself when an indiviual zone in
> the mm runs out of pages and if we cannot migrate pages between zones,
> the kernel hits an out-of-memory even though there are free pages (and
> often all of swap) available.
> 
> To address the issue of external fragementation, kernel does a compaction
> (which involves migration of pages) but it's efficacy depends upon how
> many pages are marked as MOVABLE, as only those pages can be migrated.
> 
> Currently the backing pages for GFX buffers are allocated from shmemfs
> with GFP_RECLAIMABLE flag, in units of 4KB pages.A A In the case of limited
> swap space, it may not be possible always to reclaim or swap-out pages of
> all the inactive objects, to make way for free space allowing formation
> of higher order groups of physically-contiguous pages on compaction.
> 
> Just marking the GPU pages as MOVABLE will not suffice, as i915.ko has to
> pin the pages if they are in use by GPU, which will prevent their
> migration. So the migratepage callback in shmem is also hooked up to get
> a notification when kernel initiates the page migration. On the
> notification, i915.ko appropriately unpin the pages.A A With this we can
> effectively mark the GPU pages as MOVABLE and hence mitigate the
> fragmentation problem.
> 
> v2:
> A - Rename the migration routine to gem_shrink_migratepage, move it to the
> A A A shrinker file, and use the existing constructs (Chris)
> A - To cleanup, add a new helper function to encapsulate all page migration
> A A A skip conditions (Chris)
> A - Add a new local helper function in shrinker file, for dropping the
> A A A backing pages, and call the same from gem_shrink() also (Chris)
> 
> v3:
> A - Fix/invert the check on the return value of unsafe_drop_pages (Chris)
> 
> v4:
> A - Minor tidy
> 
> Testcase: igt/gem_shrink
> Bugzilla: (e.g.) https://bugs.freedesktop.org/show_bug.cgi?id=90254
> Cc: Hugh Dickins <hughd@google.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Sourab Gupta <sourab.gupta@intel.com>
> Signed-off-by: Akash Goel <akash.goel@intel.com>
> Reviewed-by: Chris Wilson <chris@chris-wilson.co.uk>

Could this patch be re-spinned on top of current nightly?

After removing;

> WARN(page_count(newpage) != 1, "Unexpected ref count for newpage\n")

and

>	if (ret)
>		DRM_DEBUG_DRIVER("page=%p migration returned %d\n", page, ret);

This is;

Reviewed-by: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>

Regards, Joonas
-- 
Joonas Lahtinen
Open Source Technology Center
Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

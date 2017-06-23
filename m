Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6B6B16B03B6
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:54:02 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id f49so10925397wrf.5
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:02 -0700 (PDT)
Received: from mail-wr0-f193.google.com (mail-wr0-f193.google.com. [209.85.128.193])
        by mx.google.com with ESMTPS id k31si3811492wrk.167.2017.06.23.01.54.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:54:01 -0700 (PDT)
Received: by mail-wr0-f193.google.com with SMTP id z45so10917196wrb.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:54:01 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 5/6] drm/i915: use __GFP_RETRY_MAYFAIL
Date: Fri, 23 Jun 2017 10:53:44 +0200
Message-Id: <20170623085345.11304-6-mhocko@kernel.org>
In-Reply-To: <20170623085345.11304-1-mhocko@kernel.org>
References: <20170623085345.11304-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Chris Wilson <chris@chris-wilson.co.uk>

From: Michal Hocko <mhocko@suse.com>

24f8e00a8a2e ("drm/i915: Prefer to report ENOMEM rather than incur the
oom for gfx allocations") has tried to remove disruptive OOM killer
because the userspace should be able to cope with allocation failures.
At the time only __GFP_NORETRY could achieve that and it turned out
that this would fail the allocations just too easily. So "drm/i915:
Remove __GFP_NORETRY from our buffer allocator" removed it and hoped
for a better solution. __GFP_RETRY_MAYFAIL is that solution. It will
keep retrying the allocation until there is no more progress and we
would go OOM. Instead we fail the allocation and let the caller to deal
with it.

Cc: Chris Wilson <chris@chris-wilson.co.uk>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 drivers/gpu/drm/i915/i915_gem.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/i915/i915_gem.c b/drivers/gpu/drm/i915/i915_gem.c
index ae3ce1314bd1..eb193f27c8b7 100644
--- a/drivers/gpu/drm/i915/i915_gem.c
+++ b/drivers/gpu/drm/i915/i915_gem.c
@@ -2434,8 +2434,9 @@ i915_gem_object_get_pages_gtt(struct drm_i915_gem_object *obj)
 				 * again with !__GFP_NORETRY. However, we still
 				 * want to fail this allocation rather than
 				 * trigger the out-of-memory killer and for
-				 * this we want the future __GFP_MAYFAIL.
+				 * this we want __GFP_RETRY_MAYFAIL.
 				 */
+				gfp |= __GFP_RETRY_MAYFAIL;
 			}
 		} while (1);
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

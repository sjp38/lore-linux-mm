Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 1/4] mm: Check if mmu notifier callbacks are allowed to fail
Date: Mon, 10 Dec 2018 11:36:38 +0100
Message-Id: <20181210103641.31259-2-daniel.vetter@ffwll.ch>
In-Reply-To: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
References: <20181210103641.31259-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: linux-kernel-owner@vger.kernel.org
To: Intel Graphics Development <intel-gfx@lists.freedesktop.org>
Cc: DRI Development <dri-devel@lists.freedesktop.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>
List-ID: <linux-mm.kvack.org>

Just a bit of paranoia, since if we start pushing this deep into
callchains it's hard to spot all places where an mmu notifier
implementation might fail when it's not allowed to.

Inspired by some confusion we had discussing i915 mmu notifiers and
whether we could use the newly-introduced return value to handle some
corner cases. Until we realized that these are only for when a task
has been killed by the oom reaper.

An alternative approach would be to split the callback into two
versions, one with the int return value, and the other with void
return value like in older kernels. But that's a lot more churn for
fairly little gain I think.

Summary from the m-l discussion on why we want something at warning
level: This allows automated tooling in CI to catch bugs without
humans having to look at everything. If we just upgrade the existing
pr_info to a pr_warn, then we'll have false positives. And as-is, no
one will ever spot the problem since it's lost in the massive amounts
of overall dmesg noise.

v2: Drop the full WARN_ON backtrace in favour of just a pr_warn for
the problematic case (Michal Hocko).

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Cc: Paolo Bonzini <pbonzini@redhat.com>
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5119ff846769..ccc22f21b735 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -190,6 +190,9 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 						mn->ops->invalidate_range_start, _ret,
 						!blockable ? "non-" : "");
+				if (blockable)
+					pr_warn("%pS callback failure not allowed\n",
+						mn->ops->invalidate_range_start);
 				ret = _ret;
 			}
 		}
-- 
2.20.0.rc1

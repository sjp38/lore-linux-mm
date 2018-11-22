Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6288F6B2C3A
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:51:17 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id o21so1369328edq.4
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:51:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z6-v6sor5056633ejq.44.2018.11.22.08.51.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 08:51:15 -0800 (PST)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 2/3] mm, notifier: Catch sleeping/blocking for !blockable
Date: Thu, 22 Nov 2018 17:51:05 +0100
Message-Id: <20181122165106.18238-3-daniel.vetter@ffwll.ch>
In-Reply-To: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, David Rientjes <rientjes@google.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

We need to make sure implementations don't cheat and don't have a
possible schedule/blocking point deeply burried where review can't
catch it.

I'm not sure whether this is the best way to make sure all the
might_sleep() callsites trigger, and it's a bit ugly in the code flow.
But it gets the job done.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: David Rientjes <rientjes@google.com>
Cc: "Christian König" <christian.koenig@amd.com>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: "Jérôme Glisse" <jglisse@redhat.com>
Cc: linux-mm@kvack.org
Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
---
 mm/mmu_notifier.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 59e102589a25..4d282cfb296e 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -185,7 +185,13 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 	id = srcu_read_lock(&srcu);
 	hlist_for_each_entry_rcu(mn, &mm->mmu_notifier_mm->list, hlist) {
 		if (mn->ops->invalidate_range_start) {
-			int _ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
+			int _ret;
+
+			if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !blockable)
+				preempt_disable();
+			_ret = mn->ops->invalidate_range_start(mn, mm, start, end, blockable);
+			if (IS_ENABLED(CONFIG_DEBUG_ATOMIC_SLEEP) && !blockable)
+				preempt_enable();
 			if (_ret) {
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 						mn->ops->invalidate_range_start, _ret,
-- 
2.19.1

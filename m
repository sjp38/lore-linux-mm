Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D77B96B2C38
	for <linux-mm@kvack.org>; Thu, 22 Nov 2018 11:51:15 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id l45so4780037edb.1
        for <linux-mm@kvack.org>; Thu, 22 Nov 2018 08:51:15 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p16-v6sor25801703eds.29.2018.11.22.08.51.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Nov 2018 08:51:14 -0800 (PST)
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Subject: [PATCH 1/3] mm: Check if mmu notifier callbacks are allowed to fail
Date: Thu, 22 Nov 2018 17:51:04 +0100
Message-Id: <20181122165106.18238-2-daniel.vetter@ffwll.ch>
In-Reply-To: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
References: <20181122165106.18238-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>, Intel Graphics Development <intel-gfx@lists.freedesktop.org>, DRI Development <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@ffwll.ch>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, =?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>, David Rientjes <rientjes@google.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Daniel Vetter <daniel.vetter@intel.com>

Just a bit of paranoia, since if we start pushing this deep into
callchains it's hard to spot all places where an mmu notifier
implementation might fail when it's not allowed to.

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
 mm/mmu_notifier.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/mmu_notifier.c b/mm/mmu_notifier.c
index 5119ff846769..59e102589a25 100644
--- a/mm/mmu_notifier.c
+++ b/mm/mmu_notifier.c
@@ -190,6 +190,8 @@ int __mmu_notifier_invalidate_range_start(struct mm_struct *mm,
 				pr_info("%pS callback failed with %d in %sblockable context.\n",
 						mn->ops->invalidate_range_start, _ret,
 						!blockable ? "non-" : "");
+				WARN(blockable,"%pS callback failure not allowed\n",
+				     mn->ops->invalidate_range_start);
 				ret = _ret;
 			}
 		}
-- 
2.19.1

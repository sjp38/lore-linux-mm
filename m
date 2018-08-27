Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 58CE16B4039
	for <linux-mm@kvack.org>; Mon, 27 Aug 2018 07:26:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b4-v6so2129196ede.4
        for <linux-mm@kvack.org>; Mon, 27 Aug 2018 04:26:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m44-v6sor504036edm.20.2018.08.27.04.26.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Aug 2018 04:26:38 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH 2/3] mm, mmu_notifier: be explicit about range invalition non-blocking mode
Date: Mon, 27 Aug 2018 13:26:22 +0200
Message-Id: <20180827112623.8992-3-mhocko@kernel.org>
In-Reply-To: <20180827112623.8992-1-mhocko@kernel.org>
References: <20180827112623.8992-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Jerome Glisse <jglisse@redhat.com>

From: Michal Hocko <mhocko@suse.com>

If invalidate_range_start is called for !blocking mode then all
callbacks have to guarantee they will no block/sleep. The same obviously
applies to invalidate_range_end because this operation pairs with the
former and they are called from the same context. Make sure this is
appropriately documented.

Cc: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/mmu_notifier.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index 133ba78820ee..698e371aafe3 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -153,7 +153,9 @@ struct mmu_notifier_ops {
 	 *
 	 * If blockable argument is set to false then the callback cannot
 	 * sleep and has to return with -EAGAIN. 0 should be returned
-	 * otherwise.
+	 * otherwise. Please note that if invalidate_range_start approves
+	 * a non-blocking behavior then the same applies to
+	 * invalidate_range_end.
 	 *
 	 */
 	int (*invalidate_range_start)(struct mmu_notifier *mn,
-- 
2.18.0

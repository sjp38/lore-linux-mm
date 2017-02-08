Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6760028089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 15:19:10 -0500 (EST)
Received: by mail-yw0-f198.google.com with SMTP id v73so176625363ywg.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 12:19:10 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id c4si2338117ywe.473.2017.02.08.12.19.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 12:19:09 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id l16so12742897ywb.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 12:19:09 -0800 (PST)
Date: Wed, 8 Feb 2017 15:19:07 -0500
From: Tejun Heo <tj@kernel.org>
Subject: [PATCH] block: fix double-free in the failure path of cgwb_bdi_init()
Message-ID: <20170208201907.GC25826@htj.duckdns.org>
References: <CACT4Y+ZsX1gQHdr7+tqhhB6CeKHBU=4VTMDj-meNbZ=uEPLKWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+ZsX1gQHdr7+tqhhB6CeKHBU=4VTMDj-meNbZ=uEPLKWA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <axboe@fb.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, xiakaixu@huawei.com, Vlastimil Babka <vbabka@suse.cz>, Joe Perches <joe@perches.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, syzkaller <syzkaller@googlegroups.com>

When !CONFIG_CGROUP_WRITEBACK, bdi has single bdi_writeback_congested
at bdi->wb_congested.  cgwb_bdi_init() allocates it with kzalloc() and
doesn't do further initialization.  This usually works fine as the
reference count gets bumped to 1 by wb_init() and the put from
wb_exit() releases it.

However, when wb_init() fails, it puts the wb base ref automatically
freeing the wb and the explicit kfree() in cgwb_bdi_init() error path
ends up trying to free the same pointer the second time causing a
double-free.

Fix it by explicitly initilizing the refcnt to 1 and putting the base
ref from cgwb_bdi_destroy().

Signed-off-by: Tejun Heo <tj@kernel.org>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Fixes: a13f35e87140 ("writeback: don't embed root bdi_writeback_congested in bdi_writeback")
Cc: stable@vger.kernel.org # v4.2+
---
Hello,

ISTR seeing another fix for this bug but can't find it right now.  If
I'm imagining things, please apply this one.  If not, either one is
fine.

Thanks.

 mm/backing-dev.c |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index 3bfed5ab..61b3407 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -758,15 +758,20 @@ static int cgwb_bdi_init(struct backing_dev_info *bdi)
 	if (!bdi->wb_congested)
 		return -ENOMEM;
 
+	atomic_set(&bdi->wb_congested->refcnt, 1);
+
 	err = wb_init(&bdi->wb, bdi, 1, GFP_KERNEL);
 	if (err) {
-		kfree(bdi->wb_congested);
+		wb_congested_put(bdi->wb_congested);
 		return err;
 	}
 	return 0;
 }
 
-static void cgwb_bdi_destroy(struct backing_dev_info *bdi) { }
+static void cgwb_bdi_destroy(struct backing_dev_info *bdi)
+{
+	wb_congested_put(bdi->wb_congested);
+}
 
 #endif	/* CONFIG_CGROUP_WRITEBACK */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

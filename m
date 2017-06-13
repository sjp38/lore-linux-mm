Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f71.google.com (mail-vk0-f71.google.com [209.85.213.71])
	by kanga.kvack.org (Postfix) with ESMTP id C86206B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 15:18:39 -0400 (EDT)
Received: by mail-vk0-f71.google.com with SMTP id 19so25478393vkd.11
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 12:18:39 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 77si377893uac.88.2017.06.13.12.18.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 12:18:38 -0700 (PDT)
Date: Tue, 13 Jun 2017 22:18:20 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH] mm, vmpressure: free the same pointer we allocated
Message-ID: <20170613191820.GA20003@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

We keep incrementing "spec" as we parse the args so we end up calling
kfree() on a modified of spec.  It probably works or this would have
been caught in testing, but it looks weird.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 0781b1363e0a..1225ec5d9596 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -386,11 +386,11 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 	struct vmpressure_event *ev;
 	enum vmpressure_modes mode = VMPRESSURE_NO_PASSTHROUGH;
 	enum vmpressure_levels level = -1;
-	char *spec = NULL;
+	char *spec, *spec_orig;
 	char *token;
 	int ret = 0;
 
-	spec = kzalloc(MAX_VMPRESSURE_ARGS_LEN + 1, GFP_KERNEL);
+	spec_orig = spec = kzalloc(MAX_VMPRESSURE_ARGS_LEN + 1, GFP_KERNEL);
 	if (!spec) {
 		ret = -ENOMEM;
 		goto out;
@@ -429,7 +429,7 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 	list_add(&ev->node, &vmpr->events);
 	mutex_unlock(&vmpr->events_lock);
 out:
-	kfree(spec);
+	kfree(spec_orig);
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

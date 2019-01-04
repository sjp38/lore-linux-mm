Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 48A578E00F9
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 13:37:31 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id o8so17057808otp.16
        for <linux-mm@kvack.org>; Fri, 04 Jan 2019 10:37:31 -0800 (PST)
Received: from gateway20.websitewelcome.com (gateway20.websitewelcome.com. [192.185.63.14])
        by mx.google.com with ESMTPS id t4si602313otj.108.2019.01.04.10.37.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Jan 2019 10:37:30 -0800 (PST)
Received: from cm10.websitewelcome.com (cm10.websitewelcome.com [100.42.49.4])
	by gateway20.websitewelcome.com (Postfix) with ESMTP id E78CA400C4C02
	for <linux-mm@kvack.org>; Fri,  4 Jan 2019 12:37:29 -0600 (CST)
Date: Fri, 4 Jan 2019 12:37:26 -0600
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] mm: memcontrol: use struct_size() in kmalloc()
Message-ID: <20190104183726.GA6374@embeddedor>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Gustavo A. R. Silva" <gustavo@embeddedor.com>

One of the more common cases of allocation size calculations is finding
the size of a structure that has a zero-sized array at the end, along
with memory for some number of elements for that array. For example:

struct foo {
    int stuff;
    void *entry[];
};

instance = kmalloc(sizeof(struct foo) + sizeof(void *) * count, GFP_KERNEL);

Instead of leaving these open-coded and prone to type mistakes, we can
now use the new struct_size() helper:

instance = kmalloc(struct_size(instance, entry, count), GFP_KERNEL);

This code was detected with the help of Coccinelle.

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 mm/memcontrol.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index af7f18b32389..ad256cf7da47 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -3626,8 +3626,7 @@ static int __mem_cgroup_usage_register_event(struct mem_cgroup *memcg,
 	size = thresholds->primary ? thresholds->primary->size + 1 : 1;
 
 	/* Allocate memory for new array of thresholds */
-	new = kmalloc(sizeof(*new) + size * sizeof(struct mem_cgroup_threshold),
-			GFP_KERNEL);
+	new = kmalloc(struct_size(new, entries, size), GFP_KERNEL);
 	if (!new) {
 		ret = -ENOMEM;
 		goto unlock;
-- 
2.20.1

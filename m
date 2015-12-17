Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f46.google.com (mail-lf0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id D16EB4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 07:30:53 -0500 (EST)
Received: by mail-lf0-f46.google.com with SMTP id p203so51259036lfa.0
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 04:30:53 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id kh3si7588596lbc.34.2015.12.17.04.30.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 04:30:52 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 7/7] Documentation: cgroup: add memory.swap.{current,max} description
Date: Thu, 17 Dec 2015 15:30:00 +0300
Message-ID: <dbb4bf6bc071997982855c8f7d403c22cea60ffb.1450352792.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1450352791.git.vdavydov@virtuozzo.com>
References: <cover.1450352791.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

The rationale of separate swap counter is given by Johannes Weiner.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
Changes in v2:
 - Add rationale of separate swap counter provided by Johannes.

 Documentation/cgroup.txt | 33 +++++++++++++++++++++++++++++++++
 1 file changed, 33 insertions(+)

diff --git a/Documentation/cgroup.txt b/Documentation/cgroup.txt
index 31d1f7bf12a1..f441564023e1 100644
--- a/Documentation/cgroup.txt
+++ b/Documentation/cgroup.txt
@@ -819,6 +819,22 @@ PAGE_SIZE multiple when read back.
 		the cgroup.  This may not exactly match the number of
 		processes killed but should generally be close.
 
+  memory.swap.current
+
+	A read-only single value file which exists on non-root
+	cgroups.
+
+	The total amount of swap currently being used by the cgroup
+	and its descendants.
+
+  memory.swap.max
+
+	A read-write single value file which exists on non-root
+	cgroups.  The default is "max".
+
+	Swap usage hard limit.  If a cgroup's swap usage reaches this
+	limit, anonymous meomry of the cgroup will not be swapped out.
+
 
 5-2-2. General Usage
 
@@ -1291,3 +1307,20 @@ allocation from the slack available in other groups or the rest of the
 system than killing the group.  Otherwise, memory.max is there to
 limit this type of spillover and ultimately contain buggy or even
 malicious applications.
+
+The combined memory+swap accounting and limiting is replaced by real
+control over swap space.
+
+The main argument for a combined memory+swap facility in the original
+cgroup design was that global or parental pressure would always be
+able to swap all anonymous memory of a child group, regardless of the
+child's own (possibly untrusted) configuration.  However, untrusted
+groups can sabotage swapping by other means - such as referencing its
+anonymous memory in a tight loop - and an admin can not assume full
+swappability when overcommitting untrusted jobs.
+
+For trusted jobs, on the other hand, a combined counter is not an
+intuitive userspace interface, and it flies in the face of the idea
+that cgroup controllers should account and limit specific physical
+resources.  Swap space is a resource like all others in the system,
+and that's why unified hierarchy allows distributing it separately.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

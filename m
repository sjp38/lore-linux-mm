Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id EBF4B8D0039
	for <linux-mm@kvack.org>; Wed, 16 Feb 2011 20:49:40 -0500 (EST)
Message-ID: <4D5C7F00.2050802@cn.fujitsu.com>
Date: Thu, 17 Feb 2011 09:50:56 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH 4/4] cpuset: Hold callback_mutex in cpuset_clone()
References: <4D5C7EA7.1030409@cn.fujitsu.com>
In-Reply-To: <4D5C7EA7.1030409@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, linux-mm@kvack.org

Chaning cpuset->mems/cpuset->cpus should be protected under
callback_mutex.

cpuset_clone() doesn't follow this rule. It's ok because it's
called when creating and initializing a cgroup, but we'd better
hold the lock to avoid subtil break in the future.

Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 1e18d26..445573b 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1840,8 +1840,10 @@ static void cpuset_post_clone(struct cgroup_subsys *ss,
 	cs = cgroup_cs(cgroup);
 	parent_cs = cgroup_cs(parent);
 
+	mutex_lock(&callback_mutex);
 	cs->mems_allowed = parent_cs->mems_allowed;
 	cpumask_copy(cs->cpus_allowed, parent_cs->cpus_allowed);
+	mutex_unlock(&callback_mutex);
 	return;
 }
 
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DCBB48D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 01:56:06 -0500 (EST)
Message-ID: <4D660167.7070400@cn.fujitsu.com>
Date: Thu, 24 Feb 2011 14:57:43 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: [PATCH v2 4/4] cpuset: Hold callback_mutex in cpuset_clone()
References: <4D660130.8020009@cn.fujitsu.com>
In-Reply-To: <4D660130.8020009@cn.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Menage <menage@google.com>, David Rientjes <rientjes@google.com>, =?UTF-8?B?57yqIOWLsA==?= <miaox@cn.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Chaning cpuset->mems/cpuset->cpus should be protected under
callback_mutex.

cpuset_post_clone() doesn't follow this rule. It's ok because it's
called when creating/initializing a cgroup, but we'd better
hold the lock to avoid subtil break in the future.

Acked-by: Paul Menage <menage@google.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
---
 kernel/cpuset.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 3f93e5a..1ca786a 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1836,8 +1836,10 @@ static void cpuset_post_clone(struct cgroup_subsys *ss,
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

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id 19F1C6B009B
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 21:48:55 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so678402pad.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 18:48:54 -0800 (PST)
Date: Tue, 20 Nov 2012 18:48:52 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, memcg: avoid unnecessary function call when memcg is
 disabled fix
In-Reply-To: <50AC282A.4070309@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1211201847450.2278@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1211191741060.24618@chino.kir.corp.google.com> <20121120134932.055bc192.akpm@linux-foundation.org> <50AC282A.4070309@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org

Move the check for !mm out of line as suggested by Andrew.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/memcontrol.h |    2 +-
 mm/memcontrol.c            |    3 +++
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -185,7 +185,7 @@ void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx);
 static inline void mem_cgroup_count_vm_event(struct mm_struct *mm,
 					     enum vm_event_item idx)
 {
-	if (mem_cgroup_disabled() || !mm)
+	if (mem_cgroup_disabled())
 		return;
 	__mem_cgroup_count_vm_event(mm, idx);
 }
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1021,6 +1021,9 @@ void __mem_cgroup_count_vm_event(struct mm_struct *mm, enum vm_event_item idx)
 {
 	struct mem_cgroup *memcg;
 
+	if (!mm)
+		return;
+
 	rcu_read_lock();
 	memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
 	if (unlikely(!memcg))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

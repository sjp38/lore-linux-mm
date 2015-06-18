Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id F1DC76B0087
	for <linux-mm@kvack.org>; Thu, 18 Jun 2015 19:00:11 -0400 (EDT)
Received: by iefd2 with SMTP id d2so8113325ief.2
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 16:00:11 -0700 (PDT)
Received: from mail-ig0-x231.google.com (mail-ig0-x231.google.com. [2607:f8b0:4001:c05::231])
        by mx.google.com with ESMTPS id f16si576588igo.41.2015.06.18.16.00.11
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jun 2015 16:00:11 -0700 (PDT)
Received: by igblz2 with SMTP id lz2so2266926igb.1
        for <linux-mm@kvack.org>; Thu, 18 Jun 2015 16:00:11 -0700 (PDT)
Date: Thu, 18 Jun 2015 16:00:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/3] mm, oom: do not panic for oom kills triggered from
 sysrq
In-Reply-To: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1506181556330.13736@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1506181555350.13736@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Sysrq+f is used to kill a process either for debug or when the VM is
otherwise unresponsive.

It is not intended to trigger a panic when no process may be killed.

Avoid panicking the system for sysrq+f when no processes are killed.

Suggested-by: Michal Hocko <mhocko@suse.cz>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/sysrq.txt | 3 ++-
 mm/oom_kill.c           | 7 +++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/Documentation/sysrq.txt b/Documentation/sysrq.txt
--- a/Documentation/sysrq.txt
+++ b/Documentation/sysrq.txt
@@ -75,7 +75,8 @@ On all -  write a character to /proc/sysrq-trigger.  e.g.:
 
 'e'     - Send a SIGTERM to all processes, except for init.
 
-'f'	- Will call oom_kill to kill a memory hog process.
+'f'	- Will call the oom killer to kill a memory hog process, but do not
+	  panic if nothing can be killed.
 
 'g'	- Used by kgdb (kernel debugger)
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -607,6 +607,9 @@ void check_panic_on_oom(struct oom_control *oc, enum oom_constraint constraint,
 		if (constraint != CONSTRAINT_NONE)
 			return;
 	}
+	/* Do not panic for oom kills triggered by sysrq */
+	if (oc->order == -1)
+		return;
 	dump_header(oc, NULL, memcg);
 	panic("Out of memory: %s panic_on_oom is enabled\n",
 		sysctl_panic_on_oom == 2 ? "compulsory" : "system-wide");
@@ -686,11 +689,11 @@ bool out_of_memory(struct oom_control *oc)
 
 	p = select_bad_process(oc, &points, totalpages);
 	/* Found nothing?!?! Either we hang forever, or we panic. */
-	if (!p) {
+	if (!p && oc->order != -1) {
 		dump_header(oc, NULL, NULL);
 		panic("Out of memory and no killable processes...\n");
 	}
-	if (p != (void *)-1UL) {
+	if (p && p != (void *)-1UL) {
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
 		killed = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

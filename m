Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3145E6B0038
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:48:48 -0500 (EST)
Received: by mail-ee0-f44.google.com with SMTP id c13so475028eek.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 12:48:47 -0800 (PST)
Received: from mail.windriver.com (mail.windriver.com. [147.11.1.11])
        by mx.google.com with ESMTPS id p46si3376292eem.42.2014.01.14.12.48.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 12:48:47 -0800 (PST)
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 2/3] kernel: audit/fix non-modular users of module_init in core code
Date: Tue, 14 Jan 2014 15:44:47 -0500
Message-ID: <1389732288-4389-3-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <1389732288-4389-1-git-send-email-paul.gortmaker@windriver.com>
References: <1389732288-4389-1-git-send-email-paul.gortmaker@windriver.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Paul Gortmaker <paul.gortmaker@windriver.com>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Eric Biederman <ebiederm@xmission.com>

Code that is obj-y (always built-in) or dependent on a bool Kconfig
(built-in or absent) can never be modular.  So using module_init as
an alias for __initcall can be somewhat misleading.

Fix these up now, so that we can relocate module_init from
init.h into module.h in the future.  If we don't do this, we'd
have to add module.h to obviously non-modular code, and that
would be a worse thing.

The audit targets the following module_init users for change:
 kernel/user.c                  obj-y
 kernel/kexec.c                 bool KEXEC (one instance per arch)
 kernel/profile.c               bool PROFILING
 kernel/hung_task.c             bool DETECT_HUNG_TASK
 kernel/sched/stats.c           bool SCHEDSTATS
 kernel/user_namespace.c        bool USER_NS

Note that direct use of __initcall is discouraged, vs. one
of the priority categorized subgroups.  As __initcall gets
mapped onto device_initcall, our use of subsys_initcall (which
makes sense for these files) will thus change this registration
from level 6-device to level 4-subsys (i.e. slightly earlier).
However no observable impact of that difference has been observed
during testing.

Also, two instances of missing ";" at EOL are fixed in kexec.

Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Eric Biederman <ebiederm@xmission.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 kernel/hung_task.c      | 3 +--
 kernel/kexec.c          | 4 ++--
 kernel/profile.c        | 2 +-
 kernel/sched/stats.c    | 2 +-
 kernel/user.c           | 3 +--
 kernel/user_namespace.c | 2 +-
 6 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/kernel/hung_task.c b/kernel/hung_task.c
index 9328b80eaf14..7899ee9dd212 100644
--- a/kernel/hung_task.c
+++ b/kernel/hung_task.c
@@ -244,5 +244,4 @@ static int __init hung_task_init(void)
 
 	return 0;
 }
-
-module_init(hung_task_init);
+subsys_initcall(hung_task_init);
diff --git a/kernel/kexec.c b/kernel/kexec.c
index 9c970167e402..418f069b0314 100644
--- a/kernel/kexec.c
+++ b/kernel/kexec.c
@@ -1234,7 +1234,7 @@ static int __init crash_notes_memory_init(void)
 	}
 	return 0;
 }
-module_init(crash_notes_memory_init)
+subsys_initcall(crash_notes_memory_init);
 
 
 /*
@@ -1628,7 +1628,7 @@ static int __init crash_save_vmcoreinfo_init(void)
 	return 0;
 }
 
-module_init(crash_save_vmcoreinfo_init)
+subsys_initcall(crash_save_vmcoreinfo_init);
 
 /*
  * Move into place and start executing a preloaded standalone
diff --git a/kernel/profile.c b/kernel/profile.c
index 6631e1ef55ab..b37576b22acc 100644
--- a/kernel/profile.c
+++ b/kernel/profile.c
@@ -604,5 +604,5 @@ int __ref create_proc_profile(void) /* false positive from hotcpu_notifier */
 	hotcpu_notifier(profile_cpu_callback, 0);
 	return 0;
 }
-module_init(create_proc_profile);
+subsys_initcall(create_proc_profile);
 #endif /* CONFIG_PROC_FS */
diff --git a/kernel/sched/stats.c b/kernel/sched/stats.c
index da98af347e8b..a476bea17fbc 100644
--- a/kernel/sched/stats.c
+++ b/kernel/sched/stats.c
@@ -142,4 +142,4 @@ static int __init proc_schedstat_init(void)
 	proc_create("schedstat", 0, NULL, &proc_schedstat_operations);
 	return 0;
 }
-module_init(proc_schedstat_init);
+subsys_initcall(proc_schedstat_init);
diff --git a/kernel/user.c b/kernel/user.c
index c006131beb77..294fc6a94168 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -222,5 +222,4 @@ static int __init uid_cache_init(void)
 
 	return 0;
 }
-
-module_init(uid_cache_init);
+subsys_initcall(uid_cache_init);
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 240fb62cf394..4f211868e6a2 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -902,4 +902,4 @@ static __init int user_namespaces_init(void)
 	user_ns_cachep = KMEM_CACHE(user_namespace, SLAB_PANIC);
 	return 0;
 }
-module_init(user_namespaces_init);
+subsys_initcall(user_namespaces_init);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

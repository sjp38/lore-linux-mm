Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 503A56B026A
	for <linux-mm@kvack.org>; Mon,  7 May 2018 03:56:43 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id h129-v6so8674984lfg.14
        for <linux-mm@kvack.org>; Mon, 07 May 2018 00:56:43 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l18-v6sor1247339lfi.69.2018.05.07.00.56.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 07 May 2018 00:56:42 -0700 (PDT)
Message-Id: <20180507075606.870903028@gmail.com>
Date: Mon, 07 May 2018 10:52:16 +0300
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [rfc linux-next 3/3] [RFC] prctl: prctl_set_mm -- Bring back handling of PR_SET_MM_x
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline; filename=prctl-back-set-mm-x
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Jonathan de Boyne Pollard <J.deBoynePollard-newsgroups@NTLWorld.COM>, Andrey Vagin <avagin@openvz.org>, Andrew Morton <akpm@linuxfoundation.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Yang Shi <yang.shi@linux.alibaba.com>, Michal Hocko <mhocko@kernel.org>, Cyrill Gorcunov <gorcunov@gmail.com>

Recently the handling of PR_SET_MM_x been removed because we wanted to
improve locking scheme over mm::arg_start,arg_end and etc. Thus to
reduce code modification the old PR_SET_MM_x operations have been
removed (since initially they've been introduced for c/r sole sake).
Before making remove I googled if there are some users of this interface
exist and happened to miss that at least systemd is already using
PR_SET_MM_ARG_START and PR_SET_MM_ARG_END (see src/basic/process-util.c)

Also Jonathan pointed me that there is a need for sole PR_SET_MM_x
operations.

https://lkml.org/lkml/2018/5/6/127

Here is a trick: since prctl_set_mm_map now accepts struct prctl_mm_map
as an argument we can fetch current mm settings, modify the member requested
and send the map into prctl_set_mm_map directly, which simply gonna be
like an emulation of PR_SET_MM_MAP. Thus users of PR_SET_MM_x should
be able to continue utilizing the interface.

CC: Jonathan de Boyne Pollard <J.deBoynePollard-newsgroups@NTLWorld.COM>
CC: Andrey Vagin <avagin@openvz.org>
CC: Andrew Morton <akpm@linuxfoundation.org>
CC: Michael Kerrisk <mtk.manpages@gmail.com>
CC: Yang Shi <yang.shi@linux.alibaba.com>
CC: Michal Hocko <mhocko@kernel.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@gmail.com>
---
 kernel/sys.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 57 insertions(+), 8 deletions(-)

Index: linux-ml.git/kernel/sys.c
===================================================================
--- linux-ml.git.orig/kernel/sys.c
+++ linux-ml.git/kernel/sys.c
@@ -1815,7 +1815,6 @@ SYSCALL_DEFINE1(umask, int, mask)
 	return mask;
 }
 
-#ifdef CONFIG_CHECKPOINT_RESTORE
 /*
  * WARNING: we don't require any capability here so be very careful
  * in what is allowed for modification from userspace.
@@ -2046,19 +2045,36 @@ static int prctl_set_mm_map(struct prctl
 	up_read(&mm->mmap_sem);
 	return 0;
 }
-#endif /* CONFIG_CHECKPOINT_RESTORE */
 
 static int prctl_set_mm(int opt, unsigned long addr,
 			unsigned long arg4, unsigned long arg5)
 {
-#ifdef CONFIG_CHECKPOINT_RESTORE
+	static const unsigned char offsets[] = {
+		[PR_SET_MM_START_CODE]	= offsetof(struct prctl_mm_map, start_code),
+		[PR_SET_MM_END_CODE]	= offsetof(struct prctl_mm_map, end_code),
+		[PR_SET_MM_START_DATA]	= offsetof(struct prctl_mm_map, start_data),
+		[PR_SET_MM_END_DATA]	= offsetof(struct prctl_mm_map, end_data),
+		[PR_SET_MM_START_STACK]	= offsetof(struct prctl_mm_map, start_brk),
+		[PR_SET_MM_START_BRK]	= offsetof(struct prctl_mm_map, brk),
+		[PR_SET_MM_BRK]		= offsetof(struct prctl_mm_map, start_stack),
+		[PR_SET_MM_ARG_START]	= offsetof(struct prctl_mm_map, arg_start),
+		[PR_SET_MM_ARG_END]	= offsetof(struct prctl_mm_map, arg_end),
+		[PR_SET_MM_ENV_START]	= offsetof(struct prctl_mm_map, env_start),
+		[PR_SET_MM_ENV_END]	= offsetof(struct prctl_mm_map, env_end),
+	};
+	struct prctl_mm_map prctl_map = { .exe_fd = (u32)-1, };
+	struct mm_struct *mm = current->mm;
+
+	if (arg5 || (arg4 && (opt != PR_SET_MM_AUXV &&
+			      opt != PR_SET_MM_MAP &&
+			      opt != PR_SET_MM_MAP_SIZE)))
+		return -EINVAL;
+
 	if (opt == PR_SET_MM_MAP_SIZE)
 		return put_user((unsigned int)sizeof(struct prctl_mm_map),
 				(unsigned int __user *)addr);
 
 	if (opt == PR_SET_MM_MAP) {
-		struct prctl_mm_map prctl_map = { .exe_fd = (u32)-1, };
-
 		if (arg4 != sizeof(prctl_map))
 			return -EINVAL;
 
@@ -2068,10 +2084,43 @@ static int prctl_set_mm(int opt, unsigne
 
 		return prctl_set_mm_map(&prctl_map);
 	}
-#endif
 
-	pr_warn_once("PR_SET_MM_* has been removed. Use PR_SET_MM_MAP instead\n");
-	return -EINVAL;
+	if (!capable(CAP_SYS_RESOURCE))
+		return -EPERM;
+
+	if (opt == PR_SET_MM_EXE_FILE)
+		return prctl_set_mm_exe_file(mm, (unsigned int)addr);
+
+	if (opt == PR_SET_MM_AUXV)
+		return prctl_set_auxv(mm, addr, arg4);
+
+	if (opt < 1 || opt >= ARRAY_SIZE(offsets))
+		return -EINVAL;
+
+	/*
+	 * Emulate PR_SET_MM_MAP call by filling with
+	 * current values and setting one field from
+	 * the request.
+	 */
+	down_read(&mm->mmap_sem);
+	spin_lock(&mm->arg_lock);
+	prctl_map.start_code	= mm->start_code;
+	prctl_map.end_code	= mm->end_code;
+	prctl_map.start_data	= mm->start_data;
+	prctl_map.end_data	= mm->end_data;
+	prctl_map.start_brk	= mm->start_brk;
+	prctl_map.brk		= mm->brk;
+	prctl_map.start_stack	= mm->start_stack;
+	prctl_map.arg_start	= mm->arg_start;
+	prctl_map.arg_end	= mm->arg_end;
+	prctl_map.env_start	= mm->env_start;
+	prctl_map.env_end	= mm->env_end;
+	spin_unlock(&mm->arg_lock);
+	up_read(&mm->mmap_sem);
+
+	*(unsigned long *)((char *)&prctl_map + offsets[opt]) = addr;
+
+	return prctl_set_mm_map(&prctl_map, opt);
 }
 
 #ifdef CONFIG_CHECKPOINT_RESTORE

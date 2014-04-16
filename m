Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0006E6B0055
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 00:19:09 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d17so8210225eek.18
        for <linux-mm@kvack.org>; Tue, 15 Apr 2014 21:19:09 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q5si28113292eem.231.2014.04.15.21.19.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 15 Apr 2014 21:19:08 -0700 (PDT)
From: NeilBrown <neilb@suse.de>
Date: Wed, 16 Apr 2014 14:03:36 +1000
Subject: [PATCH 11/19] FS: set PF_FSTRANS while holding mmap_sem in exec.c
Message-ID: <20140416040336.10604.31309.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: xfs@oss.sgi.com

Because mmap_sem is sometimes(*) taken while holding a sock lock,
and the sock lock might be needed for reclaim (at least when loop-back
NFS is active), we must not block on FS reclaim while mmap_sem is
held.

exec.c allocates memory while holding mmap_sem, and so needs
PF_FSTRANS protection.

* lockdep reports:
[   57.653355]    [<ffffffff810eb068>] lock_acquire+0xa8/0x1f0
[   57.653355]    [<ffffffff811835a4>] might_fault+0x84/0xb0
[   57.653355]    [<ffffffff81aec65d>] do_ip_setsockopt.isra.18+0x93d/0xed0
[   57.653355]    [<ffffffff81aecc17>] ip_setsockopt+0x27/0x90
[   57.653355]    [<ffffffff81b15146>] udp_setsockopt+0x16/0x30
[   57.653355]    [<ffffffff81a913cf>] sock_common_setsockopt+0xf/0x20
[   57.653355]    [<ffffffff81a9075e>] SyS_setsockopt+0x5e/0xc0
[   57.653355]    [<ffffffff81c3d062>] system_call_fastpath+0x16/0x1b

to explain why mmap_sem might be taken while sock lock is held.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/exec.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/exec.c b/fs/exec.c
index 3d78fccdd723..2c70a03ddb2b 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -652,6 +652,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 	unsigned long stack_size;
 	unsigned long stack_expand;
 	unsigned long rlim_stack;
+	unsigned int pflags;
 
 #ifdef CONFIG_STACK_GROWSUP
 	/* Limit stack size to 1GB */
@@ -688,6 +689,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 
 	down_write(&mm->mmap_sem);
 	vm_flags = VM_STACK_FLAGS;
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	/*
 	 * Adjust stack execute permissions; explicitly enable for
@@ -741,6 +743,7 @@ int setup_arg_pages(struct linux_binprm *bprm,
 		ret = -EFAULT;
 
 out_unlock:
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	up_write(&mm->mmap_sem);
 	return ret;
 }
@@ -1369,6 +1372,7 @@ int search_binary_handler(struct linux_binprm *bprm)
 	bool need_retry = IS_ENABLED(CONFIG_MODULES);
 	struct linux_binfmt *fmt;
 	int retval;
+	unsigned int pflags;
 
 	/* This allows 4 levels of binfmt rewrites before failing hard. */
 	if (bprm->recursion_depth > 5)
@@ -1381,6 +1385,7 @@ int search_binary_handler(struct linux_binprm *bprm)
 	retval = -ENOENT;
  retry:
 	read_lock(&binfmt_lock);
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 	list_for_each_entry(fmt, &formats, lh) {
 		if (!try_module_get(fmt->module))
 			continue;
@@ -1396,6 +1401,7 @@ int search_binary_handler(struct linux_binprm *bprm)
 		read_lock(&binfmt_lock);
 		put_binfmt(fmt);
 	}
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 	read_unlock(&binfmt_lock);
 
 	if (need_retry && retval == -ENOEXEC) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

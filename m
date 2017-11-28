Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9A0176B0297
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:51 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id l25so8008397pfb.13
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g70sor7087954pgc.145.2017.11.27.23.49.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:50 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 09/18] vchecker: Support toggle on/off of callstack check
Date: Tue, 28 Nov 2017 16:48:44 +0900
Message-Id: <1511855333-3570-10-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Namhyung Kim <namhyung@kernel.org>

By default, callstack checker only collects callchains.  When a user
writes 'on' to the callstack file in debugfs, it checks and reports new
callstacks.  Writing 'off' to disable it again.

  # cd /sys/kernel/debug/vchecker
  # echo 0 8 > anon_vma/callstack
  # echo 1 > anon_vma/enable

  ... (do some work to collect enough callstacks) ...

  # echo on > anon_vma/callstack

Signed-off-by: Namhyung Kim <namhyung@kernel.org>
Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/kasan/vchecker.c | 31 +++++++++++++++++++++++++++++--
 1 file changed, 29 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/vchecker.c b/mm/kasan/vchecker.c
index 0c9a4fc..6b3824f 100644
--- a/mm/kasan/vchecker.c
+++ b/mm/kasan/vchecker.c
@@ -69,6 +69,7 @@ struct vchecker_value_arg {
 struct vchecker_callstack_arg {
 	depot_stack_handle_t *handles;
 	atomic_t count;
+	bool enabled;
 };
 
 static struct dentry *debugfs_root;
@@ -698,8 +699,7 @@ static bool check_callstack(struct kmem_cache *s, struct vchecker_cb *cb,
 	if (idx < CALLSTACK_MAX_HANDLE)
 		arg->handles[idx] = handle;
 
-	/* TODO: support reporting new callstack */
-	return true;
+	return !arg->enabled;
 }
 
 static int callstack_show(struct seq_file *f, void *v)
@@ -712,9 +712,36 @@ static int callstack_open(struct inode *inode, struct file *file)
 	return single_open(file, callstack_show, inode->i_private);
 }
 
+static void callstack_onoff(struct file *filp, bool enable)
+{
+	struct kmem_cache *s = file_inode(filp)->i_private;
+	struct vchecker_cb *cb;
+
+	mutex_lock(&vchecker_meta);
+	list_for_each_entry(cb, &s->vchecker_cache.checker->cb_list, list) {
+		if (cb->type == &vchecker_types[VCHECKER_TYPE_CALLSTACK]) {
+			struct vchecker_callstack_arg *arg = cb->arg;
+
+			arg->enabled = enable;
+		}
+	}
+	mutex_unlock(&vchecker_meta);
+}
+
 static ssize_t callstack_write(struct file *filp, const char __user *ubuf,
 			       size_t cnt, loff_t *ppos)
 {
+	char buf[4];
+
+	if (copy_from_user(buf, ubuf, 4))
+		return -EFAULT;
+
+	/* turn on/off existing callstack checkers */
+	if (!strncmp(buf, "on", 2) || !strncmp(buf, "off", 3)) {
+		callstack_onoff(filp, buf[1] == 'n');
+		return cnt;
+	}
+
 	/* add a new (disabled) callstack checker at the given offset */
 	return vchecker_type_write(filp, ubuf, cnt, ppos,
 				   VCHECKER_TYPE_CALLSTACK);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

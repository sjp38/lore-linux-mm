Subject: [PATCH] reject '\n' in a cgroup name
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Message-Id: <20080124052049.A2A8A1E3C0D@siro.lan>
Date: Thu, 24 Jan 2008 14:20:49 +0900 (JST)
From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: containers@lists.osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi,

the following patch rejects '\n' in a cgroup name.
otherwise /proc/$$/cgroup is not parsable.

example:
	imawoto% cat /proc/$$/cgroup
	memory:/
	imawoto% mkdir -p "
	memory:/foo"
	imawoto% echo $$ >| "
	memory:/foo/tasks"
	imawoto% cat /proc/$$/cgroup
	memory:/
	memory:/foo
	imawoto% 

YAMAMOTO Takashi


Signed-off-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
---

--- linux-2.6.24-rc8-mm1/kernel/cgroup.c.BACKUP	2008-01-23 14:43:29.000000000 +0900
+++ linux-2.6.24-rc8-mm1/kernel/cgroup.c	2008-01-24 13:56:28.000000000 +0900
@@ -2216,6 +2216,10 @@ static long cgroup_create(struct cgroup 
 	struct cgroup_subsys *ss;
 	struct super_block *sb = root->sb;
 
+	/* reject a newline.  otherwise /proc/$$/cgroup is not parsable. */
+	if (strchr(dentry->d_name.name, '\n'))
+		return -EINVAL;
+
 	cgrp = kzalloc(sizeof(*cgrp), GFP_KERNEL);
 	if (!cgrp)
 		return -ENOMEM;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

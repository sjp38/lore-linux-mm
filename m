Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id D7E8060021B
	for <linux-mm@kvack.org>; Mon,  7 Dec 2009 13:41:19 -0500 (EST)
Received: by fxm9 with SMTP id 9so4701017fxm.10
        for <linux-mm@kvack.org>; Mon, 07 Dec 2009 10:41:16 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 7 Dec 2009 20:41:16 +0200
Message-ID: <cc557aab0912071041j5c5731dbj9fd669ef26e6f2ae@mail.gmail.com>
Subject: [BUG?] [PATCH] soft limits and root cgroups
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

Currently, mem_cgroup_update_tree() on root cgroup calls only on
uncharge, not on charge.

Is it a bug or not?

Patch to fix, if it's a bug:

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 8aa6026..6babef1 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1366,13 +1366,15 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm
                        goto nomem;
                }
        }
+
+done:
        /*
         * Insert ancestor (and ancestor's ancestors), to softlimit RB-tree.
         * if they exceeds softlimit.
         */
        if (mem_cgroup_soft_limit_check(mem))
                mem_cgroup_update_tree(mem, page);
-done:
+
        return 0;
 nomem:
        css_put(&mem->css);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

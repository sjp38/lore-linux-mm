Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id F20B76B007B
	for <linux-mm@kvack.org>; Mon,  9 Mar 2015 17:11:19 -0400 (EDT)
Received: by wiwh11 with SMTP id h11so14913898wiw.5
        for <linux-mm@kvack.org>; Mon, 09 Mar 2015 14:11:19 -0700 (PDT)
Received: from kirsi1.inet.fi (mta-out1.inet.fi. [62.71.2.203])
        by mx.google.com with ESMTP id d2si792861wib.111.2015.03.09.14.11.18
        for <linux-mm@kvack.org>;
        Mon, 09 Mar 2015 14:11:18 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [RFC, PATCH] pagemap: do not leak physical addresses to non-privileged userspace
Date: Mon,  9 Mar 2015 23:11:12 +0200
Message-Id: <1425935472-17949-1-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Emelyanov <xemul@parallels.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Mark Seaborn <mseaborn@chromium.org>, Andy Lutomirski <luto@amacapital.net>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

As pointed by recent post[1] on exploiting DRAM physical imperfection,
/proc/PID/pagemap exposes sensitive information which can be used to do
attacks.

This is RFC patch which disallow anybody without CAP_SYS_ADMIN to read
the pagemap.

Any comments?

[1] http://googleprojectzero.blogspot.com/2015/03/exploiting-dram-rowhammer-bug-to-gain.html

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Seaborn <mseaborn@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
---
 fs/proc/task_mmu.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 246eae84b13b..b72b36e64286 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1322,6 +1322,9 @@ out:
 
 static int pagemap_open(struct inode *inode, struct file *file)
 {
+	/* do not disclose physical addresses: attack vector */
+	if (!capable(CAP_SYS_ADMIN))
+		return -EPERM;
 	pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
 			"to stop being page-shift some time soon. See the "
 			"linux/Documentation/vm/pagemap.txt for details.\n");
-- 
2.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

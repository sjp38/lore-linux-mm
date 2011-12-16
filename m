Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id 1284C6B004D
	for <linux-mm@kvack.org>; Fri, 16 Dec 2011 06:22:33 -0500 (EST)
Date: Fri, 16 Dec 2011 12:25:34 +0100
From: Djalal Harouni <tixxdz@opendz.org>
Subject: [PATCH] mm: add missing mutex lock arround notify_change
Message-ID: <20111216112534.GA13147@dztty>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wu Fengguang <fengguang.wu@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


Calls to notify_change() must hold i_mutex.

Signed-off-by: Djalal Harouni <tixxdz@opendz.org>
---
 mm/filemap.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index c106d3b..0670ec1 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1994,10 +1994,16 @@ EXPORT_SYMBOL(should_remove_suid);
 
 static int __remove_suid(struct dentry *dentry, int kill)
 {
+	int ret;
 	struct iattr newattrs;
 
 	newattrs.ia_valid = ATTR_FORCE | kill;
-	return notify_change(dentry, &newattrs);
+
+	mutex_lock(&dentry->d_inode->i_mutex);
+	ret = notify_change(dentry, &newattrs);
+	mutex_unlock(&dentry->d_inode->i_mutex);
+
+	return ret;
 }
 
 int file_remove_suid(struct file *file)
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

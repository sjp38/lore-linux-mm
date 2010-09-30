Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A69D56B0083
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 23:50:57 -0400 (EDT)
Received: by mail-iw0-f169.google.com with SMTP id 33so2614800iwn.14
        for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:50:56 -0700 (PDT)
From: Namhyung Kim <namhyung@gmail.com>
Subject: [PATCH 10/12] vmalloc: annotate lock context change on s_start/stop()
Date: Thu, 30 Sep 2010 12:50:19 +0900
Message-Id: <1285818621-29890-11-git-send-email-namhyung@gmail.com>
In-Reply-To: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
References: <1285818621-29890-1-git-send-email-namhyung@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

s_start() and s_stop() grab/release vmlist_lock but were missing proper
annotations. Add them.

Signed-off-by: Namhyung Kim <namhyung@gmail.com>
---
 mm/vmalloc.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 7ce8ca5..0be8470 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2339,6 +2339,7 @@ void pcpu_free_vm_areas(struct vm_struct **vms, int nr_vms)
 
 #ifdef CONFIG_PROC_FS
 static void *s_start(struct seq_file *m, loff_t *pos)
+	__acquires(&vmlist_lock)
 {
 	loff_t n = *pos;
 	struct vm_struct *v;
@@ -2365,6 +2366,7 @@ static void *s_next(struct seq_file *m, void *p, loff_t *pos)
 }
 
 static void s_stop(struct seq_file *m, void *p)
+	__releases(&vmlist_lock)
 {
 	read_unlock(&vmlist_lock);
 }
-- 
1.7.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

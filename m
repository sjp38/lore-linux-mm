Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 6DC366B0038
	for <linux-mm@kvack.org>; Fri, 20 Mar 2015 10:47:19 -0400 (EDT)
Received: by lagg8 with SMTP id g8so88858593lag.1
        for <linux-mm@kvack.org>; Fri, 20 Mar 2015 07:47:18 -0700 (PDT)
Received: from forward-corp1f.mail.yandex.net (forward-corp1f.mail.yandex.net. [2a02:6b8:0:801::10])
        by mx.google.com with ESMTPS id kw1si3371496lbb.18.2015.03.20.07.47.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Mar 2015 07:47:17 -0700 (PDT)
Subject: [PATCH] mm: fix lockdep build in rcu-protected get_mm_exe_file()
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 20 Mar 2015 17:47:15 +0300
Message-ID: <20150320144715.24899.24547.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
---
 kernel/fork.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/fork.c b/kernel/fork.c
index a7c596517bd6..aa2ba1a34ce8 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -696,7 +696,7 @@ void set_mm_exe_file(struct mm_struct *mm, struct file *new_exe_file)
 {
 	struct file *old_exe_file = rcu_dereference_protected(mm->exe_file,
 			!atomic_read(&mm->mm_users) || current->in_execve ||
-			lock_is_held(&mm->mmap_sem));
+			lockdep_is_held(&mm->mmap_sem));
 
 	if (new_exe_file)
 		get_file(new_exe_file);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 33CA56B0146
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 06:14:16 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id e51so1698580eek.13
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 03:14:14 -0700 (PDT)
Message-ID: <515FF3CC.80106@gmail.com>
Date: Sat, 06 Apr 2013 12:07:08 +0200
From: Marco Stornelli <marco.stornelli@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 4/4] fsfreeze: avoid to return zero in __get_user_pages
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux FS Devel <linux-fsdevel@vger.kernel.org>
Cc: Mike Snitzer <snitzer@redhat.com>, Alasdair G Kergon <agk@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>

In case of VM_FAULT_RETRY, __get_user_pages returns the number
of pages alredy gotten, but there isn't a check if this number is
zero. Instead, we have to return a proper error code so we can avoid
a possible extra call of __get_user_pages. There are several
places where get_user_pages is called inside a loop until all the
pages requested are gotten or an error code is returned.

Signed-off-by: Marco Stornelli <marco.stornelli@gmail.com>
---
 mm/memory.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index 494526a..cca14ed 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1858,7 +1858,7 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 				if (ret & VM_FAULT_RETRY) {
 					if (nonblocking)
 						*nonblocking = 0;
-					return i;
+					return i ? i : -ERESTARTSYS;
 				}
 
 				/*
-- 
1.7.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

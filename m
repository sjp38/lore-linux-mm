Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 004C66B05F6
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 12:52:09 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id e2so23484305qta.13
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 09:52:08 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b6si12414250qte.178.2017.08.02.09.52.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 09:52:08 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 6/6] userfaultfd: provide pid in userfault msg - add feat union
Date: Wed,  2 Aug 2017 18:51:45 +0200
Message-Id: <20170802165145.22628-7-aarcange@redhat.com>
In-Reply-To: <20170802165145.22628-1-aarcange@redhat.com>
References: <20170802165145.22628-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Maxime Coquelin <maxime.coquelin@redhat.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Alexey Perevalov <a.perevalov@samsung.com>

No ABI change, but this will make it more explicit to software that
ptid is only available if requested by passing UFFD_FEATURE_THREAD_ID
to UFFDIO_API. The fact it's a union will also self document it
shouldn't be taken for granted there's a tpid there.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 | 2 +-
 include/uapi/linux/userfaultfd.h | 4 +++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index ae044650dffa..9677d862ed53 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -207,7 +207,7 @@ static inline struct uffd_msg userfault_msg(unsigned long address,
 		 */
 		msg.arg.pagefault.flags |= UFFD_PAGEFAULT_FLAG_WP;
 	if (features & UFFD_FEATURE_THREAD_ID)
-		msg.arg.pagefault.ptid = task_pid_vnr(current);
+		msg.arg.pagefault.feat.ptid = task_pid_vnr(current);
 	return msg;
 }
 
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 2b24c28d99a7..d6d1f65cb3c3 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -80,7 +80,9 @@ struct uffd_msg {
 		struct {
 			__u64	flags;
 			__u64	address;
-			__u32   ptid;
+			union {
+				__u32 ptid;
+			} feat;
 		} pagefault;
 
 		struct {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

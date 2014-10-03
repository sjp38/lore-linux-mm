Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f173.google.com (mail-qc0-f173.google.com [209.85.216.173])
	by kanga.kvack.org (Postfix) with ESMTP id CBEB86B0072
	for <linux-mm@kvack.org>; Fri,  3 Oct 2014 13:08:46 -0400 (EDT)
Received: by mail-qc0-f173.google.com with SMTP id x13so1324480qcv.32
        for <linux-mm@kvack.org>; Fri, 03 Oct 2014 10:08:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id gc8si2119678qcb.7.2014.10.03.10.08.45
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Oct 2014 10:08:45 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 01/17] mm: gup: add FOLL_TRIED
Date: Fri,  3 Oct 2014 19:07:51 +0200
Message-Id: <1412356087-16115-2-git-send-email-aarcange@redhat.com>
In-Reply-To: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
References: <1412356087-16115-1-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave@sr71.net>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "\\\"Dr. David Alan Gilbert\\\"" <dgilbert@redhat.com>, Christopher Covington <cov@codeaurora.org>, Johannes Weiner <hannes@cmpxchg.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>, Isaku Yamahata <yamahata@valinux.co.jp>, Anthony Liguori <anthony@codemonkey.ws>, Stefan Hajnoczi <stefanha@gmail.com>, Wenchao Xia <wenchaoqemu@gmail.com>, Andrew Jones <drjones@redhat.com>, Juan Quintela <quintela@redhat.com>

From: Andres Lagar-Cavilla <andreslc@google.com>

Reviewed-by: Radim KrA?mA!A? <rkrcmar@redhat.com>
Signed-off-by: Andres Lagar-Cavilla <andreslc@google.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 include/linux/mm.h | 1 +
 mm/gup.c           | 4 ++++
 2 files changed, 5 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 8981cc8..0f4196a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1985,6 +1985,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
 #define FOLL_HWPOISON	0x100	/* check page is hwpoisoned */
 #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
+#define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff --git a/mm/gup.c b/mm/gup.c
index 91d044b..af7ea3e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -281,6 +281,10 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY;
 	if (*flags & FOLL_NOWAIT)
 		fault_flags |= FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT;
+	if (*flags & FOLL_TRIED) {
+		VM_WARN_ON_ONCE(fault_flags & FAULT_FLAG_ALLOW_RETRY);
+		fault_flags |= FAULT_FLAG_TRIED;
+	}
 
 	ret = handle_mm_fault(mm, vma, address, fault_flags);
 	if (ret & VM_FAULT_ERROR) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

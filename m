Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id CD0716B0271
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 13:27:31 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c73so280636259pfb.7
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 10:27:31 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id t11si2338395plm.267.2017.01.25.10.27.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jan 2017 10:27:30 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 01/12] uprobes: split THPs before trying replace them
Date: Wed, 25 Jan 2017 21:25:27 +0300
Message-Id: <20170125182538.86249-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
References: <20170125182538.86249-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>

For THPs page_check_address() always fails. It leads to endless loop in
uprobe_write_opcode().

Testcase with huge-tmpfs (not sure if it's possible to trigger this
uprobe codepath for anon memory):

	mount -t debugfs none /sys/kernel/debug
	mount -t tmpfs -o huge=always none /mnt
	gcc -Wall -O2 -o /mnt/test -x c - <<EOF
	int main(void)
	{
		return 0;
	}
	/* Padding to map the code segment with huge pmd */
	asm (".zero 2097152");
	EOF
	echo 'p /mnt/test:0' > /sys/kernel/debug/tracing/uprobe_events
	echo 1 > /sys/kernel/debug/tracing/events/uprobes/enable
	/mnt/test

Let's split THPs before trying to replace.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
---
 kernel/events/uprobes.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index d416f3baf392..1e65c79e52a6 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -300,8 +300,8 @@ int uprobe_write_opcode(struct mm_struct *mm, unsigned long vaddr,
 
 retry:
 	/* Read the page with vaddr into memory */
-	ret = get_user_pages_remote(NULL, mm, vaddr, 1, FOLL_FORCE, &old_page,
-			&vma, NULL);
+	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
+			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

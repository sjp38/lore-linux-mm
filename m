Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 842D26B0279
	for <linux-mm@kvack.org>; Wed, 21 Jun 2017 20:17:23 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r70so1266551pfb.7
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:17:23 -0700 (PDT)
Received: from mail-pg0-x231.google.com (mail-pg0-x231.google.com. [2607:f8b0:400e:c05::231])
        by mx.google.com with ESMTPS id y12si14199722pfi.21.2017.06.21.17.17.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Jun 2017 17:17:22 -0700 (PDT)
Received: by mail-pg0-x231.google.com with SMTP id f127so622427pgc.0
        for <linux-mm@kvack.org>; Wed, 21 Jun 2017 17:17:22 -0700 (PDT)
Date: Wed, 21 Jun 2017 17:17:20 -0700
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] exec: Account for argv/envp pointers
Message-ID: <20170622001720.GA32173@beast>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Qualys Security Advisory <qsa@qualys.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

When limiting the argv/envp strings during exec to 1/4 of the stack limit,
the storage of the pointers to the strings was not included. This means
that an exec with huge numbers of tiny strings could eat 1/4 of the
stack limit in strings and then additional space would be later used
by the pointers to the strings. For example, on 32-bit with a 8MB stack
rlimit, an exec with 1677721 single-byte strings would consume less than
2MB of stack, the max (8MB / 4) amount allowed, but the pointers to the
strings would consume the remaining additional stack space (1677721 *
4 == 6710884). The result (1677721 + 6710884 == 8388605) would exhaust
stack space entirely. Controlling this stack exhaustion could result in
pathological behavior in setuid binaries (CVE-2017-1000365).

Fixes: b6a2fea39318 ("mm: variable length argument support")
Cc: stable@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 fs/exec.c | 20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 72934df68471..8079ca70cfda 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -220,8 +220,18 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 
 	if (write) {
 		unsigned long size = bprm->vma->vm_end - bprm->vma->vm_start;
+		unsigned long ptr_size;
 		struct rlimit *rlim;
 
+		/*
+		 * Since the stack will hold pointers to the strings, we
+		 * must account for them as well.
+		 */
+		ptr_size = (bprm->argc + bprm->envc) * sizeof(void *);
+		if (ptr_size > ULONG_MAX - size)
+			goto fail;
+		size += ptr_size;
+
 		acct_arg_size(bprm, size / PAGE_SIZE);
 
 		/*
@@ -239,13 +249,15 @@ static struct page *get_arg_page(struct linux_binprm *bprm, unsigned long pos,
 		 *    to work from.
 		 */
 		rlim = current->signal->rlim;
-		if (size > ACCESS_ONCE(rlim[RLIMIT_STACK].rlim_cur) / 4) {
-			put_page(page);
-			return NULL;
-		}
+		if (size > READ_ONCE(rlim[RLIMIT_STACK].rlim_cur) / 4)
+			goto fail;
 	}
 
 	return page;
+
+fail:
+	put_page(page);
+	return NULL;
 }
 
 static void put_arg_page(struct page *page)
-- 
2.7.4


-- 
Kees Cook
Pixel Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

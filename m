Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 59DE76B0253
	for <linux-mm@kvack.org>; Tue, 17 May 2016 11:53:39 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id y6so42288460ywe.0
        for <linux-mm@kvack.org>; Tue, 17 May 2016 08:53:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 10si2679319qho.34.2016.05.17.08.53.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 May 2016 08:53:38 -0700 (PDT)
Date: Tue, 17 May 2016 17:53:35 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH] exec: remove the no longer needed
 remove_arg_zero()->free_arg_page()
Message-ID: <20160517155335.GA31435@redhat.com>
References: <20160516204339.GA26141@redhat.com>
 <20160516135534.98e241faa07d1d12d66ac3dd@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160516135534.98e241faa07d1d12d66ac3dd@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, hujunjie <jj.net@163.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

remove_arg_zero() does free_arg_page() for no reason. This was needed
before and only if CONFIG_MMU=y: see the commit 4fc75ff4 ("exec: fix
remove_arg_zero"), install_arg_page() was called for every page != NULL
in bprm->page[] array. Today install_arg_page() has already gone and
free_arg_page() is nop after another commit b6a2fea39 ("mm: variable
length argument support").

CONFIG_MMU=n does free_arg_pages() in free_bprm() and thus it doesn't
need remove_arg_zero()->free_arg_page() too; apart from get_arg_page()
it never checks if the page in bprm->page[] was allocated or not, so
the "extra" non-freed page is fine. OTOH, this free_arg_page() can add
the minor pessimization, the caller is going to do copy_strings_kernel()
right after remove_arg_zero() which will likely need to re-allocate the
same page again.

And as Hujunjie pointed out, the "offset == PAGE_SIZE" check is wrong
because we are going to increment bprm->p once again before return, so
CONFIG_MMU=n "leaks" the page anyway if '\0' is the final byte in this
page.

NOTE: remove_arg_zero() assumes that argv[0] is null-terminated but this
is not necessarily true. copy_strings() does "len = strnlen_user(...)",
then copy_from_user(len) but another thread or debuger can overwrite the
trailing '\0' in between. Afaics nothing really bad can happen because
we must always have the null-terminated bprm->filename copied by the 1st
copy_strings_kernel(), but perhaps we should change this code to check
"bprm->p < bprm->exec" anyway, and/or change copy_strings() to ensure
that the last byte in string is always zero.

Reported by: hujunjie <jj.net@163.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 fs/exec.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index c4010b8..9b85c4d 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -243,10 +243,6 @@ static void put_arg_page(struct page *page)
 	put_page(page);
 }
 
-static void free_arg_page(struct linux_binprm *bprm, int i)
-{
-}
-
 static void free_arg_pages(struct linux_binprm *bprm)
 {
 }
@@ -1481,9 +1477,6 @@ int remove_arg_zero(struct linux_binprm *bprm)
 
 		kunmap_atomic(kaddr);
 		put_arg_page(page);
-
-		if (offset == PAGE_SIZE)
-			free_arg_page(bprm, (bprm->p >> PAGE_SHIFT) - 1);
 	} while (offset == PAGE_SIZE);
 
 	bprm->p++;
-- 
2.5.0


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

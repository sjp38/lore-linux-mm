Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f178.google.com (mail-yk0-f178.google.com [209.85.160.178])
	by kanga.kvack.org (Postfix) with ESMTP id A50CF6B0075
	for <linux-mm@kvack.org>; Thu, 27 Feb 2014 12:23:48 -0500 (EST)
Received: by mail-yk0-f178.google.com with SMTP id 79so7404232ykr.9
        for <linux-mm@kvack.org>; Thu, 27 Feb 2014 09:23:48 -0800 (PST)
Received: from relay.sgi.com (relay3.sgi.com. [192.48.152.1])
        by mx.google.com with ESMTP id t51si8483310yhg.100.2014.02.27.09.23.47
        for <linux-mm@kvack.org>;
        Thu, 27 Feb 2014 09:23:47 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 4/4] exec: kill the unnecessary mm->def_flags setting in load_elf_binary()
Date: Thu, 27 Feb 2014 11:23:26 -0600
Message-Id: <daed0ccdee74e3d8e2074e5c9128d0fedb0f4174.1393516106.git.athorlton@sgi.com>
In-Reply-To: <cover.1393516106.git.athorlton@sgi.com>
References: <cover.1393516106.git.athorlton@sgi.com>
In-Reply-To: <cover.1393516106.git.athorlton@sgi.com>
References: <cover.1393516106.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

load_elf_binary() sets current->mm->def_flags = def_flags and
def_flags is always zero. Not only this looks strange, this is
unnecessary because mm_init() has already set ->def_flags = 0. 

Signed-off-by: Alex Thorlton <athorlton@sgi.com>
Suggested-by: Oleg Nesterov <oleg@redhat.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Cc: linux-api@vger.kernel.org

---
 fs/binfmt_elf.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/binfmt_elf.c b/fs/binfmt_elf.c
index 67be295..d09bd9c 100644
--- a/fs/binfmt_elf.c
+++ b/fs/binfmt_elf.c
@@ -579,7 +579,6 @@ static int load_elf_binary(struct linux_binprm *bprm)
 	unsigned long start_code, end_code, start_data, end_data;
 	unsigned long reloc_func_desc __maybe_unused = 0;
 	int executable_stack = EXSTACK_DEFAULT;
-	unsigned long def_flags = 0;
 	struct pt_regs *regs = current_pt_regs();
 	struct {
 		struct elfhdr elf_ex;
@@ -719,9 +718,6 @@ static int load_elf_binary(struct linux_binprm *bprm)
 	if (retval)
 		goto out_free_dentry;
 
-	/* OK, This is the point of no return */
-	current->mm->def_flags = def_flags;
-
 	/* Do this immediately, since STACK_TOP as used in setup_arg_pages
 	   may depend on the personality.  */
 	SET_PERSONALITY(loc->elf_ex);
-- 
1.7.12.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

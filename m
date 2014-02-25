Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id D0C3A6B00D7
	for <linux-mm@kvack.org>; Tue, 25 Feb 2014 14:21:43 -0500 (EST)
Received: by mail-ie0-f178.google.com with SMTP id ar20so775372iec.37
        for <linux-mm@kvack.org>; Tue, 25 Feb 2014 11:21:43 -0800 (PST)
Received: from relay.sgi.com (relay1.sgi.com. [192.48.179.29])
        by mx.google.com with ESMTP id pe7si24751916icc.84.2014.02.25.11.21.40
        for <linux-mm@kvack.org>;
        Tue, 25 Feb 2014 11:21:40 -0800 (PST)
From: Alex Thorlton <athorlton@sgi.com>
Subject: [PATCH 3/3] exec: kill the unnecessary mm->def_flags setting in load_elf_binary()
Date: Tue, 25 Feb 2014 13:21:02 -0600
Message-Id: <ad2c5e30c22c6398acb62641c054588f105cb4f4.1392009760.git.athorlton@sgi.com>
In-Reply-To: <cover.1392009759.git.athorlton@sgi.com>
References: <cover.1392009759.git.athorlton@sgi.com>
In-Reply-To: <cover.1392009759.git.athorlton@sgi.com>
References: <cover.1392009759.git.athorlton@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Alex Thorlton <athorlton@sgi.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bob Liu <lliubbo@gmail.com>, Jiang Liu <liuj97@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Oleg Nesterov <oleg@redhat.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Daeseok Youn <daeseok.youn@gmail.com>, Kent Overstreet <koverstreet@google.com>, Dario Faggioli <raistlin@linux.it>, John Stultz <johnstul@us.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Alexander Viro <viro@zeniv.linux.org.uk>, linux390@de.ibm.com, linux-s390@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org

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
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Bob Liu <lliubbo@gmail.com>
Cc: Jiang Liu <liuj97@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Daeseok Youn <daeseok.youn@gmail.com>
Cc: Kent Overstreet <koverstreet@google.com>
Cc: Dario Faggioli <raistlin@linux.it>
Cc: John Stultz <johnstul@us.ibm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org
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

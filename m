Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id CC75C6B0072
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 19:50:13 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id hz10so2453023pad.9
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 16:50:13 -0800 (PST)
From: Michel Lespinasse <walken@google.com>
Subject: [PATCH 1/9] mm: make mlockall preserve flags other than VM_LOCKED in def_flags
Date: Thu, 20 Dec 2012 16:49:49 -0800
Message-Id: <1356050997-2688-2-git-send-email-walken@google.com>
In-Reply-To: <1356050997-2688-1-git-send-email-walken@google.com>
References: <1356050997-2688-1-git-send-email-walken@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Jorn_Engel <joern@logfs.org>, Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On most architectures, def_flags is either 0 or VM_LOCKED depending on
whether mlockall(MCL_FUTURE) was called. However, this is not an absolute
rule as kvm support on s390 may set the VM_NOHUGEPAGE flag in def_flags.
We don't want mlockall to clear that.

Signed-off-by: Michel Lespinasse <walken@google.com>

---
 mm/mlock.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index f0b9ce572fc7..a2ee45c030fa 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -517,10 +517,11 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
-	unsigned int def_flags = 0;
+	unsigned int def_flags;
 
+	def_flags = current->mm->def_flags & ~VM_LOCKED;
 	if (flags & MCL_FUTURE)
-		def_flags = VM_LOCKED;
+		def_flags |= VM_LOCKED;
 	current->mm->def_flags = def_flags;
 	if (flags == MCL_FUTURE)
 		goto out;
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

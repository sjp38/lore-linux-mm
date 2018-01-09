Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE0B6B025F
	for <linux-mm@kvack.org>; Tue,  9 Jan 2018 15:57:01 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h18so11143155pfi.2
        for <linux-mm@kvack.org>; Tue, 09 Jan 2018 12:57:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d11sor2771779pgf.14.2018.01.09.12.56.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Jan 2018 12:56:59 -0800 (PST)
From: Kees Cook <keescook@chromium.org>
Subject: [PATCH 01/36] usercopy: Remove pointer from overflow report
Date: Tue,  9 Jan 2018 12:55:30 -0800
Message-Id: <1515531365-37423-2-git-send-email-keescook@chromium.org>
In-Reply-To: <1515531365-37423-1-git-send-email-keescook@chromium.org>
References: <1515531365-37423-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Kees Cook <keescook@chromium.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Windsor <dave@nullcore.net>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>, Laura Abbott <labbott@redhat.com>, Mark Rutland <mark.rutland@arm.com>, "Martin K. Petersen" <martin.petersen@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, Christoffer Dall <christoffer.dall@linaro.org>, Dave Kleikamp <dave.kleikamp@oracle.com>, Jan Kara <jack@suse.cz>, Luis de Bethencourt <luisbg@kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Rik van Riel <riel@redhat.com>, Matthew Garrett <mjg59@google.com>, linux-fsdevel@vger.kernel.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com

Using %p was already mostly useless in the usercopy overflow reports,
so this removes it entirely to avoid confusion now that %p-hashing
is enabled.

Fixes: ad67b74d2469d9b8 ("printk: hash addresses printed with %p")
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 mm/usercopy.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/mm/usercopy.c b/mm/usercopy.c
index a9852b24715d..5df1e68d4585 100644
--- a/mm/usercopy.c
+++ b/mm/usercopy.c
@@ -58,12 +58,11 @@ static noinline int check_stack_object(const void *obj, unsigned long len)
 	return GOOD_STACK;
 }
 
-static void report_usercopy(const void *ptr, unsigned long len,
-			    bool to_user, const char *type)
+static void report_usercopy(unsigned long len, bool to_user, const char *type)
 {
-	pr_emerg("kernel memory %s attempt detected %s %p (%s) (%lu bytes)\n",
+	pr_emerg("kernel memory %s attempt detected %s '%s' (%lu bytes)\n",
 		to_user ? "exposure" : "overwrite",
-		to_user ? "from" : "to", ptr, type ? : "unknown", len);
+		to_user ? "from" : "to", type ? : "unknown", len);
 	/*
 	 * For greater effect, it would be nice to do do_group_exit(),
 	 * but BUG() actually hooks all the lock-breaking and per-arch
@@ -261,6 +260,6 @@ void __check_object_size(const void *ptr, unsigned long n, bool to_user)
 		return;
 
 report:
-	report_usercopy(ptr, n, to_user, err);
+	report_usercopy(n, to_user, err);
 }
 EXPORT_SYMBOL(__check_object_size);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

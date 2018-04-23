Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5746B002F
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:47:57 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a38-v6so19257499wra.10
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:47:57 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id e17si462980edb.318.2018.04.23.08.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:47:56 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 27/37] x86/mm/pti: Keep permissions when cloning kernel text in pti_clone_kernel_text()
Date: Mon, 23 Apr 2018 17:47:30 +0200
Message-Id: <1524498460-25530-28-git-send-email-joro@8bytes.org>
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Mapping the kernel text area to user-space makes only sense
if it has the same permissions as in the kernel page-table.
If permissions are different this will cause a TLB reload
when using the kernel page-table, which is as good as not
mapping it at all.

On 64-bit kernels this patch makes no difference, as the
whole range cloned by pti_clone_kernel_text() is mapped RO
anyway. On 32 bit there are writeable mappings in the range,
so just keep the permissions as they are.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/pti.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/arch/x86/mm/pti.c b/arch/x86/mm/pti.c
index 9cceae3..e3059bb0 100644
--- a/arch/x86/mm/pti.c
+++ b/arch/x86/mm/pti.c
@@ -460,7 +460,7 @@ void pti_clone_kernel_text(void)
 	if (!pti_kernel_image_global_ok())
 		return;
 
-	pti_clone_pmds(start, end, _PAGE_RW);
+	pti_clone_pmds(start, end, 0);
 }
 
 /*
-- 
2.7.4

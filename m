Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82B656B002F
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 11:47:58 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id a38-v6so19257554wra.10
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:47:58 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id t2si10319554edf.433.2018.04.23.08.47.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 08:47:56 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH 28/37] x86/mm/pti: Map kernel-text to user-space on 32 bit kernels
Date: Mon, 23 Apr 2018 17:47:31 +0200
Message-Id: <1524498460-25530-29-git-send-email-joro@8bytes.org>
In-Reply-To: <1524498460-25530-1-git-send-email-joro@8bytes.org>
References: <1524498460-25530-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de, joro@8bytes.org

From: Joerg Roedel <jroedel@suse.de>

Keeping the kernel text mapped with G bit set keeps its
entries in the TLB across kernel entry/exit and improved the
performance. The 64 bit x86 kernels already do this when
there is no PCID, so do this in 32 bit as well since PCID is
not even supported there.

Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/mm/init_32.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index c893c6a..8299b98 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -956,4 +956,10 @@ void mark_rodata_ro(void)
 	mark_nxdata_nx();
 	if (__supported_pte_mask & _PAGE_NX)
 		debug_checkwx();
+
+	/*
+	 * Do this after all of the manipulation of the
+	 * kernel text page tables are complete.
+	 */
+	pti_clone_kernel_text();
 }
-- 
2.7.4

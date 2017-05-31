Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8D3946B0279
	for <linux-mm@kvack.org>; Wed, 31 May 2017 05:51:57 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id y39so1518317wry.10
        for <linux-mm@kvack.org>; Wed, 31 May 2017 02:51:57 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id v14si17365548wrv.47.2017.05.31.02.51.56
        for <linux-mm@kvack.org>;
        Wed, 31 May 2017 02:51:56 -0700 (PDT)
Date: Wed, 31 May 2017 11:51:48 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 29/32] x86/mm: Add support to encrypt the kernel
 in-place
Message-ID: <20170531095148.pba6ju6im4qxbwfg@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418212149.10190.70894.stgit@tlendack-t1.amdoffice.net>
 <20170518124626.hqyqqbjpy7hmlpqc@pd.tnic>
 <7e2ae014-525c-76f2-9fce-2124596db2d2@amd.com>
 <20170526162522.p7prrqqalx2ivfxl@pd.tnic>
 <33c075b1-71f6-b5d0-b1fa-d742d0659d38@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <33c075b1-71f6-b5d0-b1fa-d742d0659d38@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Tue, May 30, 2017 at 11:39:07AM -0500, Tom Lendacky wrote:
> Yes, it's from objtool:
> 
> arch/x86/mm/mem_encrypt_boot.o: warning: objtool: .text+0xd2: return
> instruction outside of a callable function

Oh, well, let's make it a global symbol then. Who knows, we might have
to live-patch it someday :-)

---
diff --git a/arch/x86/mm/mem_encrypt_boot.S b/arch/x86/mm/mem_encrypt_boot.S
index fb58f9f953e3..7720b0050840 100644
--- a/arch/x86/mm/mem_encrypt_boot.S
+++ b/arch/x86/mm/mem_encrypt_boot.S
@@ -47,9 +47,9 @@ ENTRY(sme_encrypt_execute)
 	movq	%rdx, %r12		/* Kernel length */
 
 	/* Copy encryption routine into the workarea */
-	movq	%rax, %rdi		/* Workarea encryption routine */
-	leaq	.Lenc_start(%rip), %rsi	/* Encryption routine */
-	movq	$(.Lenc_stop - .Lenc_start), %rcx	/* Encryption routine length */
+	movq	%rax, %rdi				/* Workarea encryption routine */
+	leaq	__enc_copy(%rip), %rsi			/* Encryption routine */
+	movq	$(.L__enc_copy_end - __enc_copy), %rcx	/* Encryption routine length */
 	rep	movsb
 
 	/* Setup registers for call */
@@ -70,8 +70,7 @@ ENTRY(sme_encrypt_execute)
 	ret
 ENDPROC(sme_encrypt_execute)
 
-.Lenc_start:
-ENTRY(sme_enc_routine)
+ENTRY(__enc_copy)
 /*
  * Routine used to encrypt kernel.
  *   This routine must be run outside of the kernel proper since
@@ -147,5 +146,5 @@ ENTRY(sme_enc_routine)
 	wrmsr
 
 	ret
-ENDPROC(sme_enc_routine)
-.Lenc_stop:
+.L__enc_copy_end:
+ENDPROC(__enc_copy)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

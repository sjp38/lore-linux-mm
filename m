Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id E4DEA6B0267
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 18:36:43 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so232024751pad.2
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 15:36:43 -0700 (PDT)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0047.outbound.protection.outlook.com. [104.47.42.47])
        by mx.google.com with ESMTPS id ik5si292522pac.111.2016.08.22.15.36.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 22 Aug 2016 15:36:43 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [RFC PATCH v2 06/20] x86: Handle reduction in physical address size
 with SME
Date: Mon, 22 Aug 2016 17:36:34 -0500
Message-ID: <20160822223634.29880.93825.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
References: <20160822223529.29880.50884.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek
 Wilk <konrad.wilk@oracle.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy
 Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Paolo Bonzini <pbonzini@redhat.com>, Alexander Potapenko <glider@google.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

When System Memory Encryption (SME) is enabled, the physical address
space is reduced. Adjust the x86_phys_bits value to reflect this
reduction.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/kernel/cpu/common.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/kernel/cpu/common.c b/arch/x86/kernel/cpu/common.c
index ce7a4c1..c0fe783 100644
--- a/arch/x86/kernel/cpu/common.c
+++ b/arch/x86/kernel/cpu/common.c
@@ -44,6 +44,7 @@
 #include <asm/pat.h>
 #include <asm/microcode.h>
 #include <asm/microcode_intel.h>
+#include <asm/mem_encrypt.h>
 
 #ifdef CONFIG_X86_LOCAL_APIC
 #include <asm/uv/uv.h>
@@ -736,6 +737,7 @@ void get_cpu_cap(struct cpuinfo_x86 *c)
 
 		c->x86_virt_bits = (eax >> 8) & 0xff;
 		c->x86_phys_bits = eax & 0xff;
+		c->x86_phys_bits -= sme_get_me_loss();
 		c->x86_capability[CPUID_8000_0008_EBX] = ebx;
 	}
 #ifdef CONFIG_X86_32

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

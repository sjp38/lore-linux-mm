Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 174E36B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 12:01:33 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z70so13738964wrc.1
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 09:01:33 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:190:11c2::b:1457])
        by mx.google.com with ESMTP id r21si3870456wrc.279.2017.06.10.09.01.30
        for <linux-mm@kvack.org>;
        Sat, 10 Jun 2017 09:01:30 -0700 (PDT)
Date: Sat, 10 Jun 2017 18:01:19 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v6 14/34] x86/mm: Insure that boot memory areas are
 mapped properly
Message-ID: <20170610160119.bnx5ir5dj3i27igx@pd.tnic>
References: <20170607191309.28645.15241.stgit@tlendack-t1.amdoffice.net>
 <20170607191539.28645.70161.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170607191539.28645.70161.stgit@tlendack-t1.amdoffice.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Wed, Jun 07, 2017 at 02:15:39PM -0500, Tom Lendacky wrote:
> The boot data and command line data are present in memory in a decrypted
> state and are copied early in the boot process.  The early page fault
> support will map these areas as encrypted, so before attempting to copy
> them, add decrypted mappings so the data is accessed properly when copied.
> 
> For the initrd, encrypt this data in place. Since the future mapping of the
> initrd area will be mapped as encrypted the data will be accessed properly.
> 
> Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
> ---
>  arch/x86/include/asm/mem_encrypt.h |   11 +++++
>  arch/x86/include/asm/pgtable.h     |    3 +
>  arch/x86/kernel/head64.c           |   30 ++++++++++++--
>  arch/x86/kernel/setup.c            |    9 ++++
>  arch/x86/mm/mem_encrypt.c          |   77 ++++++++++++++++++++++++++++++++++++
>  5 files changed, 126 insertions(+), 4 deletions(-)

Some cleanups ontop in case you get to send v7:

diff --git a/arch/x86/include/asm/mem_encrypt.h b/arch/x86/include/asm/mem_encrypt.h
index 61a704945294..5959a42dd4d5 100644
--- a/arch/x86/include/asm/mem_encrypt.h
+++ b/arch/x86/include/asm/mem_encrypt.h
@@ -45,13 +45,8 @@ static inline void __init sme_early_decrypt(resource_size_t paddr,
 {
 }
 
-static inline void __init sme_map_bootdata(char *real_mode_data)
-{
-}
-
-static inline void __init sme_unmap_bootdata(char *real_mode_data)
-{
-}
+static inline void __init sme_map_bootdata(char *real_mode_data)	{ }
+static inline void __init sme_unmap_bootdata(char *real_mode_data)	{ }
 
 static inline void __init sme_early_init(void)
 {
diff --git a/arch/x86/mm/mem_encrypt.c b/arch/x86/mm/mem_encrypt.c
index 2321f05045e5..32ebbe0ab04d 100644
--- a/arch/x86/mm/mem_encrypt.c
+++ b/arch/x86/mm/mem_encrypt.c
@@ -132,6 +132,10 @@ static void __init __sme_map_unmap_bootdata(char *real_mode_data, bool map)
 	struct boot_params *boot_data;
 	unsigned long cmdline_paddr;
 
+	/* If SME is not active, the bootdata is in the correct state */
+	if (!sme_active())
+		return;
+
 	__sme_early_map_unmap_mem(real_mode_data, sizeof(boot_params), map);
 	boot_data = (struct boot_params *)real_mode_data;
 
@@ -142,40 +146,22 @@ static void __init __sme_map_unmap_bootdata(char *real_mode_data, bool map)
 	cmdline_paddr = boot_data->hdr.cmd_line_ptr |
 			((u64)boot_data->ext_cmd_line_ptr << 32);
 
-	if (cmdline_paddr)
-		__sme_early_map_unmap_mem(__va(cmdline_paddr),
-					  COMMAND_LINE_SIZE, map);
+	if (!cmdline_paddr)
+		return;
+
+	__sme_early_map_unmap_mem(__va(cmdline_paddr), COMMAND_LINE_SIZE, map);
+
+	sme_early_pgtable_flush();
 }
 
 void __init sme_unmap_bootdata(char *real_mode_data)
 {
-	/* If SME is not active, the bootdata is in the correct state */
-	if (!sme_active())
-		return;
-
-	/*
-	 * The bootdata and command line aren't needed anymore so clear
-	 * any mapping of them.
-	 */
 	__sme_map_unmap_bootdata(real_mode_data, false);
-
-	sme_early_pgtable_flush();
 }
 
 void __init sme_map_bootdata(char *real_mode_data)
 {
-	/* If SME is not active, the bootdata is in the correct state */
-	if (!sme_active())
-		return;
-
-	/*
-	 * The bootdata and command line will not be encrypted, so they
-	 * need to be mapped as decrypted memory so they can be copied
-	 * properly.
-	 */
 	__sme_map_unmap_bootdata(real_mode_data, true);
-
-	sme_early_pgtable_flush();
 }
 
 void __init sme_early_init(void)

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

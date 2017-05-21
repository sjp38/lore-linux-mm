Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id C6A84280850
	for <linux-mm@kvack.org>; Sun, 21 May 2017 03:17:03 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y22so10839525wry.1
        for <linux-mm@kvack.org>; Sun, 21 May 2017 00:17:03 -0700 (PDT)
Received: from mail.skyhub.de (mail.skyhub.de. [5.9.137.197])
        by mx.google.com with ESMTP id m135si14959824wmb.30.2017.05.21.00.17.01
        for <linux-mm@kvack.org>;
        Sun, 21 May 2017 00:17:02 -0700 (PDT)
Date: Sun, 21 May 2017 09:16:50 +0200
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v5 17/32] x86/mm: Add support to access boot related data
 in the clear
Message-ID: <20170521071650.pwwmw4agggaazfrh@pd.tnic>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
 <20170418211921.10190.1537.stgit@tlendack-t1.amdoffice.net>
 <20170515183517.mb4k2gp2qobbuvtm@pd.tnic>
 <4845df29-bae7-9b78-0428-ff96dbef2128@amd.com>
 <20170518090212.kebstmnjv4h3cjf2@pd.tnic>
 <c0cb8a50-e860-169b-ee0c-7eb4db7c3fda@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <c0cb8a50-e860-169b-ee0c-7eb4db7c3fda@amd.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tom Lendacky <thomas.lendacky@amd.com>
Cc: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org, Rik van Riel <riel@redhat.com>, Radim =?utf-8?B?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On Fri, May 19, 2017 at 03:50:32PM -0500, Tom Lendacky wrote:
> The "worker" function would be doing the loop through the setup data,
> but since the setup data is mapped inside the loop I can't do the __init
> calling the non-init function and still hope to consolidate the code.
> Maybe I'm missing something here...

Hmm, I see what you mean. But the below change ontop doesn't fire any
warnings here. Maybe your .config has something set which I don't...

---
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 55317ba3b6dc..199c983192ae 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -515,71 +515,50 @@ static bool memremap_is_efi_data(resource_size_t phys_addr,
  * Examine the physical address to determine if it is boot data by checking
  * it against the boot params setup_data chain.
  */
-static bool memremap_is_setup_data(resource_size_t phys_addr,
-				   unsigned long size)
+static bool
+__memremap_is_setup_data(resource_size_t phys_addr, unsigned long size, bool early)
 {
 	struct setup_data *data;
 	u64 paddr, paddr_next;
+	u32 len;
 
 	paddr = boot_params.hdr.setup_data;
 	while (paddr) {
-		bool is_setup_data = false;
 
 		if (phys_addr == paddr)
 			return true;
 
-		data = memremap(paddr, sizeof(*data),
-				MEMREMAP_WB | MEMREMAP_DEC);
+		if (early)
+			data = early_memremap_decrypted(paddr, sizeof(*data));
+		else
+			data = memremap(paddr, sizeof(*data), MEMREMAP_WB | MEMREMAP_DEC);
 
 		paddr_next = data->next;
+		len = data->len;
 
-		if ((phys_addr > paddr) && (phys_addr < (paddr + data->len)))
-			is_setup_data = true;
+		if (early)
+			early_memunmap(data, sizeof(*data));
+		else
+			memunmap(data);
 
-		memunmap(data);
 
-		if (is_setup_data)
+		if ((phys_addr > paddr) && (phys_addr < (paddr + data->len)))
 			return true;
 
 		paddr = paddr_next;
 	}
-
 	return false;
 }
 
-/*
- * Examine the physical address to determine if it is boot data by checking
- * it against the boot params setup_data chain (early boot version).
- */
 static bool __init early_memremap_is_setup_data(resource_size_t phys_addr,
 						unsigned long size)
 {
-	struct setup_data *data;
-	u64 paddr, paddr_next;
-
-	paddr = boot_params.hdr.setup_data;
-	while (paddr) {
-		bool is_setup_data = false;
-
-		if (phys_addr == paddr)
-			return true;
-
-		data = early_memremap_decrypted(paddr, sizeof(*data));
-
-		paddr_next = data->next;
-
-		if ((phys_addr > paddr) && (phys_addr < (paddr + data->len)))
-			is_setup_data = true;
-
-		early_memunmap(data, sizeof(*data));
-
-		if (is_setup_data)
-			return true;
-
-		paddr = paddr_next;
-	}
+	return __memremap_is_setup_data(phys_addr, size, true);
+}
 
-	return false;
+static bool memremap_is_setup_data(resource_size_t phys_addr, unsigned long size)
+{
+	return __memremap_is_setup_data(phys_addr, size, false);
 }
 
 /*

-- 
Regards/Gruss,
    Boris.

Good mailing practices for 400: avoid top-posting and trim the reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

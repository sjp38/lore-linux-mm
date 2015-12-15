Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 693CF6B0038
	for <linux-mm@kvack.org>; Tue, 15 Dec 2015 04:47:01 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id p66so82243813wmp.0
        for <linux-mm@kvack.org>; Tue, 15 Dec 2015 01:47:01 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id jo5si770885wjb.37.2015.12.15.01.46.59
        for <linux-mm@kvack.org>;
        Tue, 15 Dec 2015 01:47:00 -0800 (PST)
Date: Tue, 15 Dec 2015 10:46:53 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCHV2 1/3] x86, ras: Add new infrastructure for machine check
 fixup tables
Message-ID: <20151215094653.GA25973@pd.tnic>
References: <cover.1449861203.git.tony.luck@intel.com>
 <456153d09e85f2f139020a051caed3ca8f8fca73.1449861203.git.tony.luck@intel.com>
 <20151212101142.GA3867@pd.tnic>
 <20151215010059.GA17353@agluck-desk.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20151215010059.GA17353@agluck-desk.sc.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Mon, Dec 14, 2015 at 05:00:59PM -0800, Luck, Tony wrote:
> Not sure what the "whatnot" would be though.  Making it depend on
> X86_MCE should keep it out of the tiny configurations. By the time
> you have MCE support, this seems like a pretty small incremental
> change.

Ok, so it is called CONFIG_LIBNVDIMM. Do you see a use case for this
stuff except on machines with NVDIMM hw? CONFIG_LIBNVDIMM can select it
but on !NVDIMM systems you don't really need it enabled.

> Is there some cpp magic to use an #ifdef inside a multi-line macro like this?
> Impact of not having the #ifdef is two extra symbols (the start/stop ones)
> in the symbol table of the final binary. If that's unacceptable I can fall
> back to an earlier unpublished version that had separate EXCEPTION_TABLE and
> MCEXCEPTION_TABLE macros with both invoked in the x86 vmlinux.lds.S file.

I think what is more important is that this should be in the
x86-specific linker script, not in the generic one. And yes, we should
strive to be clean and not pullute the kernel image with symbols which
are unused, i.e. when CONFIG_MCE_KERNEL_RECOVERY is not enabled.

This below seems to build ok here, ontop of yours. It could be a
MCEXCEPTION_TABLE macro, as you say:

Index: b/include/asm-generic/vmlinux.lds.h
===================================================================
--- a/include/asm-generic/vmlinux.lds.h	2015-12-15 10:17:25.568046033 +0100
+++ b/include/asm-generic/vmlinux.lds.h	2015-12-15 10:07:06.064034490 +0100
@@ -484,12 +484,6 @@
 		*(__ex_table)						\
 		VMLINUX_SYMBOL(__stop___ex_table) = .;			\
 	}								\
-	. = ALIGN(align);						\
-	__mcex_table : AT(ADDR(__mcex_table) - LOAD_OFFSET) {		\
-		VMLINUX_SYMBOL(__start___mcex_table) = .;		\
-		*(__mcex_table)						\
-		VMLINUX_SYMBOL(__stop___mcex_table) = .;		\
-	}
 
 /*
  * Init task
Index: b/arch/x86/kernel/vmlinux.lds.S
===================================================================
--- a/arch/x86/kernel/vmlinux.lds.S	2015-12-14 11:38:58.188150070 +0100
+++ b/arch/x86/kernel/vmlinux.lds.S	2015-12-15 10:09:04.624036699 +0100
@@ -110,7 +110,17 @@ SECTIONS
 
 	NOTES :text :note
 
-	EXCEPTION_TABLE(16) :text = 0x9090
+	EXCEPTION_TABLE(16)
+
+#ifdef CONFIG_MCE_KERNEL_RECOVERY
+	. = ALIGN(16);
+	__mcex_table : AT(ADDR(__mcex_table) - LOAD_OFFSET) {
+		VMLINUX_SYMBOL(__start___mcex_table) = .;
+		*(__mcex_table)
+		VMLINUX_SYMBOL(__stop___mcex_table) = .;
+	}
+#endif
+	:text = 0x9090
 
 #if defined(CONFIG_DEBUG_RODATA)
 	/* .text should occupy whole number of pages */

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

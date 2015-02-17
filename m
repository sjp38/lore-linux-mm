Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7EF816B0032
	for <linux-mm@kvack.org>; Tue, 17 Feb 2015 17:31:57 -0500 (EST)
Received: by mail-wi0-f171.google.com with SMTP id hi2so37123390wib.4
        for <linux-mm@kvack.org>; Tue, 17 Feb 2015 14:31:56 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id ff5si31762438wib.42.2015.02.17.14.31.55
        for <linux-mm@kvack.org>;
        Tue, 17 Feb 2015 14:31:55 -0800 (PST)
Date: Tue, 17 Feb 2015 23:31:05 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH v2] x86, kaslr: propagate base load address calculation
Message-ID: <20150217223105.GI26165@pd.tnic>
References: <alpine.LNX.2.00.1502101411280.10719@pobox.suse.cz>
 <CAGXu5jJzs9Ve9so96f6n-=JxP+GR3xYFQYBtZ=mUm+Q7bMAgBw@mail.gmail.com>
 <alpine.LNX.2.00.1502110001480.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502110010190.10719@pobox.suse.cz>
 <alpine.LNX.2.00.1502131602360.2423@pobox.suse.cz>
 <20150217104443.GC9784@pd.tnic>
 <alpine.LNX.2.00.1502171319040.2279@pobox.suse.cz>
 <20150217123933.GC26165@pd.tnic>
 <CAGXu5jL7opSG92o5Gu2tT-NWTfiC7dNSMLynPZWb8uHzUoUqLg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAGXu5jL7opSG92o5Gu2tT-NWTfiC7dNSMLynPZWb8uHzUoUqLg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Jiri Kosina <jkosina@suse.cz>, "H. Peter Anvin" <hpa@linux.intel.com>, LKML <linux-kernel@vger.kernel.org>, live-patching@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>

On Tue, Feb 17, 2015 at 08:45:53AM -0800, Kees Cook wrote:
> Maybe it should say:
> 
> Kernel offset: disabled
> 
> for maximum clarity?

I.e.:

---
diff --git a/arch/x86/kernel/setup.c b/arch/x86/kernel/setup.c
index 78c91bbf50e2..16b6043cb073 100644
--- a/arch/x86/kernel/setup.c
+++ b/arch/x86/kernel/setup.c
@@ -843,10 +843,14 @@ static void __init trim_low_memory_range(void)
 static int
 dump_kernel_offset(struct notifier_block *self, unsigned long v, void *p)
 {
-	pr_emerg("Kernel Offset: 0x%lx from 0x%lx "
-		 "(relocation range: 0x%lx-0x%lx)\n",
-		 (unsigned long)&_text - __START_KERNEL, __START_KERNEL,
-		 __START_KERNEL_map, MODULES_VADDR-1);
+	if (kaslr_enabled)
+		pr_emerg("Kernel Offset: 0x%lx from 0x%lx (relocation range: 0x%lx-0x%lx)\n",
+			 (unsigned long)&_text - __START_KERNEL,
+			 __START_KERNEL,
+			 __START_KERNEL_map,
+			 MODULES_VADDR-1);
+	else
+		pr_emerg("Kernel Offset: disabled\n");
 
 	return 0;
 }
---

?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

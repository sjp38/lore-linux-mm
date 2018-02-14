Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 421F16B0003
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 08:32:44 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id w16so11010949plp.20
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 05:32:44 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f7si1396772pfa.168.2018.02.14.05.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 05:32:43 -0800 (PST)
Date: Wed, 14 Feb 2018 16:32:38 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCH 5/9] x86/mm: Make LDT_BASE_ADDR dynamic
Message-ID: <20180214133238.cliqsqp5rdggjzqy@black.fi.intel.com>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
 <20180214111656.88514-6-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180214111656.88514-6-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, g@black.fi.intel.com
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 14, 2018 at 11:16:52AM +0000, Kirill A. Shutemov wrote:
> LDT_BASE_ADDR has different value in 4- and 5-level paging
> configurations.
> 
> We need to make it dynamic in preparation for boot-time switching
> between paging modes.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

I've just realized that the patch that I'm splitting has hunk that belong
here.

Could you fold it in?

Sorry for this.

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 9efee6f464ab..a32f0621d664 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -579,6 +579,9 @@ static int __init pt_dump_init(void)
 	address_markers[KASAN_SHADOW_START_NR].start_address = KASAN_SHADOW_START;
 	address_markers[KASAN_SHADOW_END_NR].start_address = KASAN_SHADOW_END;
 #endif
+#ifdef CONFIG_MODIFY_LDT_SYSCALL
+        address_markers[LDT_NR].start_address = LDT_BASE_ADDR;
+#endif
 #endif
 #ifdef CONFIG_X86_32
 	address_markers[VMALLOC_START_NR].start_address = VMALLOC_START;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

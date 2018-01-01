Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 718AE6B0278
	for <linux-mm@kvack.org>; Mon,  1 Jan 2018 09:40:19 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n13so13723557wmc.3
        for <linux-mm@kvack.org>; Mon, 01 Jan 2018 06:40:19 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m70si19765640wma.241.2018.01.01.06.40.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jan 2018 06:40:18 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.14 005/146] x86/mm/pti: Disable global pages if PAGE_TABLE_ISOLATION=y
Date: Mon,  1 Jan 2018 15:36:36 +0100
Message-Id: <20180101140124.570232806@linuxfoundation.org>
In-Reply-To: <20180101140123.743014891@linuxfoundation.org>
References: <20180101140123.743014891@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Borislav Petkov <bp@suse.de>, Andy Lutomirski <luto@kernel.org>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, "H. Peter Anvin" <hpa@zytor.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, linux-mm@kvack.org, Ingo Molnar <mingo@kernel.org>

4.14-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Dave Hansen <dave.hansen@linux.intel.com>

commit c313ec66317d421fb5768d78c56abed2dc862264 upstream.

Global pages stay in the TLB across context switches.  Since all contexts
share the same kernel mapping, these mappings are marked as global pages
so kernel entries in the TLB are not flushed out on a context switch.

But, even having these entries in the TLB opens up something that an
attacker can use, such as the double-page-fault attack:

   http://www.ieee-security.org/TC/SP2013/papers/4977a191.pdf

That means that even when PAGE_TABLE_ISOLATION switches page tables
on return to user space the global pages would stay in the TLB cache.

Disable global pages so that kernel TLB entries can be flushed before
returning to user space. This way, all accesses to kernel addresses from
userspace result in a TLB miss independent of the existence of a kernel
mapping.

Suppress global pages via the __supported_pte_mask. The user space
mappings set PAGE_GLOBAL for the minimal kernel mappings which are
required for entry/exit. These mappings are set up manually so the
filtering does not take place.

[ The __supported_pte_mask simplification was written by Thomas Gleixner. ]
Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Reviewed-by: Borislav Petkov <bp@suse.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: David Laight <David.Laight@aculab.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Eduardo Valentin <eduval@amazon.com>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Will Deacon <will.deacon@arm.com>
Cc: aliguori@amazon.com
Cc: daniel.gruss@iaik.tugraz.at
Cc: hughd@google.com
Cc: keescook@google.com
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

---
 arch/x86/mm/init.c |   12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -161,6 +161,12 @@ struct map_range {
 
 static int page_size_mask;
 
+static void enable_global_pages(void)
+{
+	if (!static_cpu_has(X86_FEATURE_PTI))
+		__supported_pte_mask |= _PAGE_GLOBAL;
+}
+
 static void __init probe_page_size_mask(void)
 {
 	/*
@@ -179,11 +185,11 @@ static void __init probe_page_size_mask(
 		cr4_set_bits_and_update_boot(X86_CR4_PSE);
 
 	/* Enable PGE if available */
+	__supported_pte_mask &= ~_PAGE_GLOBAL;
 	if (boot_cpu_has(X86_FEATURE_PGE)) {
 		cr4_set_bits_and_update_boot(X86_CR4_PGE);
-		__supported_pte_mask |= _PAGE_GLOBAL;
-	} else
-		__supported_pte_mask &= ~_PAGE_GLOBAL;
+		enable_global_pages();
+	}
 
 	/* Enable 1 GB linear kernel mappings if available: */
 	if (direct_gbpages && boot_cpu_has(X86_FEATURE_GBPAGES)) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2E4366B0253
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 17:50:08 -0400 (EDT)
Received: by obkg7 with SMTP id g7so125847873obk.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:50:08 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id m130si13295131oif.99.2015.08.24.14.50.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 14:50:07 -0700 (PDT)
Message-ID: <1440452880.14237.13.camel@hp.com>
Subject: Re: [PATCH v3 1/10] x86/vdso32: Define PGTABLE_LEVELS to 32bit VDSO
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 24 Aug 2015 15:48:00 -0600
In-Reply-To: <55D65CF7.1020903@hp.com>
References: <1438811013-30983-1-git-send-email-toshi.kani@hp.com>
	 <1438811013-30983-2-git-send-email-toshi.kani@hp.com>
	 <alpine.DEB.2.11.1508202145540.3873@nanos> <55D65CF7.1020903@hp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: hpa@zytor.com, mingo@redhat.com, akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com

On Thu, 2015-08-20 at 17:04 -0600, Toshi Kani wrote:
> On 8/20/2015 1:46 PM, Thomas Gleixner wrote:
> > On Wed, 5 Aug 2015, Toshi Kani wrote:
> > 
> > > In case of CONFIG_X86_64, vdso32/vclock_gettime.c fakes a 32bit
> > > kernel configuration by re-defining it to CONFIG_X86_32.  However,
> > > it does not re-define CONFIG_PGTABLE_LEVELS leaving it as 4 levels.
> > > Fix it by re-defining CONFIG_PGTABLE_LEVELS to 2 as X86_PAE is not
> > > set.
> > You fail to explain WHY this is required. I have not yet spotted any
> > code in vclock_gettime.c which is affected by this.
> 
> Sorry about that.  Without this patch 01, applying patch 02 & 03 causes 
> the following compile errors in vclock_gettime.c.  This is because it 
> includes pgtable_type.h (see blow), which now requires PUD_SHIFT and 
> PMD_SHIFT defined properly.  In case of X86_32, pgtable_type.h includes 
> pgtable_nopud.h and pgtable-nopmd.h, which define these SHIFTs when 
> CONFIG_PGTABLE_LEVEL is set to 2 (or 3 if PAE is also defined).
>  :

Attached is patch 01/10 with updated descriptions.  The rest of the patchset
still applies cleanly.

Please let me know if you have any further comments.
Thanks,
-Toshi

----
Subject: [PATCH v3 UPDATE 1/10] x86/vdso32: Define PGTABLE_LEVELS to 32bit
VDSO

In case of CONFIG_X86_64, vdso32/vclock_gettime.c fakes a 32-bit
non-PAE kernel configuration by re-defining it to CONFIG_X86_32.
However, it does not re-define CONFIG_PGTABLE_LEVELS leaving it
as 4 levels.

This mismatch leads <asm/pgtable_type.h> to NOT include <asm-generic/
pgtable-nopud.h> and <asm-generic/pgtable-nopmd.h>, which will cause
compile errors when a later patch enhances <asm/pgtable_type.h> to
use PUD_SHIFT and PMD_SHIFT.  These -nopud & -nopmd headers define
these SHIFTs for the 32-bit non-PAE kernel.

Fix it by re-defining CONFIG_PGTABLE_LEVELS to 2 levels.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
---
 arch/x86/entry/vdso/vdso32/vclock_gettime.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/x86/entry/vdso/vdso32/vclock_gettime.c
b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
index 175cc72..87a86e0 100644
--- a/arch/x86/entry/vdso/vdso32/vclock_gettime.c
+++ b/arch/x86/entry/vdso/vdso32/vclock_gettime.c
@@ -14,11 +14,13 @@
  */
 #undef CONFIG_64BIT
 #undef CONFIG_X86_64
+#undef CONFIG_PGTABLE_LEVELS
 #undef CONFIG_ILLEGAL_POINTER_VALUE
 #undef CONFIG_SPARSEMEM_VMEMMAP
 #undef CONFIG_NR_CPUS
 
 #define CONFIG_X86_32 1
+#define CONFIG_PGTABLE_LEVELS 2
 #define CONFIG_PAGE_OFFSET 0
 #define CONFIG_ILLEGAL_POINTER_VALUE 0
 #define CONFIG_NR_CPUS 1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

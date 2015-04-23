Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA986B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 11:54:17 -0400 (EDT)
Received: by layy10 with SMTP id y10so15979187lay.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 08:54:17 -0700 (PDT)
Received: from numascale.com (numascale.com. [213.162.240.84])
        by mx.google.com with ESMTPS id q3si6220861lah.142.2015.04.23.08.54.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Apr 2015 08:54:15 -0700 (PDT)
Date: Thu, 23 Apr 2015 23:53:57 +0800
From: Daniel J Blueman <daniel@numascale.com>
Subject: Re: [PATCH 0/13] Parallel struct page initialisation v3
Message-Id: <1429804437.24139.3@cpanel21.proisp.no>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, 'Steffen Persvold' <sp@numascale.com>

On Thu, Apr 23, 2015 at 6:33 PM, Mel Gorman <mgorman@suse.de> wrote:
> The big change here is an adjustment to the topology_init path that 
> caused
> soft lockups on Waiman and Daniel Blue had reported it was an 
> expensive
> function.
> 
> Changelog since v2
> o Reduce overhead of topology_init
> o Remove boot-time kernel parameter to enable/disable
> o Enable on UMA
> 
> Changelog since v1
> o Always initialise low zones
> o Typo corrections
> o Rename parallel mem init to parallel struct page init
> o Rebase to 4.0
[]

Splendid work! On this 256c setup, topology_init now takes 185ms.

This brings the kernel boot time down to 324s [1]. It turns out that 
one memset is responsible for most of the time setting up the the PUDs 
and PMDs; adapting memset to using non-temporal writes [3] avoids 
generating RMW cycles, bringing boot time down to 186s [2].

If this is a possibility, I can split this patch and map other arch's 
memset_nocache to memset, or change the callsite as preferred; comments 
welcome.

Thanks,
  Daniel

[1] https://resources.numascale.com/telemetry/defermem/h8qgl-defer2.txt
[2] 
https://resources.numascale.com/telemetry/defermem/h8qgl-defer2-nontemporal.txt

-- [3]

 From f822139736cab8434302693c635fa146b465273c Mon Sep 17 00:00:00 2001
 From: Daniel J Blueman <daniel@numascale.com>
Date: Thu, 23 Apr 2015 23:26:27 +0800
Subject: [RFC] Speedup PMD setup

Using non-temporal writes prevents read-modify-write cycles,
which are much slower over large topologies.

Adapt the existing memset() function into a _nocache variant and use
when setting up PMDs during early boot to reduce boot time.

Signed-off-by: Daniel J Blueman <daniel@numascale.com>
---
 arch/x86/include/asm/string_64.h |  3 ++
 arch/x86/lib/memset_64.S         | 90 
++++++++++++++++++++++++++++++++++++++++
 mm/memblock.c                    |  2 +-
 3 files changed, 94 insertions(+), 1 deletion(-)

diff --git a/arch/x86/include/asm/string_64.h 
b/arch/x86/include/asm/string_64.h
index e466119..1ef28d0 100644
--- a/arch/x86/include/asm/string_64.h
+++ b/arch/x86/include/asm/string_64.h
@@ -55,6 +55,8 @@ extern void *memcpy(void *to, const void *from, 
size_t len);
 #define __HAVE_ARCH_MEMSET
 void *memset(void *s, int c, size_t n);
 void *__memset(void *s, int c, size_t n);
+void *memset_nocache(void *s, int c, size_t n);
+void *__memset_nocache(void *s, int c, size_t n);

 #define __HAVE_ARCH_MEMMOVE
 void *memmove(void *dest, const void *src, size_t count);
@@ -77,6 +79,7 @@ int strcmp(const char *cs, const char *ct);
 #define memcpy(dst, src, len) __memcpy(dst, src, len)
 #define memmove(dst, src, len) __memmove(dst, src, len)
 #define memset(s, c, n) __memset(s, c, n)
+#define memset_nocache(s, c, n) __memset_nocache(s, c, n)
 #endif

 #endif /* __KERNEL__ */
diff --git a/arch/x86/lib/memset_64.S b/arch/x86/lib/memset_64.S
index 6f44935..fb46f78 100644
--- a/arch/x86/lib/memset_64.S
+++ b/arch/x86/lib/memset_64.S
@@ -137,6 +137,96 @@ ENTRY(__memset)
 ENDPROC(memset)
 ENDPROC(__memset)

+/*
+ * bzero_nocache - set a memory block to zero. This function uses
+ * non-temporal writes in the fastpath
+ *
+ * rdi   destination
+ * rsi   value (char)
+ * rdx   count (bytes)
+ *
+ * rax   original destination
+ */
+
+ENTRY(memset_nocache)
+ENTRY(__memset_nocache)
+	CFI_STARTPROC
+	movq %rdi,%r10
+
+	/* expand byte value */
+	movzbl %sil,%ecx
+	movabs $0x0101010101010101,%rax
+	imulq  %rcx,%rax
+
+	/* align dst */
+	movl  %edi,%r9d
+	andl  $7,%r9d
+	jnz  bad_alignment
+	CFI_REMEMBER_STATE
+after_bad_alignment:
+
+	movq  %rdx,%rcx
+	shrq  $6,%rcx
+	jz	 handle_tail
+
+	.p2align 4
+loop_64:
+	decq  %rcx
+	movnti	%rax,(%rdi)
+	movnti	%rax,8(%rdi)
+	movnti	%rax,16(%rdi)
+	movnti	%rax,24(%rdi)
+	movnti	%rax,32(%rdi)
+	movnti	%rax,40(%rdi)
+	movnti	%rax,48(%rdi)
+	movnti	%rax,56(%rdi)
+	leaq  64(%rdi),%rdi
+	jnz    loop_64
+
+	/* Handle tail in loops; the loops should be faster than hard
+	   to predict jump tables */
+	.p2align 4
+handle_tail:
+	movl	%edx,%ecx
+	andl    $63&(~7),%ecx
+	jz 		handle_7
+	shrl	$3,%ecx
+	.p2align 4
+loop_8:
+	decl   %ecx
+	movnti %rax,(%rdi)
+	leaq  8(%rdi),%rdi
+	jnz    loop_8
+
+handle_7:
+	andl	$7,%edx
+	jz      ende
+	.p2align 4
+loop_1:
+	decl    %edx
+	movb	%al,(%rdi)
+	leaq	1(%rdi),%rdi
+	jnz     loop_1
+
+ende:
+	movq	%r10,%rax
+	ret
+
+	CFI_RESTORE_STATE
+bad_alignment:
+	cmpq $7,%rdx
+	jbe	handle_7
+	movnti %rax,(%rdi)	/* unaligned store */
+	movq $8,%r8
+	subq %r9,%r8
+	addq %r8,%rdi
+	subq %r8,%rdx
+	jmp after_bad_alignment
+final:
+	CFI_ENDPROC
+ENDPROC(memset_nocache)
+ENDPROC(__memset_nocache)
+
 	/* Some CPUs support enhanced REP MOVSB/STOSB feature.
 	 * It is recommended to use this when possible.
 	 *
diff --git a/mm/memblock.c b/mm/memblock.c
index f3e97d8..df434d2 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1212,7 +1212,7 @@ again:
 done:
 	memblock_reserve(alloc, size);
 	ptr = phys_to_virt(alloc);
-	memset(ptr, 0, size);
+	memset_nocache(ptr, 0, size);

 	/*
 	 * The min_count is set to 0 so that bootmem allocated blocks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

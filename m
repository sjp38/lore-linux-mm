Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E9CE16B025F
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 02:27:20 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id t25so24212253pfg.15
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 23:27:20 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id 64si449166plb.171.2017.08.07.23.27.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 23:27:19 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm] mm: Clear to access sub-page last when clearing huge page
References: <20170807072131.8343-1-ying.huang@intel.com>
	<alpine.DEB.2.20.1708071343030.19915@nuc-kabylake>
Date: Tue, 08 Aug 2017 14:26:30 +0800
In-Reply-To: <alpine.DEB.2.20.1708071343030.19915@nuc-kabylake> (Christopher
	Lameter's message of "Mon, 7 Aug 2017 13:46:37 -0500")
Message-ID: <87wp6ebmnd.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Nadia Yvette Chambers <nyc@holomorphy.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Shaohua Li <shli@fb.com>

Christopher Lameter <cl@linux.com> writes:

> On Mon, 7 Aug 2017, Huang, Ying wrote:
>
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -4374,9 +4374,31 @@ void clear_huge_page(struct page *page,
>>  	}
>>
>>  	might_sleep();
>> -	for (i = 0; i < pages_per_huge_page; i++) {
>> +	VM_BUG_ON(clamp(addr_hint, addr, addr +
>> +			(pages_per_huge_page << PAGE_SHIFT)) != addr_hint);
>> +	n = (addr_hint - addr) / PAGE_SIZE;
>> +	if (2 * n <= pages_per_huge_page) {
>> +		base = 0;
>> +		l = n;
>> +		for (i = pages_per_huge_page - 1; i >= 2 * n; i--) {
>> +			cond_resched();
>> +			clear_user_highpage(page + i, addr + i * PAGE_SIZE);
>> +		}
>
> I really like the idea behind the patch but this is not clearing from last
> to first byte of the huge page.
>
> What seems to be happening here is clearing from the last page to the
> first page and I would think that within each page the clearing is from
> first byte to last byte. Maybe more gains can be had by really clearing
> from last to first byte of the huge page instead of this jumping over 4k
> addresses?

I changed the code to use clear_page_orig() and make it clear pages from
last to first.  The patch is as below.

With that, there is no visible changes in benchmark result.  But the
cache miss rate dropped a little from 27.64% to 26.70%.  The cache miss
rate is different with before because the clear_page() implementation
used is different.

I think this is because the size of page is relative small compared with
the cache size, so that the effect is almost invisible.

Best Regards,
Huang, Ying

--------------->8----------------
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index b4a0d43248cf..01d201afde92 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -42,8 +42,8 @@ void clear_page_erms(void *page);
 static inline void clear_page(void *page)
 {
 	alternative_call_2(clear_page_orig,
-			   clear_page_rep, X86_FEATURE_REP_GOOD,
-			   clear_page_erms, X86_FEATURE_ERMS,
+			   clear_page_orig, X86_FEATURE_REP_GOOD,
+			   clear_page_orig, X86_FEATURE_ERMS,
 			   "=D" (page),
 			   "0" (page)
 			   : "memory", "rax", "rcx");
diff --git a/arch/x86/lib/clear_page_64.S b/arch/x86/lib/clear_page_64.S
index 81b1635d67de..23e6238e625d 100644
--- a/arch/x86/lib/clear_page_64.S
+++ b/arch/x86/lib/clear_page_64.S
@@ -25,19 +25,20 @@ EXPORT_SYMBOL_GPL(clear_page_rep)
 ENTRY(clear_page_orig)
 	xorl   %eax,%eax
 	movl   $4096/64,%ecx
+	addq   $4096-64,%rdi
 	.p2align 4
 .Lloop:
 	decl	%ecx
 #define PUT(x) movq %rax,x*8(%rdi)
-	movq %rax,(%rdi)
-	PUT(1)
-	PUT(2)
-	PUT(3)
-	PUT(4)
-	PUT(5)
-	PUT(6)
 	PUT(7)
-	leaq	64(%rdi),%rdi
+	PUT(6)
+	PUT(5)
+	PUT(4)
+	PUT(3)
+	PUT(2)
+	PUT(1)
+	movq %rax,(%rdi)
+	leaq	-64(%rdi),%rdi
 	jnz	.Lloop
 	nop
 	ret

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

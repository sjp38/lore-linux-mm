Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6F6C26B0255
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 14:39:07 -0500 (EST)
Received: by mail-pf0-f171.google.com with SMTP id q63so16797163pfb.0
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 11:39:07 -0800 (PST)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id a78si6923879pfj.116.2016.02.10.11.39.06
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 11:39:06 -0800 (PST)
Date: Wed, 10 Feb 2016 11:39:05 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v10 3/4] x86, mce: Add __mcsafe_copy()
Message-ID: <20160210193905.GB29493@agluck-desk.sc.intel.com>
References: <cover.1454618190.git.tony.luck@intel.com>
 <6b63a88e925bbc821dc87f209909c3c1166b3261.1454618190.git.tony.luck@intel.com>
 <20160207164933.GE5862@pd.tnic>
 <20160209231557.GA23207@agluck-desk.sc.intel.com>
 <20160210105843.GD23914@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160210105843.GD23914@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, elliott@hpe.com, Brian Gerst <brgerst@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@ml01.01.org, x86@kernel.org

On Wed, Feb 10, 2016 at 11:58:43AM +0100, Borislav Petkov wrote:
> But one could take out that function do some microbenchmarking with
> different sizes and once with the current version and once with the
> pushes and pops of r1[2-5] to see where the breakeven is.

On a 4K page copy from a source address that isn't in the
cache I see all sorts of answers.

On my desktop (i7-3960X) it is ~50 cycles slower to push and pop the four
registers.

On my latest Xeon - I can't post benchmarks ... but also a bit slower.

On an older Xeon it is a few cycles faster (but even though I'm
looking at the median of 10,000 runs I see more run-to-run variation
that I see difference between register choices.

Here's what I tested:

	push %r12
	push %r13
	push %r14
	push %r15

	/* Loop copying whole cache lines */
1:	movq (%rsi),%r8
2:	movq 1*8(%rsi),%r9
3:	movq 2*8(%rsi),%r10
4:	movq 3*8(%rsi),%r11
9:	movq 4*8(%rsi),%r12
10:	movq 5*8(%rsi),%r13
11:	movq 6*8(%rsi),%r14
12:	movq 7*8(%rsi),%r15
	movq %r8,(%rdi)
	movq %r9,1*8(%rdi)
	movq %r10,2*8(%rdi)
	movq %r11,3*8(%rdi)
	movq %r12,4*8(%rdi)
	movq %r13,5*8(%rdi)
	movq %r14,6*8(%rdi)
	movq %r15,7*8(%rdi)
	leaq 64(%rsi),%rsi
	leaq 64(%rdi),%rdi
	decl %ecx
	jnz 1b

	pop %r15
	pop %r14
	pop %r13
	pop %r12
-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4F6EE6B0007
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 18:41:36 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id 127-v6so6783111pge.10
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 15:41:36 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id x9-v6si8455087plv.159.2018.04.30.15.41.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 30 Apr 2018 15:41:35 -0700 (PDT)
Date: Mon, 30 Apr 2018 15:41:33 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
Message-ID: <20180430224133.GA7076@bombadil.infradead.org>
References: <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien>
 <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien>
 <20180313183220.GA21538@bombadil.infradead.org>
 <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com>
 <20180429203023.GA11891@bombadil.infradead.org>
 <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
 <20180430201607.GA7041@bombadil.infradead.org>
 <4ad99a55-9c93-5ea1-5954-3cb6e5ba7df9@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4ad99a55-9c93-5ea1-5954-3cb6e5ba7df9@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: Kees Cook <keescook@chromium.org>, Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On Mon, Apr 30, 2018 at 11:29:04PM +0200, Rasmus Villemoes wrote:
> On 2018-04-30 22:16, Matthew Wilcox wrote:
> > On Mon, Apr 30, 2018 at 12:02:14PM -0700, Kees Cook wrote:
> >> (I just wish C had a sensible way to catch overflow...)
> > 
> > Every CPU I ever worked with had an "overflow" bit ... do we have a
> > friend on the C standards ctte who might figure out a way to let us
> > write code that checks it?
> 
> gcc 5.1+ (I think) have the __builtin_OP_overflow checks that should
> generate reasonable code. Too bad there's no completely generic
> check_all_ops_in_this_expression(a+b*c+d/e, or_jump_here). Though it's
> hard to define what they should be checked against - probably would
> require all subexpressions (including the variables themselves) to have
> the same type.

Nevertheless these generate much better code than our current safeguards!

extern void *malloc(unsigned long);

#define ULONG_MAX (~0UL)
#define SZ	8UL

void *a(unsigned long a)
{
	if ((ULONG_MAX / SZ) > a)
		return 0;
	return malloc(a * SZ);
}

void *b(unsigned long a)
{
	unsigned long c;
	if (__builtin_mul_overflow(a, SZ, &c))
		return 0;
	return malloc(c);
}

(a lot of code uses a constant '8' as sizeof(void *)).  Here's the
difference with gcc 7.3:

   0:   48 b8 fe ff ff ff ff    movabs $0x1ffffffffffffffe,%rax
   7:   ff ff 1f 
   a:   48 39 c7                cmp    %rax,%rdi
   d:   76 09                   jbe    18 <a+0x18>
   f:   48 c1 e7 03             shl    $0x3,%rdi
  13:   e9 00 00 00 00          jmpq   18 <a+0x18>
                        14: R_X86_64_PLT32      malloc-0x4
  18:   31 c0                   xor    %eax,%eax
  1a:   c3                      retq   

vs

  20:   48 89 f8                mov    %rdi,%rax
  23:   ba 08 00 00 00          mov    $0x8,%edx
  28:   48 f7 e2                mul    %rdx
  2b:   48 89 c7                mov    %rax,%rdi
  2e:   70 05                   jo     35 <b+0x15>
  30:   e9 00 00 00 00          jmpq   35 <b+0x15>
                        31: R_X86_64_PLT32      malloc-0x4
  35:   31 c0                   xor    %eax,%eax
  37:   c3                      retq   

We've traded a shl for a mul (because shl doesn't set Overflow, only
Carry, and that's only bit 65, not an OR of bits 35-n), but we lose the
movabs and cmp.  I'd rather run the second code fragment than the first.

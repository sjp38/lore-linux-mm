Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 342786B000C
	for <linux-mm@kvack.org>; Thu,  3 May 2018 19:00:52 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id d4-v6so13107717wrn.15
        for <linux-mm@kvack.org>; Thu, 03 May 2018 16:00:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v22-v6sor10339975edq.21.2018.05.03.16.00.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 03 May 2018 16:00:50 -0700 (PDT)
Subject: Re: [PATCH 2/2] mm: Add kvmalloc_ab_c and kvzalloc_struct
References: <CAGXu5jL9hqQGe672CmvFwqNbtTr=qu7WRwHuS4Vy7o5sX_UTgg@mail.gmail.com>
 <alpine.DEB.2.20.1803072212160.2814@hadrien>
 <20180308025812.GA9082@bombadil.infradead.org>
 <alpine.DEB.2.20.1803080722300.3754@hadrien>
 <20180308230512.GD29073@bombadil.infradead.org>
 <alpine.DEB.2.20.1803131818550.3117@hadrien>
 <20180313183220.GA21538@bombadil.infradead.org>
 <CAGXu5jKLaY2vzeFNaEhZOXbMgDXp4nF4=BnGCFfHFRwL6LXNHA@mail.gmail.com>
 <20180429203023.GA11891@bombadil.infradead.org>
 <CAGXu5j+N9tt4rxaUMxoZnE-ziqU_yu-jkt-cBZ=R8wmYq6XBTg@mail.gmail.com>
 <20180430201607.GA7041@bombadil.infradead.org>
 <4ad99a55-9c93-5ea1-5954-3cb6e5ba7df9@rasmusvillemoes.dk>
 <CAGXu5j+tYhQOfVMkZdPzW5CX103LHpm8SYSN51VFLufn0Z0y6Q@mail.gmail.com>
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <4e25ff5b-f8fc-7012-83c2-b56e6928e8bc@rasmusvillemoes.dk>
Date: Fri, 4 May 2018 01:00:43 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5j+tYhQOfVMkZdPzW5CX103LHpm8SYSN51VFLufn0Z0y6Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>, Daniel Vetter <daniel.vetter@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On 2018-05-01 19:00, Kees Cook wrote:
> On Mon, Apr 30, 2018 at 2:29 PM, Rasmus Villemoes
> <linux@rasmusvillemoes.dk> wrote:
>>
>> gcc 5.1+ (I think) have the __builtin_OP_overflow checks that should
>> generate reasonable code. Too bad there's no completely generic
>> check_all_ops_in_this_expression(a+b*c+d/e, or_jump_here). Though it's
>> hard to define what they should be checked against - probably would
>> require all subexpressions (including the variables themselves) to have
>> the same type.
>>
>> plug: https://lkml.org/lkml/2015/7/19/358
> 
> That's a very nice series. Why did it never get taken?

Well, nobody seemed particularly interested, and then
https://lkml.org/lkml/2015/10/28/215 happened... but he did later seem
to admit that it could be useful for the multiplication checking, and
that "the gcc interface for multiplication overflow is fine".

I still think even for unsigned types overflow checking can be subtle. E.g.

u32 somevar;

if (somevar + sizeof(foo) < somevar)
  return -EOVERFLOW;
somevar += sizeof(this);

is broken, because the LHS is promoted to unsigned long/size_t, then so
is the RHS for the comparison, and the comparison is thus always false
(on 64bit). It gets worse if the two types are more "opaque", and in any
case it's not always easy to verify at a glance that the types are the
same, or at least that the expression of the widest type is on the RHS.

> It seems to do the right things quite correctly.

Yes, I wouldn't suggest it without the test module verifying corner
cases, and checking it has the same semantics whether used with old or
new gcc.

Would you shepherd it through if I updated the patches and resent?

Rasmus

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3BEC16B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 17:29:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id b23so5683916wme.3
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 14:29:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r6-v6sor5450365edi.22.2018.04.30.14.29.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Apr 2018 14:29:06 -0700 (PDT)
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
From: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Message-ID: <4ad99a55-9c93-5ea1-5954-3cb6e5ba7df9@rasmusvillemoes.dk>
Date: Mon, 30 Apr 2018 23:29:04 +0200
MIME-Version: 1.0
In-Reply-To: <20180430201607.GA7041@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, Kees Cook <keescook@chromium.org>
Cc: Julia Lawall <julia.lawall@lip6.fr>, Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <mawilcox@microsoft.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, cocci@systeme.lip6.fr, Himanshu Jha <himanshujha199640@gmail.com>

On 2018-04-30 22:16, Matthew Wilcox wrote:
> On Mon, Apr 30, 2018 at 12:02:14PM -0700, Kees Cook wrote:
>>
>> Getting the constant ordering right could be part of the macro
>> definition, maybe? i.e.:
>>
>> static inline void *kmalloc_ab(size_t a, size_t b, gfp_t flags)
>> {
>>     if (__builtin_constant_p(a) && a != 0 && \
>>         b > SIZE_MAX / a)
>>             return NULL;
>>     else if (__builtin_constant_p(b) && b != 0 && \
>>                a > SIZE_MAX / b)
>>             return NULL;
>>
>>     return kmalloc(a * b, flags);
>> }
> 
> Ooh, if neither a nor b is constant, it just didn't do a check ;-(  This
> stuff is hard.
> 
>> (I just wish C had a sensible way to catch overflow...)
> 
> Every CPU I ever worked with had an "overflow" bit ... do we have a
> friend on the C standards ctte who might figure out a way to let us
> write code that checks it?

gcc 5.1+ (I think) have the __builtin_OP_overflow checks that should
generate reasonable code. Too bad there's no completely generic
check_all_ops_in_this_expression(a+b*c+d/e, or_jump_here). Though it's
hard to define what they should be checked against - probably would
require all subexpressions (including the variables themselves) to have
the same type.

plug: https://lkml.org/lkml/2015/7/19/358

Rasmus

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 454B36B0008
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:34:49 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id i11so6046470pgq.10
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 07:34:49 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [198.137.202.133])
        by mx.google.com with ESMTPS id t4si6746692pfh.290.2018.03.23.07.34.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 23 Mar 2018 07:34:47 -0700 (PDT)
Date: Fri, 23 Mar 2018 07:34:35 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 3/4] mm: Add free()
Message-ID: <20180323143435.GB5624@bombadil.infradead.org>
References: <20180322195819.24271-1-willy@infradead.org>
 <20180322195819.24271-4-willy@infradead.org>
 <1e95ce64-828b-1214-a930-1ffaedfa00b8@rasmusvillemoes.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1e95ce64-828b-1214-a930-1ffaedfa00b8@rasmusvillemoes.dk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rasmus Villemoes <linux@rasmusvillemoes.dk>
Cc: linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Mar 23, 2018 at 09:04:10AM +0100, Rasmus Villemoes wrote:
> On 2018-03-22 20:58, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > free() can free many different kinds of memory.
> 
> I'd be a bit worried about using that name. gcc very much knows about
> the C standard's definition of that function, as can be seen on
> godbolt.org by compiling
> 
> void free(const void *);
> void f(void)
> {
>     free((void*)0);
> }
> 
> with -O2 -Wall -Wextra -c. Anything from 4.6 onwards simply compiles this to
> 
> f:
>  repz retq
> 
> And sure, your free() implementation obviously also has that property,
> but I'm worried that they might one day decide to warn about the
> prototype mismatch (actually, I'm surprised it doesn't warn now, given
> that it obviously pretends to know what free() function I'm calling...),
> or make some crazy optimization that will break stuff in very subtle ways.
> 
> Also, we probably don't want people starting to use free() (or whatever
> name is chosen) if they do know the kind of memory they're freeing?
> Maybe it should not be advertised that widely (i.e., in kernel.h).

All that you've said I see as an advantage, not a disadvantage.
Maybe I should change the prototype to match the userspace
free(), although gcc is deliberately lax about the constness of
function arguments when determining compatibility with builtins.
See match_builtin_function_types() if you're really curious.

gcc already does some nice optimisations around free().  For example, it
can eliminate dead stores:

#include <stdlib.h>

void f(char *foo)
{
	foo[1] = 3;
	free(foo);
}

becomes:

0000000000000000 <f>:
   0:	e9 00 00 00 00       	jmpq   5 <f+0x5>
			1: R_X86_64_PLT32	free-0x4

You can see more things it knows about free() by grepping for
BUILT_IN_FREE.  

I absolutely do want to see people using free() instead of kfree()
if it's not important that the memory was kmalloced.  I wouldn't go
through and change existing code, but I do want to see
#define malloc(x) kvmalloc((x), GFP_KERNEL)

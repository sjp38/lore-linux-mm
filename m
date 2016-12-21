Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B19A96B03C1
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 13:02:28 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j15so27796698ioj.7
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:02:28 -0800 (PST)
Received: from mail-it0-x241.google.com (mail-it0-x241.google.com. [2607:f8b0:4001:c0b::241])
        by mx.google.com with ESMTPS id b133si17249899itc.33.2016.12.21.10.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Dec 2016 10:02:27 -0800 (PST)
Received: by mail-it0-x241.google.com with SMTP id 75so18241164ite.1
        for <linux-mm@kvack.org>; Wed, 21 Dec 2016 10:02:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161221083247.GW3174@twins.programming.kicks-ass.net>
References: <20161219225826.F8CB356F@viggo.jf.intel.com> <CA+55aFwK6JdSy9v_BkNYWNdfK82sYA1h3qCSAJQ0T45cOxeXmQ@mail.gmail.com>
 <156a5b34-ad3b-d0aa-83c9-109b366c1bdf@linux.intel.com> <CA+55aFxVzes5Jt-hC9BLVSb99x6K-_WkLO-_JTvCjhf5wuK_4w@mail.gmail.com>
 <CA+55aFwy6+ya_E8N3DFbrq2XjbDs8LWe=W_qW8awimbxw26bJw@mail.gmail.com>
 <20161221080931.GQ3124@twins.programming.kicks-ass.net> <20161221083247.GW3174@twins.programming.kicks-ass.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 21 Dec 2016 10:02:27 -0800
Message-ID: <CA+55aFx-YmpZ4NBU0oSw_iJV8jEMaL8qX-HCH=DrutQ65UYR5A@mail.gmail.com>
Subject: Re: [RFC][PATCH] make global bitlock waitqueues per-node
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Nick Piggin <npiggin@gmail.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Bob Peterson <rpeterso@redhat.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Steven Whitehouse <swhiteho@redhat.com>, Andrew Lutomirski <luto@kernel.org>, Andreas Gruenbacher <agruenba@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-mm <linux-mm@kvack.org>

On Wed, Dec 21, 2016 at 12:32 AM, Peter Zijlstra <peterz@infradead.org> wrote:
>
> FWIW, here's mine.. compiles and boots on a NUMA x86_64 machine.

So I like how your patch is smaller, but your patch is also broken.

First off, the whole contention bit is *not* NUMA-specific. It should
help non-NUMA too, by avoiding the stupid extra cache miss.

Secondly, CONFIG_NUMA is a broken thing to test anyway, since adding a
bit for the NUMA case can overflow the page flags as far as I can tell
(MIPS seems to support NUMA on 32-bit, for example, but I didn't
really check the Kconfig details). Making it dependent on 64-bit might
be ok (and would fix the issue above - I don't think we really need to
care too much about 32-bit any more)

But making it conditional at all means that now you have those two
different cases for this, which is a maintenance nightmare. So don't
do it even if we could say "screw 32-bit".

Anyway, the conditional thing could be fixed by just taking Nick's
patch 1/2, and your patch (with the conditional bits stripped out).

I do think your approach of just re-using the existing bit waiting
with just a page-specific waiting function is nicer than Nick's "let's
just roll new waiting functions" approach. It also avoids the extra
initcall.

Nick, comments?

Hugh - mind testing PeterZ's patch too? My comments about the
conditional PG_waiters bit and page bit overflow are not relevant for
your particular scenario, so you can ignore that part, and just take
PaterZ's patch directly.

               Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

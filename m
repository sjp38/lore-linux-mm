Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFA8C6B000D
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:52:31 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id 62-v6so13672472ply.4
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 12:52:31 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s1si10738062pgb.434.2018.03.26.12.52.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 12:52:30 -0700 (PDT)
Date: Mon, 26 Mar 2018 12:52:28 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm/page_owner: ignore everything below the IRQ entry
 point
Message-Id: <20180326125228.1f40abb9a52f3674b1491aea@linux-foundation.org>
In-Reply-To: <20180326141717epcms5p4064a0fd4f594b2ff434f9b05cd1ea5ad@epcms5p4>
References: <CACT4Y+Yfx+fTHyQ=d3T68bwfgQQsmqd+e72V67kaAHajo536JA@mail.gmail.com>
	<1522058304-35934-1-git-send-email-maninder1.s@samsung.com>
	<CGME20180326100020epcas5p2b50b7541e66dccf4e49db634e5fe6b41@epcms5p4>
	<20180326141717epcms5p4064a0fd4f594b2ff434f9b05cd1ea5ad@epcms5p4>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: v.narang@samsung.com
Cc: Dmitry Vyukov <dvyukov@google.com>, Maninder Singh <maninder1.s@samsung.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Kate Stewart <kstewart@linuxfoundation.org>, Thomas Gleixner <tglx@linutronix.de>, Philippe Ombredanne <pombredanne@nexb.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Stephen Rothwell <sfr@canb.auug.org.au>, Michal Hocko <mhocko@suse.com>, "vinmenon@codeaurora.org" <vinmenon@codeaurora.org>, "gomonovych@gmail.com" <gomonovych@gmail.com>, Ayush Mittal <ayush.m@samsung.com>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, AMIT SAHRAWAT <a.sahrawat@samsung.com>, PANKAJ MISHRA <pankaj.m@samsung.com>

On Mon, 26 Mar 2018 19:47:17 +0530 Vaneet Narang <v.narang@samsung.com> wrote:

> Hi Dmitry,
> 
> >Every user of stack_depot should filter out irq frames, without that
> >stack_depot will run out of memory sooner or later. so this is a
> >change in the right direction.
> > 
> >Do we need to define empty version of in_irqentry_text? Shouldn't only
> >filter_irq_stacks be used by kernel code?
> 
> We thought about this but since we were adding both the APIs filter_irq_stacks & in_irqentry_text 
> in header file so we thought of defining empty definition for both as both the APIs are accessible
> to the module who is going to include header file.
> 
> If you think empty definition of in_irqentry_text() is not requited then we will modify & resend the
> patch.
> 

filter_irq_stacks() is too large to be inlined.

The CONFIG_STACKTRACE=n versions should be regular C functions, not
macros.  But stacktrace.c decided to do them all as macros,
unfortunately.

in_irqentry_text() is probably too large to be inlined as well, and
should return bool.

Declarations for __irqentry_text_start and friends already exist in
include/asm-generic/sections.h (and, for some reason, also in
arch/arm/include/asm/traps.h) and should not be duplicated in
include/linux/stacktrace.h.

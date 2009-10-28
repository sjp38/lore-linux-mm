Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C1F4A6B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 13:53:58 -0400 (EDT)
Subject: [PATCH 0/2] Some fixes to debug_kmap_atomic()
From: Soeren Sandmann <sandmann@daimi.au.dk>
Date: 28 Oct 2009 18:53:55 +0100
Message-ID: <ye84opj9zgs.fsf@camel23.daimi.au.dk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: mingo@elte.hu, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

Hi, 

Here are two patches that fix an issue with debug_kmap_atomic(). 

The first one is a pretty straightforward fix for a race that can
cause an underflow, which in turn causes the stream of warnings to
never end.

The second patch extends debug_kmap_atomic() to deal with KM_IRQ_PTE,
KM_NMI, and KM_NMI_PTE.

I was seeing this because the __get_user_pages_fast() in
arch/x86/kernel/cpu/perf_events.c ends up eventually calling
kmap_atomic() with KM_PTE, which, with CONFIG_HIGHPTE enabled, ends up
expanding to:

#define __KM_PTE                        \
        (in_nmi() ? KM_NMI_PTE :        \
         in_irq() ? KM_IRQ_PTE :        \
         KM_PTE0)

and those KM_* types are not handled 

For the second patch, I am basically pattern matching, so I might be
completely wrong.


Thanks,
Soren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

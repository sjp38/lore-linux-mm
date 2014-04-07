Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f49.google.com (mail-wg0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 228C16B0031
	for <linux-mm@kvack.org>; Mon,  7 Apr 2014 11:10:51 -0400 (EDT)
Received: by mail-wg0-f49.google.com with SMTP id a1so7090440wgh.32
        for <linux-mm@kvack.org>; Mon, 07 Apr 2014 08:10:50 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bw16si5259030wib.115.2014.04.07.08.10.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 07 Apr 2014 08:10:49 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/3] Use an alternative to _PAGE_PROTNONE for _PAGE_NUMA
Date: Mon,  7 Apr 2014 16:10:40 +0100
Message-Id: <1396883443-11696-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Cyrill Gorcunov <gorcunov@gmail.com>, Mel Gorman <mgorman@suse.de>, Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Steven Noonan <steven@uplinklabs.net>, Rik van Riel <riel@redhat.com>, David Vrabel <david.vrabel@citrix.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrea Arcangeli <aarcange@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-X86 <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>

Aliasing _PAGE_NUMA and _PAGE_PROTNONE had some convenient properties but
it ultimately gave Xen a headache and pisses almost everybody off that
looks closely at it. Two discussions on "why this makes sense" is one
discussion too many so rather than having a third there is this series.

Conceptually it's simple -- use an unused physical address bit for _PAGE_NUMA
and make it a 64-bit only feature on x86. This had been avoided before
because if the physical address space expands we are back to square one
but lets worry about that when it happens unless the x86 maintainers or
hardware people warn us that we're about to run headlong into a wall.

Testing was minimal -- short lived JVM and autonumabench tests that trigger
the relevant paths for NUMA balancing. Functionally it did not die miserably.
Performance looks as expected with no major changes.

 arch/x86/Kconfig                     |  2 +-
 arch/x86/include/asm/pgtable.h       |  8 +++----
 arch/x86/include/asm/pgtable_types.h | 44 ++++++++++++++++++++----------------
 mm/memory.c                          | 12 ----------
 4 files changed, 29 insertions(+), 37 deletions(-)

-- 
1.8.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

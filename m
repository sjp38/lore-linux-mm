Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D6396B0005
	for <linux-mm@kvack.org>; Tue,  3 Apr 2018 21:12:33 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w9-v6so9925795plp.0
        for <linux-mm@kvack.org>; Tue, 03 Apr 2018 18:12:33 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id g11si1214037pgs.153.2018.04.03.18.12.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Apr 2018 18:12:31 -0700 (PDT)
Subject: [PATCH 00/11] [v4] Use global pages with PTI
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Tue, 03 Apr 2018 18:09:46 -0700
Message-Id: <20180404010946.6186729B@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com

Changes from v3:
 * Fix whitespace issue noticed by willy
 * Clarify comments about X86_FEATURE_PGE checks
 * Clarify commit message around the necessity of _PAGE_GLOBAL
   filtering when CR4.PGE=0 or PGE is unsupported.

Changes from v2:

 * Add performance numbers to changelogs
 * Fix compile error resulting from use of x86-specific
   __default_kernel_pte_mask in arch-generic mm/early_ioremap.c
 * Delay kernel text cloning until after we are done messing
   with it (patch 11).
 * Blacklist K8 explicitly from mapping all kernel text as
   global (this should never happen because K8 does not use
   pti when pti=auto, but we on the safe side). (patch 11)

--

The later versions of the KAISER patches (pre-PTI) allowed the
user/kernel shared areas to be GLOBAL.  The thought was that this would
reduce the TLB overhead of keeping two copies of these mappings.

During the switch over to PTI, we seem to have lost our ability to have
GLOBAL mappings.  This adds them back.

To measure the benefits of this, I took a modern Atom system without
PCIDs and ran a microbenchmark[1] (higher is better):

No Global Lines (baseline  ): 6077741 lseeks/sec
88 Global Lines (kern entry): 7528609 lseeks/sec (+23.9%)
94 Global Lines (all ktext ): 8433111 lseeks/sec (+38.8%)

On a modern Skylake desktop with PCIDs, the benefits are tangible, but not
huge:

No Global pages (baseline): 15783951 lseeks/sec
28 Global pages (this set): 16054688 lseeks/sec
                             +270737 lseeks/sec (+1.71%)

I also double-checked with a kernel compile on the Skylake system (lower
is better):

No Global pages (baseline): 186.951 seconds time elapsed  ( +-  0.35% )
28 Global pages (this set): 185.756 seconds time elapsed  ( +-  0.09% )
                             -1.195 seconds (-0.64%)

1. https://github.com/antonblanchard/will-it-scale/blob/master/tests/lseek1.c

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>

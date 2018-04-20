Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8772F6B0009
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 18:24:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so5346783pfz.19
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 15:24:19 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id p16si5677937pgc.241.2018.04.20.15.24.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Apr 2018 15:24:18 -0700 (PDT)
Subject: [PATCH 4/5] x86, pti: disallow global kernel text with RANDSTRUCT
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 20 Apr 2018 15:20:26 -0700
References: <20180420222018.E7646EE1@viggo.jf.intel.com>
In-Reply-To: <20180420222018.E7646EE1@viggo.jf.intel.com>
Message-Id: <20180420222026.D0B4AAC9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, keescook@google.com, aarcange@redhat.com, luto@kernel.org, arjan@linux.intel.com, bp@alien8.de, dan.j.williams@intel.com, dwmw2@infradead.org, gregkh@linuxfoundation.org, hughd@google.com, jpoimboe@redhat.com, jgross@suse.com, torvalds@linux-foundation.org, namit@vmware.com, peterz@infradead.org, tglx@linutronix.de, vbabka@suse.cz


I believe this was originally reported by the grsecurity team who
tweeted about it (link below).

RANDSTRUCT derives its hardening benefits from the attacker's lack of
knowledge about the layout of kernel data structures.  Keep the kernel
image non-global in cases where RANDSTRUCT is in use to help keep the
layout a secret.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Reported-by: Kees Cook <keescook@google.com>
Link: https://twitter.com/grsecurity/status/985678720630476800
Fixes: 8c06c7740 (x86/pti: Leave kernel text global for !PCID)
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Arjan van de Ven <arjan@linux.intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Josh Poimboeuf <jpoimboe@redhat.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Kees Cook <keescook@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nadav Amit <namit@vmware.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org
---

 b/arch/x86/mm/pti.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN arch/x86/mm/pti.c~pti-glb-disable-with-compile-options arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~pti-glb-disable-with-compile-options	2018-04-20 14:10:02.702749165 -0700
+++ b/arch/x86/mm/pti.c	2018-04-20 14:10:02.706749165 -0700
@@ -421,6 +421,16 @@ static inline bool pti_kernel_image_glob
 	if (boot_cpu_has(X86_FEATURE_K8))
 		return false;
 
+	/*
+	 * RANDSTRUCT derives its hardening benefits from the
+	 * attacker's lack of knowledge about the layout of kernel
+	 * data structures.  Keep the kernel image non-global in
+	 * cases where RANDSTRUCT is in use to help keep the layout a
+	 * secret.
+	 */
+	if (IS_ENABLED(CONFIG_GCC_PLUGIN_RANDSTRUCT))
+		return false;
+
 	return true;
 }
 
_

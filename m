Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D96CD6B030F
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:47:59 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id b85so2988200pfj.22
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:47:59 -0800 (PST)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id 62si4413047pgh.81.2017.11.08.11.47.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 11:47:58 -0800 (PST)
Subject: [PATCH 29/30] x86, kaiser: add Kconfig
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 08 Nov 2017 11:47:40 -0800
References: <20171108194646.907A1942@viggo.jf.intel.com>
In-Reply-To: <20171108194646.907A1942@viggo.jf.intel.com>
Message-Id: <20171108194740.D1DAB7E2@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dave.hansen@linux.intel.com, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org


From: Dave Hansen <dave.hansen@linux.intel.com>

PARAVIRT generally requires that the kernel not manage its own page
tables.  It also means that the hypervisor and kernel must agree
wholeheartedly about what format the page tables are in and what
they contain.  KAISER, unfortunately, changes the rules and they
can not be used together.

I've seen conflicting feedback from maintainers lately about whether
they want the Kconfig magic to go first or last in a patch series.
It's going last here because the partially-applied series leads to
kernels that can not boot in a bunch of cases.  I did a run through
the entire series with CONFIG_KAISER=y to look for build errors,
though.

Note from Hugh Dickins on why it depends on SMP:

	It is absurd that KAISER should depend on SMP, but
	apparently nobody has tried a UP build before: which
	breaks on implicit declaration of function
	'per_cpu_offset' in arch/x86/mm/kaiser.c.

	Now, you would expect that to be trivially fixed up; but
	looking at the System.map when that block is #ifdef'ed
	out of kaiser_init(), I see that in a UP build
	__per_cpu_user_mapped_end is precisely at
	__per_cpu_user_mapped_start, and the items carefully
	gathered into that section for user-mapping on SMP,
	dispersed elsewhere on UP.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Moritz Lipp <moritz.lipp@iaik.tugraz.at>
Cc: Daniel Gruss <daniel.gruss@iaik.tugraz.at>
Cc: Michael Schwarz <michael.schwarz@iaik.tugraz.at>
Cc: Richard Fellner <richard.fellner@student.tugraz.at>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: x86@kernel.org
---

 b/security/Kconfig |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff -puN security/Kconfig~kaiser-kconfig security/Kconfig
--- a/security/Kconfig~kaiser-kconfig	2017-11-08 10:45:41.921681364 -0800
+++ b/security/Kconfig	2017-11-08 10:45:41.925681364 -0800
@@ -54,6 +54,16 @@ config SECURITY_NETWORK
 	  implement socket and networking access controls.
 	  If you are unsure how to answer this question, answer N.
 
+config KAISER
+	bool "Remove the kernel mapping in user mode"
+	depends on X86_64 && SMP && !PARAVIRT
+	help
+	  This feature reduces the number of hardware side channels by
+	  ensuring that the majority of kernel addresses are not mapped
+	  into userspace.
+
+	  See Documentation/x86/kaiser.txt for more details.
+
 config SECURITY_INFINIBAND
 	bool "Infiniband Security Hooks"
 	depends on SECURITY && INFINIBAND
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

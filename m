Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 98A076B007E
	for <linux-mm@kvack.org>; Tue, 31 May 2016 11:28:17 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id di3so210209798pab.0
        for <linux-mm@kvack.org>; Tue, 31 May 2016 08:28:17 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id xt10si1960707pab.1.2016.05.31.08.28.16
        for <linux-mm@kvack.org>;
        Tue, 31 May 2016 08:28:16 -0700 (PDT)
Subject: [PATCH 1/8] x86, pkeys: add fault handling for PF_PK page fault bit
From: Dave Hansen <dave@sr71.net>
Date: Tue, 31 May 2016 08:28:16 -0700
References: <20160531152814.36E0B9EE@viggo.jf.intel.com>
In-Reply-To: <20160531152814.36E0B9EE@viggo.jf.intel.com>
Message-Id: <20160531152816.9C8F004A@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

PF_PK means that a memory access violated the protection key
access restrictions.  It is unconditionally an access_error()
because the permissions set on the VMA don't matter (the PKRU
value overrides it), and we never "resolve" PK faults (like
how a COW can "resolve write fault).

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/mm/fault.c |    9 +++++++++
 1 file changed, 9 insertions(+)

diff -puN arch/x86/mm/fault.c~pkeys-105-add-pk-to-fault arch/x86/mm/fault.c
--- a/arch/x86/mm/fault.c~pkeys-105-add-pk-to-fault	2016-05-31 08:27:47.161025766 -0700
+++ b/arch/x86/mm/fault.c	2016-05-31 08:27:47.166025992 -0700
@@ -1107,6 +1107,15 @@ access_error(unsigned long error_code, s
 {
 	/* This is only called for the current mm, so: */
 	bool foreign = false;
+
+	/*
+	 * Read or write was blocked by protection keys.  This is
+	 * always an unconditional error and can never result in
+	 * a follow-up action to resolve the fault, like a COW.
+	 */
+	if (error_code & PF_PK)
+		return 1;
+
 	/*
 	 * Make sure to check the VMA so that we do not perform
 	 * faults just to hit a PF_PK as soon as we fill in a
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

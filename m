Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2D8F16B0253
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 16:47:18 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id u203so179050341itc.0
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 13:47:18 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id q27si36648992pfj.25.2016.06.07.13.47.17
        for <linux-mm@kvack.org>;
        Tue, 07 Jun 2016 13:47:17 -0700 (PDT)
Subject: [PATCH 1/9] x86, pkeys: add fault handling for PF_PK page fault bit
From: Dave Hansen <dave@sr71.net>
Date: Tue, 07 Jun 2016 13:47:14 -0700
References: <20160607204712.594DE00A@viggo.jf.intel.com>
In-Reply-To: <20160607204712.594DE00A@viggo.jf.intel.com>
Message-Id: <20160607204714.DBBB24D2@viggo.jf.intel.com>
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
--- a/arch/x86/mm/fault.c~pkeys-105-add-pk-to-fault	2016-06-07 13:22:18.529937509 -0700
+++ b/arch/x86/mm/fault.c	2016-06-07 13:22:18.534937739 -0700
@@ -1112,6 +1112,15 @@ access_error(unsigned long error_code, s
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

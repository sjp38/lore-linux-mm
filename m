Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2EC046B0266
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 18:24:18 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id d185so502712819pgc.2
        for <linux-mm@kvack.org>; Wed, 01 Feb 2017 15:24:18 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id g21si15701007pgj.268.2017.02.01.15.24.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Feb 2017 15:24:17 -0800 (PST)
Subject: [RFC][PATCH 6/7] x86, mpx, selftests: Use prctl header instead of magic numbers
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Wed, 01 Feb 2017 15:24:16 -0800
References: <20170201232408.FA486473@viggo.jf.intel.com>
In-Reply-To: <20170201232408.FA486473@viggo.jf.intel.com>
Message-Id: <20170201232416.25090E28@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave.hansen@linux.intel.com>


I got away with just hard-coding the prctl() numbers in the MPX
selftests.  Include the kernel header so we can just use the
symbolic names.

---

 b/tools/testing/selftests/x86/mpx-mini-test.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff -puN tools/testing/selftests/x86/mpx-mini-test.c~mawa-068-selftests-inc tools/testing/selftests/x86/mpx-mini-test.c
--- a/tools/testing/selftests/x86/mpx-mini-test.c~mawa-068-selftests-inc	2017-02-01 15:12:18.083231385 -0800
+++ b/tools/testing/selftests/x86/mpx-mini-test.c	2017-02-01 15:12:18.087231565 -0800
@@ -40,6 +40,8 @@ int zap_all_every_this_many_mallocs = 10
 #include "mpx-debug.h"
 #include "mpx-mm.h"
 
+#include "../../../../include/uapi/linux/prctl.h"
+
 #ifndef __always_inline
 #define __always_inline inline __attribute__((always_inline)
 #endif
@@ -666,7 +668,7 @@ bool process_specific_init(void)
 	check_clear(dir, size);
 	enable_mpx(dir);
 	check_clear(dir, size);
-	if (prctl(43, 0, 0, 0, 0)) {
+	if (prctl(PR_MPX_ENABLE_MANAGEMENT, 0, 0, 0, 0)) {
 		printf("no MPX support\n");
 		abort();
 		return false;
@@ -676,7 +678,7 @@ bool process_specific_init(void)
 
 bool process_specific_finish(void)
 {
-	if (prctl(44)) {
+	if (prctl(PR_MPX_DISABLE_MANAGEMENT)) {
 		printf("no MPX support\n");
 		return false;
 	}
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

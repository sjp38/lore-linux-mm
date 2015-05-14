Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 186846B006E
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:10:34 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so91956688pac.0
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:10:33 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id g7si33381934pat.12.2015.05.14.10.10.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:10:33 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 02/11] mm: debug: deal with a new family of MM pointers
Date: Thu, 14 May 2015 13:10:05 -0400
Message-Id: <1431623414-1905-3-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
References: <1431623414-1905-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, kirill@shutemov.name, Sasha Levin <sasha.levin@oracle.com>

This teaches our printing functions about a new family of MM pointer that it
could now print.

I've picked %pZ because %pm and %pM were already taken, so I figured it
doesn't really matter what we go with. We also have the option of stealing
one of those two...

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 lib/vsprintf.c |   18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 8243e2f..9350904 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1375,6 +1375,21 @@ char *comm_name(char *buf, char *end, struct task_struct *tsk,
 	return string(buf, end, name, spec);
 }
 
+static noinline_for_stack
+char *mm_pointer(char *buf, char *end, struct task_struct *tsk,
+		struct printf_spec spec, const char *fmt)
+{
+	switch (fmt[1]) {
+	default:
+		spec.base = 16;
+		spec.field_width = sizeof(unsigned long) * 2 + 2;
+		spec.flags |= SPECIAL | SMALL | ZEROPAD;
+		return number(buf, end, (unsigned long) ptr, spec);
+	}
+
+	return buf;
+}
+
 int kptr_restrict __read_mostly;
 
 /*
@@ -1463,6 +1478,7 @@ int kptr_restrict __read_mostly;
  *        (legacy clock framework) of the clock
  * - 'Cr' For a clock, it prints the current rate of the clock
  * - 'T' task_struct->comm
+ * - 'Z' Outputs a readable version of a type of memory management struct.
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -1615,6 +1631,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 				   spec, fmt);
 	case 'T':
 		return comm_name(buf, end, ptr, spec, fmt);
+	case 'Z':
+		return mm_pointer(buf, end, ptr, spec, fmt);
 	}
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

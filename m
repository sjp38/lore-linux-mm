Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f45.google.com (mail-vn0-f45.google.com [209.85.216.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2BCE76B006C
	for <linux-mm@kvack.org>; Tue, 14 Apr 2015 16:56:42 -0400 (EDT)
Received: by vnbf1 with SMTP id f1so8221373vnb.0
        for <linux-mm@kvack.org>; Tue, 14 Apr 2015 13:56:42 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id q40si1183994yhg.81.2015.04.14.13.56.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 14 Apr 2015 13:56:40 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [RFC 02/11] mm: debug: deal with a new family of MM pointers
Date: Tue, 14 Apr 2015 16:56:24 -0400
Message-Id: <1429044993-1677-3-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
References: <1429044993-1677-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, kirill@shutemov.name, linux-mm@kvack.org

This teaches our printing functions about a new family of MM pointer that it
could now print.

I've picked %pZ because %pm and %pM were already taken, so I figured it
doesn't really matter what we go with. We also have the option of stealing
one of those two...

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 lib/vsprintf.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index 8243e2f..809d19d 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -1375,6 +1375,16 @@ char *comm_name(char *buf, char *end, struct task_struct *tsk,
 	return string(buf, end, name, spec);
 }
 
+static noinline_for_stack
+char *mm_pointer(char *buf, char *end, struct task_struct *tsk,
+		struct printf_spec spec, const char *fmt)
+{
+	switch (fmt[1]) {
+	}
+
+	return buf;
+}
+
 int kptr_restrict __read_mostly;
 
 /*
@@ -1463,6 +1473,7 @@ int kptr_restrict __read_mostly;
  *        (legacy clock framework) of the clock
  * - 'Cr' For a clock, it prints the current rate of the clock
  * - 'T' task_struct->comm
+ * - 'Z' Outputs a readable version of a type of memory management struct.
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -1615,6 +1626,8 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
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

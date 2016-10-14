Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3296B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 03:13:26 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id p53so72926722qtp.1
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 00:13:26 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id u24si8890073qtc.60.2016.10.14.00.13.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Oct 2016 00:13:25 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [PATCH 1/1] mm/percpu.c: append alignment sanity checkup to avoid
 memory leakage
Message-ID: <58008576.3060302@zoho.com>
Date: Fri, 14 Oct 2016 15:12:54 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, zijun_hu@htc.com, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

the percpu allocator only works well currently when allocates a power of
2 aligned area, but there aren't any hints for alignment requirement, so
memory leakage maybe be caused if allocate other alignment areas

the alignment must be a even at least since the LSB of a chunk->map element
is used as free/in-use flag of a area; besides, the alignment must be a
power of 2 too since ALIGN() doesn't work well for other alignment always
but is adopted by pcpu_fit_in_area(). IOW, the current allocator only works
well for a power of 2 aligned area allocation.

see below opposite example for why a odd alignment doesn't work
lets assume area [16, 36) is free but its previous one is in-use, we want
to allocate a @size == 8 and @align == 7 area. the larger area [16, 36) is
split to three areas [16, 21), [21, 29), [29, 36) eventually. however, due
to the usage for a chunk->map element, the actual offset of the aim area
[21, 29) is 21 but is recorded in relevant element as 20; moreover the
residual tail free area [29, 36) is mistook as in-use and is lost silently

unlike macro roundup(), ALIGN(x, a) doesn't work if @a isn't a power of 2
for example, roundup(10, 6) == 12 but ALIGN(10, 6) == 10, and the latter
result isn't desired obviously.

fix it by appending sanity checkup for alignment requirement

Signed-off-by: zijun_hu <zijun_hu@htc.com>
Suggested-by: Tejun Heo <tj@kernel.org>
---
 include/linux/kernel.h | 1 +
 mm/percpu.c            | 3 ++-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index bc6ed52a39b9..0dc0b21bd164 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -45,6 +45,7 @@
 
 #define REPEAT_BYTE(x)	((~0ul / 0xff) * (x))
 
+/* @a is a power of 2 value */
 #define ALIGN(x, a)		__ALIGN_KERNEL((x), (a))
 #define __ALIGN_MASK(x, mask)	__ALIGN_KERNEL_MASK((x), (mask))
 #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
diff --git a/mm/percpu.c b/mm/percpu.c
index 255714302394..10ba3f9a3826 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -886,7 +886,8 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 	size = ALIGN(size, 2);
 
-	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
+	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE
+				|| !is_power_of_2(align))) {
 		WARN(true, "illegal size (%zu) or align (%zu) for percpu allocation\n",
 		     size, align);
 		return NULL;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

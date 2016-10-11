Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFD36B0038
	for <linux-mm@kvack.org>; Tue, 11 Oct 2016 09:25:00 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id y38so14774037qta.6
        for <linux-mm@kvack.org>; Tue, 11 Oct 2016 06:25:00 -0700 (PDT)
Received: from sender153-mail.zoho.com (sender153-mail.zoho.com. [74.201.84.153])
        by mx.google.com with ESMTPS id c12si1418787qkh.323.2016.10.11.06.24.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 11 Oct 2016 06:24:59 -0700 (PDT)
From: zijun_hu <zijun_hu@zoho.com>
Subject: [RFC PATCH 1/1] mm/percpu.c: fix memory leakage issue when allocate a
 odd alignment area
Message-ID: <bc3126cd-226d-91c7-d323-48881095accf@zoho.com>
Date: Tue, 11 Oct 2016 21:24:50 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, akpm@linux-foundation.org
Cc: zijun_hu@htc.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com

From: zijun_hu <zijun_hu@htc.com>

the LSB of a chunk->map element is used for free/in-use flag of a area
and the other bits for offset, the sufficient and necessary condition of
this usage is that both size and alignment of a area must be even numbers
however, pcpu_alloc() doesn't force its @align parameter a even number
explicitly, so a odd @align maybe causes a series of errors, see below
example for concrete descriptions.

lets assume area [16, 36) is free but its previous one is in-use, we want
to allocate a @size == 8 and @align == 7 area. the larger area [16, 36) is
split to three areas [16, 21), [21, 29), [29, 36) eventually. however, due
to the usage for a chunk->map element, the actual offset of the aim area
[21, 29) is 21 but is recorded in relevant element as 20; moreover the
residual tail free area [29, 36) is mistook as in-use and is lost silently

as explained above, inaccurate either offset or free/in-use state of
a area is recorded into relevant chunk->map element if request a odd
alignment area, and so causes memory leakage issue

fix it by forcing the @align of a area to allocate a even number
as do for @size.

BTW, macro ALIGN() within pcpu_fit_in_area() is replaced by roundup() too
due to back reason. in order to align a value @v up to @a boundary, macro
roundup(v, a) is more generic than ALIGN(x, a); the latter doesn't work
well when @a isn't a power of 2 value. for example, roundup(10, 6) == 12
but ALIGN(10, 6) == 10, the former result is desired obviously

Signed-off-by: zijun_hu <zijun_hu@htc.com>
---
 include/linux/kernel.h | 1 +
 mm/percpu.c            | 6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index 74fd6f05bc5b..ddf46638ef21 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -45,6 +45,7 @@
 
 #define REPEAT_BYTE(x)	((~0ul / 0xff) * (x))
 
+/* @a is a power of 2 value */
 #define ALIGN(x, a)		__ALIGN_KERNEL((x), (a))
 #define __ALIGN_MASK(x, mask)	__ALIGN_KERNEL_MASK((x), (mask))
 #define PTR_ALIGN(p, a)		((typeof(p))ALIGN((unsigned long)(p), (a)))
diff --git a/mm/percpu.c b/mm/percpu.c
index c2f0d9734d8c..26d1c73bd9e2 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -502,7 +502,7 @@ static int pcpu_fit_in_area(struct pcpu_chunk *chunk, int off, int this_size,
 	int cand_off = off;
 
 	while (true) {
-		int head = ALIGN(cand_off, align) - off;
+		int head = roundup(cand_off, align) - off;
 		int page_start, page_end, rs, re;
 
 		if (this_size < head + size)
@@ -879,11 +879,13 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 	/*
 	 * We want the lowest bit of offset available for in-use/free
-	 * indicator, so force >= 16bit alignment and make size even.
+	 * indicator, so force alignment >= 2 even and make size even.
 	 */
 	if (unlikely(align < 2))
 		align = 2;
 
+	if (WARN_ON_ONCE(!IS_ALIGNED(align, 2)))
+		align = ALIGN(align, 2);
 	size = ALIGN(size, 2);
 
 	if (unlikely(!size || size > PCPU_MIN_UNIT_SIZE || align > PAGE_SIZE)) {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

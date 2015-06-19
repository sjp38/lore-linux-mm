Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f180.google.com (mail-qc0-f180.google.com [209.85.216.180])
	by kanga.kvack.org (Postfix) with ESMTP id 1B0146B0093
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:58:56 -0400 (EDT)
Received: by qcmc1 with SMTP id c1so3508994qcm.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:58:55 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTP id 189si11078464qhr.113.2015.06.19.07.58.53
        for <linux-mm@kvack.org>;
        Fri, 19 Jun 2015 07:58:53 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 2/3] memtest: cleanup log messages
Date: Fri, 19 Jun 2015 15:58:33 +0100
Message-Id: <1434725914-14300-3-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

- prefer pr_info(...  to printk(KERN_INFO ...
- use %pa for phys_addr_t
- use cpu_to_be64 while printing pattern in reserve_bad_mem()

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 mm/memtest.c |   14 +++++---------
 1 file changed, 5 insertions(+), 9 deletions(-)

diff --git a/mm/memtest.c b/mm/memtest.c
index 895a43c..ccaed3e 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -31,10 +31,8 @@ static u64 patterns[] __initdata =3D {
=20
 static void __init reserve_bad_mem(u64 pattern, phys_addr_t start_bad, phy=
s_addr_t end_bad)
 {
-=09printk(KERN_INFO "  %016llx bad mem addr %010llx - %010llx reserved\n",
-=09       (unsigned long long) pattern,
-=09       (unsigned long long) start_bad,
-=09       (unsigned long long) end_bad);
+=09pr_info("%016llx bad mem addr %pa - %pa reserved\n",
+=09=09cpu_to_be64(pattern), &start_bad, &end_bad);
 =09memblock_reserve(start_bad, end_bad - start_bad);
 }
=20
@@ -78,10 +76,8 @@ static void __init do_one_pass(u64 pattern, phys_addr_t =
start, phys_addr_t end)
 =09=09this_start =3D clamp(this_start, start, end);
 =09=09this_end =3D clamp(this_end, start, end);
 =09=09if (this_start < this_end) {
-=09=09=09printk(KERN_INFO "  %010llx - %010llx pattern %016llx\n",
-=09=09=09       (unsigned long long)this_start,
-=09=09=09       (unsigned long long)this_end,
-=09=09=09       (unsigned long long)cpu_to_be64(pattern));
+=09=09=09pr_info("  %pa - %pa pattern %016llx\n",
+=09=09=09=09&this_start, &this_end, cpu_to_be64(pattern));
 =09=09=09memtest(pattern, this_start, this_end - this_start);
 =09=09}
 =09}
@@ -114,7 +110,7 @@ void __init early_memtest(phys_addr_t start, phys_addr_=
t end)
 =09if (!memtest_pattern)
 =09=09return;
=20
-=09printk(KERN_INFO "early_memtest: # of tests: %d\n", memtest_pattern);
+=09pr_info("early_memtest: # of tests: %u\n", memtest_pattern);
 =09for (i =3D memtest_pattern-1; i < UINT_MAX; --i) {
 =09=09idx =3D i % ARRAY_SIZE(patterns);
 =09=09do_one_pass(patterns[idx], start, end);
--=20
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

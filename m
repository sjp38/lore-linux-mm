Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f175.google.com (mail-qc0-f175.google.com [209.85.216.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2B8926B0092
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 10:58:54 -0400 (EDT)
Received: by qcwx2 with SMTP id x2so34131088qcw.1
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:58:54 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [207.82.80.143])
        by mx.google.com with ESMTP id 70si11079700qhc.111.2015.06.19.07.58.52
        for <linux-mm@kvack.org>;
        Fri, 19 Jun 2015 07:58:53 -0700 (PDT)
From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: [PATCH 1/3] memtest: use kstrtouint instead of simple_strtoul
Date: Fri, 19 Jun 2015 15:58:32 +0100
Message-Id: <1434725914-14300-2-git-send-email-vladimir.murzin@arm.com>
In-Reply-To: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
References: <1434725914-14300-1-git-send-email-vladimir.murzin@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org

Since simple_strtoul is obsolete and memtest_pattern is type of int, use
kstrtouint instead.

Signed-off-by: Vladimir Murzin <vladimir.murzin@arm.com>
---
 mm/memtest.c |   14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/mm/memtest.c b/mm/memtest.c
index 1997d93..895a43c 100644
--- a/mm/memtest.c
+++ b/mm/memtest.c
@@ -88,14 +88,18 @@ static void __init do_one_pass(u64 pattern, phys_addr_t=
 start, phys_addr_t end)
 }
=20
 /* default is disabled */
-static int memtest_pattern __initdata;
+static unsigned int memtest_pattern __initdata;
=20
 static int __init parse_memtest(char *arg)
 {
-=09if (arg)
-=09=09memtest_pattern =3D simple_strtoul(arg, NULL, 0);
-=09else
-=09=09memtest_pattern =3D ARRAY_SIZE(patterns);
+=09if (arg) {
+=09=09int err =3D kstrtouint(arg, 0, &memtest_pattern);
+
+=09=09if (!err)
+=09=09=09return 0;
+=09}
+
+=09memtest_pattern =3D ARRAY_SIZE(patterns);
=20
 =09return 0;
 }
--=20
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

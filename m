Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id B21C46B0036
	for <linux-mm@kvack.org>; Tue, 27 May 2014 22:24:54 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id uo5so10369157pbc.28
        for <linux-mm@kvack.org>; Tue, 27 May 2014 19:24:54 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id fn1si21233413pbb.74.2014.05.27.19.24.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 19:24:53 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 28 May 2014 10:24:44 +0800
Subject: MIGRATE_RESERVE  pages in show_mem function problems
Message-ID: <35FD53F367049845BC99AC72306C23D1029A27656A08@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'akpm@linux-foundation.org'" <akpm@linux-foundation.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'cody@linux.vnet.ibm.com'" <cody@linux.vnet.ibm.com>, "'linux-arch-owner@vger.kernel.org'" <linux-arch-owner@vger.kernel.org>, 'Will Deacon' <will.deacon@arm.com>, "'hannes@cmpxchg.org'" <hannes@cmpxchg.org>

Hi =20

I find the show_mem function show page MIGRATE types result is not correct =
for
MIGRATE_RESERVE pages :

Normal: 1582*4kB (UEMC) 1317*8kB (UEMC) 1020*16kB (UEMC) 450*32kB (UEMC) 20=
6*64kB (UEMC) 40*128kB (UM) 10*256kB (UM) 10*512kB (UM) 1*1024kB (M) 0*2048=
kB 0*4096kB =3D 74592kB

Some pages should be marked (R)  , while it is changed into MIGRATE_MOVEABL=
E or UNMOVEABLE in free_area list ,
It's not correct for debug .
I make a patch for this:

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5dba293..6ef8ebe 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1198,7 +1198,8 @@ static int rmqueue_bulk(struct zone *zone, unsigned i=
nt order,
                        list_add_tail(&page->lru, list);
                if (IS_ENABLED(CONFIG_CMA)) {
                        mt =3D get_pageblock_migratetype(page);
-                       if (!is_migrate_cma(mt) && !is_migrate_isolate(mt))
+                       if (!is_migrate_cma(mt) && !is_migrate_isolate(mt)
+                               && mt !=3D MIGRATE_RESERVE)
                                mt =3D migratetype;
                }
                set_freepage_migratetype(page, mt);


seems work ok , I am curious is it a BUG ? or designed like this for some r=
eason ?

Thanks=20


<6>[  250.751554] lowmem_reserve[]: 0 0 0
<6>[  250.751606] Normal: 1582*4kB (UEMC) 1317*8kB (UEMC) 1020*16kB (UEMC) =
450*32kB (UEMC) 206*64kB (UEMC) 40*128kB (UM) 10*256kB (UM) 10*512kB (UM) 1=
*1024kB (M) 0*2048kB 0*4096kB =3D 74592kB
<6>[  250.751848] HighMem: 167*4kB (UC) 3*8kB (U) 0*16kB 0*32kB 0*64kB 0*12=
8kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB =3D 692kB
<6>[  250.752020] 62596 total pagecache pages
<6>[  250.752046] 0 pages in swap cache
<6>[  250.752074] Swap cache stats: add 0, delete 0, find 0/0




Sony Mobile Communications
Tel: My Number +18610323092
yalin.wang@sonymobile.com =A0
sonymobile.com



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

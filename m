Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f48.google.com (mail-oi0-f48.google.com [209.85.218.48])
	by kanga.kvack.org (Postfix) with ESMTP id 8AA636B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 05:15:41 -0500 (EST)
Received: by oige206 with SMTP id e206so44906409oig.2
        for <linux-mm@kvack.org>; Thu, 03 Dec 2015 02:15:41 -0800 (PST)
Received: from SHSQR01.spreadtrum.com ([222.66.158.135])
        by mx.google.com with ESMTPS id xj7si6994590oeb.42.2015.12.03.02.15.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 03 Dec 2015 02:15:40 -0800 (PST)
From: "Pradeep Goswami (Pradeep Kumar Goswami)"
	<Pradeep.Goswami@spreadtrum.com>
Subject: [PATCH]mm:Correctly update number of rotated pages on active list.
Date: Thu, 3 Dec 2015 10:08:11 +0000
Message-ID: <20151203100809.GA4544@pradeepkumarubtnb.spreadtrum.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1A08A7FF1A72D9408337106A224C0CDE@spreadtrum.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "rebecca@android.com" <rebecca@android.com>, "vdavydov@parallels.com" <vdavydov@parallels.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "vbabka@suse.cz" <vbabka@suse.cz>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "sanjeev.yadav@spreatrum.com" <sanjeev.yadav@spreatrum.com>

This patch corrects the number of pages which are rotated on active list.
The counter for rotated pages effects the number of pages
to be scanned on active pages list in  low memory situations.

Signed-off-by: Pradeep Goswami <pradeep.goswami@spredtrum.com>
Cc: Rebecca Schultz Zavin <rebecca@android.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
--- a/mm/vmscan.c       2015-11-18 20:55:38.208838142 +0800
+++ b/mm/vmscan.c       2015-11-19 14:37:31.189838998 +0800
@@ -1806,7 +1806,6 @@ static void shrink_active_list(unsigned
=20
                if (page_referenced(page, 0, sc->target_mem_cgroup,
                                    &vm_flags)) {
-                       nr_rotated +=3D hpage_nr_pages(page);
                        /* =20
                         * Identify referenced, file-backed active pages an=
d=20
                         * give them one more trip around the active list. =
So
@@ -1818,6 +1817,7 @@ static void shrink_active_list(unsigned
                         */ =20
                        if ((vm_flags & VM_EXEC) && page_is_file_cache(page=
)) {
                                list_add(&page->lru, &l_active);
+                               nr_rotated +=3D hpage_nr_pages(page);
                                continue;
                        }  =20
                }  =20

Thanks,
Pradeep.=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 65D976B0071
	for <linux-mm@kvack.org>; Tue,  2 Dec 2014 04:27:50 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so13085340pab.20
        for <linux-mm@kvack.org>; Tue, 02 Dec 2014 01:27:50 -0800 (PST)
Received: from cnbjrel01.sonyericsson.com (cnbjrel01.sonyericsson.com. [219.141.167.165])
        by mx.google.com with ESMTPS id pg9si32751761pdb.83.2014.12.02.01.27.47
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 02 Dec 2014 01:27:49 -0800 (PST)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Tue, 2 Dec 2014 17:27:36 +0800
Subject: [RFC V2] mm:add zero_page _mapcount when mapped into user space
Message-ID: <35FD53F367049845BC99AC72306C23D103E688B313E0@CNBJMBX05.corpusers.net>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "'linux-kernel@vger.kernel.org'" <linux-kernel@vger.kernel.org>, "'linux-mm@kvack.org'" <linux-mm@kvack.org>, "'linux-arm-kernel@lists.infradead.org'" <linux-arm-kernel@lists.infradead.org>

This patch add/dec zero_page's _mapcount to make sure
the mapcount is correct for zero_page,
so that when read from /proc/kpagecount, zero_page's
mapcount is also correct, userspace process like procrank can
calculate PSS correctly.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 mm/memory.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/memory.c b/mm/memory.c
index 3e50383..7215423 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2198,6 +2198,7 @@ gotten:
 		new_page =3D alloc_zeroed_user_highpage_movable(vma, address);
 		if (!new_page)
 			goto oom;
+		atomic_dec(&pfn_to_page(pte_pfn(orig_pte))->_mapcount);
 	} else {
 		new_page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 		if (!new_page)
@@ -2647,6 +2648,7 @@ static int do_anonymous_page(struct mm_struct *mm, st=
ruct vm_area_struct *vma,
 		page_table =3D pte_offset_map_lock(mm, pmd, address, &ptl);
 		if (!pte_none(*page_table))
 			goto unlock;
+		atomic_inc(&pfn_to_page(my_zero_pfn(address))->_mapcount);
 		goto setpte;
 	}
=20
--=20
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 544636B0038
	for <linux-mm@kvack.org>; Tue, 15 Sep 2015 20:25:23 -0400 (EDT)
Received: by padhk3 with SMTP id hk3so190679473pad.3
        for <linux-mm@kvack.org>; Tue, 15 Sep 2015 17:25:23 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp (TYO201.gate.nec.co.jp. [210.143.35.51])
        by mx.google.com with ESMTPS id ta10si35862900pab.211.2015.09.15.17.25.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 15 Sep 2015 17:25:22 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v1] mm: migrate: hugetlb: putback destination hugepage to
 active list
Date: Wed, 16 Sep 2015 00:21:04 +0000
Message-ID: <1442362850-23261-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
In-Reply-To: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Since commit bcc54222309c ("mm: hugetlb: introduce page_huge_active")
each hugetlb page maintains its active flag to avoid a race condition betwe=
en
multiple calls of isolate_huge_page(), but current kernel doesn't set the f=
lag
on a hugepage allocated by migration because the proper putback routine isn=
't
called. This means that users could still encounter the race referred to by
bcc54222309c in this special case, so this patch fixes it.

Fixes: bcc54222309c ("mm: hugetlb: introduce page_huge_active")
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: <stable@vger.kernel.org>  #4.1
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git v4.3-rc1/mm/migrate.c v4.3-rc1_patched/mm/migrate.c
index c3cb566af3e2..7452a00bbb50 100644
--- v4.3-rc1/mm/migrate.c
+++ v4.3-rc1_patched/mm/migrate.c
@@ -1075,7 +1075,7 @@ static int unmap_and_move_huge_page(new_page_t get_ne=
w_page,
 	if (rc !=3D MIGRATEPAGE_SUCCESS && put_new_page)
 		put_new_page(new_hpage, private);
 	else
-		put_page(new_hpage);
+		putback_active_hugepage(new_hpage);
=20
 	if (result) {
 		if (rc)
--=20
2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

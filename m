Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 261276B0032
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 05:03:05 -0400 (EDT)
Received: by pdrw1 with SMTP id w1so6104020pdr.0
        for <linux-mm@kvack.org>; Tue, 31 Mar 2015 02:03:04 -0700 (PDT)
Received: from tyo200.gate.nec.co.jp (TYO200.gate.nec.co.jp. [210.143.35.50])
        by mx.google.com with ESMTPS id v3si18544354pde.194.2015.03.31.02.03.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 31 Mar 2015 02:03:04 -0700 (PDT)
Received: from tyo201.gate.nec.co.jp ([10.7.69.201])
	by tyo200.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id t2V930Vg016992
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 31 Mar 2015 18:03:01 +0900 (JST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH v3 1/3] mm: don't call __page_cache_release for hugetlb
Date: Tue, 31 Mar 2015 08:50:45 +0000
Message-ID: <1427791840-11247-2-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1427791840-11247-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

__put_compound_page() calls __page_cache_release() to do some freeing works=
,
but it's obviously for thps, not for hugetlb. We didn't care it because Pag=
eLRU
is always cleared and page->mem_cgroup is always NULL for hugetlb.
But it's not correct and has potential risks, so let's make it conditional.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/swap.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git v4.0-rc6.orig/mm/swap.c v4.0-rc6/mm/swap.c
index cd3a5e64cea9..8e46823c3319 100644
--- v4.0-rc6.orig/mm/swap.c
+++ v4.0-rc6/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
 #include <linux/uio.h>
+#include <linux/hugetlb.h>
=20
 #include "internal.h"
=20
@@ -75,7 +76,14 @@ static void __put_compound_page(struct page *page)
 {
 	compound_page_dtor *dtor;
=20
-	__page_cache_release(page);
+	/*
+	 * __page_cache_release() is supposed to be called for thp, not for
+	 * hugetlb. This is because hugetlb page does never have PageLRU set
+	 * (it's never listed to any LRU lists) and no memcg routines should
+	 * be called for hugetlb (it has a separate hugetlb_cgroup.)
+	 */
+	if (!PageHuge(page))
+		__page_cache_release(page);
 	dtor =3D get_compound_page_dtor(page);
 	(*dtor)(page);
 }
--=20
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

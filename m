Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id A350190002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 06:00:16 -0400 (EDT)
Received: by pdbfp1 with SMTP id fp1so9982840pdb.7
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 03:00:16 -0700 (PDT)
Received: from cnbjrel02.sonyericsson.com (cnbjrel02.sonyericsson.com. [219.141.167.166])
        by mx.google.com with ESMTPS id ok14si421848pdb.2.2015.03.11.03.00.11
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Mar 2015 03:00:13 -0700 (PDT)
From: "Wang, Yalin" <Yalin.Wang@sonymobile.com>
Date: Wed, 11 Mar 2015 17:47:28 +0800
Subject: [RFC] mm:do recheck for freeable page in reclaim path
Message-ID: <35FD53F367049845BC99AC72306C23D10458D6173C0C@CNBJMBX05.corpusers.net>
References: <1426036838-18154-1-git-send-email-minchan@kernel.org>
 <1426036838-18154-3-git-send-email-minchan@kernel.org>
In-Reply-To: <1426036838-18154-3-git-send-email-minchan@kernel.org>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Shaohua Li <shli@kernel.org>

In reclaim path, if encounter a freeable page,
the try_to_unmap may fail, because the page's pte is
dirty, we can recheck this page as normal non-freeable page,
this means we can swap out this page into swap partition.

Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
---
 mm/vmscan.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 260c413..9930850 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1000,6 +1000,7 @@ static unsigned long shrink_page_list(struct list_hea=
d *page_list,
 			}
 		}
=20
+recheck:
 		if (!force_reclaim)
 			references =3D page_check_references(page, sc,
 							&freeable);
@@ -1045,6 +1046,10 @@ unmap:
 			switch (try_to_unmap(page,
 				freeable ? TTU_FREE : ttu_flags)) {
 			case SWAP_FAIL:
+				if (freeable) {
+					freeable =3D false;
+					goto recheck;
+				}
 				goto activate_locked;
 			case SWAP_AGAIN:
 				goto keep_locked;
--=20
2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 31FAE6B01F2
	for <linux-mm@kvack.org>; Wed, 18 Aug 2010 15:04:37 -0400 (EDT)
Subject: [PATCH] VM: kswapd should not do blocking memory allocations
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 18 Aug 2010 15:04:01 -0400
Message-ID: <1282158241.8540.85.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Allowing kswapd to do GFP_KERNEL memory allocations (or any blocking memory
allocations) is wrong and can cause deadlocks in try_to_release_page(), as
the filesystem believes it is safe to allocate new memory and block,
whereas kswapd is there specifically to clear a low-memory situation...

Set the gfp_mask to GFP_IOFS instead.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/mm/vmscan.c b/mm/vmscan.c
index ec5ddcc..716dd16 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2095,7 +2095,7 @@ static unsigned long balance_pgdat(pg_data_t *pgdat, =
int order)
 	unsigned long total_scanned;
 	struct reclaim_state *reclaim_state =3D current->reclaim_state;
 	struct scan_control sc =3D {
-		.gfp_mask =3D GFP_KERNEL,
+		.gfp_mask =3D GFP_IOFS,
 		.may_unmap =3D 1,
 		.may_swap =3D 1,
 		/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

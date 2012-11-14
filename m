Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 8279B6B0070
	for <linux-mm@kvack.org>; Tue, 13 Nov 2012 20:36:39 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id 47so301967yhr.14
        for <linux-mm@kvack.org>; Tue, 13 Nov 2012 17:36:38 -0800 (PST)
Date: Tue, 13 Nov 2012 17:36:33 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix shmem_getpage_gfp VM_BUG_ON fix
In-Reply-To: <20121107223830.GA12561@redhat.com>
Message-ID: <alpine.LNX.2.00.1211131733530.29535@eggly.anvils>
References: <alpine.LNX.2.00.1210242121410.1697@eggly.anvils> <20121101191052.GA5884@redhat.com> <alpine.LNX.2.00.1211011546090.19377@eggly.anvils> <20121101232030.GA25519@redhat.com> <alpine.LNX.2.00.1211011627120.19567@eggly.anvils> <20121102014336.GA1727@redhat.com>
 <alpine.LNX.2.00.1211021606580.11106@eggly.anvils> <alpine.LNX.2.00.1211051729590.963@eggly.anvils> <20121106135402.GA3543@redhat.com> <alpine.LNX.2.00.1211061521230.6954@eggly.anvils> <20121107223830.GA12561@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

We're still hoping to hear back from Dave Jones: but either way,
please fold this patch into the earlier fix for 3.7 and -stable.

Remove its VM_BUG_ON: because either it's as I believe, a tautology
which cannot happen, and does not assert what I'd intended when I put
it in, and would even be wrong if it did (a non-NULL entry can validly
materialize there); or Dave actually hit it on his updated kernel,
in which case more research will be needed, but for upstream we
do not want a user to BUG there.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

--- mmotm/mm/shmem.c	2012-11-09 09:43:46.908046342 -0800
+++ linux/mm/shmem.c	2012-11-13 17:16:38.532528959 -0800
@@ -1158,10 +1158,8 @@ repeat:
 			 * Reset swap.val? No, leave it so "failed" goes back to
 			 * "repeat": reading a hole and writing should succeed.
 			 */
-			if (error) {
-				VM_BUG_ON(error != -ENOENT);
+			if (error)
 				delete_from_swap_cache(page);
-			}
 		}
 		if (error)
 			goto failed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

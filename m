Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 6B2946B005A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 21:55:52 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so14907pad.14
        for <linux-mm@kvack.org>; Tue, 23 Oct 2012 18:55:51 -0700 (PDT)
Date: Tue, 23 Oct 2012 18:55:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch for-3.7] mm, numa: avoid setting zone_reclaim_mode unless a
 node is sufficiently distant
In-Reply-To: <CAJL_dMtS-rc1b3s9YZ+9Eapc21vF06aCT23GV8eMp13ZxURvBA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1210231853360.11290@chino.kir.corp.google.com>
References: <CAGPN=9Qx1JAr6CGO-JfoR2ksTJG_CLLZY_oBA_TFMzA_OSfiFg@mail.gmail.com> <20121022173315.7b0da762@ilfaris> <20121022214502.0fde3adc@ilfaris> <20121022170452.cc8cc629.akpm@linux-foundation.org> <alpine.LNX.2.00.1210222059120.1136@eggly.anvils>
 <20121023110434.021d100b@ilfaris> <CAJL_dMvUktOx9BqFm5jn2JbWbL_RWH412rdU+=rtDUvkuaPRUw@mail.gmail.com> <alpine.DEB.2.00.1210231541350.1221@chino.kir.corp.google.com> <CAJL_dMtS-rc1b3s9YZ+9Eapc21vF06aCT23GV8eMp13ZxURvBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Julian Wollrath <jwollrath@web.de>, Hugh Dickins <hughd@google.com>, Patrik Kullman <patrik.kullman@gmail.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

Commit 957f822a0ab9 ("mm, numa: reclaim from all nodes within reclaim
distance") caused zone_reclaim_mode to be set for all systems where two
nodes are within RECLAIM_DISTANCE of each other.  This is the opposite of
what we actually want: zone_reclaim_mode should be set if two nodes are
sufficiently distant.

Reported-by: Julian Wollrath <jwollrath@web.de>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/page_alloc.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1809,10 +1809,10 @@ static void __paginginit init_zone_allows_reclaim(int nid)
 	int i;
 
 	for_each_online_node(i)
-		if (node_distance(nid, i) <= RECLAIM_DISTANCE) {
+		if (node_distance(nid, i) <= RECLAIM_DISTANCE)
 			node_set(i, NODE_DATA(nid)->reclaim_nodes);
+		else
 			zone_reclaim_mode = 1;
-		}
 }
 
 #else	/* CONFIG_NUMA */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

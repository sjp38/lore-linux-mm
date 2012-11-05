Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id 63C906B0044
	for <linux-mm@kvack.org>; Mon,  5 Nov 2012 15:13:13 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so4559992pbb.14
        for <linux-mm@kvack.org>; Mon, 05 Nov 2012 12:13:12 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 6 Nov 2012 01:43:12 +0530
Message-ID: <CAEtiSasbEXUeFwCNO09nT8TsEzLF-zZVyJ_pCO9V49hDPbpbAQ@mail.gmail.com>
Subject: [PATCH] mm: bugfix: set current->reclaim_state to NULL while
 returning from kswapd()
From: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Minchan Kim <minchan.kim@gmail.com>, takamori.yamaguchi@jp.sony.com, takuzo.ohara@ap.sony.com, amit.agarwal@ap.sony.com, tim.bird@am.sony.com, frank.rowand@am.sony.com, kan.iibuchi@jp.sony.com, aaditya.kumar@ap.sony.com

From: Takamori Yamaguchi <takamori.yamaguchi@jp.sony.com>

In kswapd(), set current->reclaim_state to NULL before returning, as
current->reclaim_state holds reference to variable on kswapd()'s stack.

In rare cases, while returning from kswapd() during memory off lining,
__free_slab() can access dangling pointer of current->reclaim_state.

Signed-off-by: Takamori Yamaguchi <takamori.yamaguchi@jp.sony.com>
Signed-off-by: Aaditya Kumar <aaditya.kumar@ap.sony.com>

---
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 2624edc..8b055e9 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3017,6 +3017,8 @@ static int kswapd(void *p)
 						&balanced_classzone_idx);
 		}
 	}
+
+	current->reclaim_state = NULL;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

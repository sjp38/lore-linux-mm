Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9D7AF6B01AF
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 02:33:51 -0400 (EDT)
Date: Wed, 2 Jun 2010 14:45:45 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][BUGFIX][PATCH 1/2] transhuge-memcg: fix for memcg compound
Message-Id: <20100602144545.1e865f15.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100602144438.dc04ece7.nishimura@mxp.nes.nec.co.jp>
References: <20100521000539.GA5733@random.random>
	<20100602144438.dc04ece7.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

We should increase/decrease css->refcnt properly in charging/uncharging compound pages.

Without this patch, a bug like below happens:

1. create a memcg directory.
2. run a program which uses enough memory to allocate them as transparent huge pages.
3. kill the program.
4. try to remove the directory, which will never finish.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b1ac9b1..b74bd83 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1650,8 +1650,9 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
 	}
 	if (csize > page_size)
 		refill_stock(mem, csize - page_size);
+	/* increase css->refcnt by the number of tail pages */
 	if (page_size != PAGE_SIZE)
-		__css_get(&mem->css, page_size);
+		__css_get(&mem->css, (page_size >> PAGE_SHIFT) - 1);
 done:
 	return 0;
 nomem:
@@ -2237,7 +2238,7 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
 	memcg_check_events(mem, page);
 	/* at swapout, this memcg will be accessed to record to swap */
 	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		css_put(&mem->css);
+		__css_put(&mem->css, page_size >> PAGE_SHIFT);
 
 	return mem;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E30388D0039
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 03:27:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 02AB43EE0AE
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:27:48 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DC9DA45DE4D
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:27:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B9E4F45DE58
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:27:47 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id A90DBE08001
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:27:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7015A1DB8038
	for <linux-mm@kvack.org>; Fri, 28 Jan 2011 17:27:47 +0900 (JST)
Date: Fri, 28 Jan 2011 17:21:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH 3/4] mecg: fix oom flag at THP charge
Message-Id: <20110128172146.940751a5.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110128080213.GC2213@cmpxchg.org>
References: <20110128122229.6a4c74a2.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128122729.1f1c613e.kamezawa.hiroyu@jp.fujitsu.com>
	<20110128080213.GC2213@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 28 Jan 2011 09:02:13 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Fri, Jan 28, 2011 at 12:27:29PM +0900, KAMEZAWA Hiroyuki wrote:
> > 
> > Thanks to Johanns and Daisuke for suggestion.
> > =
> > Hugepage allocation shouldn't trigger oom.
> > Allocation failure is not fatal.
> > 
> > Orignal-patch-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/memcontrol.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > Index: mmotm-0125/mm/memcontrol.c
> > ===================================================================
> > --- mmotm-0125.orig/mm/memcontrol.c
> > +++ mmotm-0125/mm/memcontrol.c
> > @@ -2369,11 +2369,14 @@ static int mem_cgroup_charge_common(stru
> >  	struct page_cgroup *pc;
> >  	int ret;
> >  	int page_size = PAGE_SIZE;
> > +	bool oom;
> >  
> >  	if (PageTransHuge(page)) {
> >  		page_size <<= compound_order(page);
> >  		VM_BUG_ON(!PageTransHuge(page));
> > -	}
> > +		oom = false;
> > +	} else
> > +		oom = true;
> 
> That needs a comment.  You can take the one from my patch if you like.
> 

How about this ?
==
Hugepage allocation shouldn't trigger oom.
Allocation failure is not fatal.

Changelog:
 - added comments.

Orignal-patch-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |   11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

Index: mmotm-0125/mm/memcontrol.c
===================================================================
--- mmotm-0125.orig/mm/memcontrol.c
+++ mmotm-0125/mm/memcontrol.c
@@ -2366,11 +2366,18 @@ static int mem_cgroup_charge_common(stru
 	struct page_cgroup *pc;
 	int ret;
 	int page_size = PAGE_SIZE;
+	bool oom;
 
 	if (PageTransHuge(page)) {
 		page_size <<= compound_order(page);
 		VM_BUG_ON(!PageTransHuge(page));
-	}
+		/*
+		 * Hugepage allocation will retry in small pages even if
+		 * this allocation fails.
+		 */
+		oom = false;
+	} else
+		oom = true;
 
 	pc = lookup_page_cgroup(page);
 	/* can happen at boot */
@@ -2378,7 +2385,7 @@ static int mem_cgroup_charge_common(stru
 		return 0;
 	prefetchw(pc);
 
-	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, true, page_size);
+	ret = __mem_cgroup_try_charge(mm, gfp_mask, &mem, oom, page_size);
 	if (ret || !mem)
 		return ret;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

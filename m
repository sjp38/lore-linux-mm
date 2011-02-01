Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0D06B8D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:35:05 -0500 (EST)
Date: Tue, 1 Feb 2011 01:34:51 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] memcg: prevent endless loop when charging huge pages
 to near-limit group
Message-ID: <20110201003451.GC19534@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
 <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
 <20110131144131.6733aa3a.akpm@linux-foundation.org>
 <20110201000455.GB19534@cmpxchg.org>
 <20110131162448.e791f0ae.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110131162448.e791f0ae.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 04:24:48PM -0800, Andrew Morton wrote:
> On Tue, 1 Feb 2011 01:04:55 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > @@ -182,6 +182,14 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
> >  	return ret;
> >  }
> >  
> > +/**
> > + * res_counter_check_margin - check if the counter allows charging
> > + * @cnt: the resource counter to check
> > + * @bytes: the number of bytes to check the remaining space against
> > + *
> > + * Returns a boolean value on whether the counter can be charged
> > + * @bytes or whether this would exceed the limit.
> > + */
> >  static inline bool res_counter_check_margin(struct res_counter *cnt,
> >  					    unsigned long bytes)
> >  {
> 
> mem_cgroup_check_margin() needs some lipstick too.

*oink*

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 9e5de7c..6c07554 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1111,6 +1111,14 @@ static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
 	return false;
 }
 
+/**
+ * mem_cgroup_check_margin - check if the memory cgroup allows charging
+ * @mem: memory cgroup to check
+ * @bytes: the number of bytes the caller intends to charge
+ *
+ * Returns a boolean value on whether @mem can be charged @bytes or
+ * whether this would exceed the limit.
+ */
 static bool mem_cgroup_check_margin(struct mem_cgroup *mem, unsigned long bytes)
 {
 	if (!res_counter_check_margin(&mem->res, bytes))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

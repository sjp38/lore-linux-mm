Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E2A848D0039
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 19:05:10 -0500 (EST)
Date: Tue, 1 Feb 2011 01:04:55 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 2/3] memcg: prevent endless loop when charging huge pages
 to near-limit group
Message-ID: <20110201000455.GB19534@cmpxchg.org>
References: <1296482635-13421-1-git-send-email-hannes@cmpxchg.org>
 <1296482635-13421-3-git-send-email-hannes@cmpxchg.org>
 <20110131144131.6733aa3a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110131144131.6733aa3a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, minchan.kim@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 31, 2011 at 02:41:31PM -0800, Andrew Morton wrote:
> On Mon, 31 Jan 2011 15:03:54 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > @@ -1111,6 +1111,15 @@ static bool mem_cgroup_check_under_limit(struct mem_cgroup *mem)
> >  	return false;
> >  }
> >  
> > +static bool mem_cgroup_check_margin(struct mem_cgroup *mem, unsigned long bytes)
> > +{
> > +	if (!res_counter_check_margin(&mem->res, bytes))
> > +		return false;
> > +	if (do_swap_account && !res_counter_check_margin(&mem->memsw, bytes))
> > +		return false;
> > +	return true;
> > +}
> 
> argh.
> 
> If you ever have a function with the string "check" in its name, it's a
> good sign that you did something wrong.
> 
> Check what?  Against what?  Returning what?
> 
> mem_cgroup_check_under_limit() isn't toooo bad - the name tells you
> what's being checked and tells you what to expect the return value to
> mean.
> 
> But "res_counter_check_margin" and "mem_cgroup_check_margin" are just
> awful.  Something like
> 
> 	bool res_counter_may_charge(counter, bytes)
> 
> would be much clearer.

That makes sense for the hard limit.  But the oh-so-generic resource
counters also have a soft limit, and you don't ask for that when you
want to charge.  Right now, I do not feel creative enough to come up
with a symmetric-sounding counterpart.

> If we really want to stick with the "check" names (perhaps as an ironic
> reference to res_counter's past mistakes) then please at least document
> the sorry things?

I cowardly went with this option and have a patch below to fold into
this fix.

Maybe it would be better to use res_counter_margin(cnt) >= wanted
throughout the code.  Or still better, make memcg work on pages and
res_counters on unsigned longs so the locking is no longer needed,
together with an API for most obvious maths.  I will work something
out and submit it separately.

---
Subject: [patch fixup] res_counter: document res_counter_check_margin()

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---

diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
index 5cfd78a..a5930cb 100644
--- a/include/linux/res_counter.h
+++ b/include/linux/res_counter.h
@@ -182,6 +182,14 @@ static inline bool res_counter_check_under_limit(struct res_counter *cnt)
 	return ret;
 }
 
+/**
+ * res_counter_check_margin - check if the counter allows charging
+ * @cnt: the resource counter to check
+ * @bytes: the number of bytes to check the remaining space against
+ *
+ * Returns a boolean value on whether the counter can be charged
+ * @bytes or whether this would exceed the limit.
+ */
 static inline bool res_counter_check_margin(struct res_counter *cnt,
 					    unsigned long bytes)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

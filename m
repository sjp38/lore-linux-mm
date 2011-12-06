Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 881CF6B004F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 19:59:36 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5CC333EE0BC
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 09:59:34 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 40F8745DE4D
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 09:59:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 29CBF45DD74
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 09:59:34 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DAAF1DB8038
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 09:59:34 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id CD14B1DB803C
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 09:59:33 +0900 (JST)
Date: Tue, 6 Dec 2011 09:58:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
Message-Id: <20111206095825.69426eb2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112051552210.3938@sister.anvils>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20111202120849.GA1295@cmpxchg.org>
	<20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112051552210.3938@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 5 Dec 2011 16:13:06 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Mon, 5 Dec 2011, KAMEZAWA Hiroyuki wrote:
> > On Fri, 2 Dec 2011 13:08:49 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > On Fri, Dec 02, 2011 at 07:06:22PM +0900, KAMEZAWA Hiroyuki wrote:

> > Hmm. IMHO, we have 2 easy ways.
> > 
> >  - Ignore PCG_USED bit at LRU handling.
> >    2 problems.
> >    1. memory.stat may show very wrong statistics if swapin is too often.
> >    2. need careful use of mem_cgroup_charge_lrucare().
> > 
> >  - Clear pc->mem_cgroup at swapin-readahead.
> >    A problem.
> >    1. we need a new hook.
> > 
> > I'll try to clear pc->mem_cgroup at swapin. 
> > 
> > Thank you for pointing out.
> 
> Ying and I found PageCgroupAcctLRU very hard to grasp, even despite
> the comments Hannes added to explain it.  

Now, I don't think it's difficult. It seems no file system codes
add pages to LRU before add_to_page_cache() (I checked.)
So, what we need to care is only swap-cache. In swap-cache path,
we can do slow work.

> In moving the LRU locking
> from zone to memcg, we needed to depend upon pc->mem_cgroup: that
> was difficult while the interpretation of pc->mem_cgroup depended
> upon two flags also; and very tricky when pages were liable to shift
> underneath you from one LRU to another, as flags came and went.
> So we already eliminated PageCgroupAcctLRU here.
> 

Okay, Hm, do you see performance improvement by moving locks ?


> I'm fairly happy with what we have now, and have ported it forward
> to 3.2.0-rc3-next-20111202: with a few improvements on top of what
> we've got internally - Hannes's remark above about "amortizing the
> winnings" in the page freeing hotpath has prompted me to improve
> on what we had there, needs more testing but seems good so far.
> 
> However, I've hardly begun splitting the changes up into a series:
> had intended to do so last week, but day followed day...  If you'd
> like to see the unpolished uncommented rollup, I can post that.
> 

please.
Anyway, I'll post my own again as output even if I stop my work there.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

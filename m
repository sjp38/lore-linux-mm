Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id E2B246B004F
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 05:22:12 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8A7923EE0AE
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:22:11 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6FAF645DE69
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:22:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 565A245DE55
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:22:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 464B11DB8041
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:22:11 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E9DE31DB803A
	for <linux-mm@kvack.org>; Tue,  6 Dec 2011 19:22:10 +0900 (JST)
Date: Tue, 6 Dec 2011 19:21:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg: remove PCG_ACCT_LRU.
Message-Id: <20111206192101.8ea75558.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1112052258510.28015@sister.anvils>
References: <20111202190622.8e0488d6.kamezawa.hiroyu@jp.fujitsu.com>
	<20111202120849.GA1295@cmpxchg.org>
	<20111205095009.b82a9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112051552210.3938@sister.anvils>
	<20111206095825.69426eb2.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1112052258510.28015@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org

On Mon, 5 Dec 2011 23:36:34 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Tue, 6 Dec 2011, KAMEZAWA Hiroyuki wrote:
> > On Mon, 5 Dec 2011 16:13:06 -0800 (PST)
> > Hugh Dickins <hughd@google.com> wrote:
> > > 
> > > Ying and I found PageCgroupAcctLRU very hard to grasp, even despite
> > > the comments Hannes added to explain it.  
> > 
> > Now, I don't think it's difficult. It seems no file system codes
> > add pages to LRU before add_to_page_cache() (I checked.)
> > So, what we need to care is only swap-cache. In swap-cache path,
> > we can do slow work.
> 
> I've been reluctant to add more special code for SwapCache:
> it may or may not be a good idea.  Hannes also noted a FUSE
> case which requires the before-commit-after handling swap was
> using (for memcg-zone lru locking we've merged them into commit).
> 

I think we need a fix for FUSE. In past, FUSE/splice used
add_to_page_cache() but not it uses replace_page_cache().
So, we need another care. (I posted a patch.)


> > 
> > > In moving the LRU locking
> > > from zone to memcg, we needed to depend upon pc->mem_cgroup: that
> > > was difficult while the interpretation of pc->mem_cgroup depended
> > > upon two flags also; and very tricky when pages were liable to shift
> > > underneath you from one LRU to another, as flags came and went.
> > > So we already eliminated PageCgroupAcctLRU here.
> > > 
> > 
> > Okay, Hm, do you see performance improvement by moving locks ?
> 
> I was expecting someone to ask that question!  I'm not up-to-date
> on it, it's one of the things I have to get help to gather before
> sending in the patch series.
> 
> I believe the answer is that we saw some improvement on some tests,
> but not so much as to make a hugely compelling case for the change.
> But by that time we'd invested a lot of testing in the memcg locking,
> and little in the original zone locking, so went with the memcg
> locking anyway.
> 
> We'll get more results and hope to show a stronger case for it now.
> But our results will probably have to be based on in-house kernels,
> with a lot of the "infrastructure" mods already in place, to allow
> an easy build-time switch between zone locking and memcg locking.
> 
> That won't be such a fair test if the "infrastructure" mods are
> themselves detrimental (I believe not).  It would be better to
> compare, say, 3.2.0-next against 3.2.0-next plus our patches -
> but my own (quad) machines for testing upstream kernels won't
> be big enough to show much of interest.  I'm rather hoping
> someone will be interested enough to try on something beefier.
> 

Hmm, at first glance at the patch, it seems far complicated than
I expected and added much checks and hooks to lru path...

> > > 
> > > However, I've hardly begun splitting the changes up into a series:
> > > had intended to do so last week, but day followed day...  If you'd
> > > like to see the unpolished uncommented rollup, I can post that.
> > > 
> > 
> > please.
> > Anyway, I'll post my own again as output even if I stop my work there.
> 
> Okay, here it is: my usual mix of cleanup and functional changes.
> There's work by Ying and others in here - will apportion authorship
> more fairly when splitting.  If you're looking through it at all,
> the place to start would be memcontrol.c's lock_page_lru_irqsave().
> 

Thank you. This seems inetersting patch. Hmm...what I think of now is..
In most case, pages are newly allocated and charged ,and then, added to LRU.
pc->mem_cgroup never changes while pages are on LRU.

I have a fix for corner cases as to do

	1. lock lru
	2. remove-page-from-lru
	3. overwrite pc->mem_cgroup
	4. add page to lru again
	5. unlock lru

And blindly believe pc->mem_cgroup regardless of PCG_USED bit at LRU handling.

Hm, per-zone-per-memcg lru locking is much easier if
 - we igonore PCG_USED bit at lru handling
 - we never overwrite pc->mem_cgroup if the page is on LRU.
 - if page may be added to LRU by pagevec etc.. while we overwrite
   pc->mem_cgroup, we always take lru_lock. This is our corner case.

isn't it ? I posted a series of patch. I'm glad if you give me a
quick review.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

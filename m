Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 20074600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 19:05:02 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB104x79014800
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 1 Dec 2009 09:04:59 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 819AD45DE50
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:04:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 527C645DE53
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:04:59 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 250D91DB8041
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:04:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id BE26D1DB8043
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 09:04:58 +0900 (JST)
Date: Tue, 1 Dec 2009 09:02:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 5/9] ksm: share anon page without allocating
Message-Id: <20091201090201.7acb3d90.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0911301054230.20054@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
	<Pine.LNX.4.64.0911241645460.25288@sister.anvils>
	<20091130090448.71cf6138.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0911301054230.20054@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Nov 2009 11:18:51 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Mon, 30 Nov 2009, KAMEZAWA Hiroyuki wrote:
> > 
> > Sorry for delayed response.
> 
> No, thank you very much for spending your time on it.
> 
> > 
> > On Tue, 24 Nov 2009 16:48:46 +0000 (GMT)
> > Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > 
> > > When ksm pages were unswappable, it made no sense to include them in
> > > mem cgroup accounting; but now that they are swappable (although I see
> > > no strict logical connection)
> > I asked that for throwing away too complicated but wast of time things.
> 
> I'm sorry, I didn't understand that sentence at all!
> 
Sorry. At implementation of ksm. I don't want to consinder how to account it
because there was problems around swap accounting. So, I asked to
limit usage by itself.

> > If not on LRU, its own limitation (ksm's page limit) works enough.
> 
> Yes, I think it made sense the way it was before when unswappable,
> but that once they're swappable and that limitation is removed,
> they do then need to participate in mem cgroup accounting.
> 
> I _think_ you're agreeing, but I'm not quite sure!
> 
I agree. No objections.


> > > @@ -864,15 +865,24 @@ static int try_to_merge_one_page(struct
> ...
> > >  
> > > -	if ((vma->vm_flags & VM_LOCKED) && !err) {
> > > +	if ((vma->vm_flags & VM_LOCKED) && kpage && !err) {
> > >  		munlock_vma_page(page);
> > >  		if (!PageMlocked(kpage)) {
> > >  			unlock_page(page);
> > > -			lru_add_drain();
> > 
> > Is this related to memcg ?
> > 
> > >  			lock_page(kpage);
> > >  			mlock_vma_page(kpage);
> 
> Is the removal of lru_add_drain() related to memcg?  No, or only to
> the extent that reusing the original anon page is related to memcg.
> 
> I put lru_add_drain() in there before, because (for one of the calls
> to try_to_merge_one_page) the kpage had just been allocated an instant
> before, with lru_cache_add_lru putting it into the per-cpu array, so
> in that case mlock_vma_page(kpage) would need an lru_add_drain() to
> find it on the LRU (of course, we might be preempted to a different
> cpu in between, and lru_add_drain not be enough: but I think we've
> all come to the conclusion that lru_add_drain_all should be avoided
> unless there's a very strong reason for it).
> 
> But with this patch we're reusing the existing anon page as ksm page,
> and we know that it's been in place for at least one circuit of ksmd
> (ignoring coincidences like the jhash of the page happens to be 0),
> so we've every reason to believe that it will already be on its LRU:
> no need for lru_add_drain().
> 

Thank you for clarification.

Regards,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

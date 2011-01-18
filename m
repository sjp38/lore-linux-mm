Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 95F188D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 04:23:59 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0DB6F3EE0BC
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:23:57 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E67F245DE5C
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:23:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3280B45DE59
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:23:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19BC7E08002
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:23:56 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CD431E78001
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:23:55 +0900 (JST)
Date: Tue, 18 Jan 2011 18:17:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-Id: <20110118181757.2aefcf87.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110118084013.GK2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
	<20110118101057.51d20ed7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110118084013.GK2212@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, 18 Jan 2011 09:40:13 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, Jan 18, 2011 at 10:10:57AM +0900, KAMEZAWA Hiroyuki wrote:
> > On Mon, 17 Jan 2011 20:14:00 +0100
> > Johannes Weiner <hannes@cmpxchg.org> wrote:

> > - pc->mem_cgroup can be replaced with ID.
> >   But move it into flags field seems difficult because of races.
> > - pc->page can be replaced with some lookup routine.
> >   But Section bit encoding may be something mysterious and look up cost
> >   will be problem.
> 
> Why is that?
> 
> The lookup is actually straight-forward, like lookup_page_cgroup().
> And we only need it when coming from the per-cgroup LRU, i.e. in
> reclaim and force_empty.
>  

I see usage of pc->page is not very frequent. But I wonder we should
revisit performance of lookup_page_cgroup() before adding new weight.


> > - PCG_CACHE bit is a duplicate of information of 'page'. So, we can use PageAnon()
> 
> I did that, too.  But for this to work, we need to make sure that
> pages are always rmapped when they are charged and uncharged.  This is
> one point where I collide with THP.  It's also why I complained that
> migration clears page->mapping of replaced anonymous pages :)
> 
> > - I'm not sure PCG_MIGRATION. It's for avoiding races.
> 
> That's also a scary patch...  Yeah, it's to prevent uncharging of
> oldpage in case migration fails and it has to be reused.  I changed
> the migration sequence for memcg a bit so that we don't have to do
> that anymore.  It survived basic testing.
> 

Hmm. I saw level down of migration under memcg several times. So, I don't
want to modify running one without enough reason.
I guess all SECTION_BITS can be encoded to pc->flags without diet of flags.


> > 
> > Another idea is dynamic allocation of page_cgroup. It may be able to be a help
> > for THP enviroment but will not work well (just adds overhead) against file cache
> > workload.
> > 
> > Anwyay, my priority of development for memcg this year is:
> > 
> >  1. dirty ratio support.
> >  2. Backgound reclaim (kswapd)
> >  3. blkio tracking.
> > 
> > Diet of page_cgroup should be done in step by step. We've seen many level down
> > when some new feature comes to memory cgroup.
> 
> Yes, and that's what I'm afraid of.  We would never be able to add a
> side-feature that makes struct page increase in arbitrary size.
> 
> If the feature is sufficiently important and there is no other way, it
> should of course be an option.  But it should not be done careless.
> 
> E.g. I have a suspicion that we might be able to do dirty accounting
> without all the flags (we have them in the page anyway!) but use
> proportionals instead.  It's not page-accurate, but I think the
> fundamental problem is solved: when the dirty ratio is exceeded,
> throttle the cgroup with the biggest dirty share.
> 
> But yes, that's sort of what I want to discuss :)
> 

Using proportionals is a choice. But, IIUC, users of memcg wants 
something like /proc/meminfo. It doesn't match.
If I'm an user of container, I want an information like /proc/meminfo for
container.

Anyway, if the kernel goes to merge IO-less page reclaim, dirty ratio
support is the 1st thing we have to implement.
Without that, memcg will easily OOM.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

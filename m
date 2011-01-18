Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9AD9D8D0039
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 05:20:13 -0500 (EST)
Date: Tue, 18 Jan 2011 11:20:06 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] memory control groups
Message-ID: <20110118102006.GL2212@cmpxchg.org>
References: <20110117191359.GI2212@cmpxchg.org>
 <20110118101057.51d20ed7.kamezawa.hiroyu@jp.fujitsu.com>
 <20110118084013.GK2212@cmpxchg.org>
 <20110118181757.2aefcf87.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110118181757.2aefcf87.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, lsf-pc@lists.linux-foundation.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, Ying Han <yinghan@google.com>, Michel Lespinasse <walken@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 06:17:57PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 18 Jan 2011 09:40:13 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Tue, Jan 18, 2011 at 10:10:57AM +0900, KAMEZAWA Hiroyuki wrote:
> > > - pc->page can be replaced with some lookup routine.
> > >   But Section bit encoding may be something mysterious and look up cost
> > >   will be problem.
> > 
> > Why is that?
> > 
> > The lookup is actually straight-forward, like lookup_page_cgroup().
> > And we only need it when coming from the per-cgroup LRU, i.e. in
> > reclaim and force_empty.
> >  
> 
> I see usage of pc->page is not very frequent. But I wonder we should
> revisit performance of lookup_page_cgroup() before adding new weight.

I think those are two different things to tackle.  But I will make
sure to check for performance overhead when removing pc->page.

> > > - I'm not sure PCG_MIGRATION. It's for avoiding races.
> > 
> > That's also a scary patch...  Yeah, it's to prevent uncharging of
> > oldpage in case migration fails and it has to be reused.  I changed
> > the migration sequence for memcg a bit so that we don't have to do
> > that anymore.  It survived basic testing.
> > 
> 
> Hmm. I saw level down of migration under memcg several times. So, I don't
> want to modify running one without enough reason.
> I guess all SECTION_BITS can be encoded to pc->flags without diet of flags.

That's true, there is enough room for that.

Those reduction patches I only wrote to also pack the pc->mem_cgroup
ID into pc->flags, but these are two independent problems.

I would not have finished the patch only for that one tiny flag, but
it actually saved code and made it IMO a bit easier to understand.  I
consider this a serious upside of code that has a history of breaking.

But one at the time, first I will finish testing and benchmarking the
pc->page removal.

> > E.g. I have a suspicion that we might be able to do dirty accounting
> > without all the flags (we have them in the page anyway!) but use
> > proportionals instead.  It's not page-accurate, but I think the
> > fundamental problem is solved: when the dirty ratio is exceeded,
> > throttle the cgroup with the biggest dirty share.
> 
> Using proportionals is a choice. But, IIUC, users of memcg wants 
> something like /proc/meminfo. It doesn't match.
> If I'm an user of container, I want an information like /proc/meminfo for
> container.

I totally agree that this is information that needs exporting.

But you can easily calculate an absolute number of bytes by applying a
memcg's relative proportion to the absolute amount of dirty pages for
example.  The only difference is that it probably won't be 100%
accurate, but a few pages difference should really not matter for
user-visible statistics.

No?

> Anyway, if the kernel goes to merge IO-less page reclaim, dirty ratio
> support is the 1st thing we have to implement.
> Without that, memcg will easily OOM.

Agreed.  I am not saying that my memory footprint concerns should
stand in the way of merging important infrastructure.  This is work
that can still be done even after dirty accounting is merged.

Thanks,
	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

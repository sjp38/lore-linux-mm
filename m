Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id E60C16B018D
	for <linux-mm@kvack.org>; Wed,  1 May 2013 11:28:31 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id ro2so782069pbb.4
        for <linux-mm@kvack.org>; Wed, 01 May 2013 08:28:31 -0700 (PDT)
Date: Wed, 1 May 2013 08:28:30 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [v3.9-rc8]: kernel BUG at mm/memcontrol.c:3994! (was: Re:
 [BUG][s390x] mm: system crashed)
In-Reply-To: <20130430172711.GE1229@cmpxchg.org>
Message-ID: <alpine.LNX.2.00.1305010758090.12051@eggly.anvils>
References: <2068164110.268217.1365996520440.JavaMail.root@redhat.com> <20130415055627.GB4207@osiris> <516B9B57.6050308@redhat.com> <20130416075047.GA4184@osiris> <1638103518.2400447.1366266465689.JavaMail.root@redhat.com> <20130418071303.GB4203@osiris>
 <20130424104255.GC4350@osiris> <20130424131851.GC31960@dhcp22.suse.cz> <20130424152043.GP2018@cmpxchg.org> <alpine.LNX.2.00.1304242022200.16233@eggly.anvils> <20130430172711.GE1229@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Zhouping Liu <zliu@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, caiqian <caiqian@redhat.com>, Caspar Zhang <czhang@redhat.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Lingzhu Xiang <lxiang@redhat.com>

On Tue, 30 Apr 2013, Johannes Weiner wrote:
> On Wed, Apr 24, 2013 at 08:50:01PM -0700, Hugh Dickins wrote:
> > On Wed, 24 Apr 2013, Johannes Weiner wrote:
> > > On Wed, Apr 24, 2013 at 03:18:51PM +0200, Michal Hocko wrote:
> > > > On Wed 24-04-13 12:42:55, Heiko Carstens wrote:
> > > > > On Thu, Apr 18, 2013 at 09:13:03AM +0200, Heiko Carstens wrote:
> > > > > 
> > > > > [   48.347963] ------------[ cut here ]------------
> > > > > [   48.347972] kernel BUG at mm/memcontrol.c:3994!
> > > > > __mem_cgroup_uncharge_common() triggers:
> > > > > 
> > > > > [...]
> > > > >         if (mem_cgroup_disabled())
> > > > >                 return NULL;
> > > > > 
> > > > >         VM_BUG_ON(PageSwapCache(page));
> > > > > [...]
> > 
> > I agree that the actual memcg uncharging should be okay, but the memsw
> > swap stats will go wrong (doesn't matter toooo much), and mem_cgroup_put
> > get missed (leaking a struct mem_cgroup).
> 
> Ok, so I just went over this again.  For the swapout path the memsw
> uncharge is deferred, but if we "steal" this uncharge from the swap
> code, we actually do uncharge memsw in mem_cgroup_do_uncharge(), so we
> may prematurely unaccount the swap page, but we never leak a charge.
> Good.
> 
> Because of this stealing, we also don't do the following:
> 
> 	if (do_swap_account && ctype == MEM_CGROUP_CHARGE_TYPE_SWAPOUT) {
> 		mem_cgroup_swap_statistics(memcg, true);
> 		mem_cgroup_get(memcg);
> 	}
> 
> I.e. it does not matter that mem_cgroup_uncharge_swap() doesn't do the
> put, we are also not doing the get.  We should not leak references.
> 
> So the only thing that I can see go wrong is that we may have a
> swapped out page that is not charged to memsw and not accounted as
> MEM_CGROUP_STAT_SWAP.  But I don't know how likely that is, because we
> check for PG_swapcache in this uncharge path after the last pte is
> torn down, so even though the page is put on swap cache, it probably
> won't be swapped.  It would require that the PG_swapcache setting
> would become visible only after the page has been added to the swap
> cache AND rmap has established at least one swap pte for us to
> uncharge a page that actually continues to be used.  And that's a bit
> of a stretch, I think.

Sorry, our minds seem to work in different ways,
I understood very little of what you wrote above :-(

But once I try to disprove you with a counter-example, I seem to
arrive at the same conclusion as you have (well, I haven't quite
arrived there yet, but cannot give it any more time).

Looking at it from my point of view, I concentrate on the racy
	if (PageSwapCache(page))
		return;
	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_ANON, false);
in mem_cgroup_uncharge_page().

Now, that may or may not catch the case where last reference to page
is unmapped at the same time as the page is added to swap: but being
a MEM_CGROUP_CHARGE_TYPE_ANON call, it does not interfere with the
memsw stats and get/put at all, those remain in balance.

And mem_cgroup_uncharge_swap() has all along been prepared to get
a zero id from swap_cgroup_record(), if a SwapCache page should be
uncharged when it was never quite charged as such.

Yes, we may occasionally fail to charge a SwapCache page as such
if its final unmap from userspace races with its being added to swap;
but it's heading towards swap_writepage()'s try_to_free_swap() anyway,
so I don't think that's anything to worry about.

(If I had time to stop and read through that, I'd probably find it
just as hard to understand as what you wrote!)

> 
> Did I miss something?  If not, I'll just send a patch that removes the
> VM_BUG_ON() and adds a comment describing the scenarios and a note
> that we may want to fix this in the future.

I don't think you missed something.  Yes, please just send Linus and
Andrew a patch to remove the VM_BUG_ON() (with Cc stable tag), I now
agree that's all that's really needed - thanks.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

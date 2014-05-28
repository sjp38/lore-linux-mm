Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 857F06B0038
	for <linux-mm@kvack.org>; Wed, 28 May 2014 07:37:26 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id t60so11260048wes.27
        for <linux-mm@kvack.org>; Wed, 28 May 2014 04:37:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fm4si6599134wib.68.2014.05.28.04.37.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 04:37:23 -0700 (PDT)
Date: Wed, 28 May 2014 13:37:18 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 8/9] mm: memcontrol: rewrite charge API
Message-ID: <20140528113718.GH9895@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-9-git-send-email-hannes@cmpxchg.org>
 <20140523145413.GF22135@dhcp22.suse.cz>
 <20140527200516.GE2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140527200516.GE2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 27-05-14 16:05:16, Johannes Weiner wrote:
> On Fri, May 23, 2014 at 04:54:13PM +0200, Michal Hocko wrote:
> > On Wed 30-04-14 16:25:42, Johannes Weiner wrote:
> > > The memcg charge API charges pages before they are rmapped - i.e. have
> > > an actual "type" - and so every callsite needs its own set of charge
> > > and uncharge functions to know what type is being operated on.
> > > 
> > > Rewrite the charge API to provide a generic set of try_charge(),
> > > commit_charge() and cancel_charge() transaction operations, much like
> > > what's currently done for swap-in:
> > > 
> > >   mem_cgroup_try_charge() attempts to reserve a charge, reclaiming
> > >   pages from the memcg if necessary.
> > > 
> > >   mem_cgroup_commit_charge() commits the page to the charge once it
> > >   has a valid page->mapping and PageAnon() reliably tells the type.
> > > 
> > >   mem_cgroup_cancel_charge() aborts the transaction.
> > > 
> > > As pages need to be committed after rmap is established but before
> > > they are added to the LRU, page_add_new_anon_rmap() must stop doing
> > > LRU additions again.  Factor lru_cache_add_active_or_unevictable().
> > > 
> > > The order of functions in mm/memcontrol.c is entirely random, so this
> > > new charge interface is implemented at the end of the file, where all
> > > new or cleaned up, and documented code should go from now on.
> > 
> > I would prefer moving them after refactoring because the reviewing is
> > really harder this way. If such moving is needed at all.
> 
> I find it incredibly cumbersome to work with this code because of the
> ordering.  Sure, you use the search function of the editor, but you
> don't even know whether to look above or below, half of the hits are
> forward declarations etc. 

I tend to use cscope when moving through code so I never considered that
a big hassle.

> Crappy code attracts more crappy code, so I
> feel strongly that we clean this up and raise the bar for the future.

No objection to that. If reorganization helps in that direction then
let's do it. But I would rather do it in a separate patch to have an
easy way to compare the results (e.g. by comparing the generated code).

> As to the ordering: I chose this way because this really is a
> fundamental rewrite, and I figured it would be *easier* to read if you
> have the entire relevant code show up in the diff.  I.e. try_charge()
> is fully included, right next to its API entry function.
> 
> If this doesn't work for you - the reviewer - I'm happy to change it
> around and move the code separately.

Yeah, that would make the review easier. At least for me.
 
> > size is saying the code is slightly bigger:
> >    text    data     bss     dec     hex filename
> >  487977   84898   45984  618859   9716b mm/built-in.o.7
> >  488276   84898   45984  619158   97296 mm/built-in.o.8
> > 
> > No biggie though.
> > 
> > It is true it get's rid of ~80LOC in memcontrol.c but it adds some more
> > outside of memcg. Most of the charging paths didn't get any easier, they
> > already know the type and they have to make sure they even commit the
> > charge now.
> > 
> > But maybe it is just me feeling that now that we have
> > mem_cgroup_charge_{anon,file,swapin} the API doesn't look so insane
> > anymore and so I am not tempted to change it that much.
> 
> I should have been a little clearer in the changelog: this is mainly
> to make sure we never commit pages before their rmapping is
> established so that not only charging, but also uncharging can be
> drastically simplified.
> 
> You already noticed that when looking at the next patch, but I'll make
> sure to mention it here as well.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

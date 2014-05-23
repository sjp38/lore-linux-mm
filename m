Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4D4446B0036
	for <linux-mm@kvack.org>; Fri, 23 May 2014 11:18:55 -0400 (EDT)
Received: by mail-ee0-f51.google.com with SMTP id e51so3784803eek.10
        for <linux-mm@kvack.org>; Fri, 23 May 2014 08:18:54 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a46si7519553eep.42.2014.05.23.08.18.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 May 2014 08:18:53 -0700 (PDT)
Date: Fri, 23 May 2014 17:18:52 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 8/9] mm: memcontrol: rewrite charge API
Message-ID: <20140523151852.GG22135@dhcp22.suse.cz>
References: <1398889543-23671-1-git-send-email-hannes@cmpxchg.org>
 <1398889543-23671-9-git-send-email-hannes@cmpxchg.org>
 <20140523145413.GF22135@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140523145413.GF22135@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 23-05-14 16:54:13, Michal Hocko wrote:
> On Wed 30-04-14 16:25:42, Johannes Weiner wrote:
> > The memcg charge API charges pages before they are rmapped - i.e. have
> > an actual "type" - and so every callsite needs its own set of charge
> > and uncharge functions to know what type is being operated on.
> > 
> > Rewrite the charge API to provide a generic set of try_charge(),
> > commit_charge() and cancel_charge() transaction operations, much like
> > what's currently done for swap-in:
> > 
> >   mem_cgroup_try_charge() attempts to reserve a charge, reclaiming
> >   pages from the memcg if necessary.
> > 
> >   mem_cgroup_commit_charge() commits the page to the charge once it
> >   has a valid page->mapping and PageAnon() reliably tells the type.
> > 
> >   mem_cgroup_cancel_charge() aborts the transaction.
> > 
> > As pages need to be committed after rmap is established but before
> > they are added to the LRU, page_add_new_anon_rmap() must stop doing
> > LRU additions again.  Factor lru_cache_add_active_or_unevictable().
> > 
> > The order of functions in mm/memcontrol.c is entirely random, so this
> > new charge interface is implemented at the end of the file, where all
> > new or cleaned up, and documented code should go from now on.
> 
> I would prefer moving them after refactoring because the reviewing is
> really harder this way. If such moving is needed at all.
> 
> Anyway this is definitely not a Friday material...
> 
> So only a first impression from a quick glance.
> 
> size is saying the code is slightly bigger:
>    text    data     bss     dec     hex filename
>  487977   84898   45984  618859   9716b mm/built-in.o.7
>  488276   84898   45984  619158   97296 mm/built-in.o.8
> 
> No biggie though.
> 
> It is true it get's rid of ~80LOC in memcontrol.c but it adds some more
> outside of memcg. Most of the charging paths didn't get any easier, they
> already know the type and they have to make sure they even commit the
> charge now.
> 
> But maybe it is just me feeling that now that we have
> mem_cgroup_charge_{anon,file,swapin} the API doesn't look so insane
> anymore and so I am not tempted to change it that much.
> 
> I will look at this with a Monday and fresh brain again.

And now that I got to 9/9 it is obvious it helps a lot to clean up the
uncharge path. But I am not in a mental state to dive into this today.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

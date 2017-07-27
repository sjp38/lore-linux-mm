Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id ACC806B04C0
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 15:46:31 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id k190so56332211pge.9
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:46:31 -0700 (PDT)
Received: from mail-pf0-x232.google.com (mail-pf0-x232.google.com. [2607:f8b0:400e:c00::232])
        by mx.google.com with ESMTPS id e4si11533157pgn.444.2017.07.27.12.46.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 12:46:30 -0700 (PDT)
Received: by mail-pf0-x232.google.com with SMTP id z129so47761300pfb.3
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 12:46:30 -0700 (PDT)
Date: Thu, 27 Jul 2017 12:46:28 -0700
From: Matthias Kaehlcke <mka@chromium.org>
Subject: Re: [PATCH] mm: memcontrol: Cast mismatched enum types passed to
 memcg state and event functions
Message-ID: <20170727194628.GB84665@google.com>
References: <20170726192356.18420-1-mka@chromium.org>
 <20170726142309.ac40faf5eb99568e6edb064c@linux-foundation.org>
 <20170726214914.GA84665@google.com>
 <20170726150332.313e48837d97046924ddaa16@linux-foundation.org>
 <20170727072451.GH20970@dhcp22.suse.cz>
 <20170727141742.GA19738@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20170727141742.GA19738@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, Doug Anderson <dianders@chromium.org>

El Thu, Jul 27, 2017 at 10:17:42AM -0400 Johannes Weiner ha dit:

> On Thu, Jul 27, 2017 at 09:24:51AM +0200, Michal Hocko wrote:
> > On Wed 26-07-17 15:03:32, Andrew Morton wrote:
> > > On Wed, 26 Jul 2017 14:49:14 -0700 Matthias Kaehlcke <mka@chromium.org> wrote:
> > > 
> > > > El Wed, Jul 26, 2017 at 02:23:09PM -0700 Andrew Morton ha dit:
> > > > 
> > > > > On Wed, 26 Jul 2017 12:23:56 -0700 Matthias Kaehlcke <mka@chromium.org> wrote:
> > > > > 
> > > > > > In multiple instances enum values of an incorrect type are passed to
> > > > > > mod_memcg_state() and other memcg functions. Apparently this is
> > > > > > intentional, however clang rightfully generates tons of warnings about
> > > > > > the mismatched types. Cast the offending values to the type expected
> > > > > > by the called function. The casts add noise, but this seems preferable
> > > > > > over losing the typesafe interface or/and disabling the warning.
> > > > > > 
> > > > > > ...
> > > > > >
> > > > > > --- a/include/linux/memcontrol.h
> > > > > > +++ b/include/linux/memcontrol.h
> > > > > > @@ -576,7 +576,7 @@ static inline void __mod_lruvec_state(struct lruvec *lruvec,
> > > > > >  	if (mem_cgroup_disabled())
> > > > > >  		return;
> > > > > >  	pn = container_of(lruvec, struct mem_cgroup_per_node, lruvec);
> > > > > > -	__mod_memcg_state(pn->memcg, idx, val);
> > > > > > +	__mod_memcg_state(pn->memcg, (enum memcg_stat_item)idx, val);
> > > > > >  	__this_cpu_add(pn->lruvec_stat->count[idx], val);
> > > > > >  }
> > > > > 
> > > > > __mod_memcg_state()'s `idx' arg can be either enum memcg_stat_item or
> > > > > enum memcg_stat_item.  I think it would be better to just admit to
> > > > > ourselves that __mod_memcg_state() is more general than it appears, and
> > > > > change it to take `int idx'.  I assume that this implicit cast of an
> > > > > enum to an int will not trigger a clang warning?
> > > > 
> > > > Sure, no warnings are raised for implicit casts from enum to
> > > > int.
> > > > 
> > > > __mod_memcg_state() is not the only function though, all these
> > > > functions are called with conflicting types:
> > > > 
> > > > memcg_page_state()
> > > > __mod_memcg_state()
> > > > mod_memcg_state()
> > > > count_memcg_events()
> > > > count_memcg_page_event()
> > > > memcg_sum_events()
> > > > 
> > > > Should we change all of them to reveice an int instead of an enum?
> > > 
> > > I suspect so - the current implementation is denying reality and your
> > > original proposal is a bit of a fudge.  But I'll await input from the
> > > memcg peeps.
> > 
> > well, those enums do not help type safety much I am afraid so turining
> > the idx to int sounds like a more preferable way to me. Johannes?
> 
> I agree, turning the parameter into an int makes for much nicer code
> than the casts.
> 
> Matthias, would you care to update your patch to change these over?

Ok, I'll respin the patch to use ints as parameters.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

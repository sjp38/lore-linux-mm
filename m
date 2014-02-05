Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id A04306B0036
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 11:29:44 -0500 (EST)
Received: by mail-we0-f169.google.com with SMTP id t61so477760wes.0
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 08:29:44 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v4si15397535wjz.106.2014.02.05.08.29.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 05 Feb 2014 08:29:43 -0800 (PST)
Date: Wed, 5 Feb 2014 17:29:41 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -v2 4/6] memcg: make sure that memcg is not offline when
 charging
Message-ID: <20140205162941.GF2425@dhcp22.suse.cz>
References: <1391520540-17436-1-git-send-email-mhocko@suse.cz>
 <1391520540-17436-5-git-send-email-mhocko@suse.cz>
 <20140204162939.GP6963@cmpxchg.org>
 <20140205133834.GB2425@dhcp22.suse.cz>
 <20140205152821.GY6963@cmpxchg.org>
 <20140205161940.GE2425@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140205161940.GE2425@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 05-02-14 17:19:40, Michal Hocko wrote:
> On Wed 05-02-14 10:28:21, Johannes Weiner wrote:
[...]
> > I thought more about this and talked to Tejun as well.  He told me
> > that the rcu grace period between disabling tryget and calling
> > css_offline() is currently an implementation detail of the refcounter
> > that css uses, but it's not a guarantee.  So my initial idea of
> > reworking memcg to do css_tryget() and res_counter_charge() in the
> > same rcu section is no longer enough to synchronize against offlining.
> > We can forget about that.
> > 
> > On the other hand, memcg holds a css reference only while an actual
> > controller reference is being established (res_counter_charge), then
> > drops it.  This means that once css_tryget() is disabled, we only need
> > to wait for the css refcounter to hit 0 to know for sure that no new
> > charges can show up and reparent_charges() is safe to run, right?
> > 
> > Well, css_free() is the callback invoked when the ref counter hits 0,
> > and that is a guarantee.  From a memcg perspective, it's the right
> > place to do reparenting, not css_offline().
> 
> OK, it seems I've totally misunderstood what is the purpose of
> css_offline. My understanding was that any attempt to css_tryget will
> fail when css_offline starts. I will read through Tejun's email as well
> and think about it some more.

OK, so css_tryget fails at the time of css_offline but there is no rcu
guarantee which we rely on. This means that css_offline is of very
limitted use for us. Pages which are swapped out are not reachable for
reparent and so we still might have a lot of references to css. Whether
it makes much sense to call reparent only for the swapcache is
questionable. We are still relying on some task to release that memory
while it lives in other memcg.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

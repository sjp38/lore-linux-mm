Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 532C96B0031
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 04:30:46 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id x13so1508534wgg.9
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 01:30:45 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c9si30218045wja.128.2014.06.09.01.30.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 09 Jun 2014 01:30:44 -0700 (PDT)
Date: Mon, 9 Jun 2014 10:30:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140609083042.GB7144@dhcp22.suse.cz>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
 <20140606152914.GA14001@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140606152914.GA14001@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri 06-06-14 11:29:14, Tejun Heo wrote:
> Hello, Michal.
> 
> On Fri, Jun 06, 2014 at 04:46:50PM +0200, Michal Hocko wrote:
> > +choice
> > +	prompt "Memory Resource Controller reclaim protection"
> > +	depends on MEMCG
> > +	help
> 
> Why is this necessary?

It allows user/admin to set the default behavior.

> - This doesn't affect boot.
> 
> - memcg requires runtime config *anyway*.
> 
> - The config is inherited from the parent, so the default flipping
>   isn't exactly difficult.
> 
> Please drop the kconfig option.

How do you propose to tell the default then? Only at the runtime?
I really do not insist on the kconfig. I find it useful for a)
documentation purpose b) easy way to configure the default.

> > +static int mem_cgroup_write_reclaim_strategy(struct cgroup_subsys_state *css, struct cftype *cft,
> > +			    char *buffer)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
> > +	int ret = 0;
> > +
> > +	if (!strncmp(buffer, "low_limit_guarantee",
> > +				sizeof("low_limit_guarantee"))) {
> > +		memcg->hard_low_limit = true;
> > +	} else if (!strncmp(buffer, "low_limit_best_effort",
> > +				sizeof("low_limit_best_effort"))) {
> > +		memcg->hard_low_limit = false;
> > +	} else
> > +		ret = -EINVAL;
> > +
> > +	return ret;
> > +}
> 
> So, ummm, this raises a big red flag for me.  You're now implementing
> two behaviors in a mostly symmetric manner to soft/hard limits but
> choosing a completely different scheme in how they're configured
> without any rationale.

So what is your suggestion then? Using a global setting? Using a
separate knob? Something completely different?

> * Are you sure soft and hard guarantees aren't useful when used in
>   combination?  If so, why would that be the case?

This was a call from Google to have per-memcg setup AFAIR. Using
different reclaim protection on the global case vs. limit reclaim makes
a lot of sense to me. If this is a major obstacle then I am OK to drop
it and only have a global setting for now.

> * We have pressure monitoring interface which can be used for soft
>   limit pressure monitoring. 

Which one is that? I only know about oom_control triggered by the hard
limit pressure.

>   How should breaching soft guarantee be
>   factored into that?  There doesn't seem to be any way of notifying
>   that at the moment?  Wouldn't we want that to be integrated into the
>   same mechanism?

Yes, there is. We have a counter in memory.stat file which tells how
many times the limit has been breached.

> What scares me the most is that you don't even seem to have noticed
> the asymmetry and are proposing userland-facing interface without
> actually thinking things through.  This is exactly how we've been
> getting into trouble.

This has been discussed up and down for the last _two_ years. I have
considered other options how to provide a very _useful_ feature users
are calling for. There is even general consensus among developers that
the feature is desirable and that the two modes (soft/hard) memory
protection are needed. Yet I would _really_ like to hear any
suggestion to get unstuck. It is far from useful to come and Nack this
_again_ without providing any alternative suggestions.

> For now, for everything.
> 
>  Nacked-by: Tejun Heo <tj@kernel.org>
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

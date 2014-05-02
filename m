Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f47.google.com (mail-ee0-f47.google.com [74.125.83.47])
	by kanga.kvack.org (Postfix) with ESMTP id 884836B0036
	for <linux-mm@kvack.org>; Fri,  2 May 2014 08:03:11 -0400 (EDT)
Received: by mail-ee0-f47.google.com with SMTP id b15so3099092eek.20
        for <linux-mm@kvack.org>; Fri, 02 May 2014 05:03:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x47si1428381eel.253.2014.05.02.05.03.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 May 2014 05:03:10 -0700 (PDT)
Date: Fri, 2 May 2014 14:03:08 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140502120308.GH3446@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140430145238.4215f914f7ad025da4db5470@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140430145238.4215f914f7ad025da4db5470@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Hugh Dickins <hughd@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 30-04-14 14:52:38, Andrew Morton wrote:
> On Mon, 28 Apr 2014 14:26:41 +0200 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Hi,
> > previous discussions have shown that soft limits cannot be reformed
> > (http://lwn.net/Articles/555249/). This series introduces an alternative
> > approach for protecting memory allocated to processes executing within
> > a memory cgroup controller. It is based on a new tunable that was
> > discussed with Johannes and Tejun held during the kernel summit 2013 and
> > at LSF 2014.
> > 
> > This patchset introduces such low limit that is functionally similar
> > to a minimum guarantee. Memcgs which are under their lowlimit are not
> > considered eligible for the reclaim (both global and hardlimit) unless
> > all groups under the reclaimed hierarchy are below the low limit when
> > all of them are considered eligible.
> 
> Permitting containers to avoid global reclaim sounds rather worrisome. 
> 
> Fairness: won't it permit processes to completely protect their memory
> while everything else in the system is getting utterly pounded?  We
> need to consider global-vs-memcg fairness as well as memcg-vs-memgc.
> 
> Security: can this feature be used to DoS the machine?  Set up enough
> hierarchies which are below their low limit and we risk memory
> exhaustion and swap-thrashing and oom-killings for other processes.

Johannes has already pointed out that setting the low limit is really
supposed to be a privileged operation. And, in principle, this is not any
different from any other guarantee.
 
> All of that being said, your statement doesn't appear to be true ;)

"
Memcgs which are under their lowlimit are ignored during the reclaim
(both global and hardlimit) unless all groups under the reclaimed
hierarchy are below the low limit. Low limit will be ignored in this
case for all groups in the hierarchy.
"

Better?

> > +static void shrink_zone(struct zone *zone, struct scan_control *sc)
> > +{
> > +	if (!__shrink_zone(zone, sc, true)) {
> > +		/*
> > +		 * First round of reclaim didn't find anything to reclaim
> > +		 * because of low limit protection so try again and ignore
> > +		 * the low limit this time.
> > +		 */
> > +		__shrink_zone(zone, sc, false);
> > +	}
> >  }
> `

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

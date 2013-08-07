Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 433126B00E0
	for <linux-mm@kvack.org>; Wed,  7 Aug 2013 09:37:49 -0400 (EDT)
Date: Wed, 7 Aug 2013 15:37:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/3] memcg: Limit the number of events registered on
 oom_control
Message-ID: <20130807133746.GI8184@dhcp22.suse.cz>
References: <1375874907-22013-1-git-send-email-mhocko@suse.cz>
 <1375874907-22013-2-git-send-email-mhocko@suse.cz>
 <20130807130836.GB27006@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130807130836.GB27006@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Anton Vorontsov <anton.vorontsov@linaro.org>

On Wed 07-08-13 09:08:36, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Aug 07, 2013 at 01:28:26PM +0200, Michal Hocko wrote:
> > There is no limit for the maximum number of oom_control events
> > registered per memcg. This might lead to an user triggered memory
> > depletion if a regular user is allowed to register events.
> > 
> > Let's be more strict and cap the number of events that might be
> > registered. MAX_OOM_NOTIFY_EVENTS value is more or less random. The
> > expectation is that it should be high enough to cover reasonable
> > usecases while not too high to allow excessive resources consumption.
> > 1024 events consume something like 24KB which shouldn't be a big deal
> > and it should be good enough (even 1024 oom notification events sounds
> > crazy).
> 
> I think putting restriction on usage_event makes sense as that builds
> a shared contiguous table from all events which can't be attributed
> correctly and makes it easy to trigger allocation failures due to
> large order allocation but is this necessary for oom and vmpressure,
> both of which allocate only for the listening task?

Once I was there I made them consistent in that regards.

> It isn't different from listening from epoll, for example.

epoll limits the number of watchers, no?

> If there needs to be kernel memory limit, shouldn't that be handled by
> kmemcg?

kmemcg would surely help but turning it on just because of potential
abuse of the event registration API sounds like an overkill.

I think having a cap for user trigable kernel resources is a good thing
in general.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

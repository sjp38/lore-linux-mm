Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f175.google.com (mail-we0-f175.google.com [74.125.82.175])
	by kanga.kvack.org (Postfix) with ESMTP id 26C896B0036
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 11:12:49 -0500 (EST)
Received: by mail-we0-f175.google.com with SMTP id q59so7767466wes.34
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 08:12:48 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cd16si1822532wib.35.2014.02.13.08.12.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 13 Feb 2014 08:12:46 -0800 (PST)
Date: Thu, 13 Feb 2014 17:12:46 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/4] memcg: Low-limit reclaim
Message-ID: <20140213161246.GG11986@dhcp22.suse.cz>
References: <1386771355-21805-1-git-send-email-mhocko@suse.cz>
 <52E24956.3000007@yandex-team.ru>
 <20140129182259.GA6711@dhcp22.suse.cz>
 <877g90cy6j.wl%klamm@yandex-team.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <877g90cy6j.wl%klamm@yandex-team.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Ying Han <yinghan@google.com>, Hugh Dickins <hughd@google.com>, Michel Lespinasse <walken@google.com>, Greg Thelen <gthelen@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>

On Wed 12-02-14 16:28:36, Roman Gushchin wrote:
> Hi, Michal!
> 
> Sorry for a long reply.
> 
> At Wed, 29 Jan 2014 19:22:59 +0100,
> Michal Hocko wrote:
> > > As you can remember, I've proposed to introduce low limits about a year ago.
> > > 
> > > We had a small discussion at that time: http://marc.info/?t=136195226600004 .
> > 
> > yes I remember that discussion and vaguely remember the proposed
> > approach. I really wanted to prevent from introduction of a new knob but
> > things evolved differently than I planned since then and it turned out
> > that the knew knob is unavoidable. That's why I came with this approach
> > which is quite different from yours AFAIR.
> >  
> > > Since that time we intensively use low limits in our production
> > > (on thousands of machines). So, I'm very interested to merge this
> > > functionality into upstream.
> > 
> > Have you tried to use this implementation? Would this work as well?
> > My very vague recollection of your patch is that it didn't cover both
> > global and target reclaims and it didn't fit into the reclaim very
> > naturally it used its own scaling method. I will have to refresh my
> > memory though.
> 
> IMHO, the main problem of your implementation is the following: 
> the number of reclaimed pages is not limited at all,
> if cgroup is over it's low memory limit. So, a significant number 
> of pages can be reclaimed, even if the memory usage is only a bit 
> (e.g. one page) above the low limit.

Yes but this is the same problem as with the regular reclaim.
We do not have any guarantee that we will reclaim only the required
amount of memory. As the reclaim priority falls down we can overreclaim.
The global reclaim tries to avoid this problem by keeping the priority
as high as possible. And the target reclaim is not a big deal because we
are limiting the number of reclaimed pages to the swap cluster.

I do not see this as a practical problem of the low_limit though,
because it protects those that are below the limit not above. Small
fluctuation around the limit should be tolerable.

> In my case, this problem is solved by scaling the number of scanned pages.
> 
> I think, an ideal solution is to limit the number of reclaimed pages by 
> low limit excess value. This allows to discard my scaling code, but save
> the strict semantics of low limit under memory pressure. The main problem 
> here is how to balance scanning pressure between cgroups and LRUs.
> 
> Maybe, we should calculate the number of pages to scan in a LRU based on
> the low limit excess value instead of number of pages...

I do not like it much and I expect other mm people to feel similar. We
already have scanning scaling based on the priority. Adding a new
variable into the picture will make the whole thing only more
complicated without a very good reason for it.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

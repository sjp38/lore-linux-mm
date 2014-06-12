Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 82AAE6B00F3
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 09:56:17 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so779655wib.3
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 06:56:16 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id p14si13562786wiv.81.2014.06.12.06.56.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 06:56:15 -0700 (PDT)
Date: Thu, 12 Jun 2014 09:56:00 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140612135600.GI2878@cmpxchg.org>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612132207.GA32720@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 12, 2014 at 03:22:07PM +0200, Michal Hocko wrote:
> On Wed 11-06-14 11:36:31, Johannes Weiner wrote:
> [...]
> > This code is truly dreadful.
> > 
> > Don't call it guarantee when it doesn't guarantee anything.  I thought
> > we agreed that min, low, high, max, is reasonable nomenclature, please
> > use it consistently.
> 
> I can certainly change the internal naming. I will use your wmark naming
> suggestion.

Cool, thanks.

> > With my proposed cleanups and scalability fixes in the other mail, the
> > vmscan.c changes to support the min watermark would be something like
> > the following.
> 
> The semantic is, however, much different as pointed out in the other email.
> The following on top of you cleanup will lead to the same deadlock
> described in 1st patch (mm, memcg: allow OOM if no memcg is eligible
> during direct reclaim).

I'm currently reworking shrink_zones() and getting rid of
all_unreclaimable() etc. to remove the code duplication.

> Anyway, the situation now is pretty chaotic. I plan to gather all the
> patchse posted so far and repost for the future discussion. I just need
> to finish some internal tasks and will post it soon.

That would be great, thanks, it's really hard to follow this stuff
halfway in and halfway outside of -mm.

Now that we roughly figured out what knobs and semantics we want, it
would be great to figure out the merging logistics.

I would prefer if we could introduce max, high, low, min in unified
hierarchy, and *only* in there, so that we never have to worry about
it coexisting and interacting with the existing hard and soft limit.

It would also be beneficial to introduce them all close to each other,
develop them together, possibly submit them in the same patch series,
so that we know the requirements and how the code should look like in
the big picture and can offer a fully consistent and documented usage
model in the unified hierarchy.

Does that make sense?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

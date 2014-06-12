Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 65E906B00F5
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 10:22:44 -0400 (EDT)
Received: by mail-wi0-f171.google.com with SMTP id n15so6924352wiw.4
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 07:22:43 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ek1si3422887wib.66.2014.06.12.07.22.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Jun 2014 07:22:42 -0700 (PDT)
Date: Thu, 12 Jun 2014 16:22:37 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow guarantee reclaim
Message-ID: <20140612142237.GB32720@dhcp22.suse.cz>
References: <20140611075729.GA4520@dhcp22.suse.cz>
 <1402473624-13827-1-git-send-email-mhocko@suse.cz>
 <1402473624-13827-2-git-send-email-mhocko@suse.cz>
 <20140611153631.GH2878@cmpxchg.org>
 <20140612132207.GA32720@dhcp22.suse.cz>
 <20140612135600.GI2878@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140612135600.GI2878@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Tejun Heo <tj@kernel.org>, Roman Gushchin <klamm@yandex-team.ru>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 12-06-14 09:56:00, Johannes Weiner wrote:
> On Thu, Jun 12, 2014 at 03:22:07PM +0200, Michal Hocko wrote:
[...]
> > Anyway, the situation now is pretty chaotic. I plan to gather all the
> > patchse posted so far and repost for the future discussion. I just need
> > to finish some internal tasks and will post it soon.
> 
> That would be great, thanks, it's really hard to follow this stuff
> halfway in and halfway outside of -mm.
> 
> Now that we roughly figured out what knobs and semantics we want, it
> would be great to figure out the merging logistics.
> 
> I would prefer if we could introduce max, high, low, min in unified
> hierarchy, and *only* in there, so that we never have to worry about
> it coexisting and interacting with the existing hard and soft limit.

The primary question would be, whether this is is the best transition
strategy. I do not know how many users apart from developers are really
using unified hierarchy. I would be worried that we merge a feature which
will not be used for a long time.

Moreover, if somebody wants to transition from soft limit then it would
be really hard because switching to unified hierarchy might be a no-go.

I think that it is clear that we should deprecate soft_limit ASAP. I
also think it wont't hurt to have min, low, high in both old and unified
API and strongly warn if somebody tries to use soft_limit along with any
of the new APIs in the first step. Later we can even forbid any
combination by a hard failure.

> It would also be beneficial to introduce them all close to each other,
> develop them together, possibly submit them in the same patch series,
> so that we know the requirements and how the code should look like in
> the big picture and can offer a fully consistent and documented usage
> model in the unified hierarchy.

Min and Low should definitely go together. High sounds like an
orthogonal problem (pro-active reclaim vs reclaim protection) so I think
it can go its own way and pace. We still have to discuss its semantic
and I feel it would be a bit disturbing to have everything in one
bundle. 
I do understand your point about the global picture, though. Do you
think that there is a risk that formulating semantic for High limit
might change the way how Min and Low would be defined?

> Does that make sense?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

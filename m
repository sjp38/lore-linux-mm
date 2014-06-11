Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f169.google.com (mail-we0-f169.google.com [74.125.82.169])
	by kanga.kvack.org (Postfix) with ESMTP id 79B736B0162
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 10:11:27 -0400 (EDT)
Received: by mail-we0-f169.google.com with SMTP id t60so3962113wes.0
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 07:11:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id mc10si10294630wic.84.2014.06.11.07.11.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 07:11:23 -0700 (PDT)
Date: Wed, 11 Jun 2014 16:11:17 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 2/2] memcg: Allow hard guarantee mode for low limit
 reclaim
Message-ID: <20140611141117.GF4520@dhcp22.suse.cz>
References: <20140606144421.GE26253@dhcp22.suse.cz>
 <1402066010-25901-1-git-send-email-mhocko@suse.cz>
 <1402066010-25901-2-git-send-email-mhocko@suse.cz>
 <xr934mzt4rwc.fsf@gthelen.mtv.corp.google.com>
 <20140610165756.GG2878@cmpxchg.org>
 <20140611075729.GA4520@dhcp22.suse.cz>
 <20140611123109.GA17777@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140611123109.GA17777@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michel Lespinasse <walken@google.com>, Roman Gushchin <klamm@yandex-team.ru>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Wed 11-06-14 08:31:09, Tejun Heo wrote:
> Hello, Michal.
> 
> On Wed, Jun 11, 2014 at 09:57:29AM +0200, Michal Hocko wrote:
> > Is this the kind of symmetry Tejun is asking for and that would make
> > change is Nack position? I am still not sure it satisfies his soft
> 
> Yes, pretty much.  What primarily bothered me was the soft/hard
> guarantees being chosen by a toggle switch while the soft/hard limits
> can be configured separately and combined.

The last consensus at LSF was that there would be a knob which will
distinguish hard/best effort behavior. The weaker semantic has strong
usecases IMHO so I wanted to start with it and add a knob for the hard
guarantee later when explicitly asked for.

Going with min, low, high and hard makes more sense to me of course.

> > guarantee objections from other email.
> 
> I was wondering about the usefulness of "low" itself in isolation and

I think it has more usecases than "min" from simply practical POV. OOM
means a potential service down time and that is a no go. Optimistic
isolation on the other hand adds an advantages of the isolation most of
the time while not getting completely flat on an exception (be it
misconfiguration or a corner case like mentioned during the discussion).

That doesn't mean "min" is not useful. It definitely is, the category
of usecases will be more specific though.

> I still think it'd be less useful than "high", but as there seem to be
> use cases which can be served with that and especially as a part of a
> consistent control scheme, I have no objection.
> 
> "low" definitely requires a notification mechanism tho.

Would vmpressure notification be sufficient? That one is in place for
any memcg which is reclaimed.

Or are you thinking about something more like oom_control?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

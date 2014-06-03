Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id 58D5E6B0031
	for <linux-mm@kvack.org>; Tue,  3 Jun 2014 10:45:00 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id u57so7003489wes.29
        for <linux-mm@kvack.org>; Tue, 03 Jun 2014 07:44:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bj10si32770297wjb.133.2014.06.03.07.44.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 03 Jun 2014 07:44:58 -0700 (PDT)
Date: Tue, 3 Jun 2014 16:44:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 0/4] memcg: Low-limit reclaim
Message-ID: <20140603144455.GL1321@dhcp22.suse.cz>
References: <1398688005-26207-1-git-send-email-mhocko@suse.cz>
 <20140528121023.GA10735@dhcp22.suse.cz>
 <20140528134905.GF2878@cmpxchg.org>
 <20140528142144.GL9895@dhcp22.suse.cz>
 <20140528152854.GG2878@cmpxchg.org>
 <xr93ioopyj1y.fsf@gthelen.mtv.corp.google.com>
 <20140603110959.GE1321@dhcp22.suse.cz>
 <CAHH2K0YuEFdPRVrCfoxYwP5b0GK4cZzL5K3ByubW+087BKcsUg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0YuEFdPRVrCfoxYwP5b0GK4cZzL5K3ByubW+087BKcsUg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: Roman Gushchin <klamm@yandex-team.ru>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michel Lespinasse <walken@google.com>

On Tue 03-06-14 07:01:20, Greg Thelen wrote:
> On Jun 3, 2014 4:10 AM, "Michal Hocko" <mhocko@suse.cz> wrote:
> >
> > On Wed 28-05-14 09:17:13, Greg Thelen wrote:
> > [...]
> > > My 2c...  The following works for my use cases:
> > > 1) introduce memory.low_limit_in_bytes (default=0 thus no default change
> > >    from older kernels)
> > > 2) interested users will set low_limit_in_bytes to non-zero value.
> > >    Memory protected by low limit should be as migratable/reclaimable as
> > >    mlock memory.  If a zone full of mlock memory causes oom kills, then
> > >    so should the low limit.
> >
> > Would fallback mode in overcommit or the corner case situation break
> > your usecase?
> 
> Yes.  Fallback mode would break my use cases.  What is the corner case
> situation?  NUMA conflicts? 

Described here http://marc.info/?l=linux-mm&m=139940101124396&w=2

> Low limit is a substitute for users mlocking memory.  So if mlocked
> memory has the same NUMA conflicts, then I see no problem with low
> limit having the same behavior.

In principal they are similar - at least from the reclaim POV. The usage
will be however quite different IMO.
mlock is the explicit way to keep memory resident. The application
writer knows_what_he_is_doing, right?
Lowlimit is an administrative tool. Administrator of a potentially complex
application is tuning the said application to beat the best performance
out of it.
Now both of them know that the thing might blow up if they overcommit on
the locked memory. So the application writer can check the system state
before he asks for mlock and he knows about previous mlocks.
Admin doesn't have that possibility because the memory distribution of
the memcg is not easy to find out.

> From a user API perspective, I'm not clear on the difference between
> non-ooming (fallback) low limit and the existing soft limit interface.  If
> low limit is a "soft" (non ooming) limit then why not rework the existing
> soft limit interface and save the low limit for strict (ooming) behavior?

No, not that path again. Pretty please! We've been there and it didn't
work out. We've been told to not flip defaults and potentially break
userspace. Softlimit with it weird semantic should die and stay as a
colorful example of a bad design decision.

> Of course, Google can continue to tweak the soft limit or new low
> limit to provide an ooming guarantee rather than violating the limit.

If you have the use case for the hard guarantee then we can add a knob
as I've said repeatedly. I just wanted to hear the use case. If you have
one, great. I just wanted to start with something which is more usable
in general.

Your setup is quite specific and known to love OOM killers so you are
very well prepared for that. On the other hand my users would end up in
a surprise if they saw an OOM while the setup was seemingly correct
because lowlimit was not overcommitted.

I can come up with a patch on top of what is in mm tree now. It would
add a knob (configurable to default to fallback or OOM by default).

What do you think about this? Would that work for you and Johannes?

> PS: I currently have very limited connectivity so my responses will be
> delayed.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

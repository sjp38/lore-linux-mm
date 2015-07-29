Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f181.google.com (mail-lb0-f181.google.com [209.85.217.181])
	by kanga.kvack.org (Postfix) with ESMTP id 358B26B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:37:47 -0400 (EDT)
Received: by lbbud7 with SMTP id ud7so6762626lbb.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:37:46 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id o7si21960926lbw.36.2015.07.29.09.37.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 09:37:45 -0700 (PDT)
Date: Wed, 29 Jul 2015 19:37:26 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm v9 0/8] idle memory tracking
Message-ID: <20150729163725.GZ8100@esperanza>
References: <cover.1437303956.git.vdavydov@parallels.com>
 <20150729123629.GI15801@dhcp22.suse.cz>
 <20150729135907.GT8100@esperanza>
 <20150729142618.GJ15801@dhcp22.suse.cz>
 <20150729152817.GV8100@esperanza>
 <CAJu=L59RdowYjTyVM0Vhz79A4d=d8=ZmU7PB59CmEj5B0_c48Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CAJu=L59RdowYjTyVM0Vhz79A4d=d8=ZmU7PB59CmEj5B0_c48Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andres Lagar-Cavilla <andreslc@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K
 T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 29, 2015 at 08:55:01AM -0700, Andres Lagar-Cavilla wrote:
> On Wed, Jul 29, 2015 at 8:28 AM, Vladimir Davydov
> <vdavydov@parallels.com> wrote:
> > On Wed, Jul 29, 2015 at 04:26:19PM +0200, Michal Hocko wrote:
> >> On Wed 29-07-15 16:59:07, Vladimir Davydov wrote:
> >> > On Wed, Jul 29, 2015 at 02:36:30PM +0200, Michal Hocko wrote:
> >> > > On Sun 19-07-15 15:31:09, Vladimir Davydov wrote:
> >> > > [...]
> >> > > > ---- USER API ----
> >> > > >
> >> > > > The user API consists of two new proc files:
> >> > >
> >> > > I was thinking about this for a while. I dislike the interface.  It is
> >> > > quite awkward to use - e.g. you have to read the full memory to check a
> >> > > single memcg idleness. This might turn out being a problem especially on
> >> > > large machines.
> >> >
> >> > Yes, with this API estimating the wss of a single memory cgroup will
> >> > cost almost as much as doing this for the whole system.
> >> >
> >> > Come to think of it, does anyone really need to estimate idleness of one
> >> > particular cgroup?
> 
> You can always adorn memcg with a boolean, trivially configurable from
> user-space, and have all the idle computation paths skip the code if
> memcg->dont_care_about_idle

Or we can filter out cgroups in which we're not interested using
/proc/kpagecgroup.

> 
> >>
> >> It is certainly interesting for setting the low limit.
> >
> 
> Valuable, IMHO
> 
> > Yes, but IMO there is no point in setting the low limit for one
> > particular cgroup w/o considering what's going on with the rest of the
> > system.
> >
> 
> Probably worth more fleshing out. Why not? Because global reclaim can
> execute in any given context, so a noisy neighbor hurts all?

The low limit does not necessarily mean, the cgroup will never get
pushed below it. It will, if others feel really bad.

Also, by setting the low limit too high, you can make others thrash
constantly, which will increase IO, which, in turn, might hurt the
workload you're trying to protect. Blkio cgroup might help in this case
though.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id DC1D46B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 13:54:14 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id p11-v6so17453260oih.17
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 10:54:14 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y9-v6si12559651oia.191.2018.08.13.10.54.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Aug 2018 10:54:13 -0700 (PDT)
Date: Mon, 13 Aug 2018 10:53:52 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [PATCH RFC 1/3] cgroup: list all subsystem states in debugfs
 files
Message-ID: <20180813175348.GA31962@castle.DHCP.thefacebook.com>
References: <153414348591.737150.14229960913953276515.stgit@buzz>
 <20180813134842.GF3978217@devbig004.ftw2.facebook.com>
 <20180813171119.GA24658@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180813171119.GA24658@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Tejun Heo <tj@kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Mon, Aug 13, 2018 at 01:11:19PM -0400, Johannes Weiner wrote:
> On Mon, Aug 13, 2018 at 06:48:42AM -0700, Tejun Heo wrote:
> > Hello, Konstantin.
> > 
> > On Mon, Aug 13, 2018 at 09:58:05AM +0300, Konstantin Khlebnikov wrote:
> > > After removing cgroup subsystem state could leak or live in background
> > > forever because it is pinned by some reference. For example memory cgroup
> > > could be pinned by pages in cache or tmpfs.
> > > 
> > > This patch adds common debugfs interface for listing basic state for each
> > > controller. Controller could define callback for dumping own attributes.
> > > 
> > > In file /sys/kernel/debug/cgroup/<controller> each line shows state in
> > > format: <common_attr>=<value>... [-- <controller_attr>=<value>... ]
> > 
> > Seems pretty useful to me.  Roman, Johannes, what do you guys think?

Totally agree with the idea and was about to suggest something similar.

> Generally I like the idea of having more introspection into offlined
> cgroups, but I wonder if having only memory= and swap= could be a
> little too terse to track down what exactly is pinning the groups.
> 
> Roman has more experience debugging these pileups, but it seems to me
> that unless we add a breakdown off memory, and maybe make slabinfo
> available for these groups, that in practice this might not provide
> that much more insight than per-cgroup stat counters of dead children.

I agree here.

It's hard to say in advance what numbers are useful, so let's export
these numbers, but also make the format more extendable, so we can
easily add new information later. Maybe, something like:

cgroup {
  path = ...
  ino = ...
  main css {
    refcnt = ...
    key = value
    ...
  }
  memcg css {
    refcnt = ...
    ...
  }
  some other controller css {
  }
  ...
}

Also, because we do batch charges, printing numbers without draining stocks
is not that useful. All stats are also per-cpu cached, what adds some
inaccuracy.

Thanks!

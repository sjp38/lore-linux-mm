Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id B8CAE6B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 13:11:22 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id z200-v6so22903650ywd.22
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 10:11:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y192-v6sor4157625ywd.135.2018.08.13.10.11.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 10:11:21 -0700 (PDT)
Date: Mon, 13 Aug 2018 13:11:19 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH RFC 1/3] cgroup: list all subsystem states in debugfs
 files
Message-ID: <20180813171119.GA24658@cmpxchg.org>
References: <153414348591.737150.14229960913953276515.stgit@buzz>
 <20180813134842.GF3978217@devbig004.ftw2.facebook.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180813134842.GF3978217@devbig004.ftw2.facebook.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Roman Gushchin <guro@fb.com>

On Mon, Aug 13, 2018 at 06:48:42AM -0700, Tejun Heo wrote:
> Hello, Konstantin.
> 
> On Mon, Aug 13, 2018 at 09:58:05AM +0300, Konstantin Khlebnikov wrote:
> > After removing cgroup subsystem state could leak or live in background
> > forever because it is pinned by some reference. For example memory cgroup
> > could be pinned by pages in cache or tmpfs.
> > 
> > This patch adds common debugfs interface for listing basic state for each
> > controller. Controller could define callback for dumping own attributes.
> > 
> > In file /sys/kernel/debug/cgroup/<controller> each line shows state in
> > format: <common_attr>=<value>... [-- <controller_attr>=<value>... ]
> 
> Seems pretty useful to me.  Roman, Johannes, what do you guys think?

Generally I like the idea of having more introspection into offlined
cgroups, but I wonder if having only memory= and swap= could be a
little too terse to track down what exactly is pinning the groups.

Roman has more experience debugging these pileups, but it seems to me
that unless we add a breakdown off memory, and maybe make slabinfo
available for these groups, that in practice this might not provide
that much more insight than per-cgroup stat counters of dead children.

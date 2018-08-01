Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3E6A76B0006
	for <linux-mm@kvack.org>; Wed,  1 Aug 2018 12:16:32 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id z24-v6so4417205lji.16
        for <linux-mm@kvack.org>; Wed, 01 Aug 2018 09:16:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f15-v6sor4096069ljj.73.2018.08.01.09.16.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 01 Aug 2018 09:16:30 -0700 (PDT)
Date: Wed, 1 Aug 2018 19:16:26 +0300
From: Vladimir Davydov <vdavydov.dev@gmail.com>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-ID: <20180801161626.j2575eru2x3lukfj@esperanza>
References: <20180413113855.GI17484@dhcp22.suse.cz>
 <8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
 <20180413115454.GL17484@dhcp22.suse.cz>
 <abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
 <20180413121433.GM17484@dhcp22.suse.cz>
 <20180413125101.GO17484@dhcp22.suse.cz>
 <20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
 <20180727193134.GA10996@cmpxchg.org>
 <20180729192621.py4znecoinw5mqcp@esperanza>
 <20180730153113.GB4567@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180730153113.GB4567@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jul 30, 2018 at 11:31:13AM -0400, Johannes Weiner wrote:
> On Sun, Jul 29, 2018 at 10:26:21PM +0300, Vladimir Davydov wrote:
> > On Fri, Jul 27, 2018 at 03:31:34PM -0400, Johannes Weiner wrote:
> > > That said, the lifetime of the root reference on the ID is the online
> > > state, we put that in css_offline. Is there a reason we need to have
> > > the ID ready and the memcg in the IDR before onlining it?
> > 
> > I fail to see any reason for this in the code.
> 
> Me neither, thanks for double checking.
> 
> The patch also survives stress testing cgroup creation and destruction
> with the script from 73f576c04b94 ("mm: memcontrol: fix cgroup
> creation failure after many small jobs").
> 
> > > Can we do something like this and not mess with the alloc/free
> > > sequence at all?
> > 
> > I guess so, and this definitely looks better to me.
> 
> Cool, then I think we should merge Kirill's patch as the fix and mine
> as a follow-up cleanup.
> 
> ---
> 
> From b4106ea1f163479da805eceada60c942bd66e524 Mon Sep 17 00:00:00 2001
> From: Johannes Weiner <hannes@cmpxchg.org>
> Date: Mon, 30 Jul 2018 11:03:55 -0400
> Subject: [PATCH] mm: memcontrol: simplify memcg idr allocation and error
>  unwinding
> 
> The memcg ID is allocated early in the multi-step memcg creation
> process, which needs 2-step ID allocation and IDR publishing, as well
> as two separate IDR cleanup/unwind sites on error.
> 
> Defer the IDR allocation until the last second during onlining to
> eliminate all this complexity. There is no requirement to have the ID
> and IDR entry earlier than that. And the root reference to the ID is
> put in the offline path, so this matches nicely.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Vladimir Davydov <vdavydov.dev@gmail.com>

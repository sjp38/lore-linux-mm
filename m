Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id F05F16B000E
	for <linux-mm@kvack.org>; Mon, 16 Jul 2018 07:08:48 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id y17-v6so8652810eds.22
        for <linux-mm@kvack.org>; Mon, 16 Jul 2018 04:08:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g24-v6si5042447edh.209.2018.07.16.04.08.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 Jul 2018 04:08:47 -0700 (PDT)
Date: Mon, 16 Jul 2018 13:08:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: avoid bothering interrupted task when charge memcg
 in softirq
Message-ID: <20180716110845.GK17280@dhcp22.suse.cz>
References: <1531557122-12540-1-git-send-email-laoar.shao@gmail.com>
 <20180716075836.GC17280@dhcp22.suse.cz>
 <CALOAHbD1+eYHDo5-q1--nsBTNj66ZX6iw2YU4koLgZD_0ZDy+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALOAHbD1+eYHDo5-q1--nsBTNj66ZX6iw2YU4koLgZD_0ZDy+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yafang Shao <laoar.shao@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon 16-07-18 17:45:06, Yafang Shao wrote:
> On Mon, Jul 16, 2018 at 3:58 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Sat 14-07-18 16:32:02, Yafang Shao wrote:
> >> try_charge maybe executed in packet receive path, which is in interrupt
> >> context.
> >> In this situation, the 'current' is the interrupted task, which may has
> >> no relation to the rx softirq, So it is nonsense to use 'current'.
> >>
> >> Avoid bothering the interrupted if page_counter_try_charge failes.
> >
> > I agree with Shakeel that this changelog asks for more information about
> > "why it matters". Small inconsistencies should be tolerable because the
> > state we rely on is so rarely set that it shouldn't make a visible
> > difference in practice.
> >
> 
> HI Michal,
> 
> No, it can make a visible difference in pratice.
> The difference is in __sk_mem_raise_allocated().
> 
> Without this patch, if the random interrupted task is oom victim or
> fatal signal pending or exiting, the charge will success anyway. That
> means the cgroup limit doesn't work in this situation.
> 
> With this patch, in the same situation the charged memory will be
> uncharged as it hits the memcg limit.
> 
> That is okay if the memcg of the interrupted task is same with the
> sk->sk_memcg,  but it may not okay if they are difference.
> 
> I'm trying to prove it, but seems it's very hard to produce this issue.

So it is possible that this is so marginal that it doesn't make any
_practical_ impact after all.

-- 
Michal Hocko
SUSE Labs

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id C994B6B0003
	for <linux-mm@kvack.org>; Sat, 26 May 2018 18:37:08 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 142-v6so5931297wmt.1
        for <linux-mm@kvack.org>; Sat, 26 May 2018 15:37:08 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z8-v6sor8286972wrl.38.2018.05.26.15.37.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 26 May 2018 15:37:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180526185144.xvh7ejlyelzvqwdb@esperanza>
References: <20180525185501.82098-1-shakeelb@google.com> <20180526185144.xvh7ejlyelzvqwdb@esperanza>
From: Shakeel Butt <shakeelb@google.com>
Date: Sat, 26 May 2018 15:37:05 -0700
Message-ID: <CALvZod5yTxcuB_Aao-a0ChNEnwyBJk9UPvEQ80s9tZFBQ0cxpw@mail.gmail.com>
Subject: Re: [PATCH] memcg: force charge kmem counter too
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Cgroups <cgroups@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Sat, May 26, 2018 at 11:51 AM, Vladimir Davydov
<vdavydov.dev@gmail.com> wrote:
> On Fri, May 25, 2018 at 11:55:01AM -0700, Shakeel Butt wrote:
>> Based on several conditions the kernel can decide to force charge an
>> allocation for a memcg i.e. overcharge memcg->memory and memcg->memsw
>> counters. Do the same for memcg->kmem counter too. In cgroup-v1, this
>> bug can cause a __GFP_NOFAIL kmem allocation fail if an explicit limit
>> on kmem counter is set and reached.
>
> memory.kmem.limit is broken and unlikely to ever be fixed as this knob
> was deprecated in cgroup-v2. The fact that hitting the limit doesn't
> trigger reclaim can result in unexpected behavior from user's pov, like
> getting ENOMEM while listing a directory. Bypassing the limit for NOFAIL
> allocations isn't going to fix those problem.

I understand that fixing NOFAIL will not fix all other issues but it
still is better than current situation. IMHO we should keep fixing
kmem bit by bit.

One crazy idea is to just break it completely by force charging all the time.

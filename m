Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A7F1E6B0005
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 06:38:50 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s6so6289592pgn.16
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 03:38:50 -0700 (PDT)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p11si9013023pfj.294.2018.04.23.03.38.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 Apr 2018 03:38:49 -0700 (PDT)
Date: Mon, 23 Apr 2018 11:38:10 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC PATCH 0/2] memory.low,min reclaim
Message-ID: <20180423103804.GA12648@castle.DHCP.thefacebook.com>
References: <20180320223353.5673-1-guro@fb.com>
 <20180422202612.127760-1-gthelen@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180422202612.127760-1-gthelen@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>, Cgroups <cgroups@vger.kernel.org>, kernel-team@fb.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi, Greg!

On Sun, Apr 22, 2018 at 01:26:10PM -0700, Greg Thelen wrote:
> Roman's previously posted memory.low,min patches add per memcg effective
> low limit to detect overcommitment of parental limits.  But if we flip
> low,min reclaim to bail if usage<{low,min} at any level, then we don't need
> an effective low limit, which makes the code simpler.  When parent limits
> are overcommited memory.min will oom kill, which is more drastic but makes
> the memory.low a simpler concept.  If memcg a/b wants oom kill before
> reclaim, then give it to them.  It seems a bit strange for a/b/memory.low's
> behaviour to depend on a/c/memory.low (i.e. a/b.low is strong unless
> a/b.low+a/c.low exceed a.low).

It's actually not strange: a/b and a/c are sharing a common resource:
a/memory.low.

Exactly as a/b/memory.max and a/c/memory.max are sharing a/memory.max.
If there are sibling cgroups which are consuming memory, a cgroup can't
exceed parent's memory.max, even if its memory.max is grater.

> 
> I think there might be a simpler way (ableit it doesn't yet include
> Documentation):
> - memcg: fix memory.low
> - memcg: add memory.min
>  3 files changed, 75 insertions(+), 6 deletions(-)
> 
> The idea of this alternate approach is for memory.low,min to avoid reclaim
> if any portion of under-consideration memcg ancestry is under respective
> limit.

This approach has a significant downside: it breaks hierarchical constraints
for memory.low/min. There are two important outcomes:

1) Any leaf's memory.low/min value is respected, even if parent's value
   is lower or even 0. It's not possible anymore to limit the amount of
   protected memory for a sub-tree.
   This is especially bad in case of delegation.

2) If a cgroup has an ancestor with the usage under its memory.low/min,
   it becomes protection, even if its memory.low/min is 0. So it becomes
   impossible to have unprotected cgroups in protected sub-tree.

Thanks!

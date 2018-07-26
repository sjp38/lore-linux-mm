Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 902596B000C
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 04:19:50 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id c2-v6so494436edi.20
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 01:19:50 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m13-v6si837089edd.103.2018.07.26.01.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 01:19:49 -0700 (PDT)
Date: Thu, 26 Jul 2018 10:19:47 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Showing /sys/fs/cgroup/memory/memory.stat very slow on some
 machines
Message-ID: <20180726081947.GA28386@dhcp22.suse.cz>
References: <CAOm-9arwY3VLUx5189JAR9J7B=Miad9nQjjet_VNdT3i+J+5FA@mail.gmail.com>
 <20180717212307.d6803a3b0bbfeb32479c1e26@linux-foundation.org>
 <20180718104230.GC1431@dhcp22.suse.cz>
 <CAOm-9aqeKZ7+Jvhc5DxEEzbk4T0iQx8gZ=O1vy6YXnbOkncFsg@mail.gmail.com>
 <CALvZod7_vPwqyLBxiecZtREEeY4hioCGnZWVhQx9wVdM8CFcog@mail.gmail.com>
 <CAOm-9aprLokqi6awMvi0NbkriZBpmvnBA81QhOoHnK7ZEA96fw@mail.gmail.com>
 <CALvZod4ag02N6QPwRQCYv663hj05Z6vtrK8=XEE6uWHQCL4yRw@mail.gmail.com>
 <CAOm-9arxtTwNxXzmb8nN+N_UtjiuH0XkpkVPFHpi3EOYXvZYVA@mail.gmail.com>
 <dda7b095-db84-7e69-a03e-d8ce64fc9b8e@gmail.com>
 <CAOm-9ar2zzxZvZ9A0Yu0knn_LNcHsck72wXShFXutYvAN2qu9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOm-9ar2zzxZvZ9A0Yu0knn_LNcHsck72wXShFXutYvAN2qu9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bruce Merry <bmerry@ska.ac.za>
Cc: "Singh, Balbir" <bsingharora@gmail.com>, Shakeel Butt <shakeelb@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>

On Thu 26-07-18 08:41:35, Bruce Merry wrote:
> On 26 July 2018 at 02:55, Singh, Balbir <bsingharora@gmail.com> wrote:
> > Do you by any chance have use_hierarch=1? memcg_stat_show should just rely on counters inside the memory cgroup and the the LRU sizes for each node.
> 
> Yes, /sys/fs/cgroup/memory/memory.use_hierarchy is 1. I assume systemd
> is doing that.

And this is actually good. Non hierarchical behavior is discouraged.
The real problem is that we are keeping way too many zombie memcgs
around and waiting for memory pressure to reclaim them and so they go
away on their own.

As I've tried to explain in other email force_empty before removing the
memcg should help.

Fixing this properly would require quite some heavy lifting AFAICS. We
would basically have to move zombies out of the way which is not hard
but we do not want to hide their current memory consumption so we would
have to somehow move their stats to the parent. And then we are back to
reparenting which has been removed by b2052564e66d ("mm: memcontrol:
continue cache reclaim from offlined groups").
-- 
Michal Hocko
SUSE Labs

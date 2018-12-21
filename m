Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3CEC28E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:02:20 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id s70so6683407qks.4
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 11:02:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 12sor11916988qtx.51.2018.12.21.11.02.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 11:02:12 -0800 (PST)
Date: Fri, 21 Dec 2018 14:02:10 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: OOM notification for cgroupsv1 broken in 4.19
Message-ID: <20181221190210.GB5395@cmpxchg.org>
References: <5ba5ba06-554c-d1ec-0967-b1d3486d0699@fnal.gov>
 <20181221153302.GB6410@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181221153302.GB6410@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Burt Holzman <burt@fnal.gov>, "vdavydov.dev@gmail.com" <vdavydov.dev@gmail.com>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Dec 21, 2018 at 04:33:02PM +0100, Michal Hocko wrote:
> From 51633f683173013741f4d0ab3e31bae575341c55 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 21 Dec 2018 16:28:29 +0100
> Subject: [PATCH] memcg, oom: notify on oom killer invocation from the charge
>  path
> 
> Burt Holzman has noticed that memcg v1 doesn't notify about OOM events
> via eventfd anymore. The reason is that 29ef680ae7c2 ("memcg, oom: move
> out_of_memory back to the charge path") has moved the oom handling back
> to the charge path. While doing so the notification was left behind in
> mem_cgroup_oom_synchronize.
> 
> Fix the issue by replicating the oom hierarchy locking and the
> notification.
> 
> Reported-by: Burt Holzman <burt@fnal.gov>
> Fixes: 29ef680ae7c2 ("memcg, oom: move out_of_memory back to the charge path")
> Cc: stable # 4.19+
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Looks good to me. The async side really does too much other stuff to
cleanly share code between them, so I don't mind separate code even if
it means they both have to do the mark, lock, notify dance.

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

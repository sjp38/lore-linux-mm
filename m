Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8403C6B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:29:26 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g12-v6so7925668ioc.3
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 10:29:26 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id a188-v6si1809391ite.53.2018.04.20.10.29.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 10:29:25 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm: introduce memory.min
References: <20180420163632.3978-1-guro@fb.com>
 <527af98a-8d7f-42ab-9ba8-71444ef7e25f@infradead.org>
 <20180420172039.GA4965@castle.DHCP.thefacebook.com>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <e1ffe28c-841f-1714-7460-d2a6d309176c@infradead.org>
Date: Fri, 20 Apr 2018 10:29:13 -0700
MIME-Version: 1.0
In-Reply-To: <20180420172039.GA4965@castle.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, kernel-team@fb.com, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Tejun Heo <tj@kernel.org>

On 04/20/18 10:20, Roman Gushchin wrote:
> 
> Hi, Randy!
> 
> An updated version below.
> 
> Thanks!

OK, looks good now. Thanks.

FWIW:
Reviewed-by: Randy Dunlap <rdunlap@infradead.org> # for Documentation/ only.

> ------------------------------------------------------------
> 
> 
> From 2225fa0b3400431dd803f206b20a9344f0dfcd0a Mon Sep 17 00:00:00 2001
> From: Roman Gushchin <guro@fb.com>
> Date: Fri, 20 Apr 2018 15:24:44 +0100
> Subject: [PATCH 1/2] mm: introduce memory.min
> 
> Memory controller implements the memory.low best-effort memory
> protection mechanism, which works perfectly in many cases and
> allows protecting working sets of important workloads from
> sudden reclaim.
> 
> But it's semantics has a significant limitation: it works
> only until there is a supply of reclaimable memory.
> This makes it pretty useless against any sort of slow memory
> leaks or memory usage increases. This is especially true
> for swapless systems. If swap is enabled, memory soft protection
> effectively postpones problems, allowing a leaking application
> to fill all swap area, which makes no sense.
> The only effective way to guarantee the memory protection
> in this case is to invoke the OOM killer.
> 
> This patch introduces the memory.min interface for cgroup v2
> memory controller. It works very similarly to memory.low
> (sharing the same hierarchical behavior), except that it's
> not disabled if there is no more reclaimable memory in the system.
> 
> Signed-off-by: Roman Gushchin <guro@fb.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> Cc: Tejun Heo <tj@kernel.org>
> ---
>  Documentation/cgroup-v2.txt  | 24 ++++++++++-
>  include/linux/memcontrol.h   | 15 ++++++-
>  include/linux/page_counter.h | 11 ++++-
>  mm/memcontrol.c              | 99 ++++++++++++++++++++++++++++++++++++--------
>  mm/page_counter.c            | 63 ++++++++++++++++++++--------
>  mm/vmscan.c                  | 19 ++++++++-
>  6 files changed, 191 insertions(+), 40 deletions(-)
> 
> diff --git a/Documentation/cgroup-v2.txt b/Documentation/cgroup-v2.txt
> index 657fe1769c75..a413118b9c29 100644
> --- a/Documentation/cgroup-v2.txt
> +++ b/Documentation/cgroup-v2.txt
> @@ -1002,6 +1002,26 @@ PAGE_SIZE multiple when read back.
>  	The total amount of memory currently being used by the cgroup
>  	and its descendants.
>  
> +  memory.min
> +	A read-write single value file which exists on non-root
> +	cgroups.  The default is "0".
> +
> +	Hard memory protection.  If the memory usage of a cgroup
> +	is within its effective min boundary, the cgroup's memory
> +	won't be reclaimed under any conditions. If there is no
> +	unprotected reclaimable memory available, OOM killer
> +	is invoked.
> +
> +	Effective low boundary is limited by memory.min values of
> +	all ancestor cgroups. If there is memory.min overcommitment
> +	(child cgroup or cgroups are requiring more protected memory
> +	than parent will allow), then each child cgroup will get
> +	the part of parent's protection proportional to its
> +	actual memory usage below memory.min.
> +
> +	Putting more memory than generally available under this
> +	protection is discouraged and may lead to constant OOMs.
> +
>    memory.low
>  	A read-write single value file which exists on non-root
>  	cgroups.  The default is "0".
> @@ -1013,9 +1033,9 @@ PAGE_SIZE multiple when read back.
>  
>  	Effective low boundary is limited by memory.low values of
>  	all ancestor cgroups. If there is memory.low overcommitment
> -	(child cgroup or cgroups are requiring more protected memory,
> +	(child cgroup or cgroups are requiring more protected memory
>  	than parent will allow), then each child cgroup will get
> -	the part of parent's protection proportional to the its
> +	the part of parent's protection proportional to its
>  	actual memory usage below memory.low.
>  
>  	Putting more memory than generally available under this



-- 
~Randy

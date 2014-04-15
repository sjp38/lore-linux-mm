Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f54.google.com (mail-ee0-f54.google.com [74.125.83.54])
	by kanga.kvack.org (Postfix) with ESMTP id CD1B76B0031
	for <linux-mm@kvack.org>; Mon, 14 Apr 2014 21:52:37 -0400 (EDT)
Received: by mail-ee0-f54.google.com with SMTP id d49so7176288eek.13
        for <linux-mm@kvack.org>; Mon, 14 Apr 2014 18:52:37 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id m49si23237187eeo.281.2014.04.14.18.52.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 14 Apr 2014 18:52:36 -0700 (PDT)
Date: Mon, 14 Apr 2014 21:52:24 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm/memcontrol.c: make mem_cgroup_read_stat() read all
 interested stat item in one go
Message-ID: <20140415015224.GB7969@cmpxchg.org>
References: <1397149868-30401-1-git-send-email-nasa4836@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1397149868-30401-1-git-send-email-nasa4836@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>
Cc: mhocko@suse.cz, bsingharora@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Jianyu,

On Fri, Apr 11, 2014 at 01:11:08AM +0800, Jianyu Zhan wrote:
> Currently, mem_cgroup_read_stat() is used for user interface. The
> user accounts memory usage by memory cgroup and he _always_ requires
> exact value because he accounts memory. So we don't use quick-and-fuzzy
> -read-and-do-periodic-synchronization way. Thus, we iterate all cpus
> for one read.
> 
> And we mem_cgroup_usage() and mem_cgroup_recursive_stat() both finally
> call into mem_cgroup_read_stat().
> 
> However, these *stat snapshot* operations are implemented in a quite
> coarse way: it takes M*N iteration for each stat item(M=nr_memcgs,
> N=nr_possible_cpus). There are two deficiencies:
> 
> 1. for every stat item, we have to iterate over all percpu value, which
>    is not so cache friendly.
> 2. for every stat item, we call mem_cgroup_read_stat() once, which
>    increase the probablity of contending on pcp_counter_lock.
> 
> So, this patch improve this a bit. Concretely, for all interested stat
> items, mark them in a bitmap, and then make mem_cgroup_read_stat() read
> them all in one go.
> 
> This is more efficient, and to some degree make it more like *stat snapshot*.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>
> ---
>  mm/memcontrol.c | 91 +++++++++++++++++++++++++++++++++++++++------------------
>  1 file changed, 62 insertions(+), 29 deletions(-)

This is when the user reads statistics or when OOM happens, neither of
which I would consider fast paths.  I don't think it's worth the extra
code, which looks more cumbersome than what we have.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f200.google.com (mail-lb0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id D051A6B0253
	for <linux-mm@kvack.org>; Mon, 20 Jun 2016 02:15:00 -0400 (EDT)
Received: by mail-lb0-f200.google.com with SMTP id c1so22837518lbw.0
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 23:15:00 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com. [74.125.82.41])
        by mx.google.com with ESMTPS id 8si13902299wmu.80.2016.06.19.23.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Jun 2016 23:14:59 -0700 (PDT)
Received: by mail-wm0-f41.google.com with SMTP id a66so62853288wme.0
        for <linux-mm@kvack.org>; Sun, 19 Jun 2016 23:14:59 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: memcontrol: fix cgroup creation failure after
 many small jobs
References: <20160616034244.14839-1-hannes@cmpxchg.org>
 <20160616200617.GD3262@mtj.duckdns.org> <20160617162310.GA19084@cmpxchg.org>
 <20160617162516.GD19084@cmpxchg.org>
From: Nikolay Borisov <kernel@kyup.com>
Message-ID: <576789E0.6000302@kyup.com>
Date: Mon, 20 Jun 2016 09:14:56 +0300
MIME-Version: 1.0
In-Reply-To: <20160617162516.GD19084@cmpxchg.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, Li Zefan <lizefan@huawei.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com



On 06/17/2016 07:25 PM, Johannes Weiner wrote:
> The memory controller has quite a bit of state that usually outlives
> the cgroup and pins its CSS until said state disappears. At the same
> time it imposes a 16-bit limit on the CSS ID space to economically
> store IDs in the wild. Consequently, when we use cgroups to contain
> frequent but small and short-lived jobs that leave behind some page
> cache, we quickly run into the 64k limitations of outstanding CSSs.
> Creating a new cgroup fails with -ENOSPC while there are only a few,
> or even no user-visible cgroups in existence.
> 
> Although pinning CSSs past cgroup removal is common, there are only
> two instances that actually need an ID after a cgroup is deleted:
> cache shadow entries and swapout records.
> 
> Cache shadow entries reference the ID weakly and can deal with the CSS
> having disappeared when it's looked up later. They pose no hurdle.
> 
> Swap-out records do need to pin the css to hierarchically attribute
> swapins after the cgroup has been deleted; though the only pages that
> remain swapped out after offlining are tmpfs/shmem pages. And those
> references are under the user's control, so they are manageable.
> 
> This patch introduces a private 16-bit memcg ID and switches swap and
> cache shadow entries over to using that. This ID can then be recycled
> after offlining when the CSS remains pinned only by objects that don't
> specifically need it.
> 
> This script demonstrates the problem by faulting one cache page in a
> new cgroup and deleting it again:
> 
> set -e
> mkdir -p pages
> for x in `seq 128000`; do
>   [ $((x % 1000)) -eq 0 ] && echo $x
>   mkdir /cgroup/foo
>   echo $$ >/cgroup/foo/cgroup.procs
>   echo trex >pages/$x
>   echo $$ >/cgroup/cgroup.procs
>   rmdir /cgroup/foo
> done

Perhaps you could send this script to the LTP project to have this as a
regression test?

> 
> When run on an unpatched kernel, we eventually run out of possible IDs
> even though there are no visible cgroups:
> 
> [root@ham ~]# ./cssidstress.sh
> [...]
> 65000
> mkdir: cannot create directory '/cgroup/foo': No space left on device
> 
> After this patch, the IDs get released upon cgroup destruction and the
> cache and css objects get released once memory reclaim kicks in.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

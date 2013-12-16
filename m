Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id E62686B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 04:36:41 -0500 (EST)
Received: by mail-pa0-f43.google.com with SMTP id bj1so2712282pad.2
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 01:36:41 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id g5si8338556pav.346.2013.12.16.01.36.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 01:36:40 -0800 (PST)
Message-ID: <52AEC989.4080509@huawei.com>
Date: Mon, 16 Dec 2013 17:36:09 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: 3.13-rc breaks MEMCG_SWAP
References: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
In-Reply-To: <alpine.LNX.2.00.1312160025200.2785@eggly.anvils>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On 2013/12/16 16:36, Hugh Dickins wrote:
> CONFIG_MEMCG_SWAP is broken in 3.13-rc.  Try something like this:
> 
> mkdir -p /tmp/tmpfs /tmp/memcg
> mount -t tmpfs -o size=1G tmpfs /tmp/tmpfs
> mount -t cgroup -o memory memcg /tmp/memcg
> mkdir /tmp/memcg/old
> echo 512M >/tmp/memcg/old/memory.limit_in_bytes
> echo $$ >/tmp/memcg/old/tasks
> cp /dev/zero /tmp/tmpfs/zero 2>/dev/null
> echo $$ >/tmp/memcg/tasks
> rmdir /tmp/memcg/old
> sleep 1	# let rmdir work complete
> mkdir /tmp/memcg/new
> umount /tmp/tmpfs
> dmesg | grep WARNING
> rmdir /tmp/memcg/new
> umount /tmp/memcg
> 
> Shows lots of WARNING: CPU: 1 PID: 1006 at kernel/res_counter.c:91
>                            res_counter_uncharge_locked+0x1f/0x2f()
> 
> Breakage comes from 34c00c319ce7 ("memcg: convert to use cgroup id").
> 
> The lifetime of a cgroup id is different from the lifetime of the
> css id it replaced: memsw's css_get()s do nothing to hold on to the
> old cgroup id, it soon gets recycled to a new cgroup, which then
> mysteriously inherits the old's swap, without any charge for it.
> (I thought memsw's particular need had been discussed and was
> well understood when 34c00c319ce7 went in, but apparently not.)
> 
> The right thing to do at this stage would be to revert that and its
> associated commits; but I imagine to do so would be unwelcome to
> the cgroup guys, going against their general direction; and I've
> no idea how embedded that css_id removal has become by now.
> 
> Perhaps some creative refcounting can rescue memsw while still
> using cgroup id?
> 

Sorry for the broken.

I think we can keep the cgroup->id until the last css reference is
dropped and the css is scheduled to be destroyed.

I'll cook a fix tomorrow.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

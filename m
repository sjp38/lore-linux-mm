Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 5ED406B0072
	for <linux-mm@kvack.org>; Thu, 29 Nov 2012 09:36:56 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so6870194pad.14
        for <linux-mm@kvack.org>; Thu, 29 Nov 2012 06:36:55 -0800 (PST)
Date: Thu, 29 Nov 2012 06:36:50 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET cgroup/for-3.8] cpuset: decouple cpuset locking from
 cgroup core
Message-ID: <20121129143650.GE24683@htj.dyndns.org>
References: <1354138460-19286-1-git-send-email-tj@kernel.org>
 <50B743A1.4040405@parallels.com>
 <20121129142646.GD24683@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121129142646.GD24683@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: lizefan@huawei.com, paul@paulmenage.org, containers@lists.linux-foundation.org, cgroups@vger.kernel.org, peterz@infradead.org, mhocko@suse.cz, bsingharora@gmail.com, hannes@cmpxchg.org, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Nov 29, 2012 at 06:26:46AM -0800, Tejun Heo wrote:
> > What I'll try to do, is to come with another specialized lock in cgroup
> > just for this case. So after taking the cgroup lock, we would also take
> > an extra lock if we are adding another entry - be it task or children -
> > to the cgroup.
> 
> No, please don't do that.  Just don't invoke cgroup operation inside
> any subsystem lock.

To add a bit, you won't be solving any problem by adding more locks
here.  cpuset wants to initiate task cgroup migration.  It doesn't
matter how many locks cgroup uses internally.  You'll have to grab
them all anyway to do that.  It's not a problem caused by granularity
of cgroup_lock at all, so there just isn't any logic in dividing locks
for this.  So, again, please don't go that direction.  What we need to
do is isolating subsystem locking and implementation from cgroup
internals, not complicating cgroup internals even more, and now we
have good enoug API to achieve such isolation.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

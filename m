Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E34F26B0032
	for <linux-mm@kvack.org>; Wed, 21 Jan 2015 11:40:16 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id fl12so17790717pdb.6
        for <linux-mm@kvack.org>; Wed, 21 Jan 2015 08:40:16 -0800 (PST)
Received: from foss-mx-na.foss.arm.com (foss-mx-na.foss.arm.com. [217.140.108.86])
        by mx.google.com with ESMTP id nq15si4287798pdb.212.2015.01.21.08.40.14
        for <linux-mm@kvack.org>;
        Wed, 21 Jan 2015 08:40:15 -0800 (PST)
Date: Wed, 21 Jan 2015 16:39:55 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150121163955.GM4549@arm.com>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <54BCFDCF.9090603@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <54BCFDCF.9090603@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Cc: Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Mon, Jan 19, 2015 at 12:51:27PM +0000, Suzuki K. Poulose wrote:
> On 10/01/15 08:55, Vladimir Davydov wrote:
> > The problem is that the memory cgroup controller takes a css reference
> > per each charged page and does not reparent charged pages on css
> > offline, while cgroup_mount/cgroup_kill_sb expect all css references to
> > offline cgroups to be gone soon, restarting the syscall if the ref count
> > != 0. As a result, if you create a memory cgroup, charge some page cache
> > to it, and then remove it, unmount/mount will hang forever.
> >
> > May be, we should kill the ref counter to the memory controller root in
> > cgroup_kill_sb only if there is no children at all, neither online nor
> > offline.
> >
> 
> Still reproducible on 3.19-rc5 with the same setup.

Yeah, I'm seeing the same failure on my setup too.

> From git bisect, the last good commit is :
> 
> commit 8df0c2dcf61781d2efa8e6e5b06870f6c6785735
> Author: Pranith Kumar <bobby.prani@gmail.com>
> Date:   Wed Dec 10 15:42:28 2014 -0800
> 
>      slab: replace smp_read_barrier_depends() with lockless_dereference()

So that points at 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
as the offending commit.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

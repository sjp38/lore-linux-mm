Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id C5A6C6B0032
	for <linux-mm@kvack.org>; Thu, 22 Jan 2015 08:46:06 -0500 (EST)
Received: by mail-wg0-f50.google.com with SMTP id b13so1792570wgh.9
        for <linux-mm@kvack.org>; Thu, 22 Jan 2015 05:46:06 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id bt4si10019787wib.2.2015.01.22.05.46.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jan 2015 05:46:03 -0800 (PST)
Date: Thu, 22 Jan 2015 08:45:50 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [Regression] 3.19-rc3 : memcg: Hang in mount memcg
Message-ID: <20150122134550.GA13876@phnom.home.cmpxchg.org>
References: <54B01335.4060901@arm.com>
 <20150110085525.GD2110@esperanza>
 <54BCFDCF.9090603@arm.com>
 <20150121163955.GM4549@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150121163955.GM4549@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>, Vladimir Davydov <vdavydov@parallels.com>, Tejun Heo <tj@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mhocko@suse.cz" <mhocko@suse.cz>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>

On Wed, Jan 21, 2015 at 04:39:55PM +0000, Will Deacon wrote:
> On Mon, Jan 19, 2015 at 12:51:27PM +0000, Suzuki K. Poulose wrote:
> > On 10/01/15 08:55, Vladimir Davydov wrote:
> > > The problem is that the memory cgroup controller takes a css reference
> > > per each charged page and does not reparent charged pages on css
> > > offline, while cgroup_mount/cgroup_kill_sb expect all css references to
> > > offline cgroups to be gone soon, restarting the syscall if the ref count
> > > != 0. As a result, if you create a memory cgroup, charge some page cache
> > > to it, and then remove it, unmount/mount will hang forever.
> > >
> > > May be, we should kill the ref counter to the memory controller root in
> > > cgroup_kill_sb only if there is no children at all, neither online nor
> > > offline.
> > >
> > 
> > Still reproducible on 3.19-rc5 with the same setup.
> 
> Yeah, I'm seeing the same failure on my setup too.
> 
> > From git bisect, the last good commit is :
> > 
> > commit 8df0c2dcf61781d2efa8e6e5b06870f6c6785735
> > Author: Pranith Kumar <bobby.prani@gmail.com>
> > Date:   Wed Dec 10 15:42:28 2014 -0800
> > 
> >      slab: replace smp_read_barrier_depends() with lockless_dereference()
> 
> So that points at 3e32cb2e0a12 ("mm: memcontrol: lockless page counters")
> as the offending commit.

With b2052564e66d ("mm: memcontrol: continue cache reclaim from
offlined groups"), page cache can pin an old css and its ancestors
indefinitely, making that hang in a second mount() very likely.

However, swap entries have also been doing that for quite a while now,
and as Vladimir pointed out, the same is true for kernel memory.  This
latest change just makes this existing bug easier to trigger.

I think we have to update the lifetime rules to reflect reality here:
memory and swap lifetime is indefinite, so once the memory controller
is used, it has state that is independent from whether its mounted or
not.  We can support an identical remount, but have to fail mounting
with new parameters that would change the behavior of the controller.

Suzuki, Will, could you give the following patch a shot?

Tejun, would that route be acceptable to you?

Thanks

---

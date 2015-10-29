Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 246C082F64
	for <linux-mm@kvack.org>; Thu, 29 Oct 2015 11:25:49 -0400 (EDT)
Received: by wmll128 with SMTP id l128so26887105wml.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:25:48 -0700 (PDT)
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com. [74.125.82.45])
        by mx.google.com with ESMTPS id r140si12016423wmd.52.2015.10.29.08.25.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Oct 2015 08:25:47 -0700 (PDT)
Received: by wmeg8 with SMTP id g8so26338342wme.0
        for <linux-mm@kvack.org>; Thu, 29 Oct 2015 08:25:47 -0700 (PDT)
Date: Thu, 29 Oct 2015 16:25:46 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151029152546.GG23598@dhcp22.suse.cz>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027164227.GB7749@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue 27-10-15 09:42:27, Johannes Weiner wrote:
> On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
> > On Tue 27-10-15 11:41:38, Johannes Weiner wrote:
[...]
> Or it could be exactly the other way around when you have a workload
> that is heavy on filesystem metadata. I don't see why any scenario
> would be more important than the other.

Yes I definitely agree. No scenario is more important. We can only
come up with a default that makes more sense for the majority and
allow the minority to override. That was what I wanted to say basically.

> I'm not saying that distinguishing between consumers is wrong, just
> that "user memory vs kernel memory" is a false classification. Why do
> you call page cache user memory but dentry cache kernel memory? It
> doesn't make any sense.

We are not talking about dcache vs. page cache alone here, though. We
are talking about _all_ slab allocations vs. only user accessed memory.
The slab consumption is directly under kernel control. A great pile of
this logic is completly hidden from userspace. While user can estimate
the user memory it is hard (if possible) to do that for the kernel
memory footprint - not even mentioning this is variable and dependent on
the particular kernel version.

> > Also kmem accounting will make the load more non-deterministic because
> > many of the resources are shared between tasks in separate cgroups
> > unless they are explicitly configured. E.g. [id]cache will be shared
> > and first to touch gets charged so you would end up with more false
> > sharing.
> 
> Exactly like page cache. This differentiation isn't based on reality.

Yes false sharing is an existing and long term problem already. I just
wanted to point out that the false sharing would be even a bigger
problem because some kernel tracked resources are shared more naturally
than file sharing.

> > > IMO that's an implementation detail and a historical artifact that
> > > should not be exposed to the user. And that's the thing I hate about
> > > the current opt-out knob.
> 
> You carefully skipped over this part. We can ignore it for socket
> memory but it's something we need to figure out when it comes to slab
> accounting and tracking.

I am sorry, I didn't mean to skip this part, I though it would be clear
from the previous text. I think kmem accounting falls into the same
category. Have a sane default and a global boottime knob to override it
for those that think differently - for whatever reason they might have.

[...]
 
> Having page cache accounting built in while presenting dentry+inode
> cache as a configurable extension is completely random and doesn't
> make sense. They are both first class memory consumers. They're not
> separate categories. One isn't more "core" than the other.

Again we are talking about all slab allocations not just the dcache. 

> > > For now, something like this as a boot commandline?
> > > 
> > > cgroup.memory=nosocket
> > 
> > That would work for me.
> 
> Okay, then I'll go that route for the socket stuff.

Thanks!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

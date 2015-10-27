Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1400382F64
	for <linux-mm@kvack.org>; Tue, 27 Oct 2015 12:42:40 -0400 (EDT)
Received: by wicll6 with SMTP id ll6so168174966wic.0
        for <linux-mm@kvack.org>; Tue, 27 Oct 2015 09:42:39 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id my2si322020wic.29.2015.10.27.09.42.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Oct 2015 09:42:38 -0700 (PDT)
Date: Tue, 27 Oct 2015 09:42:27 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151027164227.GB7749@cmpxchg.org>
References: <1445487696-21545-1-git-send-email-hannes@cmpxchg.org>
 <1445487696-21545-6-git-send-email-hannes@cmpxchg.org>
 <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151027161554.GJ9891@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Tue, Oct 27, 2015 at 05:15:54PM +0100, Michal Hocko wrote:
> On Tue 27-10-15 11:41:38, Johannes Weiner wrote:
> > On Tue, Oct 27, 2015 at 01:26:47PM +0100, Michal Hocko wrote:
> > > On Mon 26-10-15 12:56:19, Johannes Weiner wrote:
> > > [...]
> > > > Now you could argue that there might exist specialized workloads that
> > > > need to account anonymous pages and page cache, but not socket memory
> > > > buffers.
> > > 
> > > Exactly, and there are loads doing this. Memcg groups are also created to
> > > limit anon/page cache consumers to not affect the others running on
> > > the system (basically in the root memcg context from memcg POV) which
> > > don't care about tracking and they definitely do not want to pay for an
> > > additional overhead. We should definitely be able to offer a global
> > > disable knob for them. The same applies to kmem accounting in general.
> > 
> > I don't see how you make such a clear distinction between, say, page
> > cache and the dentry cache, and call one user memory and the other
> > kernel memory.
> 
> Because the kernel memory footprint would be so small that it simply
> doesn't change the picture at all. While the page cache or anonymous
> memory consumption might be so large it might be disruptive.

Or it could be exactly the other way around when you have a workload
that is heavy on filesystem metadata. I don't see why any scenario
would be more important than the other.

I'm not saying that distinguishing between consumers is wrong, just
that "user memory vs kernel memory" is a false classification. Why do
you call page cache user memory but dentry cache kernel memory? It
doesn't make any sense.

> Also kmem accounting will make the load more non-deterministic because
> many of the resources are shared between tasks in separate cgroups
> unless they are explicitly configured. E.g. [id]cache will be shared
> and first to touch gets charged so you would end up with more false
> sharing.

Exactly like page cache. This differentiation isn't based on reality.

> Nevertheless, I do not want to shift the discussion from the topic. I
> just think that one-fits-all simply won't work.

Okay, this is something we can converge on.

> > That just doesn't make sense to me. They're both kernel
> > memory allocated on behalf of the user, the only difference being that
> > one is tracked on the page level and the other on the slab level, and
> > we started accounting one before the other.
> > 
> > IMO that's an implementation detail and a historical artifact that
> > should not be exposed to the user. And that's the thing I hate about
> > the current opt-out knob.

You carefully skipped over this part. We can ignore it for socket
memory but it's something we need to figure out when it comes to slab
accounting and tracking.

> > > > I don't think there is a compelling case for an elaborate interface
> > > > to make individual memory consumers configurable inside the memory
> > > > controller.
> > > 
> > > I do not think we need an elaborate interface. We just want to have
> > > a global boot time knob to overwrite the default behavior. This is
> > > few lines of code and it should give the sufficient flexibility.
> > 
> > Okay, then let's add this for the socket memory to start with. I'll
> > have to think more about how to distinguish the slab-based consumers.
> > Or maybe you have an idea.
> 
> Isn't that as simple as enabling the jump label during the
> initialization depending on the knob value? All the charging paths
> should be disabled by default already.

You missed my point. It's not about the implementation, it's about how
we present these choices to the user.

Having page cache accounting built in while presenting dentry+inode
cache as a configurable extension is completely random and doesn't
make sense. They are both first class memory consumers. They're not
separate categories. One isn't more "core" than the other.

> > For now, something like this as a boot commandline?
> > 
> > cgroup.memory=nosocket
> 
> That would work for me.

Okay, then I'll go that route for the socket stuff.

Dave is that cool with you?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

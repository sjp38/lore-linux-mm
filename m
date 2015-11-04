Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6865682F6A
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 14:50:53 -0500 (EST)
Received: by wicll6 with SMTP id ll6so38964972wic.1
        for <linux-mm@kvack.org>; Wed, 04 Nov 2015 11:50:52 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id l13si5405429wmg.29.2015.11.04.11.50.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Nov 2015 11:50:52 -0800 (PST)
Date: Wed, 4 Nov 2015 14:50:37 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 5/8] mm: memcontrol: account socket memory on unified
 hierarchy
Message-ID: <20151104195037.GA6872@cmpxchg.org>
References: <20151023131956.GA15375@dhcp22.suse.cz>
 <20151023.065957.1690815054807881760.davem@davemloft.net>
 <20151026165619.GB2214@cmpxchg.org>
 <20151027122647.GG9891@dhcp22.suse.cz>
 <20151027154138.GA4665@cmpxchg.org>
 <20151027161554.GJ9891@dhcp22.suse.cz>
 <20151027164227.GB7749@cmpxchg.org>
 <20151029152546.GG23598@dhcp22.suse.cz>
 <20151029161009.GA9160@cmpxchg.org>
 <20151104104239.GG29607@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151104104239.GG29607@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org, vdavydov@virtuozzo.com, tj@kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Nov 04, 2015 at 11:42:40AM +0100, Michal Hocko wrote:
> On Thu 29-10-15 09:10:09, Johannes Weiner wrote:
> > On Thu, Oct 29, 2015 at 04:25:46PM +0100, Michal Hocko wrote:
> > > On Tue 27-10-15 09:42:27, Johannes Weiner wrote:
> [...]
> > > > You carefully skipped over this part. We can ignore it for socket
> > > > memory but it's something we need to figure out when it comes to slab
> > > > accounting and tracking.
> > > 
> > > I am sorry, I didn't mean to skip this part, I though it would be clear
> > > from the previous text. I think kmem accounting falls into the same
> > > category. Have a sane default and a global boottime knob to override it
> > > for those that think differently - for whatever reason they might have.
> > 
> > Yes, that makes sense to me.
> > 
> > Like cgroup.memory=nosocket, would you think it makes sense to include
> > slab in the default for functional/semantical completeness and provide
> > a cgroup.memory=noslab for powerusers?
> 
> I am still not sure whether the kmem accounting is stable enough to be
> enabled by default. If for nothing else the allocation failures, which
> are not allowed for the global case and easily triggered by the hard
> limit, might be a big problem. My last attempts to allow GFP_NOFS to
> fail made me quite skeptical. I still believe this is something which
> will be solved in the long term but the current state might be still too
> fragile. So I would rather be conservative and have the kmem accounting
> disabled by default with a config option and boot parameter to override.
> If somebody is confident that the desired load is stable then the config
> can be enabled easily.

I agree with your assessment of the current kmem code state, but I
think your conclusion is completely backwards here.

The interface will be set in stone forever, whereas any stability
issues will be transient and will have to be addressed in a finite
amount of time anyway. It doesn't make sense to design an interface
based on temporary quality of implementation. Only one of those two
can ever be changed.

Because it goes without saying that once the cgroupv2 interface is
released, and people use it in production, there is no way we can then
*add* dentry cache, inode cache, and others to memory.current. That
would be an unacceptable change in interface behavior. On the other
hand, people will be prepared for hiccups in the early stages of
cgroupv2 release, and we're providing cgroup.memory=noslab to let them
workaround severe problems in production until we fix it without
forcing them to fully revert to cgroupv1.

So if we agree that there are no fundamental architectural concerns
with slab accounting, i.e. nothing that can't be addressed in the
implementation, we have to make the call now.

And I maintain that not accounting dentry cache and inode cache is a
gaping hole in memory isolation, so it should be included by default.
(The rest of the slabs is arguable, but IMO the risk of missing
something important is higher than the cost of including them.)


As far as your allocation failure concerns go, I think the kmem code
is currently not behaving as Glauber originally intended, which is to
force charge if reclaim and OOM killing weren't able to make enough
space. See this recently rewritten section of the kmem charge path:

-               /*
-                * try_charge() chose to bypass to root due to OOM kill or
-                * fatal signal.  Since our only options are to either fail
-                * the allocation or charge it to this cgroup, do it as a
-                * temporary condition. But we can't fail. From a kmem/slab
-                * perspective, the cache has already been selected, by
-                * mem_cgroup_kmem_get_cache(), so it is too late to change
-                * our minds.
-                *
-                * This condition will only trigger if the task entered
-                * memcg_charge_kmem in a sane state, but was OOM-killed
-                * during try_charge() above. Tasks that were already dying
-                * when the allocation triggers should have been already
-                * directed to the root cgroup in memcontrol.h
-                */
-               page_counter_charge(&memcg->memory, nr_pages);
-               if (do_swap_account)
-                       page_counter_charge(&memcg->memsw, nr_pages);

It could be that this never properly worked as it was tied to the
-EINTR bypass trick, but the idea was these charges never fail.

And this makes sense. If the allocator semantics are such that we
never fail these page allocations for slab, and the callsites rely on
that, surely we should not fail them in the memory controller, either.

And it makes a lot more sense to account them in excess of the limit
than pretend they don't exist. We might not be able to completely
fullfill the containment part of the memory controller (although these
slab charges will still create significant pressure before that), but
at least we don't fail the accounting part on top of it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 61AB16B0031
	for <linux-mm@kvack.org>; Fri, 28 Jun 2013 08:24:14 -0400 (EDT)
Date: Fri, 28 Jun 2013 14:24:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] vmpressure: consider "scanned < reclaimed" case when
 calculating  a pressure level.
Message-ID: <20130628122412.GB5125@dhcp22.suse.cz>
References: <20130621162743.GA2837@gmail.com>
 <CAOK=xRMhwvWrao_ve8GFsk0JBHAcWh_SB_kM6fCujp8WThPimw@mail.gmail.com>
 <CAOK=xRNEMp3igfwQfrz0ffApmoAL19OM0EGLaBJ5RerZy9ddtw@mail.gmail.com>
 <005601ce6f0c$5948ff90$0bdafeb0$%kim@samsung.com>
 <20130626073557.GD29127@bbox>
 <009601ce72fd$427eed70$c77cc850$%kim@samsung.com>
 <20130627093721.GC17647@dhcp22.suse.cz>
 <20130627153528.GA5006@gmail.com>
 <20130627161103.GA25165@dhcp22.suse.cz>
 <20130627235435.GA15637@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130627235435.GA15637@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hyunhee Kim <hyunhee.kim@samsung.com>, 'Anton Vorontsov' <anton@enomsg.org>, linux-mm@kvack.org, akpm@linux-foundation.org, rob@landley.net, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, rientjes@google.com, kirill@shutemov.name, 'Kyungmin Park' <kyungmin.park@samsung.com>

On Fri 28-06-13 08:54:35, Minchan Kim wrote:
> Hello Michal,
> 
> On Thu, Jun 27, 2013 at 06:11:03PM +0200, Michal Hocko wrote:
> > On Fri 28-06-13 00:35:28, Minchan Kim wrote:
> > > Hi Michal,
> > > 
> > > On Thu, Jun 27, 2013 at 11:37:21AM +0200, Michal Hocko wrote:
> > > > On Thu 27-06-13 15:12:10, Hyunhee Kim wrote:
> > > > > In vmpressure, the pressure level is calculated based on the ratio
> > > > > of how many pages were scanned vs. reclaimed in a given time window.
> > > > > However, there is a possibility that "scanned < reclaimed" in such a
> > > > > case, when reclaiming ends by fatal signal in shrink_inactive_list.
> > > > > So, with this patch, we just return "low" level when "scanned < reclaimed"
> > > > > happens not to have userland miss reclaim activity.
> > > > 
> > > > Hmm, fatal signal pending on kswapd doesn't make sense to me so it has
> > > > to be a direct reclaim path. Does it really make sense to signal LOW
> > > > when there is probably a big memory pressure and somebody is killing the
> > > > current allocator?
> > > 
> > > So, do you want to trigger critical instead of low?
> > > 
> > > Now, current is going to die so we can expect shortly we can get a amount
> > > of memory, normally. 
> > 
> > And also consider that this is per-memcg interface. And so it is even
> > more complicated. If a task dies then there is _no_ guarantee that there
> > will be an uncharge in that group (task could have been migrated to that
> > group so the memory belongs to somebody else).
> 
> Good point and that's one of the reason I hate memcg for just using
> vmpressure. 

Well, the very same problem is present in the memcg OOM as well. oom
score calculation is not memcg aware wrt charges.

> Let's think over it. One of the very avaialbe scenario
> which userland could do when notified from vmpressure is that manager
> process sends signal for others to release own cached memory.

Assuming those processes are in the same memcg, right?

> If we use vmpressure without move_charge_at_immigrate in multiple memcg
> group, it would be a disaster. But if we use move_charge_at_immigrate,
> we will see long stall easily so it's not an option, either.

I am not sure I am following you here. Could you be more specific what
is the actual problem?
>From my POV, a manager can see a memory pressure, it notifies others in
the same memcg and they will release their caches. With
move_charge_at_immigrate == 0 some of those might release a memory in
other group but somebody must be using memory from the currently
signaled group, right?

> So, IMO, it's not a good idea to use vmpressure with no-root memcg so
> it could raise the question again "why vmpressure is part of memcg".

Maybe I do not see the problem correctly, but making vmpressure memcg
aware was a good idea. It is something like userspace pre-oom handling.

> I really didn't want it. :(
[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

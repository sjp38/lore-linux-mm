Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 2EE9A82997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 05:34:07 -0400 (EDT)
Received: by wgez8 with SMTP id z8so12287187wge.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:34:06 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id gw2si7596803wib.96.2015.05.22.02.34.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 02:34:05 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so41280879wic.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:34:05 -0700 (PDT)
Date: Fri, 22 May 2015 11:34:03 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150522093403.GD5109@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
 <20150519212754.GO24861@htj.duckdns.org>
 <20150520131044.GA28678@dhcp22.suse.cz>
 <20150520132158.GB28678@dhcp22.suse.cz>
 <20150520175302.GA7287@redhat.com>
 <20150520202221.GD14256@dhcp22.suse.cz>
 <20150521172217.GB12800@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150521172217.GB12800@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Oleg Nesterov <oleg@redhat.com>, Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 21-05-15 13:22:17, Johannes Weiner wrote:
> On Wed, May 20, 2015 at 10:22:21PM +0200, Michal Hocko wrote:
> > On Wed 20-05-15 19:53:02, Oleg Nesterov wrote:
> > > On 05/20, Michal Hocko wrote:
> > > >
> > > > So I assume the leader simply waits for its threads to finish and it
> > > > stays in the sibling list. __unhash_process seems like it does the final
> > > > cleanup and unlinks the leader from the lists. Which means that
> > > > mm_update_next_owner never sees !group_leader. Is that correct Oleg?
> > > 
> > > Yes, yes, the group leader can't go away until the whole thread-group dies.
> > 
> > OK, then we should have a guarantee that mm->owner is always thread
> > group leader, right?
> > 
> > > But can't we kill mm->owner somehow?
> > 
> > I would be happy about that. But it is not that simple.
> > 
> > > I mean, turn it into something else,
> > > ideally into "struct mem_cgroup *" although I doubt this is possible.
> > 
> > Sounds like a good idea but... it duplicates the cgroup tracking into
> > two places and that asks for troubles. On the other hand we are doing
> > that already because mm->owner might be in a different cgroup than the
> > current. However, this is an inherent problem because CLONE_VM doesn't
> > imply CLONE_THREAD. So in the end it doesn't look much worse IMO.
> > We will loose the "this task is in charge" aspect and that would
> > be a user space visible change but I am not sure how much it is a
> > problem. Maybe somebody is (ab)using this to workaround the restriction
> > that all threads are in the same cgroup.
> 
> If mm->owner is currently always the threadgroup leader, it should be
> fairly straight forward to maintain mm->memcg on all events that move
> any threadgroup leader between cgroups, without having mm->owner, no?

I have a tentative patch for that. It is fairly straightforward and it
even reduces the code size. I plan to post it early next week after it
gets some testing. The primary thing I am worried about is the user
visible behavior change, though.

> It would have a lot of benefits for sure.  The code would be simpler,
> but it would also reduce some of the cost that Mel is observing inside
> __mem_cgroup_count_vm_event(), by reducing one level of indirection.

Agreed!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

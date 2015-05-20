Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id E2D456B0142
	for <linux-mm@kvack.org>; Wed, 20 May 2015 16:22:24 -0400 (EDT)
Received: by wibt6 with SMTP id t6so72771862wib.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 13:22:24 -0700 (PDT)
Received: from mail-wg0-x235.google.com (mail-wg0-x235.google.com. [2a00:1450:400c:c00::235])
        by mx.google.com with ESMTPS id o9si5826471wib.9.2015.05.20.13.22.22
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 13:22:23 -0700 (PDT)
Received: by wgfl8 with SMTP id l8so64692160wgf.2
        for <linux-mm@kvack.org>; Wed, 20 May 2015 13:22:22 -0700 (PDT)
Date: Wed, 20 May 2015 22:22:21 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150520202221.GD14256@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
 <20150519212754.GO24861@htj.duckdns.org>
 <20150520131044.GA28678@dhcp22.suse.cz>
 <20150520132158.GB28678@dhcp22.suse.cz>
 <20150520175302.GA7287@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150520175302.GA7287@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 20-05-15 19:53:02, Oleg Nesterov wrote:
> On 05/20, Michal Hocko wrote:
> >
> > So I assume the leader simply waits for its threads to finish and it
> > stays in the sibling list. __unhash_process seems like it does the final
> > cleanup and unlinks the leader from the lists. Which means that
> > mm_update_next_owner never sees !group_leader. Is that correct Oleg?
> 
> Yes, yes, the group leader can't go away until the whole thread-group dies.

OK, then we should have a guarantee that mm->owner is always thread
group leader, right?

> But can't we kill mm->owner somehow?

I would be happy about that. But it is not that simple.

> I mean, turn it into something else,
> ideally into "struct mem_cgroup *" although I doubt this is possible.

Sounds like a good idea but... it duplicates the cgroup tracking into
two places and that asks for troubles. On the other hand we are doing
that already because mm->owner might be in a different cgroup than the
current. However, this is an inherent problem because CLONE_VM doesn't
imply CLONE_THREAD. So in the end it doesn't look much worse IMO.
We will loose the "this task is in charge" aspect and that would
be a user space visible change but I am not sure how much it is a
problem. Maybe somebody is (ab)using this to workaround the restriction
that all threads are in the same cgroup.

>From the implementation POV it even looks easier because we just have to
hook to fork (pin the memcg on dup_mm), to attach to change the memcg 
and to mmput to unpin the memcg.

I will think about that some more.

> It would be nice to kill mm_update_next_owner()/etc, this looks really
> ugly. We only need it for mem_cgroup_from_task(), and it would be much
> more clean to have mem_cgroup_from_mm(struct mm_struct *mm), imho.
> 
> Oleg.
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

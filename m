Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9B06B0112
	for <linux-mm@kvack.org>; Wed, 20 May 2015 09:10:48 -0400 (EDT)
Received: by wgjc11 with SMTP id c11so52427427wgj.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 06:10:47 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d8si3484881wiz.107.2015.05.20.06.10.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 20 May 2015 06:10:46 -0700 (PDT)
Date: Wed, 20 May 2015 15:10:45 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150520131044.GA28678@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
 <20150519212754.GO24861@htj.duckdns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519212754.GO24861@htj.duckdns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org, Oleg Nesterov <oleg@redhat.com>

On Tue 19-05-15 17:27:54, Tejun Heo wrote:
> Hello, Michal.
> 
> On Tue, May 19, 2015 at 02:13:21PM +0200, Michal Hocko wrote:
> > This is not true. We have:
> >                 mm = get_task_mm(p);
> >                 if (!mm)
> >                         return 0;
> >                 /* We move charges only when we move a owner of the mm */
> >                 if (mm->owner == p) {
> 
> Ah, missed that part.
> 
> > So we are ignoring threads which are not owner of the mm struct and that
> > should be the thread group leader AFAICS.
> > 
> > mm_update_next_owner is rather complex (maybe too much and it would
> > deserve some attention) so there might really be some corner cases but
> > the whole memcg code relies on mm->owner rather than thread group leader
> > so I would keep the same logic here.
> > 
> > > Let's tie memory operations to the threadgroup leader so
> > > that memory is migrated only when the leader is migrated.
> > 
> > This would lead to another strange behavior when the group leader is not
> > owner (if that is possible at all) and the memory wouldn't get migrated
> > at all.
> 
> Hmmm... is it guaranteed that if a threadgroup owns a mm, the mm's
> owner would be the threadgroup leader? 

That is a good question. As I've said I would expect it to be a thread
group leader but 4cd1a8fc3d3c ("memcg: fix possible panic when
CONFIG_MM_OWNER=y") confused me by claiming
"
    Also, the owner member comment description is wrong. mm->owner does
    not necessarily point to the thread group leader.
"

But now I am looking closer into mm_update_next_owner. for_each_process
should see only thread group leaders. p->{real_parent->}children
siblings search should return group leaders as well AFAICS.

But I am completely lost in the exit code paths. E.g. what happens
when the thread group leader exits and the other threads are still
alive? I would expect another thread would be chosen as a new leader and
siblings would be updated. But I cannot find that code. Maybe the
original leader just waits for all other threads to terminate and stay
in the linked lists.

The scary comment for has_group_leader_pid suggests that a thread might
have a the real pid without being the group leader. /me confused

Something for Oleg I guess.

> If not, the current code is
> broken too as it always takes the first member which is the
> threadgroup leader and if that's not the mm owner we may skip
> immigration while migrating the whole process.
> 
> I suppose the right thing to do here is iterating the taskset and find
> the mm owner?
> 
> Thanks.
> 
> -- 
> tejun

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

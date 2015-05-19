Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 182936B00AE
	for <linux-mm@kvack.org>; Tue, 19 May 2015 09:08:04 -0400 (EDT)
Received: by wibt6 with SMTP id t6so21738952wib.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:08:02 -0700 (PDT)
Received: from mail-wi0-x22b.google.com (mail-wi0-x22b.google.com. [2a00:1450:400c:c05::22b])
        by mx.google.com with ESMTPS id p2si1424560wij.21.2015.05.19.06.08.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 06:08:01 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so116180687wic.0
        for <linux-mm@kvack.org>; Tue, 19 May 2015 06:08:01 -0700 (PDT)
Date: Tue, 19 May 2015 15:10:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150519131042.GF6203@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519121321.GB6203@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Tue 19-05-15 14:13:21, Michal Hocko wrote:
> On Mon 18-05-15 15:49:51, Tejun Heo wrote:
> > If move_charge flag is set, memcg tries to move memory charges to the
> > destnation css.  The current implementation migrates memory whenever
> > any thread of a process is migrated making the behavior somewhat
> > arbitrary. 
> 
> This is not true. We have:
>                 mm = get_task_mm(p);
>                 if (!mm)
>                         return 0;
>                 /* We move charges only when we move a owner of the mm */
>                 if (mm->owner == p) {
> 
> So we are ignoring threads which are not owner of the mm struct and that
> should be the thread group leader AFAICS.
> 
> mm_update_next_owner is rather complex (maybe too much and it would
> deserve some attention) so there might really be some corner cases but
> the whole memcg code relies on mm->owner rather than thread group leader
> so I would keep the same logic here.
> 
> > Let's tie memory operations to the threadgroup leader so
> > that memory is migrated only when the leader is migrated.
> 
> This would lead to another strange behavior when the group leader is not
> owner (if that is possible at all) and the memory wouldn't get migrated
> at all.
> 
> I am trying to wrap my head around mm_update_next_owner and maybe we can
> change it to use the thread group leader but this needs more thinking...

OK, I guess I see the reason now. CLONE_VM doesn't imply CLONE_THREAD
so we can have a separate task (with it's own group leader) which
handles its own signals while it still shares the address space. So we
cannot really use the group leader here.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

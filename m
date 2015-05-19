Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f169.google.com (mail-qc0-f169.google.com [209.85.216.169])
	by kanga.kvack.org (Postfix) with ESMTP id D1BC06B00E4
	for <linux-mm@kvack.org>; Tue, 19 May 2015 17:27:57 -0400 (EDT)
Received: by qcir1 with SMTP id r1so14406966qci.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 14:27:57 -0700 (PDT)
Received: from mail-qg0-x22a.google.com (mail-qg0-x22a.google.com. [2607:f8b0:400d:c04::22a])
        by mx.google.com with ESMTPS id i38si11018123qkh.110.2015.05.19.14.27.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 May 2015 14:27:57 -0700 (PDT)
Received: by qget53 with SMTP id t53so14597401qge.3
        for <linux-mm@kvack.org>; Tue, 19 May 2015 14:27:56 -0700 (PDT)
Date: Tue, 19 May 2015 17:27:54 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150519212754.GO24861@htj.duckdns.org>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150519121321.GB6203@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

Hello, Michal.

On Tue, May 19, 2015 at 02:13:21PM +0200, Michal Hocko wrote:
> This is not true. We have:
>                 mm = get_task_mm(p);
>                 if (!mm)
>                         return 0;
>                 /* We move charges only when we move a owner of the mm */
>                 if (mm->owner == p) {

Ah, missed that part.

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

Hmmm... is it guaranteed that if a threadgroup owns a mm, the mm's
owner would be the threadgroup leader?  If not, the current code is
broken too as it always takes the first member which is the
threadgroup leader and if that's not the mm owner we may skip
immigration while migrating the whole process.

I suppose the right thing to do here is iterating the taskset and find
the mm owner?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

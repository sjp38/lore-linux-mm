Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id 17CBF6B0131
	for <linux-mm@kvack.org>; Wed, 20 May 2015 13:53:45 -0400 (EDT)
Received: by qgfa63 with SMTP id a63so7785981qgf.0
        for <linux-mm@kvack.org>; Wed, 20 May 2015 10:53:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i81si197853qkh.107.2015.05.20.10.53.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 May 2015 10:53:44 -0700 (PDT)
Date: Wed, 20 May 2015 19:53:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
	leader is moved
Message-ID: <20150520175302.GA7287@redhat.com>
References: <1431978595-12176-1-git-send-email-tj@kernel.org> <1431978595-12176-4-git-send-email-tj@kernel.org> <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150520132158.GB28678@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On 05/20, Michal Hocko wrote:
>
> So I assume the leader simply waits for its threads to finish and it
> stays in the sibling list. __unhash_process seems like it does the final
> cleanup and unlinks the leader from the lists. Which means that
> mm_update_next_owner never sees !group_leader. Is that correct Oleg?

Yes, yes, the group leader can't go away until the whole thread-group dies.

But can't we kill mm->owner somehow? I mean, turn it into something else,
ideally into "struct mem_cgroup *" although I doubt this is possible.

It would be nice to kill mm_update_next_owner()/etc, this looks really
ugly. We only need it for mem_cgroup_from_task(), and it would be much
more clean to have mem_cgroup_from_mm(struct mm_struct *mm), imho.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

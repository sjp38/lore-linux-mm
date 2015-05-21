Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f171.google.com (mail-qk0-f171.google.com [209.85.220.171])
	by kanga.kvack.org (Postfix) with ESMTP id 36F556B018C
	for <linux-mm@kvack.org>; Thu, 21 May 2015 15:28:06 -0400 (EDT)
Received: by qkx62 with SMTP id 62so17187734qkx.3
        for <linux-mm@kvack.org>; Thu, 21 May 2015 12:28:06 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 40si22146550qkv.70.2015.05.21.12.28.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 12:28:05 -0700 (PDT)
Date: Thu, 21 May 2015 21:27:16 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
	leader is moved
Message-ID: <20150521192716.GA21304@redhat.com>
References: <1431978595-12176-1-git-send-email-tj@kernel.org> <1431978595-12176-4-git-send-email-tj@kernel.org> <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz> <20150520175302.GA7287@redhat.com> <20150520202221.GD14256@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150520202221.GD14256@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On 05/20, Michal Hocko wrote:
>
> On Wed 20-05-15 19:53:02, Oleg Nesterov wrote:
> >
> > Yes, yes, the group leader can't go away until the whole thread-group dies.
>
> OK, then we should have a guarantee that mm->owner is always thread
> group leader, right?

No, please note that the exiting leader does exit_mm()->mm_update_next_owner()
and this changes mm->owner.

Btw, this connects to other potential cleanups... task_struct->mm looks
a bit strange, we probably want to move it into signal_struct->mm and
make exit_mm/etc per-process. But this is not trivial, and off-topic.

Offtopic, because the exiting leader has to call mm_update_next_owner()
in any case. Simply because it does cgroup_exit() after that, so
get_mem_cgroup_from_mm() can't work if mm->owner is zombie.

This also means that get_mem_cgroup_from_mm() can race with the exiting
mm->owner unless I missed something.

> > But can't we kill mm->owner somehow?
>
> I would be happy about that. But it is not that simple.

Yes, yes, I understand.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

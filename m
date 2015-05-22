Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f180.google.com (mail-qk0-f180.google.com [209.85.220.180])
	by kanga.kvack.org (Postfix) with ESMTP id 26872829BA
	for <linux-mm@kvack.org>; Fri, 22 May 2015 12:29:44 -0400 (EDT)
Received: by qkdn188 with SMTP id n188so15571797qkd.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 09:29:44 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q136si1817295qha.12.2015.05.22.09.29.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 09:29:43 -0700 (PDT)
Date: Fri, 22 May 2015 18:29:00 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
	leader is moved
Message-ID: <20150522162900.GA8955@redhat.com>
References: <1431978595-12176-1-git-send-email-tj@kernel.org> <1431978595-12176-4-git-send-email-tj@kernel.org> <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz> <20150520175302.GA7287@redhat.com> <20150520202221.GD14256@dhcp22.suse.cz> <20150521192716.GA21304@redhat.com> <20150522093639.GE5109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522093639.GE5109@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On 05/22, Michal Hocko wrote:
>
> On Thu 21-05-15 21:27:16, Oleg Nesterov wrote:
> > On 05/20, Michal Hocko wrote:
> > >
> > > On Wed 20-05-15 19:53:02, Oleg Nesterov wrote:
> > > >
> > > > Yes, yes, the group leader can't go away until the whole thread-group dies.
> > >
> > > OK, then we should have a guarantee that mm->owner is always thread
> > > group leader, right?
> >
> > No, please note that the exiting leader does exit_mm()->mm_update_next_owner()
> > and this changes mm->owner.
>
> I am confused now. Yeah it changes the owner but the new one will be
> again the thread group leader, right?

Why?

In the likely case (if CLONE_VM without CLONE_THREAD was not used) the
last for_each_process() in mm_update_next_owner() will find another thread
from the same group.

Oh. I think mm_update_next_owner() needs some cleanups. Perhaps I'll send
the patch today.

> > Btw, this connects to other potential cleanups... task_struct->mm looks
> > a bit strange, we probably want to move it into signal_struct->mm and
> > make exit_mm/etc per-process. But this is not trivial, and off-topic.
>
> I am not sure this is a good idea but I would have to think about this
> some more. Let's not distract this email thread and discuss it in a
> separate thread please.

Yes, yes. I mentioned this to explain that we can't keep the exited leader
as mm->owner in any case. And report that get_mem_cgroup_from_mm() looks
racy.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

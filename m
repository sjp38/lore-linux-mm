Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 854AF6B0265
	for <linux-mm@kvack.org>; Fri, 22 May 2015 05:36:43 -0400 (EDT)
Received: by wizk4 with SMTP id k4so41424100wiz.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:36:43 -0700 (PDT)
Received: from mail-wi0-x236.google.com (mail-wi0-x236.google.com. [2a00:1450:400c:c05::236])
        by mx.google.com with ESMTPS id cj8si2745458wjc.164.2015.05.22.02.36.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 02:36:42 -0700 (PDT)
Received: by wicmx19 with SMTP id mx19so41351320wic.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 02:36:41 -0700 (PDT)
Date: Fri, 22 May 2015 11:36:40 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150522093639.GE5109@dhcp22.suse.cz>
References: <1431978595-12176-1-git-send-email-tj@kernel.org>
 <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
 <20150519212754.GO24861@htj.duckdns.org>
 <20150520131044.GA28678@dhcp22.suse.cz>
 <20150520132158.GB28678@dhcp22.suse.cz>
 <20150520175302.GA7287@redhat.com>
 <20150520202221.GD14256@dhcp22.suse.cz>
 <20150521192716.GA21304@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150521192716.GA21304@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Thu 21-05-15 21:27:16, Oleg Nesterov wrote:
> On 05/20, Michal Hocko wrote:
> >
> > On Wed 20-05-15 19:53:02, Oleg Nesterov wrote:
> > >
> > > Yes, yes, the group leader can't go away until the whole thread-group dies.
> >
> > OK, then we should have a guarantee that mm->owner is always thread
> > group leader, right?
> 
> No, please note that the exiting leader does exit_mm()->mm_update_next_owner()
> and this changes mm->owner.

I am confused now. Yeah it changes the owner but the new one will be
again the thread group leader, right?
 
> Btw, this connects to other potential cleanups... task_struct->mm looks
> a bit strange, we probably want to move it into signal_struct->mm and
> make exit_mm/etc per-process. But this is not trivial, and off-topic.

I am not sure this is a good idea but I would have to think about this
some more. Let's not distract this email thread and discuss it in a
separate thread please.

> Offtopic, because the exiting leader has to call mm_update_next_owner()
> in any case. Simply because it does cgroup_exit() after that, so
> get_mem_cgroup_from_mm() can't work if mm->owner is zombie.
> 
> This also means that get_mem_cgroup_from_mm() can race with the exiting
> mm->owner unless I missed something.
> 
> > > But can't we kill mm->owner somehow?
> >
> > I would be happy about that. But it is not that simple.
> 
> Yes, yes, I understand.
> 
> Oleg.
> 

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

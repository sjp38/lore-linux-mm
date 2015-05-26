Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 26E0F6B0182
	for <linux-mm@kvack.org>; Tue, 26 May 2015 03:16:58 -0400 (EDT)
Received: by wizk4 with SMTP id k4so66738526wiz.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 00:16:57 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id ge8si16569432wib.104.2015.05.26.00.16.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 00:16:56 -0700 (PDT)
Received: by wichy4 with SMTP id hy4so69972297wic.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 00:16:56 -0700 (PDT)
Date: Tue, 26 May 2015 09:16:55 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150526071654.GE14681@dhcp22.suse.cz>
References: <20150520132158.GB28678@dhcp22.suse.cz>
 <20150520175302.GA7287@redhat.com>
 <20150520202221.GD14256@dhcp22.suse.cz>
 <20150521192716.GA21304@redhat.com>
 <20150522093639.GE5109@dhcp22.suse.cz>
 <20150522162900.GA8955@redhat.com>
 <20150522165734.GH5109@dhcp22.suse.cz>
 <20150522183042.GF26770@redhat.com>
 <20150525160626.GC19389@dhcp22.suse.cz>
 <20150525170601.GA438@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150525170601.GA438@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Mon 25-05-15 19:06:01, Oleg Nesterov wrote:
> On 05/25, Michal Hocko wrote:
> >
> > On Fri 22-05-15 20:30:42, Oleg Nesterov wrote:
> > > On 05/22, Michal Hocko wrote:
> > > >
> > > > On Fri 22-05-15 18:29:00, Oleg Nesterov wrote:
> > > > >
> > > > > In the likely case (if CLONE_VM without CLONE_THREAD was not used) the
> > > > > last for_each_process() in mm_update_next_owner() will find another thread
> > > > > from the same group.
> > > >
> > > > My understanding was that for_each_process will iterate only over
> > > > processes (represented by the thread group leaders).
> > >
> > > Yes. But note the inner for_each_thread() loop. And note that we
> > > we need this loop exactly because the leader can be zombie.
> >
> > I was too vague, sorry about that.
> 
> Looks like, we confused each other somehow ;) Not sure I understand your
> concerns...
> 
> But,
> 
> > What I meant was that
> > for_each_process would pick up a group leader
> 
> Yes. In the case above it will find the caller (current) too,
> 
> > and the inner
> > for_each_thread will return it as the first element in the list.
> 
> Yes, and this will be "current" task. But current->mm == NULL, so
> for_each_thread() will continue and find another thread which becomes
> the new mm->owner.

OK, this is the part I was missing. exit_mm manages to set mm to NULL
before calling mm_update_next_owner. Now it makes much moer sense.
Thanks for your patience! It really seems like we are broken here.
The most reasonable way forward is to get rid of the owner. The patch
will go to the list today.

> Just in case, note the BUG_ON(c == p). I think that BUG_ON(p->mm) at
> the start will look much better. This is what mm_update_next_owner()
> actually assumes.
> 
> Oleg.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

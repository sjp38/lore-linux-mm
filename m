Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id E6733829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 12:57:37 -0400 (EDT)
Received: by wichy4 with SMTP id hy4so53500423wic.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 09:57:37 -0700 (PDT)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com. [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id x4si4671541wjr.105.2015.05.22.09.57.35
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 09:57:36 -0700 (PDT)
Received: by wgfl8 with SMTP id l8so23355042wgf.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 09:57:35 -0700 (PDT)
Date: Fri, 22 May 2015 18:57:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
 leader is moved
Message-ID: <20150522165734.GH5109@dhcp22.suse.cz>
References: <1431978595-12176-4-git-send-email-tj@kernel.org>
 <20150519121321.GB6203@dhcp22.suse.cz>
 <20150519212754.GO24861@htj.duckdns.org>
 <20150520131044.GA28678@dhcp22.suse.cz>
 <20150520132158.GB28678@dhcp22.suse.cz>
 <20150520175302.GA7287@redhat.com>
 <20150520202221.GD14256@dhcp22.suse.cz>
 <20150521192716.GA21304@redhat.com>
 <20150522093639.GE5109@dhcp22.suse.cz>
 <20150522162900.GA8955@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522162900.GA8955@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On Fri 22-05-15 18:29:00, Oleg Nesterov wrote:
> On 05/22, Michal Hocko wrote:
> >
> > On Thu 21-05-15 21:27:16, Oleg Nesterov wrote:
> > > On 05/20, Michal Hocko wrote:
> > > >
> > > > On Wed 20-05-15 19:53:02, Oleg Nesterov wrote:
> > > > >
> > > > > Yes, yes, the group leader can't go away until the whole thread-group dies.
> > > >
> > > > OK, then we should have a guarantee that mm->owner is always thread
> > > > group leader, right?
> > >
> > > No, please note that the exiting leader does exit_mm()->mm_update_next_owner()
> > > and this changes mm->owner.
> >
> > I am confused now. Yeah it changes the owner but the new one will be
> > again the thread group leader, right?
> 
> Why?
> 
> In the likely case (if CLONE_VM without CLONE_THREAD was not used) the
> last for_each_process() in mm_update_next_owner() will find another thread
> from the same group.

My understanding was that for_each_process will iterate only over
processes (represented by the thread group leaders). That was the reason
I was asking about thread group leader exiting before other threads.
I am sorry to ask again, but let me ask again. How would we get
!group_leader from p->{real_parent->}sibling or from for_each_process?

> Oh. I think mm_update_next_owner() needs some cleanups. Perhaps I'll send
> the patch today.

Please hold on, I have a patch to get rid of the owner altogether. I
will post it sometimes next week. Let's see whether this is a viable
option. If not then we can clean this up.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

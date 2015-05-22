Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id AFA74829C8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 14:31:31 -0400 (EDT)
Received: by qkgv12 with SMTP id v12so18565524qkg.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 11:31:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 107si3214898qge.122.2015.05.22.11.31.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 11:31:31 -0700 (PDT)
Date: Fri, 22 May 2015 20:30:42 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 3/7] memcg: immigrate charges only when a threadgroup
	leader is moved
Message-ID: <20150522183042.GF26770@redhat.com>
References: <20150519121321.GB6203@dhcp22.suse.cz> <20150519212754.GO24861@htj.duckdns.org> <20150520131044.GA28678@dhcp22.suse.cz> <20150520132158.GB28678@dhcp22.suse.cz> <20150520175302.GA7287@redhat.com> <20150520202221.GD14256@dhcp22.suse.cz> <20150521192716.GA21304@redhat.com> <20150522093639.GE5109@dhcp22.suse.cz> <20150522162900.GA8955@redhat.com> <20150522165734.GH5109@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522165734.GH5109@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Tejun Heo <tj@kernel.org>, lizefan@huawei.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, linux-mm@kvack.org

On 05/22, Michal Hocko wrote:
>
> On Fri 22-05-15 18:29:00, Oleg Nesterov wrote:
> >
> > In the likely case (if CLONE_VM without CLONE_THREAD was not used) the
> > last for_each_process() in mm_update_next_owner() will find another thread
> > from the same group.
>
> My understanding was that for_each_process will iterate only over
> processes (represented by the thread group leaders).

Yes. But note the inner for_each_thread() loop. And note that we
we need this loop exactly because the leader can be zombie.

> How would we get
> !group_leader from p->{real_parent->}sibling

As for children/siblings we can't get !group_leader, yes. And this is
actually not right ;) See the (self-nacked) 2/3 I just sent.

> > Oh. I think mm_update_next_owner() needs some cleanups. Perhaps I'll send
> > the patch today.
>
> Please hold on, I have a patch to get rid of the owner altogether. I
> will post it sometimes next week. Let's see whether this is a viable
> option. If not then we can clean this up.

Great. Please ignore 1-3 I already sent.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

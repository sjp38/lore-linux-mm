Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id E15896B0069
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 09:36:11 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id gf13so3235321lab.1
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 06:36:11 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id la5si7025584lac.99.2014.10.24.06.36.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Oct 2014 06:36:09 -0700 (PDT)
Date: Fri, 24 Oct 2014 09:36:05 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Fix NULL pointer deref in task_in_mem_cgroup()
Message-ID: <20141024133605.GA17987@phnom.home.cmpxchg.org>
References: <1414082865-4091-1-git-send-email-jack@suse.cz>
 <20141023181929.GB15937@phnom.home.cmpxchg.org>
 <20141024085807.GA28644@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141024085807.GA28644@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Jan Kara <jack@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Fri, Oct 24, 2014 at 10:58:07AM +0200, Michal Hocko wrote:
> On Thu 23-10-14 14:19:29, Johannes Weiner wrote:
> > On Thu, Oct 23, 2014 at 06:47:45PM +0200, Jan Kara wrote:
> > > 'curr' pointer in task_in_mem_cgroup() can be NULL when we race with
> > > somebody clearing task->mm. Check for it before dereferencing the
> > > pointer.
> > 
> > If task->mm is already NULL, we fall back to mem_cgroup_from_task(),
> > which definitely returns a memcg unless you pass NULL in there.  So I
> > don't see how that could happen, and the NULL checks in the fallback
> > branch as well as in __mem_cgroup_same_or_subtree seem bogus to me.
> 
> It came from 3a981f482cc2 (memcg: fix use_hierarchy css_is_ancestor oops
> regression). I do not see mem_cgroup_same_or_subtree called from
> page_referenced path so it is probably gone.

It's still there in invalid_page_referenced_vma().  And it can still
pass NULL.

> task_in_mem_cgroup is just confused because curr can never be NULL as
> the task is never NULL.

That's correct.

My patches to clean all this up have been stress-tested over night, I
will send them out in a jiffy.

Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

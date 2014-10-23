Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id BA9A86B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 15:38:34 -0400 (EDT)
Received: by mail-la0-f44.google.com with SMTP id hs14so1465374lab.31
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 12:38:33 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id tn9si4095806lbb.72.2014.10.23.12.38.32
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Oct 2014 12:38:32 -0700 (PDT)
Date: Thu, 23 Oct 2014 15:38:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg: Fix NULL pointer deref in task_in_mem_cgroup()
Message-ID: <20141023193830.GB558@phnom.home.cmpxchg.org>
References: <1414082865-4091-1-git-send-email-jack@suse.cz>
 <20141023181929.GB15937@phnom.home.cmpxchg.org>
 <20141023183435.GD21034@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023183435.GD21034@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu, Oct 23, 2014 at 08:34:35PM +0200, Jan Kara wrote:
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
>   OK, I admittedly don't understand that code much. I was just wondering
> that we check 'curr' for being NULL in all the places except for that one
> which looked suspicious... If curr cannot be NULL, then we should just
> remove those checks I assume.

Agreed.  They make the code quite hard to understand and change
because all callchains need to be verified up the stack.

Thanks for the nudge, I'm going to remove the bogus ones.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

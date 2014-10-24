Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f176.google.com (mail-lb0-f176.google.com [209.85.217.176])
	by kanga.kvack.org (Postfix) with ESMTP id 67C316B006C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2014 04:58:09 -0400 (EDT)
Received: by mail-lb0-f176.google.com with SMTP id p9so2152334lbv.7
        for <linux-mm@kvack.org>; Fri, 24 Oct 2014 01:58:08 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i5si6034534lbd.20.2014.10.24.01.58.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 24 Oct 2014 01:58:07 -0700 (PDT)
Date: Fri, 24 Oct 2014 10:58:07 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: Fix NULL pointer deref in task_in_mem_cgroup()
Message-ID: <20141024085807.GA28644@dhcp22.suse.cz>
References: <1414082865-4091-1-git-send-email-jack@suse.cz>
 <20141023181929.GB15937@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023181929.GB15937@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 23-10-14 14:19:29, Johannes Weiner wrote:
> On Thu, Oct 23, 2014 at 06:47:45PM +0200, Jan Kara wrote:
> > 'curr' pointer in task_in_mem_cgroup() can be NULL when we race with
> > somebody clearing task->mm. Check for it before dereferencing the
> > pointer.
> 
> If task->mm is already NULL, we fall back to mem_cgroup_from_task(),
> which definitely returns a memcg unless you pass NULL in there.  So I
> don't see how that could happen, and the NULL checks in the fallback
> branch as well as in __mem_cgroup_same_or_subtree seem bogus to me.

It came from 3a981f482cc2 (memcg: fix use_hierarchy css_is_ancestor oops
regression). I do not see mem_cgroup_same_or_subtree called from
page_referenced path so it is probably gone.
task_in_mem_cgroup is just confused because curr can never be NULL as
the task is never NULL.
---

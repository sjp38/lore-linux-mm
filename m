Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8DE556B0038
	for <linux-mm@kvack.org>; Mon, 20 Feb 2017 12:43:04 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id q39so19795042wrb.3
        for <linux-mm@kvack.org>; Mon, 20 Feb 2017 09:43:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b205si13142972wmd.127.2017.02.20.09.43.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Feb 2017 09:43:03 -0800 (PST)
Date: Mon, 20 Feb 2017 18:42:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/cgroup: avoid panic when init with low memory
Message-ID: <20170220174258.GA31541@dhcp22.suse.cz>
References: <1487154969-6704-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170220130123.GI2431@dhcp22.suse.cz>
 <934d40ec-060b-4794-2fdc-35a7ea1dc9e2@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <934d40ec-060b-4794-2fdc-35a7ea1dc9e2@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 20-02-17 18:09:43, Laurent Dufour wrote:
> On 20/02/2017 14:01, Michal Hocko wrote:
> > On Wed 15-02-17 11:36:09, Laurent Dufour wrote:
> >> The system may panic when initialisation is done when almost all the
> >> memory is assigned to the huge pages using the kernel command line
> >> parameter hugepage=xxxx. Panic may occur like this:
> > 
> > I am pretty sure the system might blow up in many other ways when you
> > misconfigure it and pull basically all the memory out. Anyway...
> > 
> > [...]
> > 
> >> This is a chicken and egg issue where the kernel try to get free
> >> memory when allocating per node data in mem_cgroup_init(), but in that
> >> path mem_cgroup_soft_limit_reclaim() is called which assumes that
> >> these data are allocated.
> >>
> >> As mem_cgroup_soft_limit_reclaim() is best effort, it should return
> >> when these data are not yet allocated.
> > 
> > ... this makes some sense. Especially when there is no soft limit
> > configured. So this is a good step. I would just like to ask you to go
> > one step further. Can we make the whole soft reclaim thing uninitialized
> > until the soft limit is actually set? Soft limit is not used in cgroup
> > v2 at all and I would strongly discourage it in v1 as well. We will save
> > few bytes as a bonus.
> 
> Hi Michal, and thanks for the review.
> 
> I'm not familiar with that part of the kernel, so to be sure we are on
> the same line, are you suggesting to set soft_limit_tree at the first
> time mem_cgroup_write() is called to set a soft_limit field ?

yes

> Obviously, all callers to soft_limit_tree_node() and
> soft_limit_tree_from_page() will have to check for the return pointer to
> be NULL.

All callers that need to access the tree unconditionally, yes. Which is
the case anyway, right? I haven't checked the check you have added is
sufficient, but we shouldn't have that many of them because some code
paths are called only when the soft limit is enabled.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

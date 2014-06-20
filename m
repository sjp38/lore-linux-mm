Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f41.google.com (mail-qa0-f41.google.com [209.85.216.41])
	by kanga.kvack.org (Postfix) with ESMTP id 74C7F6B0037
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 17:01:41 -0400 (EDT)
Received: by mail-qa0-f41.google.com with SMTP id cm18so3695872qab.0
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:01:41 -0700 (PDT)
Received: from mail-qc0-x234.google.com (mail-qc0-x234.google.com [2607:f8b0:400d:c01::234])
        by mx.google.com with ESMTPS id k96si12317456qgk.39.2014.06.20.14.01.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 20 Jun 2014 14:01:40 -0700 (PDT)
Received: by mail-qc0-f180.google.com with SMTP id r5so3981324qcx.25
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 14:01:40 -0700 (PDT)
Date: Fri, 20 Jun 2014 17:01:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] mm/mempolicy: fix sleeping function called from invalid
 context
Message-ID: <20140620210137.GA2059@mtj.dyndns.org>
References: <53902A44.50005@cn.fujitsu.com>
 <20140605132339.ddf6df4a0cf5c14d17eb8691@linux-foundation.org>
 <539192F1.7050308@cn.fujitsu.com>
 <alpine.DEB.2.02.1406081539140.21744@chino.kir.corp.google.com>
 <539574F1.2060701@cn.fujitsu.com>
 <alpine.DEB.2.02.1406090209460.24247@chino.kir.corp.google.com>
 <53967465.7070908@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53967465.7070908@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: David Rientjes <rientjes@google.com>, Gu Zheng <guz.fnst@cn.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>, stable@vger.kernel.org

Hello, Li.

Sorry about the long delay.

On Tue, Jun 10, 2014 at 10:58:45AM +0800, Li Zefan wrote:
> Yes, this is a long-standing issue. Besides the race you described, the child
> task's mems_allowed can be wrong if the cpuset's nodemask changes before the
> child has been added to the cgroup's tasklist.
> 
> I remember Tejun once said he wanted to disallow task migration between
> cgroups during fork, and that should fix this problem.

I'm having trouble remembering but yeah enforcing stricter behavior
across fork could be beneficial.  Hmmm... the problem with making
forks exclusive against migrations is that we'll end up adding more
locking to the fork path which isn't too nice.

Hmmm... other controllers (cgroup_freezer) can reliably synchronize
the child's state to the cgroup it belongs to.  Why can't cpuset?  Is
there something fundamentally missing in the cgroup API?

> > It needs to be slightly rewritten to work properly without negatively 
> > impacting the latency of fork().  Do you have the cycles to do it?
> > 
> 
> Sounds you have other idea?

I don't think the suggested patch breaks anything more than it was
broken before and we should probably apply it for the time being.  Li?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

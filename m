Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id DAE456B084F
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 09:04:31 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id 22-v6so5938376ywd.15
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 06:04:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c132-v6sor608018yba.1.2018.08.17.06.04.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 17 Aug 2018 06:04:28 -0700 (PDT)
Date: Fri, 17 Aug 2018 09:04:25 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v8 0/2] Directed kmem charging
Message-ID: <20180817130425.GA12351@cmpxchg.org>
References: <20180627191250.209150-1-shakeelb@google.com>
 <20180815152511.3ea63aa54c5fac0bfe9370da@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180815152511.3ea63aa54c5fac0bfe9370da@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jan Kara <jack@suse.com>, Greg Thelen <gthelen@google.com>, Amir Goldstein <amir73il@gmail.com>, Roman Gushchin <guro@fb.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Wed, Aug 15, 2018 at 03:25:11PM -0700, Andrew Morton wrote:
> On Wed, 27 Jun 2018 12:12:48 -0700 Shakeel Butt <shakeelb@google.com> wrote:
> 
> > The Linux kernel's memory cgroup allows limiting the memory usage of
> > the jobs running on the system to provide isolation between the jobs.
> > All the kernel memory allocated in the context of the job and marked
> > with __GFP_ACCOUNT will also be included in the memory usage and be
> > limited by the job's limit.
> > 
> > The kernel memory can only be charged to the memcg of the process in
> > whose context kernel memory was allocated. However there are cases where
> > the allocated kernel memory should be charged to the memcg different
> > from the current processes's memcg. This patch series contains two such
> > concrete use-cases i.e. fsnotify and buffer_head.
> > 
> > The fsnotify event objects can consume a lot of system memory for large
> > or unlimited queues if there is either no or slow listener. The events
> > are allocated in the context of the event producer. However they should
> > be charged to the event consumer. Similarly the buffer_head objects can
> > be allocated in a memcg different from the memcg of the page for which
> > buffer_head objects are being allocated.
> > 
> > To solve this issue, this patch series introduces mechanism to charge
> > kernel memory to a given memcg. In case of fsnotify events, the memcg of
> > the consumer can be used for charging and for buffer_head, the memcg of
> > the page can be charged. For directed charging, the caller can use the
> > scope API memalloc_[un]use_memcg() to specify the memcg to charge for
> > all the __GFP_ACCOUNT allocations within the scope.
> 
> This patchset is not showing signs of having been well reviewed at
> this time.  Could people please take another look?

I don't have the mailing list archives for this anymore, but the
series as it stands in mmots looks good to me and incorporates all the
feedback I remember giving.

[ My only gripe really is that it applies current->active_memcg only
  to kmem charges, not others as well. Right now it doesn't matter,
  but I can see this costing a kernel developer implementing remote
  charges for something other than kmem some time to realize. ]

Anyway, please feel free to add

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

for 1/2 and 2/2 plus their two fixlets.

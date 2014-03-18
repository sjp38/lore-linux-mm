Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id E7C336B00F0
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 04:55:35 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hm4so3298245wib.0
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 01:55:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l7si6898462wib.15.2014.03.18.01.55.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 01:55:33 -0700 (PDT)
Date: Tue, 18 Mar 2014 09:55:32 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH RESEND -mm 01/12] memcg: flush cache creation works
 before memcg cache destruction
Message-ID: <20140318085532.GB3191@dhcp22.suse.cz>
References: <cover.1394708827.git.vdavydov@parallels.com>
 <4cccfcf74595f26532a6dda7264dc420df82fb8a.1394708827.git.vdavydov@parallels.com>
 <20140317160755.GB30623@dhcp22.suse.cz>
 <5328006D.5020802@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5328006D.5020802@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, glommer@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org

On Tue 18-03-14 12:14:37, Vladimir Davydov wrote:
> On 03/17/2014 08:07 PM, Michal Hocko wrote:
> > On Thu 13-03-14 19:06:39, Vladimir Davydov wrote:
> >> When we get to memcg cache destruction, either from the root cache
> >> destruction path or when turning memcg offline, there still might be
> >> memcg cache creation works pending that was scheduled before we
> >> initiated destruction. We need to flush them before starting to destroy
> >> memcg caches, otherwise we can get a leaked kmem cache or, even worse,
> >> an attempt to use after free.
> > How can we use-after-free? Even if there is a pending work item to
> > create a new cache then we keep the css reference for the memcg and
> > release it from the worker (memcg_create_cache_work_func). So although
> > this can race with memcg offlining the memcg itself will be still alive.
> 
> There are actually two issues:
> 
> 1) When we destroy a root cache using kmem_cache_destroy(), we should
> ensure all pending memcg creation works for this root cache are over,
> otherwise a work could be executed after the root cache is destroyed
> resulting in use-after-free.

Dunno, but this sounds backwards to me. If we are using a root cache for
a new child creation then the child should make sure that the root
doesn't go away, no? Cannot we take a reference to the root cache before
we schedule memcg_create_cache_work_func?

But I admit that the root cache concept is not entirely clear to me.

> 2) Memcg offline. In this case use-after-free is impossible in a memcg
> creation work handler, because, as you mentioned, the work holds the css
> reference. However, we still have to synchronize against pending
> requests, otherwise a work handler can be executed after we destroyed
> the caches corresponding to the memcg being offlined resulting in a
> kmem_cache leak.

If that is a case then we should come up with a proper synchronization
because synchronization by workqueues and explicit flushing and
canceling is really bad.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

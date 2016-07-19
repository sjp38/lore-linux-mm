Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id ECFB26B025E
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 10:19:59 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id x83so14669552wma.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:19:59 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id n125si20366860wme.125.2016.07.19.07.19.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 07:19:58 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id q128so21091433wma.1
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:19:58 -0700 (PDT)
Date: Tue, 19 Jul 2016 16:19:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from the
 reclaim path
Message-ID: <20160719141956.GJ9486@dhcp22.suse.cz>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org>
 <1468831285-27242-1-git-send-email-mhocko@kernel.org>
 <20160719135426.GA31229@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160719135426.GA31229@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com

On Tue 19-07-16 09:54:26, Johannes Weiner wrote:
> On Mon, Jul 18, 2016 at 10:41:24AM +0200, Michal Hocko wrote:
> > The original intention of f9054c70d28b was to help with the OOM
> > situations where the oom victim depends on mempool allocation to make a
> > forward progress. We can handle that case in a different way, though. We
> > can check whether the current task has access to memory reserves ad an
> > OOM victim (TIF_MEMDIE) and drop __GFP_NOMEMALLOC protection if the pool
> > is empty.
> > 
> > David Rientjes was objecting that such an approach wouldn't help if the
> > oom victim was blocked on a lock held by process doing mempool_alloc. This
> > is very similar to other oom deadlock situations and we have oom_reaper
> > to deal with them so it is reasonable to rely on the same mechanism
> > rather inventing a different one which has negative side effects.
> 
> I don't understand how this scenario wouldn't be a flat-out bug.
> 
> Mempool guarantees forward progress by having all necessary memory
> objects for the guaranteed operation in reserve. Think about it this
> way: you should be able to delete the pool->alloc() call entirely and
> still make reliable forward progress. It would kill concurrency and be
> super slow, but how could it be affected by a system OOM situation?

Yes this is my understanding of the mempool usage as well. It is much
harder to check whether mempool users are really behaving and they do
not request more than the pre allocated pool allows them, though. That
would be a bug in the consumer not the mempool as such of course.

My original understanding of f9054c70d28b was that it acts as
a prevention for issues where the OOM victim loops inside the
mempool_alloc not doing reasonable progress because those who should
refill the pool are stuck for some reason (aka assume that not all
mempool users are behaving or they have unexpected dependencies like WQ
without WQ_MEM_RECLAIM and similar).

My thinking was that the victim has access to memory reserves by default
so it sounds reasonable to preserve this access also when it is in the
mempool_alloc. Therefore I wanted to preserve that particular logic and
came up with this patch which should be safer than f9054c70d28b. But the
more I am thinking about it the more it sounds like papering over a bug
somewhere else.

So I guess we should just go and revert f9054c70d28b and get back to
David's lockup and investigate what exactly went wrong and why. The
current form of f9054c70d28b is simply too dangerous.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

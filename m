Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f49.google.com (mail-yh0-f49.google.com [209.85.213.49])
	by kanga.kvack.org (Postfix) with ESMTP id 9D84A6B0031
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 18:52:01 -0500 (EST)
Received: by mail-yh0-f49.google.com with SMTP id z20so11979186yhz.36
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 15:52:01 -0800 (PST)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id f29si8508268yhd.170.2013.12.04.15.52.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 15:52:00 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f73so11914186yha.7
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 15:52:00 -0800 (PST)
Date: Wed, 4 Dec 2013 15:51:57 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 2/2] mm: memcg: do not allow task about to OOM kill to
 bypass the limit
In-Reply-To: <1386197114-5317-3-git-send-email-hannes@cmpxchg.org>
Message-ID: <alpine.DEB.2.02.1312041546370.6329@chino.kir.corp.google.com>
References: <1386197114-5317-1-git-send-email-hannes@cmpxchg.org> <1386197114-5317-3-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, 4 Dec 2013, Johannes Weiner wrote:

> 4942642080ea ("mm: memcg: handle non-error OOM situations more
> gracefully") allowed tasks that already entered a memcg OOM condition
> to bypass the memcg limit on subsequent allocation attempts hoping
> this would expedite finishing the page fault and executing the kill.
> 
> David Rientjes is worried that this breaks memcg isolation guarantees
> and since there is no evidence that the bypass actually speeds up
> fault processing just change it so that these subsequent charge
> attempts fail outright.  The notable exception being __GFP_NOFAIL
> charges which are required to bypass the limit regardless.
> 
> Reported-by: David Rientjes <rientjes@google.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: David Rientjes <rientjes@google.com>

Thanks!

I think we should consider marking this for stable@vger.kernel.org for 
3.12 since the original patch went into 3.12-rc6.  Depending on the number 
of allocators in the oom memcg, the amount of memory bypassed can become 
quite large.

For example, in a memcg with a limit of 128MB, if you start 10 concurrent 
processes that simply allocate a lot of memory you can get quite a bit of 
memory bypassed.  If I start 10 membench processes, which would cause a 
128MB memcg to oom even if only one such process were running, we get:

# grep RSS /proc/1092[0-9]/status
VmRSS:	   15724 kB
VmRSS:	   15064 kB
VmRSS:	   13224 kB
VmRSS:	   14520 kB
VmRSS:	   14472 kB
VmRSS:	   13016 kB
VmRSS:	   13024 kB
VmRSS:	   14560 kB
VmRSS:	   14864 kB
VmRSS:	   14772 kB

And all of those total ~140MB of memory while bound to a memcg with a 
128MB limit, about 10% of memory is bypassed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

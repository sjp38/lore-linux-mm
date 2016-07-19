Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2240F6B0005
	for <linux-mm@kvack.org>; Mon, 18 Jul 2016 22:01:07 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id qh10so8352665pac.2
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:01:07 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id d63si6523264pfc.34.2016.07.18.19.01.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Jul 2016 19:01:06 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id ks6so1752236pab.0
        for <linux-mm@kvack.org>; Mon, 18 Jul 2016 19:01:06 -0700 (PDT)
Date: Mon, 18 Jul 2016 19:00:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC PATCH 1/2] mempool: do not consume memory reserves from
 the reclaim path
In-Reply-To: <1468831285-27242-1-git-send-email-mhocko@kernel.org>
Message-ID: <alpine.DEB.2.10.1607181858020.16586@chino.kir.corp.google.com>
References: <1468831164-26621-1-git-send-email-mhocko@kernel.org> <1468831285-27242-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Mikulas Patocka <mpatocka@redhat.com>, Ondrej Kozina <okozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Mel Gorman <mgorman@suse.de>, Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, dm-devel@redhat.com, Michal Hocko <mhocko@suse.com>

On Mon, 18 Jul 2016, Michal Hocko wrote:

> David Rientjes was objecting that such an approach wouldn't help if the
> oom victim was blocked on a lock held by process doing mempool_alloc. This
> is very similar to other oom deadlock situations and we have oom_reaper
> to deal with them so it is reasonable to rely on the same mechanism
> rather inventing a different one which has negative side effects.
> 

Right, this causes oom livelock as described in the aforementioned thread: 
the oom victim is waiting on a mutex that is held by a thread doing 
mempool_alloc().  The oom reaper is not guaranteed to free any memory, so 
nothing on the system can allocate memory from the page allocator.

I think the better solution here is to allow mempool_alloc() users to set 
__GFP_NOMEMALLOC if they are in a context which allows them to deplete 
memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 69F6C6B0032
	for <linux-mm@kvack.org>; Wed,  1 Jul 2015 10:30:47 -0400 (EDT)
Received: by qkhu186 with SMTP id u186so30561736qkh.0
        for <linux-mm@kvack.org>; Wed, 01 Jul 2015 07:30:47 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 9si2406270qkq.48.2015.07.01.07.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jul 2015 07:30:46 -0700 (PDT)
Message-ID: <5593F98C.4010406@redhat.com>
Date: Wed, 01 Jul 2015 10:30:36 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
 allocations
References: <1435677437-16717-1-git-send-email-mhocko@suse.cz> <20150701061731.GB6286@dhcp22.suse.cz> <20150701133715.GA6287@dhcp22.suse.cz>
In-Reply-To: <20150701133715.GA6287@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Marian Marinov <mm@1h.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org

On 07/01/2015 09:37 AM, Michal Hocko wrote:

> Fix this issue by limiting the wait to reclaim triggered by __GFP_FS
> allocations to make sure we are not called from filesystem paths which
> might be doing exactly this kind of IO optimizations. The page fault
> path, which is the only path that triggers memcg oom killer since 3.12,
> shouldn't require GFP_NOFS and so we shouldn't reintroduce the premature
> OOM killer issue which was originally addressed by the heuristic.
> 
> As per David Chinner the xfs is doing similar thing since 2.6.15 already
> so ext4 is not the only affected filesystem. Moreover he notes:
> : For example: IO completion might require unwritten extent conversion
> : which executes filesystem transactions and GFP_NOFS allocations. The
> : writeback flag on the pages can not be cleared until unwritten
> : extent conversion completes. Hence memory reclaim cannot wait on
> : page writeback to complete in GFP_NOFS context because it is not
> : safe to do so, memcg reclaim or otherwise.

I remember fixing something like this back in the 2.2
days. Funny how these bugs keep coming back.

> Cc: stable # 3.6+
> Fixes: c3b94f44fcb0 ("memcg: further prevent OOM with too many dirty pages")
> Reported-by: Nikolay Borisov <kernel@kyup.com>
> Signed-off-by: Michal Hocko <mhocko@suse.cz>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

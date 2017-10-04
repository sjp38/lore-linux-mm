Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 29A0C6B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 04:33:46 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z1so11463533wre.6
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 01:33:46 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k27si13166682wrd.344.2017.10.04.01.33.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 01:33:44 -0700 (PDT)
Date: Wed, 4 Oct 2017 10:33:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: tty crash due to auto-failing vmalloc
Message-ID: <20171004083343.tqy5xjzyd332bwdn@dhcp22.suse.cz>
References: <20171003225504.GA966@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171003225504.GA966@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue 03-10-17 18:55:04, Johannes Weiner wrote:
[...]
> commit 5d17a73a2ebeb8d1c6924b91e53ab2650fe86ffb
> Author: Michal Hocko <mhocko@suse.com>
> Date:   Fri Feb 24 14:58:53 2017 -0800
> 
>     vmalloc: back off when the current task is killed
>     
>     __vmalloc_area_node() allocates pages to cover the requested vmalloc
>     size.  This can be a lot of memory.  If the current task is killed by
>     the OOM killer, and thus has an unlimited access to memory reserves, it
>     can consume all the memory theoretically.  Fix this by checking for
>     fatal_signal_pending and back off early.
>     
>     Link: http://lkml.kernel.org/r/20170201092706.9966-4-mhocko@kernel.org
>     Signed-off-by: Michal Hocko <mhocko@suse.com>
>     Reviewed-by: Christoph Hellwig <hch@lst.de>
>     Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>     Cc: Al Viro <viro@zeniv.linux.org.uk>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> This talks about the oom killer and memory exhaustion, but most fatal
> signals don't happen due to the OOM killer.

Now that we have cd04ae1e2dc8 ("mm, oom: do not rely on TIF_MEMDIE for
memory reserves access") the risk of the memory depletion is much
smaller so reverting the above commit should be acceptable. On the other
hand the failure is still possible and the caller should be prepared for
that.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

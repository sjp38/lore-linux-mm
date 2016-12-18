Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id A17596B0038
	for <linux-mm@kvack.org>; Sun, 18 Dec 2016 11:06:12 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so15765323wms.7
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:06:12 -0800 (PST)
Received: from mail-wj0-f195.google.com (mail-wj0-f195.google.com. [209.85.210.195])
        by mx.google.com with ESMTPS id lm8si15271273wjb.234.2016.12.18.08.06.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Dec 2016 08:06:11 -0800 (PST)
Received: by mail-wj0-f195.google.com with SMTP id j10so20606350wjb.3
        for <linux-mm@kvack.org>; Sun, 18 Dec 2016 08:06:10 -0800 (PST)
Date: Sun, 18 Dec 2016 17:06:08 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: crash during oom reaper
Message-ID: <20161218160608.GA8440@dhcp22.suse.cz>
References: <20161216090157.GA13940@dhcp22.suse.cz>
 <d944e3ca-07d4-c7d6-5025-dc101406b3a7@oracle.com>
 <20161216101113.GE13940@dhcp22.suse.cz>
 <20161216104438.GD27758@node>
 <20161216114243.GG13940@dhcp22.suse.cz>
 <20161216123555.GE27758@node>
 <20161216125650.GJ13940@dhcp22.suse.cz>
 <20161216130730.GF27758@node>
 <20161216131427.GM13940@dhcp22.suse.cz>
 <7918aa6b-8517-956b-5258-616ef1df6338@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7918aa6b-8517-956b-5258-616ef1df6338@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Vegard Nossum <vegard.nossum@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Rik van Riel <riel@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Sun 18-12-16 22:47:07, Tetsuo Handa wrote:
> On 2016/12/16 22:14, Michal Hocko wrote:
[...]
> > I would have to rememeber all the details. This is mostly off-topic for
> > this particular thread so I think it would be better if you could send a
> > full patch separatelly and we can discuss it there?
> > 
> 
> zap_page_range() calls mmu_notifier_invalidate_range_start().
> mmu_notifier_invalidate_range_start() calls __mmu_notifier_invalidate_range_start().
> __mmu_notifier_invalidate_range_start() calls srcu_read_lock()/srcu_read_unlock().
> This means that zap_page_range() might sleep.
> 
> I don't know what individual notifier will do, but for example
> 
>   static const struct mmu_notifier_ops i915_gem_userptr_notifier = {
>           .invalidate_range_start = i915_gem_userptr_mn_invalidate_range_start,
>   };
> 
> i915_gem_userptr_mn_invalidate_range_start() calls flush_workqueue()
> which means that we can OOM livelock if work item involves memory allocation.
> Some of other notifiers call mutex_lock()/mutex_unlock().
> 
> Even if none of currently in-tree notifier users are blocked on memory
> allocation, I think it is not guaranteed that future changes/users won't be
> blocked on memory allocation.

Kirill has sent this as a separate patchset [1]. Could you follow up on
that there please?

http://lkml.kernel.org/r/20161216141556.75130-4-kirill.shutemov@linux.intel.com

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

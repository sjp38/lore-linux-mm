Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CB776B0038
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 07:00:25 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id f16so7612726ioe.1
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 04:00:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i126si2215703ith.160.2017.11.03.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 03 Nov 2017 04:00:24 -0700 (PDT)
Subject: Re: [PATCH v17 3/6] mm/balloon_compaction.c: split balloon page allocation and enqueue
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
	<1509696786-1597-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1509696786-1597-4-git-send-email-wei.w.wang@intel.com>
Message-Id: <201711031959.CCC21876.tQFLHOOFVMJSFO@I-love.SAKURA.ne.jp>
Date: Fri, 3 Nov 2017 19:59:38 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: wei.w.wang@intel.com, virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Wei Wang wrote:
> Here's a detailed analysis of the deadlock by Tetsuo Handa:
> 
> In leak_balloon(), mutex_lock(&vb->balloon_lock) is called in order to
> serialize against fill_balloon(). But in fill_balloon(),
> alloc_page(GFP_HIGHUSER[_MOVABLE] | __GFP_NOMEMALLOC | __GFP_NORETRY) is
> called with vb->balloon_lock mutex held. Since GFP_HIGHUSER[_MOVABLE]
> implies __GFP_DIRECT_RECLAIM | __GFP_IO | __GFP_FS, despite __GFP_NORETRY
> is specified, this allocation attempt might indirectly depend on somebody
> else's __GFP_DIRECT_RECLAIM memory allocation. And such indirect
> __GFP_DIRECT_RECLAIM memory allocation might call leak_balloon() via
> virtballoon_oom_notify() via blocking_notifier_call_chain() callback via
> out_of_memory() when it reached __alloc_pages_may_oom() and held oom_lock
> mutex. Since vb->balloon_lock mutex is already held by fill_balloon(), it
> will cause OOM lockup. Thus, do not wait for vb->balloon_lock mutex if
> leak_balloon() is called from out_of_memory().

Please drop "Thus, do not wait for vb->balloon_lock mutex if leak_balloon()
is called from out_of_memory()." part. This is not what this patch will do.

> 
> Thread1                                Thread2
> fill_balloon()
>  takes a balloon_lock
>   balloon_page_enqueue()
>    alloc_page(GFP_HIGHUSER_MOVABLE)
>     direct reclaim (__GFP_FS context)  takes a fs lock
>      waits for that fs lock             alloc_page(GFP_NOFS)
>                                          __alloc_pages_may_oom()
>                                           takes the oom_lock
>                                            out_of_memory()
>                                             blocking_notifier_call_chain()
>                                              leak_balloon()
>                                                tries to take that
> 					       balloon_lock and deadlocks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

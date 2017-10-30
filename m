Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1696B0253
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 05:46:50 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id z80so11359151pff.11
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 02:46:50 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id f17si9657755pgn.596.2017.10.30.02.46.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 02:46:49 -0700 (PDT)
Message-ID: <59F6F58A.2030000@intel.com>
Date: Mon, 30 Oct 2017 17:48:58 +0800
From: Wei Wang <wei.w.wang@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] virtio_balloon: fix deadlock on OOM
References: <1507900754-32239-1-git-send-email-mst@redhat.com>
In-Reply-To: <1507900754-32239-1-git-send-email-mst@redhat.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael S. Tsirkin" <mst@redhat.com>, linux-kernel@vger.kernel.org
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michal Hocko <mhocko@suse.com>, Jason Wang <jasowang@redhat.com>, virtualization@lists.linux-foundation.org, linux-mm@kvack.org

On 10/13/2017 09:21 PM, Michael S. Tsirkin wrote:
> fill_balloon doing memory allocations under balloon_lock
> can cause a deadlock when leak_balloon is called from
> virtballoon_oom_notify and tries to take same lock.
>
> To fix, split page allocation and enqueue and do allocations outside the lock.
>
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
>
>    Thread1                                       Thread2
>      fill_balloon()
>        takes a balloon_lock
>        balloon_page_enqueue()
>          alloc_page(GFP_HIGHUSER_MOVABLE)
>            direct reclaim (__GFP_FS context)       takes a fs lock
>              waits for that fs lock                  alloc_page(GFP_NOFS)
>                                                        __alloc_pages_may_oom()
>                                                          takes the oom_lock
>                                                          out_of_memory()
>                                                            blocking_notifier_call_chain()
>                                                              leak_balloon()
>                                                                tries to take that balloon_lock and deadlocks
>
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Wei Wang <wei.w.wang@intel.com>
> ---

The "virtio-balloon enhancement" series has a dependency on this patch.
Could you send out a new version soon? Or I can include it in the series 
if you want.


Best,
Wei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

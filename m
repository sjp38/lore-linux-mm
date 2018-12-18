Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 655BF8E0001
	for <linux-mm@kvack.org>; Mon, 17 Dec 2018 23:38:39 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so19646879qtr.7
        for <linux-mm@kvack.org>; Mon, 17 Dec 2018 20:38:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h14si4570340qvc.2.2018.12.17.20.38.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 20:38:38 -0800 (PST)
Date: Mon, 17 Dec 2018 23:38:35 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] Export mm_update_next_owner function for unuse_mm.
Message-ID: <20181217233821-mutt-send-email-mst@kernel.org>
References: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1545104531-30658-1-git-send-email-gchen.guomin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gchen.guomin@gmail.com
Cc: Jason Wang <jasowang@redhat.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, "Luis R. Rodriguez" <mcgrof@kernel.org>, guominchen@tencent.com, "Eric W. Biederman" <ebiederm@xmission.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Dec 18, 2018 at 11:42:11AM +0800, gchen.guomin@gmail.com wrote:
> From: guomin chen <gchen.guomin@gmail.com>
> 
> When mm->owner is modified by exit_mm, if the new owner directly calls
> unuse_mm to exit, it will cause Use-After-Free. Due to the unuse_mm()
> directly sets tsk->mm=NULL.
> 
>  Under normal circumstances,When do_exit exits, mm->owner will
>  be updated on exit_mm(). but when the kernel process calls
>  unuse_mm() and then exits,mm->owner cannot be updated. And it
>  will point to a task that has been released.
> 
> The current issue flow is as follows:
> Process C              Process A         Process B
> qemu-system-x86_64:     kernel:vhost_net  kernel: vhost_net
> open /dev/vhost-net
>   VHOST_SET_OWNER   create kthread vhost-%d  create kthread vhost-%d
>   network init           use_mm()          use_mm()
>    ...                   ...
>    Abnormal exited
>    ...
>   do_exit
>   exit_mm()
>   update mm->owner to A
>   exit_files()
>    close_files()
>    kthread_should_stop() unuse_mm()
>     Stop Process A       tsk->mm=NULL
>                          do_exit()
>                          can't update owner
>                          A exit completed  vhost-%d  rcv first package
>                                            vhost-%d build rcv buffer for vq
>                                            page fault
>                                            access mm & mm->owner
>                                            NOW,mm->owner still pointer A
>                                            kernel UAF
>     stop Process B
> 
> Although I am having this issue on vhost_net,But it affects all users of
> unuse_mm.
> 
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>
> Cc: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Arnd Bergmann <arnd@arndb.de>
> Cc: linux-kernel@vger.kernel.org
> Cc: linux-mm@kvack.org
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: Christoph Hellwig <hch@infradead.org>
> Signed-off-by: guomin chen <gchen.guomin@gmail.com>
> ---
>  kernel/exit.c    | 1 +
>  mm/mmu_context.c | 1 +
>  2 files changed, 2 insertions(+)
> 
> diff --git a/kernel/exit.c b/kernel/exit.c
> index 0e21e6d..9e046dd 100644
> --- a/kernel/exit.c
> +++ b/kernel/exit.c
> @@ -486,6 +486,7 @@ void mm_update_next_owner(struct mm_struct *mm)
>  	task_unlock(c);
>  	put_task_struct(c);
>  }
> +EXPORT_SYMBOL(mm_update_next_owner);
>  #endif /* CONFIG_MEMCG */
>  
>  /*

So why export it? Is that still needed?

> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index 3e612ae..9eb81aa 100644
> --- a/mm/mmu_context.c
> +++ b/mm/mmu_context.c
> @@ -60,5 +60,6 @@ void unuse_mm(struct mm_struct *mm)
>  	/* active_mm is still 'mm' */
>  	enter_lazy_tlb(mm, tsk);
>  	task_unlock(tsk);
> +	mm_update_next_owner(mm);
>  }
>  EXPORT_SYMBOL_GPL(unuse_mm);
> -- 
> 1.8.3.1

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id B1C1A8E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 20:36:29 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id d35so10270459qtd.20
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 17:36:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b50si6373507qtb.258.2018.12.09.17.36.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Dec 2018 17:36:28 -0800 (PST)
Date: Sun, 9 Dec 2018 20:36:26 -0500
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH]  Fix mm->owner point to a task that does not exists
Message-ID: <20181209201309-mutt-send-email-mst@kernel.org>
References: <1544340077-11491-1-git-send-email-gchen.guomin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1544340077-11491-1-git-send-email-gchen.guomin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gchen.guomin@gmail.com
Cc: guominchen <guominchen@tencent.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com

On Sun, Dec 09, 2018 at 03:21:17PM +0800, gchen.guomin@gmail.com wrote:
> From: guominchen <guominchen@tencent.com>
> 
>   Under normal circumstances,When do_exit exits, mm->owner will
>   be updated, but when the kernel process calls unuse_mm and exits,
>   mm->owner cannot be updated. And will point to a task that has
>   been released.
> 
>   Below is my issue on vhost_net:
>     A, B are two kernel processes(such as vhost_worker),
>     C is a user space process(such as qemu), and all
>     three use the mm of the user process C.
>     Now, because user process C exits abnormally, the owner of this
>     mm becomes A. When A calls unuse_mm and exits, this mm->ower
>     still points to the A that has been released.
>     When B accesses this mm->owner again, A has been released.
> 
>   Process A		Process B
>  vhost_worker()	       vhost_worker()
>   ---------    		---------
>   use_mm()		use_mm()
>    ...
>   unuse_mm()
>      tsk->mm=NULL
>    do_exit()     	page fault
>     exit_mm()	 	access mm->owner
>    can't update owner	kernel Oops
> 
> 			unuse_mm()
> 
> Cc: <linux-mm@kvack.org>
> Cc: <linux-kernel@vger.kernel.org>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Jason Wang <jasowang@redhat.com>
> Cc: <netdev@vger.kernel.org>
> Signed-off-by: guominchen <guominchen@tencent.com>
> ---
>  mm/mmu_context.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/mm/mmu_context.c b/mm/mmu_context.c
> index 3e612ae..185bb23 100644
> --- a/mm/mmu_context.c
> +++ b/mm/mmu_context.c
> @@ -56,7 +56,6 @@ void unuse_mm(struct mm_struct *mm)
>  
>  	task_lock(tsk);
>  	sync_mm_rss(mm);
> -	tsk->mm = NULL;
>  	/* active_mm is still 'mm' */
>  	enter_lazy_tlb(mm, tsk);
>  	task_unlock(tsk);

So that will work for vhost because we never drop
the mm reference before destroying the task.
I wonder whether that's true for other users though.

It would seem cleaner to onvoke some callback so
tasks such as vhost can drop the reference.

And looking at all this code, I don't understand why
is mm->owner safe to change like this:
        mm->owner = NULL;

when users seem to use it under RCU.



> -- 
> 1.8.3.1

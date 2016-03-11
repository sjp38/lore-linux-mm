Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 540D16B0254
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 06:18:40 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id p65so13712841wmp.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 03:18:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gz10si10455106wjc.107.2016.03.11.03.18.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Mar 2016 03:18:39 -0800 (PST)
Subject: Re: [PATCH] ipc, shm: make shmem attach/detach wait for mmap_sem
 killable
References: <1456752417-9626-10-git-send-email-mhocko@kernel.org>
 <1457518778-32235-1-git-send-email-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56E2A98E.5070302@suse.cz>
Date: Fri, 11 Mar 2016 12:18:38 +0100
MIME-Version: 1.0
In-Reply-To: <1457518778-32235-1-git-send-email-mhocko@kernel.org>
Content-Type: text/plain; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Davidlohr Bueso <dave@stgolabs.net>, Michal Hocko <mhocko@suse.com>, Hugh Dickins <hughd@google.com>

On 03/09/2016 11:19 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> shmat and shmdt rely on mmap_sem for write. If the waiting task
> gets killed by the oom killer it would block oom_reaper from
> asynchronous address space reclaim and reduce the chances of timely
> OOM resolving. Wait for the lock in the killable mode and return with
> EINTR if the task got killed while waiting.
>
> Cc: Hugh Dickins <hughd@google.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> Acked-by: Davidlohr Bueso <dave@stgolabs.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>   ipc/shm.c | 9 +++++++--
>   1 file changed, 7 insertions(+), 2 deletions(-)
>
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 331fc1b0b3c7..13282510bc0d 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -1200,7 +1200,11 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
>   	if (err)
>   		goto out_fput;
>
> -	down_write(&current->mm->mmap_sem);
> +	if (down_write_killable(&current->mm->mmap_sem)) {
> +		err = -EINTR;
> +		goto out_fput;
> +	}
> +
>   	if (addr && !(shmflg & SHM_REMAP)) {
>   		err = -EINVAL;
>   		if (addr + size < addr)
> @@ -1271,7 +1275,8 @@ SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
>   	if (addr & ~PAGE_MASK)
>   		return retval;
>
> -	down_write(&mm->mmap_sem);
> +	if (down_write_killable(&mm->mmap_sem))
> +		return -EINTR;
>
>   	/*
>   	 * This function tries to be smart and unmap shm segments that
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

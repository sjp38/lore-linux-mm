Date: Tue, 10 Jul 2007 09:41:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] do not limit locked memory when RLIMIT_MEMLOCK is
 RLIM_INFINITY
Message-Id: <20070710094114.86db9e84.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4692D230.3050403@oracle.com>
References: <4692D230.3050403@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Herbert van den Bergh <Herbert.van.den.Bergh@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Dave McCracken <dave.mccracken@oracle.com>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Mon, 09 Jul 2007 17:26:24 -0700
Herbert van den Bergh <Herbert.van.den.Bergh@oracle.com> wrote:

> 
> This patch fixes a bug in mm/mlock.c on 32-bit architectures that prevents
> a user from locking more than 4GB of shared memory, or allocating more
> than 4GB of shared memory in hugepages, when rlim[RLIMIT_MEMLOCK] is
> set to RLIM_INFINITY.
> 
just curious...why a resouce which can be used longer than a process's
lifetime is limited by RLIMIT ?

Thanks,
-Kame


> Signed-off-by: Herbert van den Bergh <herbert.van.den.bergh@oracle.com>
> Acked-by: Chris Mason <chris.mason@oracle.com>
> 
> --- linux-2.6.22/mm/mlock.c.orig    2007-07-09 10:19:31.000000000 -0700
> +++ linux-2.6.22/mm/mlock.c    2007-07-09 10:19:19.000000000 -0700
> @@ -244,9 +244,12 @@ int user_shm_lock(size_t size, struct us
>  
>      locked = (size + PAGE_SIZE - 1) >> PAGE_SHIFT;
>      lock_limit = current->signal->rlim[RLIMIT_MEMLOCK].rlim_cur;
> +    if (lock_limit == RLIM_INFINITY)
> +        allowed = 1;
>      lock_limit >>= PAGE_SHIFT;
>      spin_lock(&shmlock_user_lock);
> -    if (locked + user->locked_shm > lock_limit && !capable(CAP_IPC_LOCK))
> +    if (!allowed &&
> +        locked + user->locked_shm > lock_limit && !capable(CAP_IPC_LOCK))
>          goto out;
>      get_uid(user);
>      user->locked_shm += locked;
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

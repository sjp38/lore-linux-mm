Date: Mon, 9 Jul 2007 17:47:45 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: [PATCH] do not limit locked memory when RLIMIT_MEMLOCK is
 RLIM_INFINITY
Message-Id: <20070709174745.34668a90.randy.dunlap@oracle.com>
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

On Mon, 09 Jul 2007 17:26:24 -0700 Herbert van den Bergh wrote:

> 
> This patch fixes a bug in mm/mlock.c on 32-bit architectures that prevents
> a user from locking more than 4GB of shared memory, or allocating more
> than 4GB of shared memory in hugepages, when rlim[RLIMIT_MEMLOCK] is
> set to RLIM_INFINITY.

Something has converted tabs to spaces in your patch.
Ah, thunderbird.  Did you use an external editor plugin?

If not, did you use preformat and other instructions from
http://mbligh.org/linuxdocs/Email/Clients/Thunderbird ?

Please send a patch to yourself and make sure that you can apply
the received patch cleanly.

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

---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

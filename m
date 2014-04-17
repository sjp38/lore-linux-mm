Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 399486B0081
	for <linux-mm@kvack.org>; Thu, 17 Apr 2014 06:54:14 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id bs8so2560057wib.1
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 03:54:13 -0700 (PDT)
Received: from mail-we0-x236.google.com (mail-we0-x236.google.com [2a00:1450:400c:c03::236])
        by mx.google.com with ESMTPS id eh10si1134649wib.58.2014.04.17.03.54.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Apr 2014 03:54:12 -0700 (PDT)
Received: by mail-we0-f182.google.com with SMTP id p61so279420wes.13
        for <linux-mm@kvack.org>; Thu, 17 Apr 2014 03:54:12 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1397272942.2686.4.camel@buesod1.americas.hpqcorp.net>
References: <1397272942.2686.4.camel@buesod1.americas.hpqcorp.net>
From: Michael Kerrisk <mtk.manpages@gmail.com>
Date: Thu, 17 Apr 2014 12:53:52 +0200
Message-ID: <CAHO5Pa3BOgJGCm7NvE4xbm3O1WbRLRBS0pgvErPudypP_iiZ3g@mail.gmail.com>
Subject: Re: [PATCH v2] ipc,shm: disable shmmax and shmall by default
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Michael Kerrisk-manpages <mtk.manpages@gmail.com>

On Sat, Apr 12, 2014 at 5:22 AM, Davidlohr Bueso <davidlohr@hp.com> wrote:
> From: Davidlohr Bueso <davidlohr@hp.com>
>
> The default size for shmmax is, and always has been, 32Mb.
> Today, in the XXI century, it seems that this value is rather small,
> making users have to increase it via sysctl, which can cause
> unnecessary work and userspace application workarounds[1].
>
> Instead of choosing yet another arbitrary value, larger than 32Mb,
> this patch disables the use of both shmmax and shmall by default,
> allowing users to create segments of unlimited sizes. Users and
> applications that already explicitly set these values through sysctl
> are left untouched, and thus does not change any of the behavior.
>
> So a value of 0 bytes or pages, for shmmax and shmall, respectively,
> implies unlimited memory, as opposed to disabling sysv shared memory.
> This is safe as 0 cannot possibly be used previously as SHMMIN is
> hardcoded to 1 and cannot be modified.
>
> This change allows Linux to treat shm just as regular anonymous memory.
> One important difference between them, though, is handling out-of-memory
> conditions: as opposed to regular anon memory, the OOM killer will not
> free the memory as it is shm, allowing users to potentially abuse this.
> To overcome this situation, the shm_rmid_forced option must be enabled.
>
> [1]: http://rhaas.blogspot.com/2012/06/absurd-shared-memory-limits.html
>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Of the two proposed approaches (the other being
marc.info/?l=linux-kernel&m=139730332306185), this looks preferable to
me, since it allows strange users to maintain historical behavior
(i.e., the ability to set a limit) if they really want it, so:

Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>

One or two comments below, that you might consider for your v3 patch.

> ---
> Changes from v1:
>  - Respect SHMMIN even when shmmax is 0 (unlimited).
>    This fixes the shmget02 test that broke in v1. (per Manfred)
>
>  - Update changelog regarding OOM description (per Kosaki)
>
>  include/linux/shm.h      | 2 +-
>  include/uapi/linux/shm.h | 8 ++++----
>  ipc/shm.c                | 6 ++++--
>  3 files changed, 9 insertions(+), 7 deletions(-)
>
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index 1e2cd2e..0ca06a3 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -4,7 +4,7 @@
>  #include <asm/page.h>
>  #include <uapi/linux/shm.h>
>
> -#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
> +#define SHMALL 0 /* max shm system wide (pages) */
>  #include <asm/shmparam.h>
>  struct shmid_kernel /* private to the kernel */
>  {
> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> index 78b6941..5f0ef28 100644
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -9,14 +9,14 @@
>
>  /*
>   * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
> - * be increased by sysctl
> + * be increased by sysctl. By default, disable SHMMAX and SHMALL with

s/increased/modified/

> + * 0 bytes, thus allowing processes to have unlimited shared memory.
>   */
> -
> -#define SHMMAX 0x2000000                /* max shared seg size (bytes) */
> +#define SHMMAX 0                        /* max shared seg size (bytes) */

I suggest: s/(bytes)/(bytes); 0 means "no limit" */

>  #define SHMMIN 1                        /* min shared seg size (bytes) */
>  #define SHMMNI 4096                     /* max num of segs system wide */
>  #ifndef __KERNEL__
> -#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
> +#define SHMALL 0

As long as we're here, let's add a meaningful comment to that one:

/* system-wide limit on number of pages of shared memory; 0 means "no limit" */

Cheers,

Michael


>  #endif
>  #define SHMSEG SHMMNI                   /* max shared segs per process */
>
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 7645961..8630561 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -490,10 +490,12 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>         int id;
>         vm_flags_t acctflag = 0;
>
> -       if (size < SHMMIN || size > ns->shm_ctlmax)
> +       if (size < SHMMIN ||
> +           (ns->shm_ctlmax && size > ns->shm_ctlmax))
>                 return -EINVAL;
>
> -       if (ns->shm_tot + numpages > ns->shm_ctlall)
> +       if (ns->shm_ctlall &&
> +           ns->shm_tot + numpages > ns->shm_ctlall)
>                 return -ENOSPC;
>
>         shp = ipc_rcu_alloc(sizeof(*shp));
> --
> 1.8.1.4
>
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Michael Kerrisk Linux man-pages maintainer;
http://www.kernel.org/doc/man-pages/
Author of "The Linux Programming Interface", http://blog.man7.org/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

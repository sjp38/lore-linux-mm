Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id D07486B0036
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 18:30:10 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va2so2719508obc.0
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 15:30:10 -0700 (PDT)
Received: from mail-ob0-x231.google.com (mail-ob0-x231.google.com [2607:f8b0:4003:c01::231])
        by mx.google.com with ESMTPS id sm4si5455448obb.112.2014.04.03.15.30.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 03 Apr 2014 15:30:10 -0700 (PDT)
Received: by mail-ob0-f177.google.com with SMTP id wo20so2573035obc.36
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 15:30:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
 <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
 <1396306773.18499.22.camel@buesod1.americas.hpqcorp.net> <20140331161308.6510381345cb9a1b419d5ec0@linux-foundation.org>
 <1396308332.18499.25.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org>
 <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com>
 <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com>
 <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com>
 <20140401142947.927642a408d84df27d581e36@linux-foundation.org>
 <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com>
 <20140401144801.603c288674ab8f417b42a043@linux-foundation.org>
 <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com>
 <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com>
 <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 3 Apr 2014 18:29:49 -0400
Message-ID: <CAHGf_=r2=LEEW=ZcxQcCWVdEnLWPTkKhSgKBaRA01ge9Dk3FeQ@mail.gmail.com>
Subject: Re: [PATCH] ipc,shm: disable shmmax and shmall by default
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Apr 2, 2014 at 8:20 PM, Davidlohr Bueso <davidlohr@hp.com> wrote:
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
> kill processes that are hogging memory through shm, allowing users to
> potentially abuse this. To overcome this situation, the shm_rmid_forced
> option must be enabled.

I'm very slightly against this sentence.

OOM killer WILL kill the process because shm touching increase RSS anyway.
But the killing doesn't make memory freeing because it's shmem.

>
> Running this patch through LTP, everything passes, except the following,
> which, due to the nature of this change, is quite expected:
>
> shmget02    1  TFAIL  :  call succeeded unexpectedly
>
> [1]: http://rhaas.blogspot.com/2012/06/absurd-shared-memory-limits.html
>
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> ---
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
> + * 0 bytes, thus allowing processes to have unlimited shared memory.
>   */
> -
> -#define SHMMAX 0x2000000                /* max shared seg size (bytes) */
> +#define SHMMAX 0                        /* max shared seg size (bytes) */
>  #define SHMMIN 1                        /* min shared seg size (bytes) */
>  #define SHMMNI 4096                     /* max num of segs system wide */
>  #ifndef __KERNEL__
> -#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
> +#define SHMALL 0
>  #endif
>  #define SHMSEG SHMMNI                   /* max shared segs per process */
>
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 7645961..ae01ffa 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -490,10 +490,12 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>         int id;
>         vm_flags_t acctflag = 0;
>
> -       if (size < SHMMIN || size > ns->shm_ctlmax)
> +       if (ns->shm_ctlmax &&
> +           (size < SHMMIN || size > ns->shm_ctlmax))
>                 return -EINVAL;
>
> -       if (ns->shm_tot + numpages > ns->shm_ctlall)
> +       if (ns->shm_ctlall &&
> +           ns->shm_tot + numpages > ns->shm_ctlall)
>                 return -ENOSPC;
>
>         shp = ipc_rcu_alloc(sizeof(*shp));

Looks good.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

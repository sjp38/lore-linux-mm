Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f50.google.com (mail-ee0-f50.google.com [74.125.83.50])
	by kanga.kvack.org (Postfix) with ESMTP id DFB4B6B0073
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 01:05:58 -0400 (EDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so288394eek.23
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:58 -0700 (PDT)
Received: from mail-ee0-x232.google.com (mail-ee0-x232.google.com [2a00:1450:4013:c00::232])
        by mx.google.com with ESMTPS id q5si1268508eem.321.2014.04.22.22.05.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 22:05:57 -0700 (PDT)
Received: by mail-ee0-f50.google.com with SMTP id c13so282809eek.37
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:57 -0700 (PDT)
Message-ID: <5357490E.1010505@gmail.com>
Date: Wed, 23 Apr 2014 07:01:02 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] ipc/shm.c: Increase the defaults for SHMALL, SHMMAX.
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398090397-2397-2-git-send-email-manfred@colorfullife.com> <1398090397-2397-3-git-send-email-manfred@colorfullife.com> <1398090397-2397-4-git-send-email-manfred@colorfullife.com> <1398090397-2397-5-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-5-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: mtk.manpages@gmail.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/21/2014 04:26 PM, Manfred Spraul wrote:
> System V shared memory
> 
> a) can be abused to trigger out-of-memory conditions and the standard
>    measures against out-of-memory do not work:
> 
>     - it is not possible to use setrlimit to limit the size of shm segments.
> 
>     - segments can exist without association with any processes, thus
>       the oom-killer is unable to free that memory.
> 
> b) is typically used for shared information - today often multiple GB.
>    (e.g. database shared buffers)
> 
> The current default is a maximum segment size of 32 MB and a maximum total
> size of 8 GB. This is often too much for a) and not enough for b), which
> means that lots of users must change the defaults.
> 
> This patch increases the default limits (nearly) to the maximum, which is
> perfect for case b). The defaults are used after boot and as the initial
> value for each new namespace.
> 
> Admins/distros that need a protection against a) should reduce the limits
> and/or enable shm_rmid_forced.
> 
> Further notes:
> - The patch only changes default, overrides behave as before:
>         # sysctl kernel.shmall=33554432
>   would recreate the previous limit for SHMMAX (for the current namespace).
> 
> - Disabling sysv shm allocation is possible with:
>         # sysctl kernel.shmall=0
>   (not a new feature, also per-namespace)
> 
> - The limits are intentionally set to a value slightly less than ULONG_MAX,
>   to avoid triggering overflows in user space apps.
>   [not unreasonable, see http://marc.info/?l=linux-mm&m=139638334330127]
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> Reported-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: mtk.manpages@gmail.com
> ---
>  include/linux/shm.h      | 3 +--
>  include/uapi/linux/shm.h | 8 +++-----
>  2 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/include/linux/shm.h b/include/linux/shm.h
> index 1e2cd2e..57d7770 100644
> --- a/include/linux/shm.h
> +++ b/include/linux/shm.h
> @@ -3,9 +3,8 @@
>  
>  #include <asm/page.h>
>  #include <uapi/linux/shm.h>
> -
> -#define SHMALL (SHMMAX/PAGE_SIZE*(SHMMNI/16)) /* max shm system wide (pages) */
>  #include <asm/shmparam.h>
> +
>  struct shmid_kernel /* private to the kernel */
>  {	
>  	struct kern_ipc_perm	shm_perm;
> diff --git a/include/uapi/linux/shm.h b/include/uapi/linux/shm.h
> index 78b6941..74e786d 100644
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -9,15 +9,13 @@
>  
>  /*
>   * SHMMAX, SHMMNI and SHMALL are upper limits are defaults which can
> - * be increased by sysctl
> + * be modified by sysctl.
>   */
>  
> -#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
>  #define SHMMIN 1			 /* min shared seg size (bytes) */
>  #define SHMMNI 4096			 /* max num of segs system wide */
> -#ifndef __KERNEL__
> -#define SHMALL (SHMMAX/getpagesize()*(SHMMNI/16))
> -#endif
> +#define SHMMAX (ULONG_MAX - (1L<<24))	 /* max shared seg size (bytes) */
> +#define SHMALL (ULONG_MAX - (1L<<24))	 /* max shm system wide (pages) */
>  #define SHMSEG SHMMNI			 /* max shared segs per process */

Acked-by: Michael Kerrisk <mtk.manpages@gmail.com>


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

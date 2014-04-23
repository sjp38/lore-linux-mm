Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 2AB176B0070
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 01:05:54 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so291635eek.31
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:53 -0700 (PDT)
Received: from mail-ee0-x22b.google.com (mail-ee0-x22b.google.com [2a00:1450:4013:c00::22b])
        by mx.google.com with ESMTPS id d5si1306663eei.148.2014.04.22.22.05.52
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 22:05:52 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so287710eek.16
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:52 -0700 (PDT)
Message-ID: <53574888.4090602@gmail.com>
Date: Wed, 23 Apr 2014 06:58:48 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] ipc/shm.c: check for overflows of shm_tot
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398090397-2397-2-git-send-email-manfred@colorfullife.com> <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-3-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: mtk.manpages@gmail.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/21/2014 04:26 PM, Manfred Spraul wrote:
> shm_tot counts the total number of pages used by shm segments.
> 
> If SHMALL is ULONG_MAX (or nearly ULONG_MAX), then the number
> can overflow.  Subsequent calls to shmctl(,SHM_INFO,) would return
> wrong values for shm_tot.
> 
> The patch adds a detection for overflows.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> ---
>  ipc/shm.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 382e2fb..2dfa3d6 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -493,7 +493,8 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  	if (size < SHMMIN || size > ns->shm_ctlmax)
>  		return -EINVAL;
>  
> -	if (ns->shm_tot + numpages > ns->shm_ctlall)
> +	if (ns->shm_tot + numpages < ns->shm_tot ||
> +			ns->shm_tot + numpages > ns->shm_ctlall)
>  		return -ENOSPC;
>  
>  	shp = ipc_rcu_alloc(sizeof(*shp));
> 

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

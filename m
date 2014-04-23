Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id E5FB26B0071
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 01:05:56 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so287752eek.16
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:56 -0700 (PDT)
Received: from mail-ee0-x22c.google.com (mail-ee0-x22c.google.com [2a00:1450:4013:c00::22c])
        by mx.google.com with ESMTPS id g45si1304199eev.160.2014.04.22.22.05.55
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 22:05:55 -0700 (PDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so296717eek.3
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:55 -0700 (PDT)
Message-ID: <535748AD.9000804@gmail.com>
Date: Wed, 23 Apr 2014 06:59:25 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] ipc/shm.c: check for integer overflow during shmget.
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398090397-2397-2-git-send-email-manfred@colorfullife.com> <1398090397-2397-3-git-send-email-manfred@colorfullife.com> <1398090397-2397-4-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-4-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: mtk.manpages@gmail.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/21/2014 04:26 PM, Manfred Spraul wrote:
> SHMMAX is the upper limit for the size of a shared memory segment,
> counted in bytes. The actual allocation is that size, rounded up to
> the next full page.
> Add a check that prevents the creation of segments where the
> rounded up size causes an integer overflow.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> ---
>  ipc/shm.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 2dfa3d6..f000696 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -493,6 +493,9 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  	if (size < SHMMIN || size > ns->shm_ctlmax)
>  		return -EINVAL;
>  
> +	if (numpages << PAGE_SHIFT < size)
> +		return -ENOSPC;
> +
>  	if (ns->shm_tot + numpages < ns->shm_tot ||
>  			ns->shm_tot + numpages > ns->shm_ctlall)
>  		return -ENOSPC;
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

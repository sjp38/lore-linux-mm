Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 290956B0070
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 01:05:52 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id b57so287189eek.35
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:51 -0700 (PDT)
Received: from mail-ee0-x22b.google.com (mail-ee0-x22b.google.com [2a00:1450:4013:c00::22b])
        by mx.google.com with ESMTPS id z2si1326155eeo.64.2014.04.22.22.05.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 22 Apr 2014 22:05:50 -0700 (PDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so290897eek.30
        for <linux-mm@kvack.org>; Tue, 22 Apr 2014 22:05:50 -0700 (PDT)
Message-ID: <53574867.5010108@gmail.com>
Date: Wed, 23 Apr 2014 06:58:15 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/4] ipc/shm.c: check for ulong overflows in shmat
References: <1398090397-2397-1-git-send-email-manfred@colorfullife.com> <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
In-Reply-To: <1398090397-2397-2-git-send-email-manfred@colorfullife.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manfred Spraul <manfred@colorfullife.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: mtk.manpages@gmail.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, gthelen@google.com, aswin@hp.com, linux-mm@kvack.org

On 04/21/2014 04:26 PM, Manfred Spraul wrote:
> find_vma_intersection does not work as intended if addr+size overflows.
> The patch adds a manual check before the call to find_vma_intersection.
> 
> Signed-off-by: Manfred Spraul <manfred@colorfullife.com>
> ---
>  ipc/shm.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 7645961..382e2fb 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -1160,6 +1160,9 @@ long do_shmat(int shmid, char __user *shmaddr, int shmflg, ulong *raddr,
>  	down_write(&current->mm->mmap_sem);
>  	if (addr && !(shmflg & SHM_REMAP)) {
>  		err = -EINVAL;
> +		if (addr + size < addr)
> +			goto invalid;
> +
>  		if (find_vma_intersection(current->mm, addr, addr + size))
>  			goto invalid;
>  		/*
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

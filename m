Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f43.google.com (mail-ee0-f43.google.com [74.125.83.43])
	by kanga.kvack.org (Postfix) with ESMTP id 1CFCD6B003B
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 14:28:22 -0400 (EDT)
Received: by mail-ee0-f43.google.com with SMTP id e53so4452959eek.30
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 11:28:21 -0700 (PDT)
Received: from mail-ee0-f46.google.com (mail-ee0-f46.google.com [74.125.83.46])
        by mx.google.com with ESMTPS id v2si11549880eel.136.2014.04.11.11.28.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 11:28:20 -0700 (PDT)
Received: by mail-ee0-f46.google.com with SMTP id t10so4425156eei.19
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 11:28:19 -0700 (PDT)
Message-ID: <5348343F.6030300@colorfullife.com>
Date: Fri, 11 Apr 2014 20:28:15 +0200
From: Manfred Spraul <manfred@colorfullife.com>
MIME-Version: 1.0
Subject: Re: [PATCH] ipc,shm: disable shmmax and shmall by default
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net> <20140331170546.3b3e72f0.akpm@linux-foundation.org> <1396371699.25314.11.camel@buesod1.americas.hpqcorp.net> <CAHGf_=qsf6vN5k=-PLraG8Q_uU1pofoBDktjVH1N92o76xPadQ@mail.gmail.com> <1396377083.25314.17.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rLLBDr5ptLMvFD-M+TPQSnK3EP=7R+27K8or84rY-KLA@mail.gmail.com> <1396386062.25314.24.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rhXrBQSmDBJJ-vPxBbhjJ91Fh2iWe1cf_UQd-tCfpb2w@mail.gmail.com> <20140401142947.927642a408d84df27d581e36@linux-foundation.org> <CAHGf_=p70rLOYwP2OgtK+2b+41=GwMA9R=rZYBqRr1w_O5UnKA@mail.gmail.com> <20140401144801.603c288674ab8f417b42a043@linux-foundation.org> <CAHGf_=r5AUu6yvJgOzwYDghBo6iT2q+nNumpvqwer+igcfChrA@mail.gmail.com> <1396394931.25314.34.camel@buesod1.americas.hpqcorp.net> <CAHGf_=rH+vfFzRrh35TETxjFU2HM0xnDQFweQ+Bfw20Pm2nL3g@mail.gmail.com> <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
In-Reply-To: <1396484447.2953.1.camel@buesod1.americas.hpqcorp.net>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, aswin@hp.com, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Greg Thelen <gthelen@google.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Hi Davidlohr,

On 04/03/2014 02:20 AM, Davidlohr Bueso wrote:
> The default size for shmmax is, and always has been, 32Mb.
> Today, in the XXI century, it seems that this value is rather small,
> making users have to increase it via sysctl, which can cause
> unnecessary work and userspace application workarounds[1].
>
> [snip]
> Running this patch through LTP, everything passes, except the following,
> which, due to the nature of this change, is quite expected:
>
> shmget02    1  TFAIL  :  call succeeded unexpectedly
Why is this TFAIL expected?
>
> diff --git a/ipc/shm.c b/ipc/shm.c
> index 7645961..ae01ffa 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -490,10 +490,12 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>   	int id;
>   	vm_flags_t acctflag = 0;
>   
> -	if (size < SHMMIN || size > ns->shm_ctlmax)
> +	if (ns->shm_ctlmax &&
> +	    (size < SHMMIN || size > ns->shm_ctlmax))
>   		return -EINVAL;
>   
> -	if (ns->shm_tot + numpages > ns->shm_ctlall)
> +	if (ns->shm_ctlall &&
> +	    ns->shm_tot + numpages > ns->shm_ctlall)
>   		return -ENOSPC;
>   
>   	shp = ipc_rcu_alloc(sizeof(*shp));
Ok, I understand it:
Your patch disables checking shmmax, shmall *AND* checking for SHMMIN.

a) Have you double checked that 0-sized shm segments work properly?
  Does the swap code handle it properly, ...?

b) It's that yet another risk for user space incompatibility?

c) The patch summary is misleading, the impact on SHMMIN is not mentioned.

--
     Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

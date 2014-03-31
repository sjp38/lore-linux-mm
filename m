Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 429146B0035
	for <linux-mm@kvack.org>; Mon, 31 Mar 2014 17:32:20 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so8851101pbb.11
        for <linux-mm@kvack.org>; Mon, 31 Mar 2014 14:32:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id dw1si2243852pbc.304.2014.03.31.14.32.18
        for <linux-mm@kvack.org>;
        Mon, 31 Mar 2014 14:32:18 -0700 (PDT)
Date: Mon, 31 Mar 2014 14:32:17 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc,shm: increase default size for shmmax
Message-Id: <20140331143217.c6ff958e1fd9944d78507418@linux-foundation.org>
In-Reply-To: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
References: <1396235199.2507.2.camel@buesod1.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>
Cc: Manfred Spraul <manfred@colorfullife.com>, aswin@hp.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, 30 Mar 2014 20:06:39 -0700 Davidlohr Bueso <davidlohr@hp.com> wrote:

> From: Davidlohr Bueso <davidlohr@hp.com>
> 
> The default size is, and always has been, 32Mb. Today, in the
> XXI century, it seems that this value is rather small, making
> users have to increase it via sysctl, which can cause unnecessary
> work and userspace application workarounds[1]. I have arbitrarily
> chosen a 4x increase, leaving it at 128Mb, and naturally, the
> same goes for shmall. While it may make more sense to set the value
> based on the system memory, this limit must be the same across all
> systems, and left to users to change if needed.
> 
> ...
>
> --- a/include/uapi/linux/shm.h
> +++ b/include/uapi/linux/shm.h
> @@ -12,7 +12,7 @@
>   * be increased by sysctl
>   */
>  
> -#define SHMMAX 0x2000000		 /* max shared seg size (bytes) */
> +#define SHMMAX 0x8000000		 /* max shared seg size (bytes) */
>  #define SHMMIN 1			 /* min shared seg size (bytes) */
>  #define SHMMNI 4096			 /* max num of segs system wide */
>  #ifndef __KERNEL__

urgh.  Perhaps we should have made the default "zero bytes" to force
everyone to think about what they really need and to configure their
systems.  Of course that just means that distros will poke some random
number in there at init time.

- With this change, the limit is no longer "the same across all
  systems" because the patch increases it for more recent kernels.

  Why do you say it "must be the same" and why is this not a problem
  in the develop-on-new-kernel, run-on-old-kernel scenario?

- The sysctl became somewhat pointless when we added ipc namespaces. 
  shm_init_ns() ignores the sysctl and goes straight to SHMMAX, and
  altering the sysctl will have no effect upon existing namespaces
  anyway.

- Shouldn't there be a way to alter this namespace's shm_ctlmax?

- What happens if we just nuke the limit altogether and fall back to
  the next check, which presumably is the rlimit bounds?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

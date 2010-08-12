Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EF0E56B02A7
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 16:11:49 -0400 (EDT)
Date: Thu, 12 Aug 2010 13:10:05 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] ipc/shm.c: add RSS and swap size information to
 /proc/sysvipc/shm
Message-Id: <20100812131005.e466a9fd.akpm@linux-foundation.org>
In-Reply-To: <20100811201345.GA11304@p100.box>
References: <20100811201345.GA11304@p100.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Helge Deller <deller@gmx.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Aug 2010 22:13:45 +0200
Helge Deller <deller@gmx.de> wrote:

> The kernel currently provides no functionality to analyze the RSS
> and swap space usage of each individual sysvipc shared memory segment.
> 
> This patch add this info for each existing shm segment by extending
> the output of /proc/sysvipc/shm by two columns for RSS and swap.
> 
> Since shmctl(SHM_INFO) already provides a similiar calculation (it
> currently sums up all RSS/swap info for all segments), I did split
> out a static function which is now used by the /proc/sysvipc/shm 
> output and shmctl(SHM_INFO).
> 

I suppose that could be useful, although it would be most interesting
to hear why _you_ consider it useful?

But is it useful enough to risk breaking existing code which parses
that file?  The risk is not great, but it's there.

> 
> ---
> 
>  shm.c |   63 ++++++++++++++++++++++++++++++++++++++++++---------------------
>  1 file changed, 42 insertions(+), 21 deletions(-)
> 
> 
> diff --git a/ipc/shm.c b/ipc/shm.c
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -108,7 +108,11 @@ void __init shm_init (void)
>  {
>  	shm_init_ns(&init_ipc_ns);
>  	ipc_init_proc_interface("sysvipc/shm",
> -				"       key      shmid perms       size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime\n",
> +#if BITS_PER_LONG <= 32
> +				"       key      shmid perms       size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime        RSS       swap\n",
> +#else
> +				"       key      shmid perms                  size  cpid  lpid nattch   uid   gid  cuid  cgid      atime      dtime      ctime                   RSS                  swap\n",

This adds 11 new spaces between "perms" and "size", only on 64-bit
machines.  That was unchangelogged and adds another (smaller) risk of
breaking things.  Please explain.

This interface is really old and crufty and horrid, but I guess that
there's not a lot we can do about that :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

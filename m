Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7C40B6B0087
	for <linux-mm@kvack.org>; Tue,  7 Dec 2010 18:10:57 -0500 (EST)
Date: Tue, 7 Dec 2010 15:10:54 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] use total_highpages when calculating lowmem-only
 allocation sizes (core)
Message-Id: <20101207151054.32542836.akpm@linux-foundation.org>
In-Reply-To: <4CFD20370200007800026269@vpn.id2.novell.com>
References: <4CFD20370200007800026269@vpn.id2.novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jan Beulich <JBeulich@novell.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 06 Dec 2010 16:41:11 +0000
"Jan Beulich" <JBeulich@novell.com> wrote:

> For those (large) table allocations that come only from lowmem, the
> total amount of memory shouldn't really matter.
> 
> For vfs_caches_init(), in the same spirit also replace the use of
> nr_free_pages() by nr_free_buffer_pages().
> 
> Signed-off-by: Jan Beulich <jbeulich@novell.com>
> 
> ---
>  fs/dcache.c                       |    4 ++--
>  init/main.c                       |    5 +++--
>  2 files changed, 5 insertions(+), 4 deletions(-)
> 
> --- linux-2.6.37-rc4/fs/dcache.c
> +++ 2.6.37-rc4-use-totalhigh_pages/fs/dcache.c
> @@ -2474,10 +2474,10 @@ void __init vfs_caches_init(unsigned lon
>  {
>  	unsigned long reserve;
>  
> -	/* Base hash sizes on available memory, with a reserve equal to
> +	/* Base hash sizes on available lowmem memory, with a reserve equal to
>             150% of current kernel size */
>  
> -	reserve = min((mempages - nr_free_pages()) * 3/2, mempages - 1);
> +	reserve = min((mempages - nr_free_buffer_pages()) * 3/2, mempages - 1);
>  	mempages -= reserve;
>  
>  	names_cachep = kmem_cache_create("names_cache", PATH_MAX, 0,
> --- linux-2.6.37-rc4/init/main.c
> +++ 2.6.37-rc4-use-totalhigh_pages/init/main.c
> @@ -22,6 +22,7 @@
>  #include <linux/init.h>
>  #include <linux/initrd.h>
>  #include <linux/bootmem.h>
> +#include <linux/highmem.h>
>  #include <linux/acpi.h>
>  #include <linux/tty.h>
>  #include <linux/percpu.h>
> @@ -673,13 +674,13 @@ asmlinkage void __init start_kernel(void
>  #endif
>  	thread_info_cache_init();
>  	cred_init();
> -	fork_init(totalram_pages);
> +	fork_init(totalram_pages - totalhigh_pages);
>  	proc_caches_init();
>  	buffer_init();
>  	key_init();
>  	security_init();
>  	dbg_late_init();
> -	vfs_caches_init(totalram_pages);
> +	vfs_caches_init(totalram_pages - totalhigh_pages);
>  	signals_init();
>  	/* rootfs populating might need page-writeback */
>  	page_writeback_init();

Dunno.  The code is really quite confused, unobvious and not obviously
correct.

Mainly because it has callers who read some global state and then pass
that into callees who take that arg and then combine it with other
global state.  The code would be much more confidence-inspiring if it
were cleaned up, so that all callees just read the global state when
they need it.

And is there any significant difference between (totalram_pages -
totalhigh_pages) and nr_free_buffer_pages()?  They're both kind-of
evaluating the same thing?

And after this patch, vfs_caches_init() is evaluating

	totalram_pages - totalhigh_pages - nr_free_buffer_pages()

which will be pretty close to zero, won't it?  Maybe negative?  Does
the code actually work??

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

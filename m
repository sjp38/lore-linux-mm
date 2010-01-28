Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 131966B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 03:55:00 -0500 (EST)
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o0S8stAo006819
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 08:54:56 GMT
Received: from pwj2 (pwj2.prod.google.com [10.241.219.66])
	by wpaz29.hot.corp.google.com with ESMTP id o0S8srxI030945
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 00:54:54 -0800
Received: by pwj2 with SMTP id 2so329445pwj.34
        for <linux-mm@kvack.org>; Thu, 28 Jan 2010 00:54:53 -0800 (PST)
Date: Thu, 28 Jan 2010 00:54:49 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v4 1/2] sysctl clean up vm related variable
 declarations
In-Reply-To: <20100127153232.f8efc531.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1001280048110.15953@chino.kir.corp.google.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com> <20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com> <20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com> <20100126151202.75bd9347.akpm@linux-foundation.org>
 <20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com> <20100126161952.ee267d1c.akpm@linux-foundation.org> <20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com> <20100127153053.b8a8a1a1.kamezawa.hiroyu@jp.fujitsu.com>
 <20100127153232.f8efc531.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Jan 2010, KAMEZAWA Hiroyuki wrote:

> Now, there are many "extern" declaration in kernel/sysctl.c. "extern"
> declaration in *.c file is not appreciated in general.
> And Hmm...it seems there are a few redundant declarations.
> 

sysctl_overcommit_memory and sysctl_overcommit_ratio, right?

> Because most of sysctl variables are defined in its own header file,
> they should be declared in the same style, be done in its own *.h file.
> 
> This patch removes some VM(memory management) related sysctl's
> variable declaration from kernel/sysctl.c and move them to
> proper places.
> 
> Change log:
>  - 2010/01/27 (new)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This is a very nice cleanup of the sysctl code, I hope you find the time 
to push it regardless of the future direction of the oom killer lowmem 
constraint.

One comment below.

> ---
>  include/linux/mm.h     |    5 +++++
>  include/linux/mmzone.h |    1 +
>  include/linux/oom.h    |    5 +++++
>  kernel/sysctl.c        |   16 ++--------------
>  mm/mmap.c              |    5 +++++
>  5 files changed, 18 insertions(+), 14 deletions(-)
> 
> Index: mmotm-2.6.33-Jan15-2/include/linux/mm.h
> ===================================================================
> --- mmotm-2.6.33-Jan15-2.orig/include/linux/mm.h
> +++ mmotm-2.6.33-Jan15-2/include/linux/mm.h
> @@ -1432,6 +1432,7 @@ int in_gate_area_no_task(unsigned long a
>  #define in_gate_area(task, addr) ({(void)task; in_gate_area_no_task(addr);})
>  #endif	/* __HAVE_ARCH_GATE_AREA */
>  
> +extern int sysctl_drop_caches;
>  int drop_caches_sysctl_handler(struct ctl_table *, int,
>  					void __user *, size_t *, loff_t *);
>  unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> @@ -1476,5 +1477,9 @@ extern int soft_offline_page(struct page
>  
>  extern void dump_page(struct page *page);
>  
> +#ifndef CONFIG_NOMMU
> +extern int sysctl_nr_trim_pages;

This should be #ifndef CONFIG_MMU.

> +#endif
> +
>  #endif /* __KERNEL__ */
>  #endif /* _LINUX_MM_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id BCB936B002B
	for <linux-mm@kvack.org>; Sat, 10 Nov 2012 21:35:08 -0500 (EST)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3950186pbb.14
        for <linux-mm@kvack.org>; Sat, 10 Nov 2012 18:35:08 -0800 (PST)
Date: Sat, 10 Nov 2012 18:35:05 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] mm: Export a function to read vm_committed_as
In-Reply-To: <1352600728-17766-1-git-send-email-kys@microsoft.com>
Message-ID: <alpine.DEB.2.00.1211101830250.18494@chino.kir.corp.google.com>
References: <1352600728-17766-1-git-send-email-kys@microsoft.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "K. Y. Srinivasan" <kys@microsoft.com>
Cc: gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com, andi@firstfloor.org, akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyuki@gmail.com, mhocko@suse.cz, hannes@cmpxchg.org, yinghan@google.com

On Sat, 10 Nov 2012, K. Y. Srinivasan wrote:

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2d94235..e527239 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -89,6 +89,17 @@ int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
>  struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
>  
>  /*
> + * A wrapper to read vm_committed_as that can be used by external modules.
> + */
> +
> +unsigned long read_vm_committed_as(void)
> +{
> +	return percpu_counter_read_positive(&vm_committed_as);
> +}
> +
> +EXPORT_SYMBOL_GPL(read_vm_committed_as);
> +
> +/*
>   * Check that a process has enough memory to allocate a new virtual
>   * mapping. 0 means there is enough memory for the allocation to
>   * succeed and -ENOMEM implies there is not.

This is precisely what I didn't want to see; I was expecting that this 
function was going to have some name that would describe what a hypervisor 
would use it for, regardless of its implementation and current use of 
vm_committed_as.  read_vm_committed_as() misses the entire point of the 
suggestion and a few people have mentioned that they think this 
implementation will evolve over time.

Please think of what you're trying to determine in the code that will 
depend on this and then convert the existing user in 
drivers/xen/xen-selfballoon.c.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6D4C8E00F9
	for <linux-mm@kvack.org>; Sat,  5 Jan 2019 14:15:02 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id t7so36145480edr.21
        for <linux-mm@kvack.org>; Sat, 05 Jan 2019 11:15:02 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b3si1798907ede.42.2019.01.05.11.15.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 05 Jan 2019 11:15:00 -0800 (PST)
Subject: Re: [PATCH] mm/mincore: allow for making sys_mincore() privileged
References: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <d4846cb2-2a4b-b8b3-daac-e5f51751bbf1@suse.cz>
Date: Sat, 5 Jan 2019 20:14:57 +0100
MIME-Version: 1.0
In-Reply-To: <nycvar.YFH.7.76.1901051817390.16954@cbobk.fhfr.pm>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jikos@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Peter Zijlstra <peterz@infradead.org>, Michal Hocko <mhocko@suse.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On 5.1.2019 18:27, Jiri Kosina wrote:
> From: Jiri Kosina <jkosina@suse.cz>
> 
> There are possibilities [1] how mincore() could be used as a converyor of 
> a sidechannel information about pagecache metadata.
> 
> Provide vm.mincore_privileged sysctl, which makes it possible to mincore() 
> start returning -EPERM in case it's invoked by a process lacking 
> CAP_SYS_ADMIN.

Haven't checked the details yet, but wouldn't it be safe if anonymous private
mincore() kept working, and restrictions were applied only to page cache?

> The default behavior stays "mincore() can be used by anybody" in order to 
> be conservative with respect to userspace behavior.

What if we lied instead of returned -EPERM, to not break userspace so obviously?
I guess false positive would be the safer lie?

> [1] https://www.theregister.co.uk/2019/01/05/boffins_beat_page_cache/
> 
> Signed-off-by: Jiri Kosina <jkosina@suse.cz>
> ---
>  Documentation/sysctl/vm.txt | 9 +++++++++
>  kernel/sysctl.c             | 8 ++++++++
>  mm/mincore.c                | 5 +++++
>  3 files changed, 22 insertions(+)
> 
> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
> index 187ce4f599a2..afb8635e925e 100644
> --- a/Documentation/sysctl/vm.txt
> +++ b/Documentation/sysctl/vm.txt
> @@ -41,6 +41,7 @@ Currently, these files are in /proc/sys/vm:
>  - min_free_kbytes
>  - min_slab_ratio
>  - min_unmapped_ratio
> +- mincore_privileged
>  - mmap_min_addr
>  - mmap_rnd_bits
>  - mmap_rnd_compat_bits
> @@ -485,6 +486,14 @@ files and similar are considered.
>  The default is 1 percent.
>  
>  ==============================================================
> +mincore_privileged:
> +
> +mincore() could be potentially used to mount a side-channel attack against
> +pagecache metadata. This sysctl provides system administrators means to
> +make it available only to processess that own CAP_SYS_ADMIN capability.
> +
> +The default is 0, which means mincore() can be used without restrictions.
> +==============================================================
>  
>  mmap_min_addr
>  
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 1825f712e73b..f03cb07c8dd4 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -114,6 +114,7 @@ extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
>  #ifndef CONFIG_MMU
>  extern int sysctl_nr_trim_pages;
>  #endif
> +extern int sysctl_mincore_privileged;
>  
>  /* Constants used for minimum and  maximum */
>  #ifdef CONFIG_LOCKUP_DETECTOR
> @@ -1684,6 +1685,13 @@ static struct ctl_table vm_table[] = {
>  		.extra2		= (void *)&mmap_rnd_compat_bits_max,
>  	},
>  #endif
> +	{
> +		.procname	= "mincore_privileged",
> +		.data		= &sysctl_mincore_privileged,
> +		.maxlen		= sizeof(sysctl_mincore_privileged),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec,
> +	},
>  	{ }
>  };
>  
> diff --git a/mm/mincore.c b/mm/mincore.c
> index 218099b5ed31..77d4928cdfaa 100644
> --- a/mm/mincore.c
> +++ b/mm/mincore.c
> @@ -21,6 +21,8 @@
>  #include <linux/uaccess.h>
>  #include <asm/pgtable.h>
>  
> +int sysctl_mincore_privileged;
> +
>  static int mincore_hugetlb(pte_t *pte, unsigned long hmask, unsigned long addr,
>  			unsigned long end, struct mm_walk *walk)
>  {
> @@ -228,6 +230,9 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
>  	unsigned long pages;
>  	unsigned char *tmp;
>  
> +	if (sysctl_mincore_privileged && !capable(CAP_SYS_ADMIN))
> +		return -EPERM;
> +
>  	/* Check the start address: needs to be page-aligned.. */
>  	if (start & ~PAGE_MASK)
>  		return -EINVAL;
> 

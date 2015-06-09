Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id EFCDC6B006C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 03:06:31 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so8600085pdj.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 00:06:31 -0700 (PDT)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id mt2si7624285pbb.42.2015.06.09.00.06.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 00:06:31 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id EB4D4AC01E1
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:06:27 +0900 (JST)
Message-ID: <55769058.3030406@jp.fujitsu.com>
Date: Tue, 09 Jun 2015 16:06:00 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 08/12] mm: use mirrorable to switch allocate mirrored
 memory
References: <55704A7E.5030507@huawei.com> <55704C79.5060608@huawei.com>
In-Reply-To: <55704C79.5060608@huawei.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2015/06/04 22:02, Xishi Qiu wrote:
> Add a new interface in path /proc/sys/vm/mirrorable. When set to 1, it means
> we should allocate mirrored memory for both user and kernel processes.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

I can't see why do we need this switch. If this is set, all GFP_HIGHUSER will use
mirrored memory ?

Or will you add special MMAP/madvise flag to use mirrored memory ?

Thanks,
-Kame

> ---
>   include/linux/mmzone.h | 1 +
>   kernel/sysctl.c        | 9 +++++++++
>   mm/page_alloc.c        | 1 +
>   3 files changed, 11 insertions(+)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index f82e3ae..20888dd 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -85,6 +85,7 @@ struct mirror_info {
>   };
>
>   extern struct mirror_info mirror_info;
> +extern int sysctl_mirrorable;
>   #  define is_migrate_mirror(migratetype) unlikely((migratetype) == MIGRATE_MIRROR)
>   #else
>   #  define is_migrate_mirror(migratetype) false
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> index 2082b1a..dc2625e 100644
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1514,6 +1514,15 @@ static struct ctl_table vm_table[] = {
>   		.extra2		= &one,
>   	},
>   #endif
> +#ifdef CONFIG_MEMORY_MIRROR
> +	{
> +		.procname	= "mirrorable",
> +		.data		= &sysctl_mirrorable,
> +		.maxlen		= sizeof(sysctl_mirrorable),
> +		.mode		= 0644,
> +		.proc_handler	= proc_dointvec_minmax,
> +	},
> +#endif
>   	{
>   		.procname	= "user_reserve_kbytes",
>   		.data		= &sysctl_user_reserve_kbytes,
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 249a8f6..63b90ca 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -212,6 +212,7 @@ int user_min_free_kbytes = -1;
>
>   #ifdef CONFIG_MEMORY_MIRROR
>   struct mirror_info mirror_info;
> +int sysctl_mirrorable = 0;
>   #endif
>
>   static unsigned long __meminitdata nr_kernel_pages;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

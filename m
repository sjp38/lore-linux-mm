Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BF036B0033
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 04:44:50 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id 43so441308qtr.6
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 01:44:50 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z33si1024331qtg.282.2017.09.22.01.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 01:44:49 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8M8iTXn080012
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 04:44:48 -0400
Received: from e06smtp13.uk.ibm.com (e06smtp13.uk.ibm.com [195.75.94.109])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d4pnp1mpj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 04:44:48 -0400
Received: from localhost
	by e06smtp13.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <borntraeger@de.ibm.com>;
	Fri, 22 Sep 2017 09:44:45 +0100
Subject: Re: [PATCH] KSM: Replace jhash2 with xxhash
References: <20170921074519.9333-1-nefelim4ag@gmail.com>
From: Christian Borntraeger <borntraeger@de.ibm.com>
Date: Fri, 22 Sep 2017 10:44:43 +0200
MIME-Version: 1.0
In-Reply-To: <20170921074519.9333-1-nefelim4ag@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <cd6d2967-1e2c-27e0-79f6-39dc28320a11@de.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Timofey Titovets <nefelim4ag@gmail.com>, linux-mm@kvack.org, kvm list <kvm@vger.kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>

Can you please CC the kvm list for these patches. There were other patches
floating around that tried to use the crypto API with CRC and Claudio was working
on some refactoring that made the has function arch specific. 


On 09/21/2017 09:45 AM, Timofey Titovets wrote:
> xxhash much faster then jhash,
> ex. for x86_64 host:
> PAGE_SIZE: 4096, loop count: 1048576
> jhash2:   0xacbc7a5b            time: 1907 ms,  th:  2251.9 MiB/s
> xxhash32: 0x570da981            time: 739 ms,   th:  5809.4 MiB/s
> xxhash64: 0xa1fa032ab85bbb62    time: 371 ms,   th: 11556.6 MiB/s
> 
> xxhash64 on x86_32 work with ~ same speed as jhash2.
> xxhash32 on x86_32 work with ~ same speed as for x86_64
> 
> So replace jhash with xxhash,
> and use fastest version for current target ARCH.
> 
> Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
> ---
>  mm/Kconfig |  1 +
>  mm/ksm.c   | 25 ++++++++++++++++++-------
>  2 files changed, 19 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 9c4bdddd80c2..252ab266ac23 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -305,6 +305,7 @@ config MMU_NOTIFIER
>  config KSM
>  	bool "Enable KSM for page merging"
>  	depends on MMU
> +	select XXHASH
>  	help
>  	  Enable Kernel Samepage Merging: KSM periodically scans those areas
>  	  of an application's address space that an app has advised may be
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 15dd7415f7b3..e012d9778c18 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -25,7 +25,8 @@
>  #include <linux/pagemap.h>
>  #include <linux/rmap.h>
>  #include <linux/spinlock.h>
> -#include <linux/jhash.h>
> +#include <linux/xxhash.h>
> +#include <linux/bitops.h> /* BITS_PER_LONG */
>  #include <linux/delay.h>
>  #include <linux/kthread.h>
>  #include <linux/wait.h>
> @@ -51,6 +52,12 @@
>  #define DO_NUMA(x)	do { } while (0)
>  #endif
> 
> +#if BITS_PER_LONG == 64
> +typedef	u64	xxhash;
> +#else
> +typedef	u32	xxhash;
> +#endif
> +
>  /*
>   * A few notes about the KSM scanning process,
>   * to make it easier to understand the data structures below:
> @@ -186,7 +193,7 @@ struct rmap_item {
>  	};
>  	struct mm_struct *mm;
>  	unsigned long address;		/* + low bits used for flags below */
> -	unsigned int oldchecksum;	/* when unstable */
> +	xxhash oldchecksum;		/* when unstable */
>  	union {
>  		struct rb_node node;	/* when node of unstable tree */
>  		struct {		/* when listed from stable tree */
> @@ -255,7 +262,7 @@ static unsigned int ksm_thread_pages_to_scan = 100;
>  static unsigned int ksm_thread_sleep_millisecs = 20;
> 
>  /* Checksum of an empty (zeroed) page */
> -static unsigned int zero_checksum __read_mostly;
> +static xxhash zero_checksum __read_mostly;
> 
>  /* Whether to merge empty (zeroed) pages with actual zero pages */
>  static bool ksm_use_zero_pages __read_mostly;
> @@ -982,11 +989,15 @@ static int unmerge_and_remove_all_rmap_items(void)
>  }
>  #endif /* CONFIG_SYSFS */
> 
> -static u32 calc_checksum(struct page *page)
> +static xxhash calc_checksum(struct page *page)
>  {
> -	u32 checksum;
> +	xxhash checksum;
>  	void *addr = kmap_atomic(page);
> -	checksum = jhash2(addr, PAGE_SIZE / 4, 17);
> +#if BITS_PER_LONG == 64
> +	checksum = xxh64(addr, PAGE_SIZE, 0);
> +#else
> +	checksum = xxh32(addr, PAGE_SIZE, 0);
> +#endif
>  	kunmap_atomic(addr);
>  	return checksum;
>  }
> @@ -1994,7 +2005,7 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  	struct page *tree_page = NULL;
>  	struct stable_node *stable_node;
>  	struct page *kpage;
> -	unsigned int checksum;
> +	xxhash checksum;
>  	int err;
>  	bool max_page_sharing_bypass = false;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

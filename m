Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id F35FD6B0253
	for <linux-mm@kvack.org>; Fri,  7 Aug 2015 18:55:38 -0400 (EDT)
Received: by pawu10 with SMTP id u10so97768802paw.1
        for <linux-mm@kvack.org>; Fri, 07 Aug 2015 15:55:38 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ay7si20225362pbd.72.2015.08.07.15.55.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Aug 2015 15:55:38 -0700 (PDT)
Date: Fri, 7 Aug 2015 15:55:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 2/2] mm: hugetlb: add VmHugetlbRSS: field in
 /proc/pid/status
Message-Id: <20150807155537.d483456f753355059f9ce10a@linux-foundation.org>
In-Reply-To: <1438932278-7973-3-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp>
	<1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com>
	<1438932278-7973-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Rientjes <rientjes@google.com>, =?ISO-8859-1?Q?J=F6rn?= Engel <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 7 Aug 2015 07:24:50 +0000 Naoya Horiguchi <n-horiguchi@ah.jp.nec.com> wrote:

> Currently there's no easy way to get per-process usage of hugetlb pages, which
> is inconvenient because applications which use hugetlb typically want to control
> their processes on the basis of how much memory (including hugetlb) they use.
> So this patch simply provides easy access to the info via /proc/pid/status.
> 
> This patch shouldn't change the OOM behavior (so hugetlb usage is ignored as
> is now,) which I guess is fine until we have some strong reason to do it.
> 

A procfs change triggers a documentation change.  Always, please. 
Documentation/filesystems/proc.txt is the place.

>
> ...
>
> @@ -504,6 +519,9 @@ static inline spinlock_t *huge_pte_lockptr(struct hstate *h,
>  {
>  	return &mm->page_table_lock;
>  }
> +
> +#define get_hugetlb_rss(mm)	0
> +#define mod_hugetlb_rss(mm, value)	do {} while (0)

I don't think these have to be macros?  inline functions are nicer in
several ways: more readable, more likely to be documented, can prevent
unused variable warnings.

>  #endif	/* CONFIG_HUGETLB_PAGE */
>  
>  static inline spinlock_t *huge_pte_lock(struct hstate *h,
>
> ...
>
> --- v4.2-rc4.orig/mm/memory.c
> +++ v4.2-rc4/mm/memory.c
> @@ -620,12 +620,12 @@ int __pte_alloc_kernel(pmd_t *pmd, unsigned long address)
>  	return 0;
>  }
>  
> -static inline void init_rss_vec(int *rss)
> +inline void init_rss_vec(int *rss)
>  {
>  	memset(rss, 0, sizeof(int) * NR_MM_COUNTERS);
>  }
>  
> -static inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
> +inline void add_mm_rss_vec(struct mm_struct *mm, int *rss)
>  {
>  	int i;

The inlines are a bit odd, but this does save ~10 bytes in memory.o for
some reason.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

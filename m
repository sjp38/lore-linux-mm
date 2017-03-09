Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B37138320B
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 20:45:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id l66so87665321pfl.6
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 17:45:14 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id c21si4872657pgi.128.2017.03.08.17.45.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 17:45:14 -0800 (PST)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -mm -v6 1/9] mm, swap: Make swap cluster size same of THP size on x86_64
References: <20170308072613.17634-1-ying.huang@intel.com>
	<20170308072613.17634-2-ying.huang@intel.com>
	<20170308125631.GX16328@bombadil.infradead.org>
Date: Thu, 09 Mar 2017 09:45:11 +0800
In-Reply-To: <20170308125631.GX16328@bombadil.infradead.org> (Matthew Wilcox's
	message of "Wed, 8 Mar 2017 04:56:31 -0800")
Message-ID: <87k27zi5p4.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Hi, Matthew,

Matthew Wilcox <willy@infradead.org> writes:

> On Wed, Mar 08, 2017 at 03:26:05PM +0800, Huang, Ying wrote:
>> In this patch, the size of the swap cluster is changed to that of the
>> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
>> the THP swap support on x86_64.  Where one swap cluster will be used to
>> hold the contents of each THP swapped out.  And some information of the
>> swapped out THP (such as compound map count) will be recorded in the
>> swap_cluster_info data structure.
>> 
>> For other architectures which want THP swap support,
>> ARCH_USES_THP_SWAP_CLUSTER need to be selected in the Kconfig file for
>> the architecture.
>> 
>> In effect, this will enlarge swap cluster size by 2 times on x86_64.
>> Which may make it harder to find a free cluster when the swap space
>> becomes fragmented.  So that, this may reduce the continuous swap space
>> allocation and sequential write in theory.  The performance test in 0day
>> shows no regressions caused by this.
>
> Well ... if there are no regressions found, why not change it
> unconditionally?  The value '256' seems relatively arbitrary (I bet it
> was tuned by some doofus with a 486, 8MB RAM and ST506 hard drive ...
> it certainly hasn't changed since git started in 2005)
>
> Might be worth checking with the PowerPC people to see if their larger
> pages causes this smaller patch to perform badly:

I found the huge page size is large not only on PowerPC, for example, on
MIPS, the PMD_SHIFT could be from 21 to 29, depends on configuration.  I
don't know the situation for the other architectures.  So I thought it
may be better to let the architecture developers to determine whether to
make the change and under which configuration.

> diff --git a/mm/swapfile.c b/mm/swapfile.c
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -199,7 +199,7 @@ static void discard_swap_cluster(struct swap_info_struct *si,
>  	}
>  }
>  
> -#define SWAPFILE_CLUSTER	256
> +#define SWAPFILE_CLUSTER	HPAGE_PMD_NR
>  #define LATENCY_LIMIT		256
>  
>  static inline void cluster_set_flag(struct swap_cluster_info *info,

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

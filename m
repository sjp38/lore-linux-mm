Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 758B06B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 17:22:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id m89so34593056pfj.1
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 14:22:49 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id zd5si7369676pac.155.2016.09.01.14.22.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Sep 2016 14:22:48 -0700 (PDT)
Date: Thu, 1 Sep 2016 14:22:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -v2 01/10] swap: Change SWAPFILE_CLUSTER to 512
Message-Id: <20160901142246.631fe47a558bb7522f73c034@linux-foundation.org>
In-Reply-To: <1472743023-4116-2-git-send-email-ying.huang@intel.com>
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
	<1472743023-4116-2-git-send-email-ying.huang@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

On Thu,  1 Sep 2016 08:16:54 -0700 "Huang, Ying" <ying.huang@intel.com> wrote:

> From: Huang Ying <ying.huang@intel.com>
> 
> In this patch, the size of the swap cluster is changed to that of the
> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
> the THP swap support on x86_64.  Where one swap cluster will be used to
> hold the contents of each THP swapped out.  And some information of the
> swapped out THP (such as compound map count) will be recorded in the
> swap_cluster_info data structure.
> 
> In effect,  this will enlarge swap  cluster size by 2  times.  Which may
> make  it harder  to find  a  free cluster  when the  swap space  becomes
> fragmented.   So  that,  this  may  reduce  the  continuous  swap  space
> allocation and sequential write in theory.  The performance test in 0day
> show no regressions caused by this.
> 
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -196,7 +196,7 @@ static void discard_swap_cluster(struct swap_info_struct *si,
>  	}
>  }
>  
> -#define SWAPFILE_CLUSTER	256
> +#define SWAPFILE_CLUSTER	512
>  #define LATENCY_LIMIT		256
>  

What happens to architectures which have different HPAGE_SIZE and/or
PAGE_SIZE?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

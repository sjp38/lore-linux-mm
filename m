Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id DF75A6B0069
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 19:05:05 -0400 (EDT)
Received: by mail-yb0-f199.google.com with SMTP id t65so89237688yba.0
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 16:05:05 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id i67si7826559pfg.136.2016.09.01.16.05.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Sep 2016 16:05:04 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH -v2 01/10] swap: Change SWAPFILE_CLUSTER to 512
References: <1472743023-4116-1-git-send-email-ying.huang@intel.com>
	<1472743023-4116-2-git-send-email-ying.huang@intel.com>
	<20160901142246.631fe47a558bb7522f73c034@linux-foundation.org>
Date: Thu, 01 Sep 2016 16:04:57 -0700
In-Reply-To: <20160901142246.631fe47a558bb7522f73c034@linux-foundation.org>
	(Andrew Morton's message of "Thu, 1 Sep 2016 14:22:46 -0700")
Message-ID: <87h99zdxwm.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Huang, Ying" <ying.huang@intel.com>, tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Shaohua Li <shli@kernel.org>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>

Andrew Morton <akpm@linux-foundation.org> writes:

> On Thu,  1 Sep 2016 08:16:54 -0700 "Huang, Ying" <ying.huang@intel.com> wrote:
>
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> In this patch, the size of the swap cluster is changed to that of the
>> THP (Transparent Huge Page) on x86_64 architecture (512).  This is for
>> the THP swap support on x86_64.  Where one swap cluster will be used to
>> hold the contents of each THP swapped out.  And some information of the
>> swapped out THP (such as compound map count) will be recorded in the
>> swap_cluster_info data structure.
>> 
>> In effect,  this will enlarge swap  cluster size by 2  times.  Which may
>> make  it harder  to find  a  free cluster  when the  swap space  becomes
>> fragmented.   So  that,  this  may  reduce  the  continuous  swap  space
>> allocation and sequential write in theory.  The performance test in 0day
>> show no regressions caused by this.
>> 
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -196,7 +196,7 @@ static void discard_swap_cluster(struct swap_info_struct *si,
>>  	}
>>  }
>>  
>> -#define SWAPFILE_CLUSTER	256
>> +#define SWAPFILE_CLUSTER	512
>>  #define LATENCY_LIMIT		256
>>  
>
> What happens to architectures which have different HPAGE_SIZE and/or
> PAGE_SIZE?

For the architecture with HPAGE_SIZE / PAGE_SIZE == 512 (for example
x86_64), the huge page swap optimizing will be turned on.  For other
architectures, it will be turned off as before.

This mostly because I don't know whether it is a good idea to turn on
THP swap optimizing for the architectures other than x86_64.  For
example, it appears that the huge page size is 8M (1<<23) on SPARC.  But
I don't know whether 8M is too big for a swap cluster.  And it appears
that the huge page size could be as large as 512M on MIPS.

Best Regards,
Huang, Ying

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

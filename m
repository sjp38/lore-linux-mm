Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F22D6B025E
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 13:49:59 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z96so6045192wrb.21
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 10:49:59 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id q30si647863edc.284.2017.10.20.10.49.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 10:49:58 -0700 (PDT)
Subject: Re: [PATCH 1/1] mm:hugetlbfs: Fix hwpoison reserve accounting
References: <20171019230007.17043-1-mike.kravetz@oracle.com>
 <20171019230007.17043-2-mike.kravetz@oracle.com>
 <20171020023019.GA9318@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <5016e528-8ea9-7597-3420-086ae57f3d9d@oracle.com>
Date: Fri, 20 Oct 2017 10:49:46 -0700
MIME-Version: 1.0
In-Reply-To: <20171020023019.GA9318@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On 10/19/2017 07:30 PM, Naoya Horiguchi wrote:
> On Thu, Oct 19, 2017 at 04:00:07PM -0700, Mike Kravetz wrote:
> 
> Thank you for addressing this. The patch itself looks good to me, but
> the reported issue (negative reserve count) doesn't reproduce in my trial
> with v4.14-rc5, so could you share the exact procedure for this issue?

Sure, but first one question on your test scenario below.

> 
> When error handler runs over a huge page, the reserve count is incremented
> so I'm not sure why the reserve count goes negative.

I'm not sure I follow.  What specific code is incrementing the reserve
count?  

>                                                      My operation is like below:
> 
>   $ sysctl vm.nr_hugepages=10
>   $ grep HugePages_ /proc/meminfo
>   HugePages_Total:      10
>   HugePages_Free:       10
>   HugePages_Rsvd:        0
>   HugePages_Surp:        0
>   $ ./test_alloc_generic -B hugetlb_file -N1 -L "mmap access memory_error_injection:error_type=madv_hard"  // allocate a 2MB file on hugetlbfs, then madvise(MADV_HWPOISON) on it.
>   $ grep HugePages_ /proc/meminfo
>   HugePages_Total:      10
>   HugePages_Free:        9
>   HugePages_Rsvd:        1  // reserve count is incremented
>   HugePages_Surp:        0

This is confusing to me.  I can not create a test where there is a reserve
count after poisoning page.

I tried to recreate your test.  Running unmodified 4.14.0-rc5.

Before test
-----------
HugePages_Total:       1
HugePages_Free:        1
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

After open(creat) and mmap of 2MB hugetlbfs file
------------------------------------------------
HugePages_Total:       1
HugePages_Free:        1
HugePages_Rsvd:        1
HugePages_Surp:        0
Hugepagesize:       2048 kB

Reserve count is 1 as expected/normal

After madvise(MADV_HWPOISON) of the single huge page in mapping/file
--------------------------------------------------------------------
HugePages_Total:       1
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

In this case, the reserve (and free) count were decremented.  Note that
before the poison operation the page was not associated with the mapping/
file.  I did not look closely at the code, but assume the madvise may
cause the page to be 'faulted in'.

The counts remain the same when the program exits
-------------------------------------------------
HugePages_Total:       1
HugePages_Free:        0
HugePages_Rsvd:        0
HugePages_Surp:        0
Hugepagesize:       2048 kB

Remove the file (rm /var/opt/oracle/hugepool/foo)
-------------------------------------------------
HugePages_Total:       1
HugePages_Free:        0
HugePages_Rsvd:    18446744073709551615
HugePages_Surp:        0
Hugepagesize:       2048 kB

I am still confused about how your test maintains a reserve count after
poisoning.  It may be a good idea for you to test my patch with your
test scenario as I can not recreate here.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

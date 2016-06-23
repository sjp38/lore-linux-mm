Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1273C828E1
	for <linux-mm@kvack.org>; Thu, 23 Jun 2016 05:29:51 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id na2so54420325lbb.1
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:29:51 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id n124si5319263wma.8.2016.06.23.02.29.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jun 2016 02:29:49 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id v199so118474244wmv.0
        for <linux-mm@kvack.org>; Thu, 23 Jun 2016 02:29:49 -0700 (PDT)
Date: Thu, 23 Jun 2016 11:29:46 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: A question about the patch(commit :c777e2a8b654 powerpc/mm: Fix
 Multi hit ERAT cause by recent THP update)
Message-ID: <20160623092946.GA30082@dhcp22.suse.cz>
References: <576AA934.4090504@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <576AA934.4090504@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhong jiang <zhongjiang@huawei.com>
Cc: aneesh.kumar@linux.vnet.ibm.com, Linux Memory Management List <linux-mm@kvack.org>

On Wed 22-06-16 23:05:24, zhong jiang wrote:
> Hi  Aneesh
> 
>                 CPU0                            CPU1
>     shrink_page_list()
>       add_to_swap()
>         split_huge_page_to_list()
>           __split_huge_pmd_locked()
>             pmdp_huge_clear_flush_notify()
>         // pmd_none() == true
>                                         exit_mmap()
>                                           unmap_vmas()
>                                             zap_pmd_range()
>                                               // no action on pmd since pmd_none() == true
>         pmd_populate()
> 
> 
> the mm should be the last user  when CPU1 process is exiting,  CPU0 must be a own mm .
> two different process  should not be influenced each other.  in a words , they should not
> have race.

No this is a different scenario than
http://lkml.kernel.org/r/1466517956-13875-1-git-send-email-zhongjiang@huawei.com
we were discussing recently. Note that pages are still on the LRU lists
while the mm which maps them is exiting. So the above race is very much
possible.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

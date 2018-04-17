Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 96C486B0007
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 19:37:34 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id i127so4240093pgc.22
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 16:37:34 -0700 (PDT)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id 14-v6si15084489ple.450.2018.04.17.16.37.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 16:37:33 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180417232248.GA27631@bombadil.infradead.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <6782cd11-48e5-6c12-db1c-9478ab37f77e@linux.alibaba.com>
Date: Tue, 17 Apr 2018 16:37:11 -0700
MIME-Version: 1.0
In-Reply-To: <20180417232248.GA27631@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/17/18 4:22 PM, Matthew Wilcox wrote:
> On Wed, Apr 18, 2018 at 05:08:13AM +0800, Yang Shi wrote:
>> When applications use huge page on hugetlbfs, it just need check the
>> filesystem magic number, but it is not enough for tmpfs. So, introduce
>> ST_HUGE flag to statfs if super block has SB_HUGE set which indicates
>> huge page is supported on the specific filesystem.
> Hm.  What's the plan for communicating support for page sizes other
> than PMD page sizes?  I know ARM has several different page sizes,
> as do PA-RISC and ia64.  Even x86 might support 1G page sizes through
> tmpfs one day.

For THP page size, we already have 
/sys/kernel/mm/transparent_hugepage/hpage_pmd_size exported. The 
applications could read this to get the THP size. If PUD size THP 
supported is added later, we can export hpage_pud_size.

Please see the below commit log for more details:

commit 49920d28781dcced10cd30cb9a938e7d045a1c94
Author: Hugh Dickins <hughd@google.com>
Date:A A  Mon Dec 12 16:44:50 2016 -0800

 A A A  mm: make transparent hugepage size public

 A A A  Test programs want to know the size of a transparent hugepage. While it
 A A A  is commonly the same as the size of a hugetlbfs page (shown as
 A A A  Hugepagesize in /proc/meminfo), that is not always so: powerpc
 A A A  implements transparent hugepages in a different way from hugetlbfs
 A A A  pages, so it's coincidence when their sizes are the same; and x86 and
 A A A  others can support more than one hugetlbfs page size.

 A A A  Add /sys/kernel/mm/transparent_hugepage/hpage_pmd_size to show the THP
 A A A  size in bytes - it's the same for Anonymous and Shmem hugepages.A  Call
 A A A  it hpage_pmd_size (after HPAGE_PMD_SIZE) rather than hpage_size, in 
case
 A A A  some transparent support for pud and pgd pages is added later.


Thanks,
Yang

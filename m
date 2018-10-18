Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id D58BB6B0008
	for <linux-mm@kvack.org>; Thu, 18 Oct 2018 19:16:55 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id k3-v6so2753077qta.23
        for <linux-mm@kvack.org>; Thu, 18 Oct 2018 16:16:55 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id y24si4112887qve.86.2018.10.18.16.16.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Oct 2018 16:16:54 -0700 (PDT)
Subject: Re: [PATCH] hugetlbfs: dirty pages as they are added to pagecache
References: <20181018041022.4529-1-mike.kravetz@oracle.com>
 <20181018160827.0cb656d594ffb2f0f069326c@linux-foundation.org>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <6d6e4733-39aa-a958-c0a2-c5a47cdcc7d0@oracle.com>
Date: Thu, 18 Oct 2018 16:16:40 -0700
MIME-Version: 1.0
In-Reply-To: <20181018160827.0cb656d594ffb2f0f069326c@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Alexander Viro <viro@zeniv.linux.org.uk>, stable@vger.kernel.org

On 10/18/18 4:08 PM, Andrew Morton wrote:
> On Wed, 17 Oct 2018 21:10:22 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:
> 
>> Some test systems were experiencing negative huge page reserve
>> counts and incorrect file block counts.  This was traced to
>> /proc/sys/vm/drop_caches removing clean pages from hugetlbfs
>> file pagecaches.  When non-hugetlbfs explicit code removes the
>> pages, the appropriate accounting is not performed.
>>
>> This can be recreated as follows:
>>  fallocate -l 2M /dev/hugepages/foo
>>  echo 1 > /proc/sys/vm/drop_caches
>>  fallocate -l 2M /dev/hugepages/foo
>>  grep -i huge /proc/meminfo
>>    AnonHugePages:         0 kB
>>    ShmemHugePages:        0 kB
>>    HugePages_Total:    2048
>>    HugePages_Free:     2047
>>    HugePages_Rsvd:    18446744073709551615
>>    HugePages_Surp:        0
>>    Hugepagesize:       2048 kB
>>    Hugetlb:         4194304 kB
>>  ls -lsh /dev/hugepages/foo
>>    4.0M -rw-r--r--. 1 root root 2.0M Oct 17 20:05 /dev/hugepages/foo
>>
>> To address this issue, dirty pages as they are added to pagecache.
>> This can easily be reproduced with fallocate as shown above. Read
>> faulted pages will eventually end up being marked dirty.  But there
>> is a window where they are clean and could be impacted by code such
>> as drop_caches.  So, just dirty them all as they are added to the
>> pagecache.
>>
>> In addition, it makes little sense to even try to drop hugetlbfs
>> pagecache pages, so disable calls to these filesystems in drop_caches
>> code.
>>
>> ...
>>
>> --- a/fs/drop_caches.c
>> +++ b/fs/drop_caches.c
>> @@ -9,6 +9,7 @@
>>  #include <linux/writeback.h>
>>  #include <linux/sysctl.h>
>>  #include <linux/gfp.h>
>> +#include <linux/magic.h>
>>  #include "internal.h"
>>  
>>  /* A global variable is a bit ugly, but it keeps the code simple */
>> @@ -18,6 +19,12 @@ static void drop_pagecache_sb(struct super_block *sb, void *unused)
>>  {
>>  	struct inode *inode, *toput_inode = NULL;
>>  
>> +	/*
>> +	 * It makes no sense to try and drop hugetlbfs page cache pages.
>> +	 */
>> +	if (sb->s_magic == HUGETLBFS_MAGIC)
>> +		return;
> 
> Hardcoding hugetlbfs seems wrong here.  There are other filesystems
> where it makes no sense to try to drop pagecache.  ramfs and, errrr...
> 
> I'm struggling to remember which is the correct thing to test here. 
> BDI_CAP_NO_WRITEBACK should get us there, but doesn't seem quite
> appropriate.

I was not sure about this, and expected someone could come up with
something better.  It just seems there are filesystems like huegtlbfs,
where it makes no sense wasting cycles traversing the filesystem.  So,
let's not even try.

Hoping someone can come up with a better method than hard coding as
I have done above.
-- 
Mike Kravetz

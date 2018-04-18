Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 453036B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 16:53:37 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g1-v6so1652616plm.2
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 13:53:37 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id f2si1702543pgn.320.2018.04.18.13.53.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 13:53:35 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <2804a1d0-9d68-ac43-3041-9490147b52b5@oracle.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <293caaaf-39c0-7634-fbd2-70a540ea58db@linux.alibaba.com>
Date: Wed, 18 Apr 2018 13:53:28 -0700
MIME-Version: 1.0
In-Reply-To: <2804a1d0-9d68-ac43-3041-9490147b52b5@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>, viro@zeniv.linux.org.uk, nyc@holomorphy.com, kirill.shutemov@linux.intel.com, hughd@google.com, akpm@linux-foundation.org
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 4/18/18 1:26 PM, Mike Kravetz wrote:
> On 04/17/2018 02:08 PM, Yang Shi wrote:
>> And, set the flag for hugetlbfs as well to keep the consistency, and the
>> applications don't have to know what filesystem is used to use huge
>> page, just need to check ST_HUGE flag.
> For hugetlbfs, setting such a flag would be for consistency only.  mapping
> hugetlbfs files REQUIRES huge page alignment and size.

Yes, applications don't have to read this flag if the underlying 
filesystem is hugetlbfs. The fs magic number is good enough.

>
> If an application would want to take advantage of this flag for tmpfs, it
> needs to map at a fixed address (MAP_FIXED) for huge page alignment.  So,
> it will need to do one of the 'mmap tricks' to get a mapping at a suitably
> aligned address.

It doesn't have to be MAP_FIXED, but definitely has to be huge page 
aligned. This flag is aimed for this case. With this flag, the 
applications can know the underlying tmpfs with huge page supported, 
then the applications can mmap memory with huge page alignment 
intentionally.

>
> IIRC, there is code to 'suitably align' DAX mappings to appropriate huge page
> boundaries.  Perhaps, something like this could be added for tmpfs mounted
> with huge=?  Of course, this would not take into account 'length' but may
> help some.

Might be. However THP already exported huge page size to sysfs, the 
applications can read it to get the alignment.

Thanks,
Yang

>

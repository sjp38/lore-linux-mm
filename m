Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2D0926B0008
	for <linux-mm@kvack.org>; Tue, 17 Apr 2018 17:51:28 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f19so11780688pfn.6
        for <linux-mm@kvack.org>; Tue, 17 Apr 2018 14:51:28 -0700 (PDT)
Received: from out30-132.freemail.mail.aliyun.com (out30-132.freemail.mail.aliyun.com. [115.124.30.132])
        by mx.google.com with ESMTPS id bh10-v6si12097829plb.322.2018.04.17.14.51.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Apr 2018 14:51:26 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: introduce ST_HUGE flag and set it to tmpfs and
 hugetlbfs
References: <1523999293-94152-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180417143144.b7ffb07fad28875bad546247@linux-foundation.org>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <8f01845c-51dd-20a6-1d75-64f9de0ccb0b@linux.alibaba.com>
Date: Tue, 17 Apr 2018 14:51:17 -0700
MIME-Version: 1.0
In-Reply-To: <20180417143144.b7ffb07fad28875bad546247@linux-foundation.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: viro@zeniv.linux.org.uk, nyc@holomorphy.com, mike.kravetz@oracle.com, kirill.shutemov@linux.intel.com, hughd@google.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-man@vger.kernel.org, mtk.manpages@gmail.com, linux-api@vger.kernel.org



On 4/17/18 2:31 PM, Andrew Morton wrote:
> On Wed, 18 Apr 2018 05:08:13 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
>> Since tmpfs THP was supported in 4.8, hugetlbfs is not the only
>> filesystem with huge page support anymore. tmpfs can use huge page via
>> THP when mounting by "huge=" mount option.
>>
>> When applications use huge page on hugetlbfs, it just need check the
>> filesystem magic number, but it is not enough for tmpfs. So, introduce
>> ST_HUGE flag to statfs if super block has SB_HUGE set which indicates
>> huge page is supported on the specific filesystem.
>>
>> Some applications could benefit from this change, for example QEMU.
>> When use mmap file as guest VM backend memory, QEMU typically mmap the
>> file size plus one extra page. If the file is on hugetlbfs the extra
>> page is huge page size (i.e. 2MB), but it is still 4KB on tmpfs even
>> though THP is enabled. tmpfs THP requires VMA is huge page aligned, so
>> if 4KB page is used THP will not be used at all. The below /proc/meminfo
>> fragment shows the THP use of QEMU with 4K page:
>>
>> ShmemHugePages:   679936 kB
>> ShmemPmdMapped:        0 kB
>>
>> With ST_HUGE flag, QEMU can get huge page, then /proc/meminfo looks
>> like:
>>
>> ShmemHugePages:    77824 kB
>> ShmemPmdMapped:     6144 kB
>>
>> With this flag, the applications can know if huge page is supported on
>> the filesystem then optimize the behavior of the applications
>> accordingly. Although the similar function can be implemented in
>> applications by traversing the mount options, it looks more convenient
>> if kernel can provide such flag.
>>
>> Even though ST_HUGE is set, f_bsize still returns 4KB for tmpfs since
>> THP could be split, and it also my fallback to 4KB page silently if
>> there is not enough huge page.
>>
>> And, set the flag for hugetlbfs as well to keep the consistency, and the
>> applications don't have to know what filesystem is used to use huge
>> page, just need to check ST_HUGE flag.
>>
> Patch is simple enough, although I'm having trouble forming an opinion
> about it ;)
>
> It will call for an update to the statfs(2) manpage.  I'm not sure
> which of linux-man@vger.kernel.org, mtk.manpages@gmail.com and
> linux-api@vger.kernel.org is best for that, so I'd cc all three...

Thanks, Andrew. Added cc to those 3 lists.

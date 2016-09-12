Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5E77A6B0038
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 13:15:38 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 192so137818736itm.2
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:15:38 -0700 (PDT)
Received: from mail-oi0-x22f.google.com (mail-oi0-x22f.google.com. [2607:f8b0:4003:c06::22f])
        by mx.google.com with ESMTPS id d14si7161333otd.277.2016.09.12.10.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Sep 2016 10:15:37 -0700 (PDT)
Received: by mail-oi0-x22f.google.com with SMTP id q188so208796137oia.3
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 10:15:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160912100910.GC23346@node.shutemov.name>
References: <147361509579.17004.5258725187329709824.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20160912100910.GC23346@node.shutemov.name>
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 12 Sep 2016 10:15:35 -0700
Message-ID: <CAPcyv4i0j2d9NqqG4JJFDykP400xT+JcO9wA+d9MiRJTBHTfbA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm, mincore2(): retrieve dax and tlb-size
 attributes of an address range
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Linux MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Xiao Guangrong <guangrong.xiao@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-api@vger.kernel.org, Dave Hansen <dave.hansen@linux.intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Mon, Sep 12, 2016 at 3:09 AM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Sun, Sep 11, 2016 at 10:31:35AM -0700, Dan Williams wrote:
>> As evidenced by this bug report [1], userspace libraries are interested
>> in whether a mapping is DAX mapped, i.e. no intervening page cache.
>> Rather than using the ambiguous VM_MIXEDMAP flag in smaps, provide an
>> explicit "is dax" indication as a new flag in the page vector populated
>> by mincore.
>>
>> There are also cases, particularly for testing and validating a
>> configuration to know the hardware mapping geometry of the pages in a
>> given process address range.  Consider filesystem-dax where a
>> configuration needs to take care to align partitions and block
>> allocations before huge page mappings might be used, or
>> anonymous-transparent-huge-pages where a process is opportunistically
>> assigned large pages.  mincore2() allows these configurations to be
>> surveyed and validated.
>>
>> The implementation takes advantage of the unused bits in the per-page
>> byte returned for each PAGE_SIZE extent of a given address range.  The
>> new format of each vector byte is:
>>
>> (TLB_SHIFT - PAGE_SHIFT) << 2 | vma_is_dax() << 1 | page_present
>>
>> [1]: https://lkml.org/lkml/2016/9/7/61
>>
>> Cc: Arnd Bergmann <arnd@arndb.de>
>> Cc: Andrea Arcangeli <aarcange@redhat.com>
>> Cc: Andrew Morton <akpm@linux-foundation.org>
>> Cc: Dave Hansen <dave.hansen@linux.intel.com>
>> Cc: Xiao Guangrong <guangrong.xiao@linux.intel.com>
>> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> Signed-off-by: Dan Williams <dan.j.williams@intel.com>
>> ---
>>  include/linux/syscalls.h               |    2 +
>>  include/uapi/asm-generic/mman-common.h |    3 +
>>  kernel/sys_ni.c                        |    1
>>  mm/mincore.c                           |  126 +++++++++++++++++++++++++-------
>>  4 files changed, 104 insertions(+), 28 deletions(-)
>>
>> diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
>> index d02239022bd0..4aa2ee7e359a 100644
>> --- a/include/linux/syscalls.h
>> +++ b/include/linux/syscalls.h
>> @@ -467,6 +467,8 @@ asmlinkage long sys_munlockall(void);
>>  asmlinkage long sys_madvise(unsigned long start, size_t len, int behavior);
>>  asmlinkage long sys_mincore(unsigned long start, size_t len,
>>                               unsigned char __user * vec);
>> +asmlinkage long sys_mincore2(unsigned long start, size_t len,
>> +                             unsigned char __user * vec, int flags);
>
> We had few attempts to extand mincore(2) interface/functionality before.
> None of them ended up in upsteam.
>
> How this attempt compares to previous?

Not sure, I'm wading into this cold trying to get my pet problem
solved, hence the RFC.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

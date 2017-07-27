Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 992C26B04CF
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 17:18:54 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id d15so22998982qta.11
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 14:18:54 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id x67si5201204qka.71.2017.07.27.14.18.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 14:18:53 -0700 (PDT)
Subject: Re: [RFC PATCH 3/3] mm: shm: Use new hugetlb size encoding
 definitions
References: <20170328175408.GD7838@bombadil.infradead.org>
 <1500330481-28476-1-git-send-email-mike.kravetz@oracle.com>
 <1500330481-28476-4-git-send-email-mike.kravetz@oracle.com>
 <20170726095338.GF2981@dhcp22.suse.cz> <20170726100718.GG2981@dhcp22.suse.cz>
 <d6c78995-bd4c-3894-0a48-b289ad81104b@oracle.com>
 <20170727075051.GJ20970@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <9baf7efb-3772-b101-b68a-ab88c02bfc40@oracle.com>
Date: Thu, 27 Jul 2017 14:18:11 -0700
MIME-Version: 1.0
In-Reply-To: <20170727075051.GJ20970@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Matthew Wilcox <willy@infradead.org>, akpm@linux-foundation.org, ak@linux.intel.com, mtk.manpages@gmail.com, Davidlohr Bueso <dbueso@suse.de>, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, aarcange@redhat.com

On 07/27/2017 12:50 AM, Michal Hocko wrote:
> On Wed 26-07-17 10:39:30, Mike Kravetz wrote:
>> On 07/26/2017 03:07 AM, Michal Hocko wrote:
>>> On Wed 26-07-17 11:53:38, Michal Hocko wrote:
>>>> On Mon 17-07-17 15:28:01, Mike Kravetz wrote:
>>>>> Use the common definitions from hugetlb_encode.h header file for
>>>>> encoding hugetlb size definitions in shmget system call flags.  In
>>>>> addition, move these definitions to the from the internal to user
>>>>> (uapi) header file.
>>>>
>>>> s@to the from@from@
>>>>
>>>>>
>>>>> Suggested-by: Matthew Wilcox <willy@infradead.org>
>>>>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>>>>
>>>> with s@HUGETLB_FLAG_ENCODE__16GB@HUGETLB_FLAG_ENCODE_16GB@
>>>>
>>>> Acked-by: Michal Hocko <mhocko@suse.com>
>>>
>>> Btw. man page mentions only 2MB and 1GB, we should document others and
>>> note that each arch might support only subset of them
>>
>> Thanks for looking at these Michal.
>> BTW, those definitions below are wrong.  They should be SHM_HUGE_*. :(
> 
> Ups, and I completely missed that.
> 
>> In the overview of this RFC, I mentioned still needing to address the
>> comment from Aneesh about splitting SHM_HUGE_* definitions into arch
>> specific header files.  This is how it is done for mmap.  If an arch
>> supports multiple huge page sizes, the 'asm/mman.h' contains definitions
>> for those sizes.  There will be a bit of churn (such as header file
>> renaming) to do this for shm as well.  So, I keep going back and forth
>> asking myself 'is it worth it'?
> 
> Why cannot we use a generic header? Btw. I think it would be better for
> MMAP definitions as well.

I assume you are asking about a uapi asm-generic header file?  Currently
mmap has two such files:  mman.h and mman-common.h.  In order to get the
definitions in such files, arch specific header files must #include the
asm-generic headers.  There are arch specific mmap headers today that do
not include either of the asm-generic headers.  And, they have their own
definitions for MAP_HUGE_SHIFT.  So, it seems we can not use one of the
existing mmap asm-generic header files.  Rather, we would need to create
a new one and have that included by all arch specific files.

However, ALL the MAP_HUGE_* definitions in all the arch specific and
asm-generic header files are the same.  It would be possible to just put
all those MAP_HUGE_* definitions in the primary uapi header file
(include/uapi/linux/mman.h).  If there was ever a need for arch specific
values in the future, we could split them out at that time.

>> Some things to consider.
>>
>> - We should be consistent between mmap and shm.  Also remember, that I
>>   will propose adding the same type of encoding to memfd_create.  So,
>>   three system calls will use the encoding.  They should be consistent.
> 
> agreed
> 
>> - Adding the arch specific definitions seems the 'most correct', as a
>>   user can not use a definition not supported by the arch.  However,
>>   even if an arch supports a huge page size it does not mean that the
>>   running kernel supports that size.  Therefore, the folllowing is in
>>   the man page.
>>   "The  range  of  huge page sizes that are supported by the system
>>    can be discovered by listing  the  subdirectories  in
>>    /sys/kernel/mm/hugepages."
> 
> Doesn't the respective call return -EINVAL on the unsupported hugepage
> size?

Yes, it does.

>> - Another alternative is to make all known huge page sizes available
>>   to all users.  This is 'easier' as the definitions can likely reside
>>   in a common header file.  The user will  need to determine what
>>   huge page sizes are supported by the running kernel as mentioned in
>>   the man page.
> 
> yes I think this makes more sense.

Ok, thanks.

The only remaining question is what kind of common header to use:
1) An asm-generic header file in case there may be arch specific differences
   in the future.
2) Use the primary uapi header file in include/uapi/linux/mman|shm.h.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

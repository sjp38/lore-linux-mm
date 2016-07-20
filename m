Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA24E6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 03:37:50 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so70874790pab.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 00:37:50 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTP id 80si2008310pfv.7.2016.07.20.00.37.48
        for <linux-mm@kvack.org>;
        Wed, 20 Jul 2016 00:37:49 -0700 (PDT)
Message-ID: <578F2781.80502@huawei.com>
Date: Wed, 20 Jul 2016 15:25:53 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] kexec: add a pmd huge entry condition during the
 page table
References: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com> <1468299403-27954-2-git-send-email-zhongjiang@huawei.com> <87a8hm3lme.fsf@x220.int.ebiederm.org> <5785E764.8050304@huawei.com> <87vb08ich2.fsf@x220.int.ebiederm.org>
In-Reply-To: <87vb08ich2.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, kexec@lists.infradead.org

On 2016/7/14 21:19, Eric W. Biederman wrote:
> zhong jiang <zhongjiang@huawei.com> writes:
>
>> On 2016/7/12 23:46, Eric W. Biederman wrote:
>>> zhongjiang <zhongjiang@huawei.com> writes:
>>>
>>>> From: zhong jiang <zhongjiang@huawei.com>
>>>>
>>>> when image is loaded into kernel, we need set up page table for it. and 
>>>> all valid pfn also set up new mapping. it will tend to establish a pmd 
>>>> page table in the form of a large page if pud_present is true. relocate_kernel 
>>>> points to code segment can locate in the pmd huge entry in init_transtion_pgtable. 
>>>> therefore, we need to take the situation into account.
>>> I can see how in theory this might be necessary but when is a kernel virtual
>>> address on x86_64 that is above 0x8000000000000000 in conflict with an
>>> identity mapped physicall address that are all below 0x8000000000000000?
>>>
>>> If anything the code could be simplified to always assume those mappings
>>> are unoccupied.
>>>
>>> Did you run into an actual failure somewhere?
>>>
>>> Eric
>>>
>>    I  do not understand what you trying to say,  Maybe I miss your point.
>>   
>>   The key is how to ensure that relocate_kernel points to the pmd
>>   entry is not huge page.
> Kernel virtual addresses are in the negative half of the address space.
> Identity mapped physical addresses are in the positive half of the
> address space.
>
> As the entire negative half of the address space at the time that page
> table entry is being created the are no huge pages present.
>
> Even testing pmd_present is a redundant, and that is probably the bug.
>
> Eric
>
> .
  ok , I know your mean.  we allocate new pgd page, that is  control_code_page,
  to rebuild new mapping machanism in init_pgtable.  because the relocate_kernel
  is in the negative half of the address space.   and The page table is not establise
  for the new pgd.  To my surprise,  if the page table is not exist, why we need check
  p(g,u,m)d_present() . if not , I still think that it can exist a pmd huge .

 or Maybe I misunderstand its meaning.

  Thanks
  zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

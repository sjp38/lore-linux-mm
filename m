Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5E24C6B0003
	for <linux-mm@kvack.org>; Tue, 24 Jul 2018 13:56:52 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id u16-v6so511547pfm.15
        for <linux-mm@kvack.org>; Tue, 24 Jul 2018 10:56:52 -0700 (PDT)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id f67-v6si11542590plb.460.2018.07.24.10.56.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Jul 2018 10:56:51 -0700 (PDT)
Subject: Re: [RFC v5 PATCH 2/2] mm: mmap: zap pages with read mmap_sem in
 munmap
References: <1531956101-8526-1-git-send-email-yang.shi@linux.alibaba.com>
 <1531956101-8526-3-git-send-email-yang.shi@linux.alibaba.com>
 <25fca2a1-0a55-13eb-0c75-6d0238fe780b@linux.vnet.ibm.com>
 <b8c128c4-3a8e-ed17-2d9f-76f71bfdad43@linux.alibaba.com>
 <e9553340-3b8d-bc26-781d-8a6a8716bc8f@linux.vnet.ibm.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <02228f42-438b-7840-5653-f076fc190f14@linux.alibaba.com>
Date: Tue, 24 Jul 2018 10:56:31 -0700
MIME-Version: 1.0
In-Reply-To: <e9553340-3b8d-bc26-781d-8a6a8716bc8f@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, mhocko@kernel.org, willy@infradead.org, kirill@shutemov.name, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org


>>>> +static int vm_munmap_zap_rlock(unsigned long start, size_t len)
>>>> +{
>>>> +A A A  int ret;
>>>> +A A A  struct mm_struct *mm = current->mm;
>>>> +A A A  LIST_HEAD(uf);
>>>> +
>>>> +A A A  ret = do_munmap_zap_rlock(mm, start, len, &uf);
>>>> +A A A  userfaultfd_unmap_complete(mm, &uf);
>>>> +A A A  return ret;
>>>> +}
>>>> +
>>>>  A  int vm_munmap(unsigned long start, size_t len)
>>>>  A  {
>>>>  A A A A A  int ret;
>>> A stupid question, since the overhead of vm_munmap_zap_rlock() compared to
>>> vm_munmap() is not significant, why not putting that in vm_munmap() instead of
>>> introducing a new vm_munmap_zap_rlock() ?
>> Since vm_munmap() is called in other paths too, i.e. drm driver, kvm, etc. I'm
>> not quite sure if those paths are safe enough to this optimization. And, it
>> looks they are not the main sources of the latency, so here I introduced
>> vm_munmap_zap_rlock() for munmap() only.
> For my information, what could be unsafe for these paths ?

I'm just not sure if they are safe enough nor not, because I'm not 
knowledgeable enough to kvm and drm drivers. They might be safe, but I 
don't know how to prove that.

So, since they might be not the main sources of latency (I haven't seen 
any hung report due to them), so it sounds safe to not touch them for now.

>
>> If someone reports or we see they are the sources of latency too, and the
>> optimization is proved safe to them, we can definitely extend this to all
>> vm_munmap() calls
>>
>> Thanks,
>> Yang
>>
>>>> @@ -2855,10 +2939,9 @@ int vm_munmap(unsigned long start, size_t len)
>>>>  A  SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>>>>  A  {
>>>>  A A A A A  profile_munmap(addr);
>>>> -A A A  return vm_munmap(addr, len);
>>>> +A A A  return vm_munmap_zap_rlock(addr, len);
>>>>  A  }
>>>>
>>>> -
>>>>  A  /*
>>>>  A A  * Emulation of deprecated remap_file_pages() syscall.
>>>>  A A  */
>>>> @@ -3146,7 +3229,7 @@ void exit_mmap(struct mm_struct *mm)
>>>>  A A A A A  tlb_gather_mmu(&tlb, mm, 0, -1);
>>>>  A A A A A  /* update_hiwater_rss(mm) here? but nobody should be looking */
>>>>  A A A A A  /* Use -1 here to ensure all VMAs in the mm are unmapped */
>>>> -A A A  unmap_vmas(&tlb, vma, 0, -1);
>>>> +A A A  unmap_vmas(&tlb, vma, 0, -1, false);
>>>>  A A A A A  free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
>>>>  A A A A A  tlb_finish_mmu(&tlb, 0, -1);
>>>>

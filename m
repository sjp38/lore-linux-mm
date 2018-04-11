Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0498D6B0009
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:03:55 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i4so690919wrh.4
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 02:03:54 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id d5si10041edi.418.2018.04.11.02.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Apr 2018 02:03:53 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3B90gNM036535
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:03:52 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2h9cpmqfh7-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:03:51 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 11 Apr 2018 10:03:47 +0100
Subject: Re: [PATCH v3 2/2] mm: remove odd HAVE_PTE_SPECIAL
References: <1523433816-14460-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523433816-14460-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <de6ee514-8b7e-24d0-a7ee-a8887e8b0ae9@c-s.fr>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 11 Apr 2018 11:03:37 +0200
MIME-Version: 1.0
In-Reply-To: <de6ee514-8b7e-24d0-a7ee-a8887e8b0ae9@c-s.fr>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <93ed4fe4-dd1e-51be-948b-d53b16de21c5@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe LEROY <christophe.leroy@c-s.fr>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>, Robin Murphy <robin.murphy@arm.com>



On 11/04/2018 10:58, Christophe LEROY wrote:
> 
> 
> Le 11/04/2018 A  10:03, Laurent Dufour a A(C)critA :
>> Remove the additional define HAVE_PTE_SPECIAL and rely directly on
>> CONFIG_ARCH_HAS_PTE_SPECIAL.
>>
>> There is no functional change introduced by this patch
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>> A  mm/memory.c | 19 ++++++++-----------
>> A  1 file changed, 8 insertions(+), 11 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 96910c625daa..7f7dc7b2a341 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -817,17 +817,12 @@ static void print_bad_pte(struct vm_area_struct *vma,
>> unsigned long addr,
>> A A  * PFNMAP mappings in order to support COWable mappings.
>> A A  *
>> A A  */
>> -#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
>> -# define HAVE_PTE_SPECIAL 1
>> -#else
>> -# define HAVE_PTE_SPECIAL 0
>> -#endif
>> A  struct page *_vm_normal_page(struct vm_area_struct *vma, unsigned long addr,
>> A A A A A A A A A A A A A A A A A A  pte_t pte, bool with_public_device)
>> A  {
>> A A A A A  unsigned long pfn = pte_pfn(pte);
>> A  -A A A  if (HAVE_PTE_SPECIAL) {
>> +A A A  if (IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL)) {
>> A A A A A A A A A  if (likely(!pte_special(pte)))
>> A A A A A A A A A A A A A  goto check_pfn;
>> A A A A A A A A A  if (vma->vm_ops && vma->vm_ops->find_special_page)
>> @@ -862,7 +857,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma,
>> unsigned long addr,
>> A A A A A A A A A  return NULL;
>> A A A A A  }
>> A  -A A A  /* !HAVE_PTE_SPECIAL case follows: */
>> +A A A  /* !CONFIG_ARCH_HAS_PTE_SPECIAL case follows: */
>> A  A A A A A  if (unlikely(vma->vm_flags & (VM_PFNMAP|VM_MIXEDMAP))) {
>> A A A A A A A A A  if (vma->vm_flags & VM_MIXEDMAP) {
>> @@ -881,7 +876,8 @@ struct page *_vm_normal_page(struct vm_area_struct *vma,
>> unsigned long addr,
>> A  A A A A A  if (is_zero_pfn(pfn))
>> A A A A A A A A A  return NULL;
>> -check_pfn:
>> +
>> +check_pfn: __maybe_unused
> 
> See below
> 
>> A A A A A  if (unlikely(pfn > highest_memmap_pfn)) {
>> A A A A A A A A A  print_bad_pte(vma, addr, pte, NULL);
>> A A A A A A A A A  return NULL;
>> @@ -891,7 +887,7 @@ struct page *_vm_normal_page(struct vm_area_struct *vma,
>> unsigned long addr,
>> A A A A A A  * NOTE! We still have PageReserved() pages in the page tables.
>> A A A A A A  * eg. VDSO mappings can cause them to exist.
>> A A A A A A  */
>> -out:
>> +out: __maybe_unused
> 
> Why do you need that change ?
> 
> There is no reason for the compiler to complain. It would complain if the goto
> was within a #ifdef, but all the purpose of using IS_ENABLED() is to allow the
> compiler to properly handle all possible cases. That's all the force of
> IS_ENABLED() compared to ifdefs, and that the reason why they are plebicited,
> ref Linux Codying style for a detailed explanation.

Fair enough.

Should I submit a v4 just to remove these so ugly __maybe_unused ?

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 02F366B0005
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:44:15 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id i4so8497263wrh.4
        for <linux-mm@kvack.org>; Tue, 10 Apr 2018 09:44:14 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id h30si468974edc.442.2018.04.10.09.44.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Apr 2018 09:44:13 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3AGgBs0025973
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:44:12 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2h90hksmgc-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 10 Apr 2018 12:44:12 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 10 Apr 2018 17:44:10 +0100
Subject: Re: [PATCH v2 2/2] mm: remove odd HAVE_PTE_SPECIAL
References: <1523373951-10981-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <1523373951-10981-3-git-send-email-ldufour@linux.vnet.ibm.com>
 <3f20ac8b-20b8-f052-bc44-dcc0316354ca@arm.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Tue, 10 Apr 2018 18:44:00 +0200
MIME-Version: 1.0
In-Reply-To: <3f20ac8b-20b8-f052-bc44-dcc0316354ca@arm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <1521dc0e-e9f8-d10f-e213-1b1552eb03fa@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-doc@vger.kernel.org, linux-snps-arc@lists.infradead.org, linux-arm-kernel@lists.infradead.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, Jerome Glisse <jglisse@redhat.com>, mhocko@kernel.org, aneesh.kumar@linux.vnet.ibm.com, akpm@linux-foundation.org, mpe@ellerman.id.au, benh@kernel.crashing.org, paulus@samba.org, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, "David S . Miller" <davem@davemloft.net>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Vineet Gupta <vgupta@synopsys.com>, Palmer Dabbelt <palmer@sifive.com>, Albert Ou <albert@sifive.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, David Rientjes <rientjes@google.com>



On 10/04/2018 17:58, Robin Murphy wrote:
> On 10/04/18 16:25, Laurent Dufour wrote:
>> Remove the additional define HAVE_PTE_SPECIAL and rely directly on
>> CONFIG_ARCH_HAS_PTE_SPECIAL.
>>
>> There is no functional change introduced by this patch
>>
>> Signed-off-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
>> ---
>> A  mm/memory.c | 23 ++++++++++-------------
>> A  1 file changed, 10 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index 96910c625daa..53b6344a90d2 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -817,19 +817,13 @@ static void print_bad_pte(struct vm_area_struct *vma,
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
>> -A A A A A A A  if (likely(!pte_special(pte)))
>> -A A A A A A A A A A A  goto check_pfn;
>> +#ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
> 
> Nit: Couldn't you use IS_ENABLED(CONFIG_ARCH_HAS_PTE_SPECIAL) within the
> existing code structure to avoid having to add these #ifdefs?

I agree, that would be better. I didn't thought about this option..
Thanks for reporting this.

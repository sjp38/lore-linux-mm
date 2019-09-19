Return-Path: <SRS0=3rjY=XO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.2 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CFB6C4CEC4
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 02:17:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CB802218AE
	for <linux-mm@archiver.kernel.org>; Thu, 19 Sep 2019 02:16:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="HOgLAhQl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CB802218AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 929076B0329; Wed, 18 Sep 2019 22:16:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8D9B36B032B; Wed, 18 Sep 2019 22:16:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7F0046B032C; Wed, 18 Sep 2019 22:16:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0106.hostedemail.com [216.40.44.106])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9CD6B0329
	for <linux-mm@kvack.org>; Wed, 18 Sep 2019 22:16:58 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 16CB4180AD803
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:16:58 +0000 (UTC)
X-FDA: 75950057316.05.wheel21_3cbfd66ae985f
X-HE-Tag: wheel21_3cbfd66ae985f
X-Filterd-Recvd-Size: 9200
Received: from mail-pf1-f196.google.com (mail-pf1-f196.google.com [209.85.210.196])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 19 Sep 2019 02:16:57 +0000 (UTC)
Received: by mail-pf1-f196.google.com with SMTP id q12so1182958pff.9
        for <linux-mm@kvack.org>; Wed, 18 Sep 2019 19:16:57 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:to:cc:references:from:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding;
        bh=v8j+KKtmRVgMXlvD0CNN4PMpgxJdXZjDz2rJhuUyCXk=;
        b=HOgLAhQlZVOSPHKYoDkAVD3oL1lCw1GE1ZHBOF2nQQIdMqGoTCHK4zJ4hjAcCbHwth
         0+Y43Ifzp50k4DuSGywzI5fGgz0Zz4nBLdqJzK/n4l7DoKyRyrjyS96/QtCjKoswlzE+
         nbWD/skOa3B5bs5MB6VP04wPKrGvVCiFmp/1uaHGlU7WgWbe6dK9tuAJjloMhL5mFAZo
         KuJkdAvWs0L875tb9h1ARdEkmGJv0t/QgMoaAyVGFRrL0GBfbuvcSR5SNsqOKgJFf6wy
         IiSKa/IC/WSC1njRHr+BebkeMwE363WpPVOkUYFAZjaunXzKUCOkVDDcu/rTdUPKnkYQ
         v5aA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-transfer-encoding;
        bh=v8j+KKtmRVgMXlvD0CNN4PMpgxJdXZjDz2rJhuUyCXk=;
        b=scmZJwE1xg1F1Imzp0DcjC4wQMRxY1ul5pEawCSw6c5tfQRNovIj+5AqXIuAFSIdlZ
         JndGd7RKm+pAFV/KNPRIJ8SXqeV8i9BtnVVYI84ma8KCDb7l4PrjYVNFsrejksK0iAX5
         ZKLPASNY8MQygCJ2zbJjI3bOqeLeT6IXalx32NUsiMEW6UDtg4hMPOa/abeVhNQDyWrh
         6no5brf7M5Y+YmvX7RDFd1AWIeVdUoF1+dJvwOLiu2ab7D1bx63EVG2lfkeGAm0nPSqE
         9zQiK+lX1qcKMIGIv7ASgPB4xiWGYoAk7t2eVO19BM5rdPJvhJDE/MdkbAFPvRrSs2ZN
         IJ7Q==
X-Gm-Message-State: APjAAAWBddR55gQZCqVyi1oQ96rQzkpwiw2HeGTj0KMJMw+C8XMigwuM
	y3iF1xnlX41AkJUSvBz1/14=
X-Google-Smtp-Source: APXvYqyekBZ5hZ8KIt+X8yfqNbL6YgnRIcVS2ZkbCmmFIyM+ir8QRC6om0PvBn39Wzt+1iBsGgw1iQ==
X-Received: by 2002:a62:7d81:: with SMTP id y123mr7630365pfc.133.1568859416096;
        Wed, 18 Sep 2019 19:16:56 -0700 (PDT)
Received: from [0.0.0.0] (104.129.187.94.16clouds.com. [104.129.187.94])
        by smtp.gmail.com with ESMTPSA id z12sm12749012pfj.41.2019.09.18.19.16.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Sep 2019 19:16:55 -0700 (PDT)
Subject: Re: [PATCH v4 3/3] mm: fix double page fault on arm64 if PTE_AF is
 cleared
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Jia He <justin.he@arm.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will@kernel.org>,
 Mark Rutland <mark.rutland@arm.com>, James Morse <james.morse@arm.com>,
 Marc Zyngier <maz@kernel.org>, Matthew Wilcox <willy@infradead.org>,
 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
 linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org, Suzuki Poulose <Suzuki.Poulose@arm.com>,
 Punit Agrawal <punitagrawal@gmail.com>,
 Anshuman Khandual <anshuman.khandual@arm.com>,
 Jun Yao <yaojun8558363@gmail.com>, Alex Van Brunt <avanbrunt@nvidia.com>,
 Robin Murphy <robin.murphy@arm.com>, Thomas Gleixner <tglx@linutronix.de>,
 Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?=
 <jglisse@redhat.com>, Ralph Campbell <rcampbell@nvidia.com>,
 Kaly Xin <Kaly.Xin@arm.com>
References: <20190918131914.38081-1-justin.he@arm.com>
 <20190918131914.38081-4-justin.he@arm.com>
 <20190918140027.ckj32xnryyyesc23@box>
From: Jia He <hejianet@gmail.com>
Message-ID: <bebe97e1-b1fe-7f36-91c0-7d412f093560@gmail.com>
Date: Thu, 19 Sep 2019 10:16:34 +0800
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <20190918140027.ckj32xnryyyesc23@box>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Kirill

[On behalf of justin.he@arm.com because some mails are filted...]

On 2019/9/18 22:00, Kirill A. Shutemov wrote:
> On Wed, Sep 18, 2019 at 09:19:14PM +0800, Jia He wrote:
>> When we tested pmdk unit test [1] vmmalloc_fork TEST1 in arm64 guest, there
>> will be a double page fault in __copy_from_user_inatomic of cow_user_page.
>>
>> Below call trace is from arm64 do_page_fault for debugging purpose
>> [  110.016195] Call trace:
>> [  110.016826]  do_page_fault+0x5a4/0x690
>> [  110.017812]  do_mem_abort+0x50/0xb0
>> [  110.018726]  el1_da+0x20/0xc4
>> [  110.019492]  __arch_copy_from_user+0x180/0x280
>> [  110.020646]  do_wp_page+0xb0/0x860
>> [  110.021517]  __handle_mm_fault+0x994/0x1338
>> [  110.022606]  handle_mm_fault+0xe8/0x180
>> [  110.023584]  do_page_fault+0x240/0x690
>> [  110.024535]  do_mem_abort+0x50/0xb0
>> [  110.025423]  el0_da+0x20/0x24
>>
>> The pte info before __copy_from_user_inatomic is (PTE_AF is cleared):
>> [ffff9b007000] pgd=000000023d4f8003, pud=000000023da9b003, pmd=000000023d4b3003, pte=360000298607bd3
>>
>> As told by Catalin: "On arm64 without hardware Access Flag, copying from
>> user will fail because the pte is old and cannot be marked young. So we
>> always end up with zeroed page after fork() + CoW for pfn mappings. we
>> don't always have a hardware-managed access flag on arm64."
>>
>> This patch fix it by calling pte_mkyoung. Also, the parameter is
>> changed because vmf should be passed to cow_user_page()
>>
>> [1] https://github.com/pmem/pmdk/tree/master/src/test/vmmalloc_fork
>>
>> Reported-by: Yibo Cai <Yibo.Cai@arm.com>
>> Signed-off-by: Jia He <justin.he@arm.com>
>> ---
>>   mm/memory.c | 35 ++++++++++++++++++++++++++++++-----
>>   1 file changed, 30 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index e2bb51b6242e..d2c130a5883b 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -118,6 +118,13 @@ int randomize_va_space __read_mostly =
>>   					2;
>>   #endif
>>   
>> +#ifndef arch_faults_on_old_pte
>> +static inline bool arch_faults_on_old_pte(void)
>> +{
>> +	return false;
>> +}
>> +#endif
>> +
>>   static int __init disable_randmaps(char *s)
>>   {
>>   	randomize_va_space = 0;
>> @@ -2140,8 +2147,12 @@ static inline int pte_unmap_same(struct mm_struct *mm, pmd_t *pmd,
>>   	return same;
>>   }
>>   
>> -static inline void cow_user_page(struct page *dst, struct page *src, unsigned long va, struct vm_area_struct *vma)
>> +static inline void cow_user_page(struct page *dst, struct page *src,
>> +				 struct vm_fault *vmf)
>>   {
>> +	struct vm_area_struct *vma = vmf->vma;
>> +	unsigned long addr = vmf->address;
>> +
>>   	debug_dma_assert_idle(src);
>>   
>>   	/*
>> @@ -2152,20 +2163,34 @@ static inline void cow_user_page(struct page *dst, struct page *src, unsigned lo
>>   	 */
>>   	if (unlikely(!src)) {
>>   		void *kaddr = kmap_atomic(dst);
>> -		void __user *uaddr = (void __user *)(va & PAGE_MASK);
>> +		void __user *uaddr = (void __user *)(addr & PAGE_MASK);
>> +		pte_t entry;
>>   
>>   		/*
>>   		 * This really shouldn't fail, because the page is there
>>   		 * in the page tables. But it might just be unreadable,
>>   		 * in which case we just give up and fill the result with
>> -		 * zeroes.
>> +		 * zeroes. On architectures with software "accessed" bits,
>> +		 * we would take a double page fault here, so mark it
>> +		 * accessed here.
>>   		 */
>> +		if (arch_faults_on_old_pte() && !pte_young(vmf->orig_pte)) {
>> +			spin_lock(vmf->ptl);
>> +			if (likely(pte_same(*vmf->pte, vmf->orig_pte))) {
>> +				entry = pte_mkyoung(vmf->orig_pte);
>> +				if (ptep_set_access_flags(vma, addr,
>> +							  vmf->pte, entry, 0))
>> +					update_mmu_cache(vma, addr, vmf->pte);
>> +			}
> I don't follow.
>
> So if pte has changed under you, you don't set the accessed bit, but never
> the less copy from the user.
>
> What makes you think it will not trigger the same problem?
>
> I think we need to make cow_user_page() fail in this case and caller --
> wp_page_copy() -- return zero. If the fault was solved by other thread, we
> are fine. If not userspace would re-fault on the same address and we will
> handle the fault from the second attempt.

Thanks for the pointing. How about make cow_user_page() be returned

VM_FAULT_RETRY? Then in do_page_fault(), it can retry the page fault?

---
Cheers,
Justin (Jia He)

>
>> +			spin_unlock(vmf->ptl);
>> +		}
>> +
>>   		if (__copy_from_user_inatomic(kaddr, uaddr, PAGE_SIZE))
>>   			clear_page(kaddr);
>>   		kunmap_atomic(kaddr);
>>   		flush_dcache_page(dst);
>>   	} else
>> -		copy_user_highpage(dst, src, va, vma);
>> +		copy_user_highpage(dst, src, addr, vma);
>>   }
>>   
>>   static gfp_t __get_fault_gfp_mask(struct vm_area_struct *vma)
>> @@ -2318,7 +2343,7 @@ static vm_fault_t wp_page_copy(struct vm_fault *vmf)
>>   				vmf->address);
>>   		if (!new_page)
>>   			goto oom;
>> -		cow_user_page(new_page, old_page, vmf->address, vma);
>> +		cow_user_page(new_page, old_page, vmf);
>>   	}
>>   
>>   	if (mem_cgroup_try_charge_delay(new_page, mm, GFP_KERNEL, &memcg, false))
>> -- 
>> 2.17.1
>>
>>
-- 



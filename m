Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 047C76B025F
	for <linux-mm@kvack.org>; Wed, 16 Aug 2017 10:36:00 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id y96so6167679wrc.10
        for <linux-mm@kvack.org>; Wed, 16 Aug 2017 07:35:59 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 92si1186235edm.381.2017.08.16.07.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Aug 2017 07:35:58 -0700 (PDT)
Subject: Re: [PATCH v7 2/9] mm, swap: Add infrastructure for saving page
 metadata on swap
References: <cover.1502219353.git.khalid.aziz@oracle.com>
 <cover.1502219353.git.khalid.aziz@oracle.com>
 <87ff7a44c45bd6a146102c6e6033ee7810d9ebb5.1502219353.git.khalid.aziz@oracle.com>
 <20170815.215326.1833101229202321710.davem@davemloft.net>
From: Khalid Aziz <khalid.aziz@oracle.com>
Message-ID: <05c64690-fa24-7104-4f1f-d98ff54863bc@oracle.com>
Date: Wed, 16 Aug 2017 08:34:42 -0600
MIME-Version: 1.0
In-Reply-To: <20170815.215326.1833101229202321710.davem@davemloft.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, dave.hansen@linux.intel.com, arnd@arndb.de, kirill.shutemov@linux.intel.com, mhocko@suse.com, jack@suse.cz, ross.zwisler@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, dave.jiang@intel.com, willy@infradead.org, hughd@google.com, minchan@kernel.org, hannes@cmpxchg.org, hillf.zj@alibaba-inc.com, shli@fb.com, mingo@kernel.org, jmarchan@redhat.com, lstoakes@gmail.com, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, sparclinux@vger.kernel.org, khalid@gonehiking.org

On 08/15/2017 10:53 PM, David Miller wrote:
> From: Khalid Aziz <khalid.aziz@oracle.com>
> Date: Wed,  9 Aug 2017 15:25:55 -0600
> 
>> @@ -1399,6 +1399,12 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>   				(flags & TTU_MIGRATION)) {
>>   			swp_entry_t entry;
>>   			pte_t swp_pte;
>> +
>> +			if (arch_unmap_one(mm, vma, address, pteval) < 0) {
>> +				set_pte_at(mm, address, pvmw.pte, pteval);
>> +				ret = false;
>> +				page_vma_mapped_walk_done(&pvmw);
>> +				break;
>>   			/*
>>   			 * Store the pfn of the page in a special migration
>>   			 * pte. do_swap_page() will wait until the migration
>> @@ -1410,6 +1416,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>   			if (pte_soft_dirty(pteval))
>>   				swp_pte = pte_swp_mksoft_dirty(swp_pte);
>>   			set_pte_at(mm, address, pvmw.pte, swp_pte);
>> +			}
> 
> This basic block doesn't look right.  I think the new closing brace is
> intended to be right after the new break; statement.  If not at the
> very least the indentation of the existing code in there needs to be
> adjusted.

Hi Dave,

Thanks. That brace needs to move up right after break. I will fix that.

--
Khalid

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

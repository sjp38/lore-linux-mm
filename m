Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1C8006B002A
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 14:14:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id o11so4443880pgp.14
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 11:14:52 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id h8si1721452pgc.32.2018.02.09.11.14.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 11:14:51 -0800 (PST)
Subject: Re: [PATCH] mm: thp: fix potential clearing to referenced flag in
 page_idle_clear_pte_refs_one()
References: <1517875596-76350-1-git-send-email-yang.shi@linux.alibaba.com>
 <20180208143926.5484e8fd75a56ff35b778bcc@linux-foundation.org>
 <20180209043325.l6b6hwgeomqldeb6@node.shutemov.name>
 <a19c08ad-ce34-3a9f-0c7c-6ca912660456@linux.alibaba.com>
 <20180209081638.hcmruhckeu47kibx@node.shutemov.name>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <fe38e7dc-f8e7-4062-198a-50f59aff6d0e@linux.alibaba.com>
Date: Fri, 9 Feb 2018 11:14:29 -0800
MIME-Version: 1.0
In-Reply-To: <20180209081638.hcmruhckeu47kibx@node.shutemov.name>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, gavin.dg@linux.alibaba.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2/9/18 12:16 AM, Kirill A. Shutemov wrote:
> On Thu, Feb 08, 2018 at 08:47:35PM -0800, Yang Shi wrote:
>>
>> On 2/8/18 8:33 PM, Kirill A. Shutemov wrote:
>>> On Thu, Feb 08, 2018 at 02:39:26PM -0800, Andrew Morton wrote:
>>>> On Tue,  6 Feb 2018 08:06:36 +0800 Yang Shi <yang.shi@linux.alibaba.com> wrote:
>>>>
>>>>> For PTE-mapped THP, the compound THP has not been split to normal 4K
>>>>> pages yet, the whole THP is considered referenced if any one of sub
>>>>> page is referenced.
>>>>>
>>>>> When walking PTE-mapped THP by pvmw, all relevant PTEs will be checked
>>>>> to retrieve referenced bit. But, the current code just returns the
>>>>> result of the last PTE. If the last PTE has not referenced, the
>>>>> referenced flag will be cleared.
>>>>>
>>>>> So, here just break pvmw walk once referenced PTE is found if the page
>>>>> is a part of THP.
>>>>>
>>>>> ...
>>>>>
>>>>> --- a/mm/page_idle.c
>>>>> +++ b/mm/page_idle.c
>>>>> @@ -67,6 +67,14 @@ static bool page_idle_clear_pte_refs_one(struct page *page,
>>>>>    		if (pvmw.pte) {
>>>>>    			referenced = ptep_clear_young_notify(vma, addr,
>>>>>    					pvmw.pte);
>>>>> +			/*
>>>>> +			 * For PTE-mapped THP, one sub page is referenced,
>>>>> +			 * the whole THP is referenced.
>>>>> +			 */
>>>>> +			if (referenced && PageTransCompound(pvmw.page)) {
>>>>> +				page_vma_mapped_walk_done(&pvmw);
>>>>> +				break;
>>>>> +			}
>>>> This means that the function will no longer clear the referenced bits
>>>> in all the ptes.  What effect does this have and should we document
>>>> this in some fashion?
>>> Yeah, the patch is wrong. We need to get all ptes for THP cleared.
>>>
>>> What about something like this instead (untested):
>> Thanks, Kirill. It looks correct. All ptes should be cleared.
>>
>> I'm going to prepare v2 patch.
> Note, it should be ||=, not |= (although it would work correctly too).

checkpatch doesn't like "||=", it reports no space error. Use referenced 
= referenced || ptep_clear_young_notify(...) to make checkpatch happy.

Regards,
Yang

>
> I should really wake up properly before touching code. :-/
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

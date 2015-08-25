Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 253316B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 07:44:19 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so13020106wid.1
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 04:44:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id eg9si38335065wjd.184.2015.08.25.04.44.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 04:44:17 -0700 (PDT)
Subject: Re: [PATCHv3 4/5] mm: make compound_head() robust
References: <1439976106-137226-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1439976106-137226-5-git-send-email-kirill.shutemov@linux.intel.com>
 <20150820163643.dd87de0c1a73cb63866b2914@linux-foundation.org>
 <20150821121028.GB12016@node.dhcp.inet.fi>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC550D.5060501@suse.cz>
Date: Tue, 25 Aug 2015 13:44:13 +0200
MIME-Version: 1.0
In-Reply-To: <20150821121028.GB12016@node.dhcp.inet.fi>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On 08/21/2015 02:10 PM, Kirill A. Shutemov wrote:
> On Thu, Aug 20, 2015 at 04:36:43PM -0700, Andrew Morton wrote:
>> On Wed, 19 Aug 2015 12:21:45 +0300 "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com> wrote:
>>
>>> The patch introduces page->compound_head into third double word block in
>>> front of compound_dtor and compound_order. That means it shares storage
>>> space with:
>>>
>>>   - page->lru.next;
>>>   - page->next;
>>>   - page->rcu_head.next;
>>>   - page->pmd_huge_pte;
>>>

We should probably ask Paul about the chances that rcu_head.next would 
like to use the bit too one day?
For pgtable_t I can't think of anything better than a warning in the 
generic definition in include/asm-generic/page.h and hope that anyone 
reimplementing it for a new arch will look there first.
The lru part is probably the hardest to prevent danger. It can be used 
for any private purposes. Hopefully everyone currently uses only 
standard list operations here, and the list poison values don't set bit 
0. But I see there can be some arbitrary CONFIG_ILLEGAL_POINTER_VALUE 
added to the poisons, so maybe that's worth some build error check? 
Anyway we would be imposing restrictions on types that are not ours, so 
there might be some resistance...

>
>> Anyway, this is quite subtle and there's a risk that people will
>> accidentally break it later on.  I don't think the patch puts
>> sufficient documentation in place to prevent this.
>
> I would appreciate for suggestion on place and form of documentation.
>
>> And even documentation might not be enough to prevent accidents.
>
> The only think I can propose is VM_BUG_ON() in PageTail() and
> compound_head() which would ensure that page->compound_page points to
> place within MAX_ORDER_NR_PAGES before the current page if bit 0 is set.

That should probably catch some bad stuff, but probably only moments 
before it would crash anyway if the pointer was bogus. But I also don't 
see better way, because we can't proactively put checks in those who 
would "misbehave", as we don't know who they are. Putting more debug 
checks in e.g. page freeing might help, but probably not much.

> Do you consider this helpful?
>
>>>
>>> ...
>>>
>>> --- a/include/linux/mm_types.h
>>> +++ b/include/linux/mm_types.h
>>> @@ -120,7 +120,12 @@ struct page {
>>>   		};
>>>   	};
>>>
>>> -	/* Third double word block */
>>> +	/*
>>> +	 * Third double word block
>>> +	 *
>>> +	 * WARNING: bit 0 of the first word encode PageTail and *must* be 0
>>> +	 * for non-tail pages.
>>> +	 */
>>>   	union {
>>>   		struct list_head lru;	/* Pageout list, eg. active_list
>>>   					 * protected by zone->lru_lock !
>>> @@ -143,6 +148,7 @@ struct page {
>>>   						 */
>>>   		/* First tail page of compound page */

Note that compound_head is not just in the *first* tail page. Only the 
rest is.

>>>   		struct {
>>> +			unsigned long compound_head; /* If bit zero is set */
>>
>> I think the comments around here should have more details and should
>> be louder!
>
> I'm always bad when it comes to documentation. Is it enough?
>
> 	/*
> 	 * Third double word block
> 	 *
> 	 * WARNING: bit 0 of the first word encode PageTail(). That means
> 	 * the rest users of the storage space MUST NOT use the bit to
> 	 * avoid collision and false-positive PageTail().
> 	 */
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

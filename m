Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 672FF6B01E3
	for <linux-mm@kvack.org>; Thu, 13 May 2010 03:18:57 -0400 (EDT)
Received: by pzk28 with SMTP id 28so1092672pzk.11
        for <linux-mm@kvack.org>; Thu, 13 May 2010 00:18:55 -0700 (PDT)
Message-ID: <4BEBA70C.9050404@vflare.org>
Date: Thu, 13 May 2010 12:45:24 +0530
From: Nitin Gupta <ngupta@vflare.org>
Reply-To: ngupta@vflare.org
MIME-Version: 1.0
Subject: Re: [PATCH] Cleanup migrate case in try_to_unmap_one
References: <1272899957-11604-1-git-send-email-ngupta@vflare.org> <20100513144336.216D.A69D9226@jp.fujitsu.com>
In-Reply-To: <20100513144336.216D.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 05/13/2010 11:34 AM, KOSAKI Motohiro wrote:
>> Remove duplicate handling of TTU_MIGRATE case for
>> anonymous and filesystem pages.
>>
>> Signed-off-by: Nitin Gupta <ngupta@vflare.org>
> 
> This patch change swap cache case. I think this is not intentional.
> 
> 

IIUC, we never call this function with TTU_MIGRATE for swap cache pages.
So, the behavior after this patch remains unchanged.

Thanks,
Nitin




> 
>> ---
>>  mm/rmap.c |   17 ++++-------------
>>  1 files changed, 4 insertions(+), 13 deletions(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 07fc947..8ccfe4a 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -946,6 +946,10 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  			dec_mm_counter(mm, MM_FILEPAGES);
>>  		set_pte_at(mm, address, pte,
>>  				swp_entry_to_pte(make_hwpoison_entry(page)));
>> +	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
>> +		swp_entry_t entry;
>> +		entry = make_migration_entry(page, pte_write(pteval));
>> +		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>>
>>  	} else if (PageAnon(page)) {
>>  		swp_entry_t entry = { .val = page_private(page) };
>>  
>> @@ -967,22 +971,9 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>>  			}
>>  			dec_mm_counter(mm, MM_ANONPAGES);
>>  			inc_mm_counter(mm, MM_SWAPENTS);
>> -		} else if (PAGE_MIGRATION) {
>> -			/*
>> -			 * Store the pfn of the page in a special migration
>> -			 * pte. do_swap_page() will wait until the migration
>> -			 * pte is removed and then restart fault handling.
>> -			 */
>> -			BUG_ON(TTU_ACTION(flags) != TTU_MIGRATION);
>> -			entry = make_migration_entry(page, pte_write(pteval));
>>  		}
>>  		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>>  		BUG_ON(pte_file(*pte));
>> -	} else if (PAGE_MIGRATION && (TTU_ACTION(flags) == TTU_MIGRATION)) {
>> -		/* Establish migration entry for a file page */
>> -		swp_entry_t entry;
>> -		entry = make_migration_entry(page, pte_write(pteval));
>> -		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
>>  	} else
>>  		dec_mm_counter(mm, MM_FILEPAGES);
>>  
>> -- 
>> 1.6.6.1
>>
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id ED7396B0071
	for <linux-mm@kvack.org>; Sun, 10 Oct 2010 13:04:06 -0400 (EDT)
Message-ID: <4CB1F369.1080108@redhat.com>
Date: Sun, 10 Oct 2010 13:10:01 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC]vmscan: doing page_referenced() in batch way
References: <1285729053.27440.13.camel@sli10-conroe.sh.intel.com> <20101006131052.e3ae026f.akpm@linux-foundation.org>
In-Reply-To: <20101006131052.e3ae026f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Shaohua Li <shaohua.li@intel.com>, linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, hughd@google.com
List-ID: <linux-mm.kvack.org>

On 10/06/2010 04:10 PM, Andrew Morton wrote:
> On Wed, 29 Sep 2010 10:57:33 +0800
> Shaohua Li<shaohua.li@intel.com>  wrote:
>
>> when memory pressure is high, page_referenced() causes a lot of lock contention
>> for anon_vma->lock or mapping->i_mmap_lock. Considering pages from one file
>> usually live side by side in LRU list, we can lock several pages in
>> shrink_page_list() and do batch page_referenced() to avoid some lock/unlock,
>> which should reduce lock contention a lot. The locking rule documented in
>> rmap.c is:
>> page_lock
>> 	mapping->i_mmap_lock
>> 		anon_vma->lock
>> For a batch of pages, we do page lock for all of them first and check their
>> reference, and then release their i_mmap_lock or anon_vma lock. This seems not
>> break the rule to me.
>> Before I further polish the patch, I'd like to know if there is anything
>> preventing us to do such batch here.
>
> The patch adds quite a bit of complexity, so we'd need to see benchmark
> testing results which justify it, please.
>
> Also, the entire patch is irrelevant for uniprocessor machines, so the
> runtime overhead and code-size increases for CONFIG_SMP=n builds should
> be as low as possible - ideally zero.  Please quantify this as well
> within the changelog if you pursue this work.
>
>>
>> ...
>>
>> +#define PRC_PAGE_NUM 8
>> +struct page_reference_control {
>> +	int num;
>> +	struct page *pages[PRC_PAGE_NUM];
>> +	int references[PRC_PAGE_NUM];
>> +	struct anon_vma *anon_vma;
>> +	struct address_space *mapping;
>> +	/* no ksm */
>> +};
>
> hm, 120 bytes of stack consumed, deep in page reclaim.
>
>>   #endif
>>
>>   extern int hwpoison_filter(struct page *p);
>>
>> ...
>>
>>   static int page_referenced_file(struct page *page,
>>   				struct mem_cgroup *mem_cont,
>> -				unsigned long *vm_flags)
>> +				unsigned long *vm_flags,
>> +				struct page_reference_control *prc)
>>   {
>>   	unsigned int mapcount;
>>   	struct address_space *mapping = page->mapping;
>> @@ -603,8 +623,25 @@ static int page_referenced_file(struct p
>>   	 */
>>   	BUG_ON(!PageLocked(page));
>>
>> -	spin_lock(&mapping->i_mmap_lock);
>> +	if (prc) {
>> +		if (mapping == prc->mapping) {
>> +			goto skip_lock;
>> +		}
>> +		if (prc->anon_vma) {
>> +			page_unlock_anon_vma(prc->anon_vma);
>> +			prc->anon_vma = NULL;
>> +		}
>> +		if (prc->mapping) {
>> +			spin_unlock(&prc->mapping->i_mmap_lock);
>> +			prc->mapping = NULL;
>> +		}
>> +		prc->mapping = mapping;
>> +
>> +		spin_lock(&mapping->i_mmap_lock);
>> +	} else
>> +		spin_lock(&mapping->i_mmap_lock);
>
> Move the spin_lock() outside, remove the `else' part.
>
>> +skip_lock:
>>   	/*
>>   	 * i_mmap_lock does not stabilize mapcount at all, but mapcount
>>   	 * is more likely to be accurate if we note it after spinning.
>> @@ -628,7 +665,8 @@ static int page_referenced_file(struct p
>>   			break;
>>   	}
>>
>> -	spin_unlock(&mapping->i_mmap_lock);
>> +	if (!prc)
>> +		spin_unlock(&mapping->i_mmap_lock);
>>   	return referenced;
>>   }
>>
>>
>> ...
>>
>> +static void do_prc_batch(struct scan_control *sc,
>> +	struct page_reference_control *prc)
>> +{
>> +	int i;
>> +	for (i = 0; i<  prc->num; i++)
>> +		prc->references[i] = page_check_references(prc->pages[i], sc,
>> +			prc);
>> +	/*
>> +	 * we must release all locks here, the lock ordering requries
>> +	 * pagelock->
>> +	 *   mapping->i_mmap_lock->
>> +	 *     anon_vma->lock
>> +	 * release lock guarantee we don't break the rule in next run
>> +	 */
>> +	if (prc->anon_vma) {
>> +		page_unlock_anon_vma(prc->anon_vma);
>> +		prc->anon_vma = NULL;
>> +	}
>> +	if (prc->mapping) {
>> +		spin_unlock(&prc->mapping->i_mmap_lock);
>> +		prc->mapping = NULL;
>> +	}
>> +}
>
> I didn't check the locking alterations.

I've tried to wrap my head around them, but haven't
yet been able to convince myself that it is safe.

What if we have multiple pages sharing the same
mapping or root anon_vma, which is not the same
as the prc->anon_vma ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

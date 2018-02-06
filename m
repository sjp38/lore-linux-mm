Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id CEC886B0297
	for <linux-mm@kvack.org>; Tue,  6 Feb 2018 13:42:10 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k14so1758618wrc.14
        for <linux-mm@kvack.org>; Tue, 06 Feb 2018 10:42:10 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m79si69391wmc.37.2018.02.06.10.42.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Feb 2018 10:42:09 -0800 (PST)
Date: Tue, 6 Feb 2018 10:32:54 -0800
From: Davidlohr Bueso <dave@stgolabs.net>
Subject: Re: [PATCH 06/64] mm: teach pagefault paths about range locking
Message-ID: <20180206183254.zsm276etjarud3lj@linux-n805>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
 <20180205012754.23615-7-dbueso@wotan.suse.de>
 <7217f6dc-bce0-e73f-7d63-a328180d6ca7@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <7217f6dc-bce0-e73f-7d63-a328180d6ca7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Davidlohr Bueso <dbueso@suse.de>, akpm@linux-foundation.org, mingo@kernel.org, peterz@infradead.org, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 05 Feb 2018, Laurent Dufour wrote:

>> --- a/drivers/misc/sgi-gru/grufault.c
>> +++ b/drivers/misc/sgi-gru/grufault.c
>> @@ -189,7 +189,8 @@ static void get_clear_fault_map(struct gru_state *gru,
>>   */
>>  static int non_atomic_pte_lookup(struct vm_area_struct *vma,
>>  				 unsigned long vaddr, int write,
>> -				 unsigned long *paddr, int *pageshift)
>> +				 unsigned long *paddr, int *pageshift,
>> +				 struct range_lock *mmrange)
>>  {
>>  	struct page *page;
>>
>> @@ -198,7 +199,8 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
>>  #else
>>  	*pageshift = PAGE_SHIFT;
>>  #endif
>> -	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
>> +	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0,
>> +			   &page, NULL, mmrange) <= 0)
>
>There is no need to pass down the range here since underlying called
>__get_user_pages_locked() is told to not unlock the mmap_sem.
>In general get_user_pages() doesn't need a range parameter.

Yeah, you're right. At least it was a productive exercise for auditing.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

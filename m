Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 851CF6B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 00:10:54 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id u142so53323280oia.2
        for <linux-mm@kvack.org>; Tue, 12 Jul 2016 21:10:54 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id a125si884410oii.140.2016.07.12.21.10.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 12 Jul 2016 21:10:53 -0700 (PDT)
Message-ID: <5785BEA6.2060404@huawei.com>
Date: Wed, 13 Jul 2016 12:08:06 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] kexec: remove unnecessary unusable_pages
References: <1468299403-27954-1-git-send-email-zhongjiang@huawei.com> <87poqi3muo.fsf@x220.int.ebiederm.org>
In-Reply-To: <87poqi3muo.fsf@x220.int.ebiederm.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: dyoung@redhat.com, horms@verge.net.au, vgoyal@redhat.com, yinghai@kernel.org, akpm@linux-foundation.org, kexec@lists.infradead.org, linux-mm@kvack.org

On 2016/7/12 23:19, Eric W. Biederman wrote:
> zhongjiang <zhongjiang@huawei.com> writes:
>
>> From: zhong jiang <zhongjiang@huawei.com>
>>
>> In general, kexec alloc pages from buddy system, it cannot exceed
>> the physical address in the system.
>>
>> The patch just remove this unnecessary code, no functional change.
> On 32bit systems with highmem support kexec can very easily receive a
> page from the buddy allocator that can exceed 4GiB.  This doesn't show
> up on 64bit systems as typically the memory limits are less than the
> address space.  But this code is very necessary on some systems and
> removing it is not ok.
>
> Nacked-by: "Eric W. Biederman" <ebiederm@xmission.com>
>
  This viewpoint is as opposed to me,  32bit systems architectural decide it can not
  access exceed 4GiB whether the highmem or not.   but there is one exception, 
  when PAE enable, its physical address should be extended to 36,  new paging  mechanism
  established for it.  therefore, the  page from the buddy allocator can exceed 4GiB.

  moreover,  on 32bit systems I can not understand why KEXEC_SOURCE_MEMORY_LIMIT
  is defined to -1UL. therefore, kimge_aloc_page allocate page will always add to unusable_pages.

  Thanks
  zhongjiang
>> Signed-off-by: zhong jiang <zhongjiang@huawei.com>
>> ---
>>  include/linux/kexec.h |  1 -
>>  kernel/kexec_core.c   | 13 -------------
>>  2 files changed, 14 deletions(-)
>>
>> diff --git a/include/linux/kexec.h b/include/linux/kexec.h
>> index e8acb2b..26e4917 100644
>> --- a/include/linux/kexec.h
>> +++ b/include/linux/kexec.h
>> @@ -162,7 +162,6 @@ struct kimage {
>>  
>>  	struct list_head control_pages;
>>  	struct list_head dest_pages;
>> -	struct list_head unusable_pages;
>>  
>>  	/* Address of next control page to allocate for crash kernels. */
>>  	unsigned long control_page;
>> diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
>> index 56b3ed0..448127d 100644
>> --- a/kernel/kexec_core.c
>> +++ b/kernel/kexec_core.c
>> @@ -257,9 +257,6 @@ struct kimage *do_kimage_alloc_init(void)
>>  	/* Initialize the list of destination pages */
>>  	INIT_LIST_HEAD(&image->dest_pages);
>>  
>> -	/* Initialize the list of unusable pages */
>> -	INIT_LIST_HEAD(&image->unusable_pages);
>> -
>>  	return image;
>>  }
>>  
>> @@ -517,10 +514,6 @@ static void kimage_free_extra_pages(struct kimage *image)
>>  {
>>  	/* Walk through and free any extra destination pages I may have */
>>  	kimage_free_page_list(&image->dest_pages);
>> -
>> -	/* Walk through and free any unusable pages I have cached */
>> -	kimage_free_page_list(&image->unusable_pages);
>> -
>>  }
>>  void kimage_terminate(struct kimage *image)
>>  {
>> @@ -647,12 +640,6 @@ static struct page *kimage_alloc_page(struct kimage *image,
>>  		page = kimage_alloc_pages(gfp_mask, 0);
>>  		if (!page)
>>  			return NULL;
>> -		/* If the page cannot be used file it away */
>> -		if (page_to_pfn(page) >
>> -				(KEXEC_SOURCE_MEMORY_LIMIT >> PAGE_SHIFT)) {
>> -			list_add(&page->lru, &image->unusable_pages);
>> -			continue;
>> -		}
>>  		addr = page_to_pfn(page) << PAGE_SHIFT;
>>  
>>  		/* If it is the destination page we want use it */
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

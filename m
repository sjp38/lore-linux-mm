Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id 38B8A6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 10:47:43 -0400 (EDT)
Received: by igtg8 with SMTP id g8so2856579igt.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 07:47:43 -0700 (PDT)
Received: from mail-ie0-x229.google.com (mail-ie0-x229.google.com. [2607:f8b0:4001:c03::229])
        by mx.google.com with ESMTPS id n30si421319ioi.107.2015.06.26.07.47.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jun 2015 07:47:42 -0700 (PDT)
Received: by ieqy10 with SMTP id y10so77324283ieq.0
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 07:47:42 -0700 (PDT)
Message-ID: <558D660B.7070102@gmail.com>
Date: Fri, 26 Jun 2015 10:47:39 -0400
From: nick <xerofoify@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: Add error check after call to rmap_walk in the function
 page_referenced
References: <1435282597-21728-1-git-send-email-xerofoify@gmail.com> <20150626155614.04bffed1@BR9TG4T3.de.ibm.com>
In-Reply-To: <20150626155614.04bffed1@BR9TG4T3.de.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dominik Dingel <dingel@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, riel@redhat.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, dave@stgolabs.net, koct9i@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 2015-06-26 09:56 AM, Dominik Dingel wrote:
> On Thu, 25 Jun 2015 21:36:37 -0400
> Nicholas Krause <xerofoify@gmail.com> wrote:
> 
>> This adds a return check after the call to the function rmap_walk
>> in the function page_referenced as this function call can fail
>> and thus should signal callers of page_referenced if this happens
>> by returning the SWAP macro return value as returned by rmap_walk
>> here. In addition also check if have locked the page pointer as
>> passed to this particular and unlock it with unlock_page if this
>> page is locked before returning our SWAP marco return code from
>> rmap_walk.
>>
>> Signed-off-by: Nicholas Krause <xerofoify@gmail.com>
>> ---
>>  mm/rmap.c | 10 +++++++++-
>>  1 file changed, 9 insertions(+), 1 deletion(-)
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 171b687..e4df848 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -814,7 +814,9 @@ static bool invalid_page_referenced_vma(struct vm_area_struct *vma, void *arg)
>>   * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
>>   *
>>   * Quick test_and_clear_referenced for all mappings to a page,
>> - * returns the number of ptes which referenced the page.
>> + * returns the number of ptes which referenced the page.On
>> + * error returns either zero or the error code returned from
>> + * the failed call to rmap_walk.
>>   */
>>  int page_referenced(struct page *page,
>>  		    int is_locked,
>> @@ -855,7 +857,13 @@ int page_referenced(struct page *page,
>>  		rwc.invalid_vma = invalid_page_referenced_vma;
>>  	}
>>
>> +
> 
> unnecessary empty line
> 
>>  	ret = rmap_walk(page, &rwc);
>> +	if (!ret) {
>> +		if (we_locked)
>> +			unlock_page(page);
>> +		return ret;
>> +	}
> 
> I don't see why the function should propagate the rmap_walk return value.
> rmap_walk will not set pra.referenced, so that both callers just skip.
> 
> What is the purpose of the given patch? Do you have any real case introducing such code,
> which is imho incomplete as all callers need to take care of the changed return value!
> 
There is only one caller that needs to be moved over if this case is put in. Further more 
do we care if executing rmap_walk fails as if it does this means we were unable to execute
the function page_referenced one on the rmap_walk_control structure rwc and this can be
a issue in my option, if not then we can just remove the ret variable and execute rmap_walk
without checking it's return value.
Cheers Nick 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

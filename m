Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 13EB76B0092
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:35:14 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Thu, 3 May 2012 02:35:13 -0600
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id AFA1DC9005A
	for <linux-mm@kvack.org>; Thu,  3 May 2012 04:35:07 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q438Z98g112400
	for <linux-mm@kvack.org>; Thu, 3 May 2012 04:35:09 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q43E61lc008451
	for <linux-mm@kvack.org>; Thu, 3 May 2012 10:06:02 -0400
Date: Thu, 3 May 2012 16:35:06 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] MM: check limit while deallocating bootmem node
Message-ID: <20120503083506.GA19924@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1336008674-10858-1-git-send-email-shangw@linux.vnet.ibm.com>
 <20120503074708.GA31780@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120503074708.GA31780@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org

>> For the particular bootmem node, the minimal and maximal PFN (
>> Page Frame Number) have been traced in the instance of "struct
>> bootmem_data_t". On current implementation, the maximal PFN isn't
>> checked while deallocating a bunch (BITS_PER_LONG) of page frames.
>> So the current implementation won't work if the maximal PFN isn't
>> aligned with BITS_PER_LONG.
>
>That's not true, given how the bitmap works, see my previous mail.
>
>> The patch will check the maximal PFN of the given bootmem node.
>> Also, we needn't check all the bits map when the starting PFN isn't
>> BITS_PER_LONG aligned.
>
>Actually, it's musn't.  I just realized that this code is totally
>buggy :(
>
>vec is an aligned chunk of memory that start is pointing into.  If
>start is not aligned, we check the bitmap at the wrong offset
>throughout the loop.
>
>Your skipping the unaligned bits is not an optimization, it's a
>bugfix.
>
>> Actually, we should start from the offset
>> of the bits map, which indicated by the starting PFN. By the way,
>> V2 patch removed the duplicate check according to comments from
>> Johannes Weiner.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> ---
>>  mm/bootmem.c |    7 +++++--
>>  1 files changed, 5 insertions(+), 2 deletions(-)
>> 
>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>> index 5a04536..b4f3ba5 100644
>> --- a/mm/bootmem.c
>> +++ b/mm/bootmem.c
>> @@ -201,9 +201,11 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>>  			count += BITS_PER_LONG;
>>  			start += BITS_PER_LONG;
>>  		} else {
>> -			unsigned long off = 0;
>> +			unsigned long cursor = start;
>> +			unsigned long off = cursor & (BITS_PER_LONG - 1);
>>  
>> -			while (vec && off < BITS_PER_LONG) {
>> +			vec >>= off;
>> +			while (vec) {
>>  				if (vec & 1) {
>>  					page = pfn_to_page(start + off);
>
>I don't understand this.
>
>start + (start & (BITS_PER_LONG - 1)) ?
>

Yeah, It has calculated the PFN wrongly here. Actually, "cursor"
should be used here.

>>  					__free_pages_bootmem(page, 0);
>> @@ -211,6 +213,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>>  				}
>>  				vec >>= 1;
>>  				off++;
>> +				cursor++;
>
>cursor is not really used anywhere.
>
>>  			start = ALIGN(start + 1, BITS_PER_LONG);
>>  		}
>> -- 
>
>I think all we need to add is
>
>	vec >>= start & (BITS_PER_LONG - 1);
>
>before the loop, and call the patch a bugfix rather than an
>optimization.
>
>And removing the off < BITS_PER_LONG check should probably be a
>separate change with its own explanation then, to not have unrelated
>cleanup and error potential in a bugfix patch.
>
>How about this:
>
>---
>From: Gavin Shan <shangw@linux.vnet.ibm.com>
>Subject: [patch 1/2] mm: bootmem: fix checking the bitmap when finally
> freeing bootmem
>
>When bootmem releases an unaligned chunk of memory at the beginning of
>a node to the page allocator, it iterates from that unaligned PFN but
>checks an aligned word of the page bitmap.  The checked bits do not
>correspond to the PFNs and, as a result, reserved pages can be freed.
>
>Properly shift the bitmap word so that the lowest bit corresponds to
>the starting PFN before entering the freeing loop.
>

Thanks for changing it correctly, Johannes ;-)

>Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
>---
> mm/bootmem.c |    1 +
> 1 file changed, 1 insertion(+)
>
>diff --git a/mm/bootmem.c b/mm/bootmem.c
>index 0131170..67872fc 100644
>--- a/mm/bootmem.c
>+++ b/mm/bootmem.c
>@@ -203,6 +203,7 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
> 		} else {
> 			unsigned long off = 0;
>
>+			vec >>= start & (BITS_PER_LONG - 1);
> 			while (vec && off < BITS_PER_LONG) {

I think it can be changed to "while (vec) {" since it's duplicate
check. "vec" has no chance to have more bits than BITS_PER_LONG here.

Others look good. Need I change it accordingly and send it out
again?

> 				if (vec & 1) {
> 					page = pfn_to_page(start + off);

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

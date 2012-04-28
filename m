Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id BCC046B00EC
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 21:58:33 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <shangw@linux.vnet.ibm.com>;
	Fri, 27 Apr 2012 19:58:33 -0600
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 9EFDB19D8048
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:58:19 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3S1wRdq209570
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:58:29 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3S1wRQ6020658
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 19:58:27 -0600
Date: Sat, 28 Apr 2012 09:58:26 +0800
From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] MM: check limit while deallocating bootmem node
Message-ID: <20120428015826.GB8061@shangw>
Reply-To: Gavin Shan <shangw@linux.vnet.ibm.com>
References: <1335498104-31900-1-git-send-email-shangw@linux.vnet.ibm.com>
 <1335498104-31900-2-git-send-email-shangw@linux.vnet.ibm.com>
 <20120427232750.GA2415@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120427232750.GA2415@cmpxchg.org>
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
>>
>> The patch will check the maximal PFN of the given bootmem node.
>> Also, we needn't check all the bits map when the starting PFN isn't
>> BITS_PER_LONG aligned. Actually, we should start from the offset
>> of the bits map, which indicated by the starting PFN.
>> 
>> Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
>> ---
>>  mm/bootmem.c |   11 ++++++++---
>>  1 files changed, 8 insertions(+), 3 deletions(-)
>> 
>> diff --git a/mm/bootmem.c b/mm/bootmem.c
>> index 5a04536..ebac3ba 100644
>> --- a/mm/bootmem.c
>> +++ b/mm/bootmem.c
>> @@ -194,16 +194,20 @@ static unsigned long __init free_all_bootmem_core(bootmem_data_t *bdata)
>>  		 * BITS_PER_LONG block of pages in front of us, free
>>  		 * it in one go.
>>  		 */
>> -		if (IS_ALIGNED(start, BITS_PER_LONG) && vec == ~0UL) {
>> +		if (end - start >= BITS_PER_LONG &&
>> +		    IS_ALIGNED(start, BITS_PER_LONG) &&
>> +		    vec == ~0UL) {
>
>Did you have any actual problems with the code or was this just by
>review?
>

I just got this for review. There're no real problem against it ;-)

>vec has bits set for unreserved pages and the bitmap is aligned and
>reserved per default.  So if the chunk is smaller than (end - start),
>then vec is already != ~0UL.  The check you add should be redundant.
>

Yes. I'll remove the duplicate check in next revision.

>>  			int order = ilog2(BITS_PER_LONG);
>>  
>>  			__free_pages_bootmem(pfn_to_page(start), order);
>>  			count += BITS_PER_LONG;
>>  			start += BITS_PER_LONG;
>>  		} else {
>> -			unsigned long off = 0;
>> +			unsigned long cursor = start;
>> +			unsigned long off = cursor & (BITS_PER_LONG - 1);
>>  
>> -			while (vec && off < BITS_PER_LONG) {
>> +			vec >>= off;
>> +			while (vec && off < BITS_PER_LONG && cursor < end) {
>
>Optimization looks ok, although I doubt it makes a notable difference,
>this case should be pretty rare.
>
>Also, if you reach end, vec has no more bits set, so the cursor < end
>check should again be redundant.  I think we can also remove the
>off < BITS_PER_LONG, there can hardly be more than BITS_PER_LONG
>set bits in vec.
>

Yes. I'll change that into "while (vec)" in next revision.

Thanks,
Gavin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

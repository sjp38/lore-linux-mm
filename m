Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BD716B0047
	for <linux-mm@kvack.org>; Tue,  9 Mar 2010 10:56:19 -0500 (EST)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id o29FuGiK032311
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 15:56:16 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o29FuGEx1048670
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 16:56:16 +0100
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o29FuGbv010127
	for <linux-mm@kvack.org>; Tue, 9 Mar 2010 16:56:16 +0100
Message-ID: <4B966F93.9060207@linux.vnet.ibm.com>
Date: Tue, 09 Mar 2010 16:56:03 +0100
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] page-allocator: Under memory pressure, wait on pressure
 to relieve instead of congestion
References: <1268048904-19397-1-git-send-email-mel@csn.ul.ie> <1268048904-19397-2-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1003090946180.28897@router.home>
In-Reply-To: <alpine.DEB.2.00.1003090946180.28897@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



Christoph Lameter wrote:
> On Mon, 8 Mar 2010, Mel Gorman wrote:
> 
>> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
>> index 30fe668..72465c1 100644
>> --- a/include/linux/mmzone.h
>> +++ b/include/linux/mmzone.h
>> @@ -398,6 +398,9 @@ struct zone {
>>  	unsigned long		wait_table_hash_nr_entries;
>>  	unsigned long		wait_table_bits;
>>
>> +	/* queue for processes waiting for pressure to relieve */
>> +	wait_queue_head_t	*pressure_wq;
>> +
>>  	/*
> 
> The waitqueue is in a zone? But allocation occurs by scanning a
> list of possible zones.
> 
>> +long zonepressure_wait(struct zone *zone, unsigned int order, long timeout)
> 
> So zone specific.
> 
>> -		if (!page && gfp_mask & __GFP_NOFAIL)
>> -			congestion_wait(BLK_RW_ASYNC, HZ/50);
>> +		if (!page && gfp_mask & __GFP_NOFAIL) {
>> +			/* If still failing, wait for pressure on zone to relieve */
>> +			zonepressure_wait(preferred_zone, order, HZ/50);
> 
> The first zone is special therefore...
> 
> What happens if memory becomes available in another zone? Lets say we are
> waiting on HIGHMEM and memory in ZONE_NORMAL becomes available?

Do you mean the same as Nick asked or another aspect of it?
citation:
"I mean the other way around. If that zone's watermarks are not met, 
then why shouldn't it be woken up by other zones reaching their watermarks."


-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

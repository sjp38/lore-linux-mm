Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DEE1B6B01F7
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 04:53:48 -0400 (EDT)
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o3K8sfhR008344
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 08:54:41 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3K8sfTt835806
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 09:54:41 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o3K8se7T012373
	for <linux-mm@kvack.org>; Tue, 20 Apr 2010 09:54:41 +0100
Message-ID: <4BCD6BCB.4040403@linux.vnet.ibm.com>
Date: Tue, 20 Apr 2010 10:54:35 +0200
From: Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/3] Avoid the use of congestion_wait under zone pressure
References: <20100322235053.GD9590@csn.ul.ie> <4BA940E7.2030308@redhat.com> <20100324145028.GD2024@csn.ul.ie> <4BCC4B0C.8000602@linux.vnet.ibm.com> <20100419214412.GB5336@cmpxchg.org> <4BCD55DA.2020000@linux.vnet.ibm.com>
In-Reply-To: <4BCD55DA.2020000@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, gregkh@novell.com, Corrado Zoccolo <czoccolo@gmail.com>
List-ID: <linux-mm.kvack.org>



Christian Ehrhardt wrote:
> 
> 
> Johannes Weiner wrote:
[...]

>>>
>>> It stays at ~85M with more writes which is approx 50% of my free 160M 
>>> memory.
>>
>> Ok, so I am the idiot that got quoted on 'the active set is not too 
>> big, so
>> buffer heads are not a problem when avoiding to scan it' in eternal 
>> history.
>>
>> But the threshold inactive/active ratio for skipping active file pages is
>> actually 1:1.
>>
>> The easiest 'fix' is probably to change that ratio, 2:1 (or even 3:1?) 
>> appears
>> to be a bit more natural anyway?  Below is a patch that changes it to 
>> 2:1.
>> Christian, can you check if it fixes your regression?
> 
> I'll check it out.
> from the numbers I have up to now I know that the good->bad transition 
> for my case is somewhere between 30M/60M e.g. first and second write.
> The ratio 2:1 will eat max 53M of my ~160M that gets split up.
> 
> That means setting the ratio to 2:1 or whatever else might help or not, 
> but eventually there is just another setting of workload vs. memory 
> constraints that would still be affected. Still I guess 3:1 (and I'll 
> try that as well) should be enough to be a bit more towards the save side.

For "my case" 2:1 is not enough, 3:1 almost and 4:1 fixes the issue.
Still as I mentioned before I think any value carved in stone can and 
will be bad to some use case - as 1:1 is for mine.

If we end up being unable to fix it internally by allowing the system to 
"forget" and eventually free old unused buffers at least somewhen - then 
we should neither implement it as 2:1 nor 3:1 nor whatsoever, but as 
userspace configurable e.g. /proc/sys/vm/active_inactive_ratio.

I hope your suggestion below or an extension to it will allow the kernel 
to free the buffers somewhen. Depending on how good/fast this solution 
then will work we can still modify the ratio if needed.

>> Additionally, we can always scan active file pages but only deactivate 
>> them
>> when the ratio is off and otherwise strip buffers of clean pages.
> 
> In think we need something that allows the system to forget its history 
> somewhen - be it 1:1 or x:1 - if the workload changes "long enough"(tm) 
> it should eventually throw all old things out.
> Like I described before many systems have different usage patterns when 
> e.g. comparing day/night workload. So it is far from optimal if e.g. day 
> write loads eat so much cache and never give it back for nightly huge 
> reads tasks or something similar.
> 
> Would your suggestion achieve that already?
> If not what kind change could?
> 
[...]
-- 

Grusse / regards, Christian Ehrhardt
IBM Linux Technology Center, System z Linux Performance

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

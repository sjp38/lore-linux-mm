Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5D2E86B0082
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 22:19:55 -0500 (EST)
Message-ID: <4B21BA54.1090103@redhat.com>
Date: Thu, 10 Dec 2009 22:19:48 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] vmscan: limit concurrent reclaimers in shrink_zone
References: <20091210185626.26f9828a@cuia.bos.redhat.com> <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
In-Reply-To: <28c262360912101803i7b43db78se8cf9ec61d92ee0f@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: lwoodman@redhat.com, kosaki.motohiro@jp.fujitsu.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, aarcange@redhat.com
List-ID: <linux-mm.kvack.org>

On 12/10/2009 09:03 PM, Minchan Kim wrote:

>> +The default value is 8.
>> +
>> +=============================================================
>
> I like this. but why do you select default value as constant 8?
> Do you have any reason?
>
> I think it would be better to select the number proportional to NR_CPU.
> ex) NR_CPU * 2 or something.
>
> Otherwise looks good to me.

Pessimistically, I assume that the pageout code spends maybe
10% of its time on locking (we have seen far, far worse than
this with thousands of processes in the pageout code).  That
means if we have more than 10 threads in the pageout code,
we could end up spending more time on locking and less doing
real work - slowing everybody down.

I rounded it down to the closest power of 2 to come up with
an arbitrary number that looked safe :)

However, this number is per zone - I imagine that really large
systems will have multiple memory zones, so they can run with
more than 8 processes in the pageout code simultaneously.

> Reviewed-by: Minchan Kim<minchan.kim@gmail.com>

Thank you.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

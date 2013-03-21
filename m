Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id BF8BB6B0002
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 17:46:25 -0400 (EDT)
Message-ID: <514B7F6C.2060200@web.de>
Date: Thu, 21 Mar 2013 22:45:16 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
References: <Pine.LNX.4.44L0.1303211708470.1899-100000@iolanthe.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.1303211708470.1899-100000@iolanthe.rowland.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, michael@amarulasolutions.com

On 03/21/13 22:12, Alan Stern wrote:
> On Thu, 21 Mar 2013, Alan Stern wrote:
>
>> On Thu, 21 Mar 2013, Soeren Moch wrote:
>>
>>> Now I found out what is going on here:
>>>
>>> In itd_urb_transaction() we allocate 9 iTDs for each URB with
>>> number_of_packets == 64 in my case. The iTDs are added to
>>> sched->td_list. For a frame-aligned scheduling we need 8 iTDs, the 9th
>>> one is released back to the front of the streams free_list in
>>> iso_sched_free(). This iTD was cleared after allocation and has a frame
>>> number of 0 now. So for each allocation when now_frame == 0 we allocate
>>> from the dma_pool, not from the free_list.
>>
>> Okay, that is a problem.  But it shouldn't be such a big problem,
>> because now_frame should not be equal to 0 very often.
>
> Oh, wait, now I get it.  We never reach a steady state, because the
> free list never shrinks, but occasionally it does increase when
> now_frame is equal to 0.  Even though that doesn't happen very often,
> the effects add up.

Correct. Approximately twice a second we allocate 9 iTDs from the 
dma_pool in my case (the frame numbers run from 0 to 511 - not up to 
2047, which I thought they should). But since we allocate iTDs every 8 
frames in my case (for each active stream), the pool allocations occur 
only when we hit the allocation sequence frame 0,8,16,... (not one of 
the other 7 opportunities frame 1,9,17,... - frame 7,15,23,...)

> Very good; tomorrow I will send your patch in.
>
> Alan Stern
>
Thank you. And also thanks to all who helped to track down this issue.

  Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

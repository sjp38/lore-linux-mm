Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 92C4D6B0037
	for <linux-mm@kvack.org>; Thu, 21 Mar 2013 18:16:28 -0400 (EDT)
Message-ID: <514B86A9.60401@web.de>
Date: Thu, 21 Mar 2013 23:16:09 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] USB: EHCI: fix for leaking isochronous data
References: <Pine.LNX.4.44L0.1303211659080.1899-100000@iolanthe.rowland.org> <Pine.LNX.4.44L0.1303211708470.1899-100000@iolanthe.rowland.org> <20130321212033.GQ21478@lunn.ch>
In-Reply-To: <20130321212033.GQ21478@lunn.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, USB list <linux-usb@vger.kernel.org>, Jason Cooper <jason@lakedaemon.net>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>, linux-mm@kvack.org, Kernel development list <linux-kernel@vger.kernel.org>, linux-arm-kernel@lists.infradead.org, michael@amarulasolutions.com

On 21.03.2013 22:20, Andrew Lunn wrote:
> On Thu, Mar 21, 2013 at 05:12:01PM -0400, Alan Stern wrote:
>> On Thu, 21 Mar 2013, Alan Stern wrote:
>>
>>> On Thu, 21 Mar 2013, Soeren Moch wrote:
>>>
>>>> Now I found out what is going on here:
>>>>
>>>> In itd_urb_transaction() we allocate 9 iTDs for each URB with
>>>> number_of_packets == 64 in my case. The iTDs are added to
>>>> sched->td_list. For a frame-aligned scheduling we need 8 iTDs, the 9th
>>>> one is released back to the front of the streams free_list in
>>>> iso_sched_free(). This iTD was cleared after allocation and has a frame
>>>> number of 0 now. So for each allocation when now_frame == 0 we allocate
>>>> from the dma_pool, not from the free_list.
>>>
>>> Okay, that is a problem.  But it shouldn't be such a big problem,
>>> because now_frame should not be equal to 0 very often.
>>
>> Oh, wait, now I get it.  We never reach a steady state, because the
>> free list never shrinks, but occasionally it does increase when
>> now_frame is equal to 0.  Even though that doesn't happen very often,
>> the effects add up.
>>
>> Very good; tomorrow I will send your patch in.
>
> Hi Alan, Soeren
>
> Could you word the description a bit better. If Alan did not get it
> without a bit of thought, few others are going to understand it
> without a better explanation.
>
> Thanks
> 	Andrew
>

Alan,

can you come up with a better explanation, please? I think your 
description how it is supposed to work from here
    http://marc.info/?l=linux-usb&m=136345559432055&w=2
is required to understand the problem and the fix.

Thanks,
   Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

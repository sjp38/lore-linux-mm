Message-ID: <40CF2CF5.5000209@pacbell.net>
Date: Tue, 15 Jun 2004 10:08:05 -0700
From: David Brownell <david-b@pacbell.net>
MIME-Version: 1.0
Subject: Re: [linux-usb-devel] Patch for UHCI driver (from kernel 2.6.6).
References: <Pine.LNX.4.44L0.0406151221220.1960-100000@ida.rowland.org>
In-Reply-To: <Pine.LNX.4.44L0.0406151221220.1960-100000@ida.rowland.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Stern <stern@rowland.harvard.edu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Nicolas DET <nd@bplan-gmbh.de>, USB development list <linux-usb-devel@lists.sourceforge.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Alan Stern wrote:
> On Mon, 14 Jun 2004, David Brownell wrote:
> 
> 
>>Seems like the dma_alloc_coherent() API spec can't be
>>implemented on such machines then, since it's defined
>>to return memory(*) such that:
>>
>>   ... a write by either the device or the processor
>>   can immediately be read by the processor or device
>>   without having to worry about caching effects.
>>
>>...
> 
> That text strikes me as rather ambiguous.  ...
> ...  It doesn't specify what happens to the other data
> bytes in the same cache line which _weren't_ written -- maybe they'll be
> messed up.

Actually I thought it was quite explicit:  "without having
to worry about caching effects".  What you described is
clearly a caching effect:  caused by caching.  And maybe
fixable by appropriate cache-flushing, or other cache-aware
driver logic ... making it "worry about caching effects".
Like the patch from Nicolas.

Maybe what we really need is patches to make USB switch to
dma_alloc_noncoherent(), checking dma_is_consistent() to
see whether a given QH/TD/ED/iTD/sITD/FSTN/... needs to be
explicitly flushed from cpu cache before handover to HC.

- Dave



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Message-ID: <48BFEE2C.70303@linux-foundation.org>
Date: Thu, 04 Sep 2008 09:18:20 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [PATCH 4/4] capture pages freed during direct reclaim for	allocation
 by the reclaimer
References: <1220467452-15794-5-git-send-email-apw@shadowen.org>	 <1220475206-23684-1-git-send-email-apw@shadowen.org>	 <48BEFAF9.3030006@linux-foundation.org> <1220510308.8609.167.camel@twins>
In-Reply-To: <1220510308.8609.167.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Wed, 2008-09-03 at 16:00 -0500, Christoph Lameter wrote:
>> Andy Whitcroft wrote:
>>
>>>  
>>>  #ifndef __GENERATING_BOUNDS_H
>>> @@ -208,6 +211,9 @@ __PAGEFLAG(SlubDebug, slub_debug)
>>>   */
>>>  TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
>>>  __PAGEFLAG(Buddy, buddy)
>>> +PAGEFLAG(BuddyCapture, buddy_capture)	/* A buddy page, but reserved. */
>>> +	__SETPAGEFLAG(BuddyCapture, buddy_capture)
>>> +	__CLEARPAGEFLAG(BuddyCapture, buddy_capture)
>> Doesnt __PAGEFLAG do what you want without having to explicitly specify
>> __SET/__CLEAR?
> 
> PAGEFLAG() __PAGEFLAG()
> 
> does TESTPAGEFLAG() double.
> 

Usually one either wants the atomic versions or the non atomic versions. This
usage seems to be mainly non atomic plus one use of ClearPageBuddy() in
capture_or_return() (Which raises some questions about how the bit
modifications are serialized. Is there concurrency during free?)

So

__PAGEFLAG(BuddyCapture, buddy_capture)
	CLEARPAGEFLAG(BuddyCapture, buddy_capture)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

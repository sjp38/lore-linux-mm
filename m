Message-ID: <43C9DD98.5000506@yahoo.com.au>
Date: Sun, 15 Jan 2006 16:28:56 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Race in new page migration code?
References: <20060114155517.GA30543@wotan.suse.de> <Pine.LNX.4.62.0601140955340.11378@schroedinger.engr.sgi.com> <20060114181949.GA27382@wotan.suse.de> <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0601141040400.11601@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Sat, 14 Jan 2006, Nick Piggin wrote:
> 
> 
>>>We take that reference count on the page:
>>
>>Yes, after you have dropped all your claims to pin this page
>>(ie. pte lock). You really can't take a refcount on a page that
> 
> 
> Oh. Now I see. I screwed that up by a fix I added.... We cannot drop the 
> ptl here. So back to the way it was before. Remove the draining from 
> isolate_lru_page and do it before scanning for pages so that we do not
> have to drop the ptl. 
> 

OK (either way is fine), but you should still drop the __isolate_lru_page
nonsense and revert it like my patch does.

> Also remove the WARN_ON since its now even possible that other actions of 
> the VM move the pages into the LRU lists while we scan for pages to
> migrate.
> 

Well, it has always been possible since vmscan started batching scans a
long time ago. Actually seeing as you only take a read lock on the semaphore
it is probably also possible to have a concurrent migrate operation cause
this as well.

Thanks,
Nick

-- 
SUSE Labs, Novell Inc.

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

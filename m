From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <7969951.1222961144280.kamezawa.hiroyu@jp.fujitsu.com>
Date: Fri, 3 Oct 2008 00:25:44 +0900 (JST)
Subject: Re: Re: [PATCH 4/4] capture pages freed during direct reclaim for allocation by the reclaimer
In-Reply-To: <20081002150221.GF11089@brain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <20081002150221.GF11089@brain>
 <1222864261-22570-1-git-send-email-apw@shadowen.org> <1222864261-22570-5-git-send-email-apw@shadowen.org> <20081002162414.03470f46.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>On Thu, Oct 02, 2008 at 04:24:14PM +0900, KAMEZAWA Hiroyuki wrote:
>> On Wed,  1 Oct 2008 13:31:01 +0100
>> Andy Whitcroft <apw@shadowen.org> wrote:
>> 
>> > When a process enters direct reclaim it will expend effort identifying
>> > and releasing pages in the hope of obtaining a page.  However as these
>> > pages are released asynchronously there is every possibility that the
>> > pages will have been consumed by other allocators before the reclaimer
>> > gets a look in.  This is particularly problematic where the reclaimer is
>> > attempting to allocate a higher order page.  It is highly likely that
>> > a parallel allocation will consume lower order constituent pages as we
>> > release them preventing them coelescing into the higher order page the
>> > reclaimer desires.
>> > 
>> > This patch set attempts to address this for allocations above
>> > ALLOC_COSTLY_ORDER by temporarily collecting the pages we are releasing
>> > onto a local free list.  Instead of freeing them to the main buddy lists,
>> > pages are collected and coelesced on this per direct reclaimer free list.
>> > Pages which are freed by other processes are also considered, where they
>> > coelesce with a page already under capture they will be moved to the
>> > capture list.  When pressure has been applied to a zone we then consult
>> > the capture list and if there is an appropriatly sized page available
>> > it is taken immediatly and the remainder returned to the free pool.
>> > Capture is only enabled when the reclaimer's allocation order exceeds
>> > ALLOC_COSTLY_ORDER as free pages below this order should naturally occur
>> > in large numbers following regular reclaim.
>> > 
>> > Thanks go to Mel Gorman for numerous discussions during the development
>> > of this patch and for his repeated reviews.
>> > 
>> 
>> Hmm.. is this routine better than
>>   mm/memory_hotplug.c::do_migrate_range(start_pfn, end_pfn) ?
>
>Are you suggesting that it might be more adventageous to try and migrate
>things out of this area as part of reclaim?  If so then I tend to agree,
>though that would be a good idea generally with or without capture.
>
>/me adds it to his todo list to test that out.
>
I just remember I did the same kind of work to offline pages.
Sorry for noise.

I just have an idea to support following kind of interface via memory hotplug
This makes all pages in the section to be hugepage.

 #echo huge > /sys/device/system/memory/memoryXXX/state
 (memory hotplug interface supports online/offline here.)

But no patches yet...

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

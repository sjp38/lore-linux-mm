Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 2DC1C6B02A6
	for <linux-mm@kvack.org>; Sun, 24 Jun 2012 19:52:43 -0400 (EDT)
Message-ID: <4FE7A867.70207@kernel.org>
Date: Mon, 25 Jun 2012 08:53:11 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: consider all swapped back pages in used-once logic
References: <1337246033-13719-1-git-send-email-mhocko@suse.cz> <20120517195342.GB1800@cmpxchg.org> <20120521025149.GA32375@gmail.com> <20120521073632.GL1406@cmpxchg.org> <20120521085951.GA4687@gmail.com> <20120521093705.GM1406@cmpxchg.org> <20120521110659.GA7143@gmail.com> <20120623110450.GP27816@cmpxchg.org>
In-Reply-To: <20120623110450.GP27816@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Zheng Liu <gnehzuil.liu@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>

Hi Hannes,

On 06/23/2012 08:04 PM, Johannes Weiner wrote:

> On Mon, May 21, 2012 at 07:07:00PM +0800, Zheng Liu wrote:
>> On Mon, May 21, 2012 at 11:37:05AM +0200, Johannes Weiner wrote:
>> [snip]
>>>>> Is it because the read()/write() IO is high throughput and pushes
>>>>> pages through the LRU lists faster than the mmap pages are referenced?
>>>>
>>>> Yes, in this application, one query needs to access mapped file page
>>>> twice and file page cache twice.  Namely, one query needs to do 4 disk
>>>> I/Os.  We have used fadvise(2) to reduce file page cache accessing to
>>>> only once.  For mapped file page, in fact them are accessed only once
>>>> because in one query the same data is accessed twice.  Thus, one query
>>>> causes 2 disk I/Os now.  The size of read/write is quite larger than
>>>> mmap/munmap.  So, as you see, if we can keep mmap/munmap file in memory
>>>> as much as possible, we will gain the better performance.
>>>
>>> You access the same unmapped cache twice, i.e. repeated reads or
>>> writes against the same file offset?
>>
>> No.  We access the same mapped file twice.
>>
>>>
>>> How do you use fadvise?
>>
>> We access the header and content of the file respectively using read/write.
>> The header and content are sequentially.  So we use fadivse(2) with
>> FADV_WILLNEED flag to do a readahead.
>>
>>>> In addition, another factor also has some impacts for this application.
>>>> In inactive_file_is_low_global(), it is different between 2.6.18 and
>>>> upstream kernel.  IMHO, it causes that mapped file pages in active list
>>>> are moved into inactive list frequently.
>>>>
>>>> Currently, we add a parameter in inactive_file_is_low_global() to adjust
>>>> this ratio.  Meanwhile we activate every mapped file pages for the first
>>>> time.  Then the performance gets better, but it still doesn't reach the
>>>> performance of 2.6.18.
>>>
>>> 2.6.18 didn't have the active list protection at all and always
>>> forcibly deactivated pages during reclaim.  Have you tried fully
>>> reverting to this by making inactive_file_is_low_global() return true
>>> unconditionally?
>>
>> No, I don't try it.  AFAIK, 2.6.18 didn't protect the active list.  But
>> it doesn't always forcibly deactivate the pages.  I remember that in
>> 2.6.18 kernel we calculate 'mapped_ratio' in shrink_active_list(), and
>> then we get 'swap_tendency' according to 'mapped_ratio', 'distress', and
>> 'sc->swappiness'.  If 'swap_tendency' is not greater than 100.  It
>> doesn't reclaim mapped file pages.  By this equation, if the sum of the
>> anonymous pages and mapped file pages is not greater than the 50% of
>> total pages, we don't deactivate these pages.  Am I missing something?
> 
> I think we need to go back to protecting mapped pages based on how
> much of reclaimable memory they make up, one way or another.


I partly agreed it with POV regression.
But I would like to understand rationale of "Why we should handle specially mmapped page".
In case of code pages(VM_EXEC), we already have handled it specially and
I understand why we did. At least, my opinion was that our LRU algorithm doesn't consider
_frequency_ fully while it does _recency_ well. I thought code page would be high frequency of access
compared to other pages.
But in case of mapped data pages, why we should handle specially?
I guess mapped data pages would have higher access chance than unmapped page because
unmapped page doesn't have any owner(it's just for caching for reducing I/O) while mapped page
has a owner above.

Doesn't it make sense?

If we don't have any rationale, I would like to add new explicit API(ex, madvise(WORING_SET))
rather than depending VM internal implementation.

> 
> Minchan suggested recently to have a separate LRU list for easily
> reclaimable pages.  If we balance the lists according to relative
> size, we have pressure on mapped pages dictated by availability of
> clean cache that is easier to reclaim.

> 

> Rik, Minchan, what do you think?


Yes. with Ereclaimable LRU list, we could do it. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

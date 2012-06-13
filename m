Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 313226B0069
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 20:10:25 -0400 (EDT)
Message-ID: <4FD7DA71.70500@kernel.org>
Date: Wed, 13 Jun 2012 09:10:25 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] [RFC] tmpfs: Add FALLOC_FL_MARK_VOLATILE/UNMARK_VOLATILE
 handlers
References: <1338575387-26972-1-git-send-email-john.stultz@linaro.org> <1338575387-26972-4-git-send-email-john.stultz@linaro.org> <4FC9235F.5000402@gmail.com>	<4FC92E30.4000906@linaro.org> <4FC9360B.4020401@gmail.com>	<4FC937AD.8040201@linaro.org> <4FC9438B.1000403@gmail.com>	<4FC94F61.20305@linaro.org> <4FCFB4F6.6070308@gmail.com>	<4FCFEE36.3010902@linaro.org> <CAO6Zf6D++8hOz19BmUwQ8iwbQknQRNsF4npP4r-830j04vbj=g@mail.gmail.com> <4FD13C30.2030401@linux.vnet.ibm.com> <4FD16B6E.8000307@linaro.org> <4FD1848B.7040102@gmail.com> <4FD2C6C5.1070900@linaro.org> <4FD6ECE2.6070901@kernel.org> <4FD79A14.5090801@linaro.org>
In-Reply-To: <4FD79A14.5090801@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dave Chinner <david@fromorbit.com>, Neil Brown <neilb@suse.de>, Andrea Righi <andrea@betterlinux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Taras Glek <tgek@mozilla.com>, Mike Hommey <mh@glandium.org>, Jan Kara <jack@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 06/13/2012 04:35 AM, John Stultz wrote:

> On 06/12/2012 12:16 AM, Minchan Kim wrote:
>> Please, Cced linux-mm.
>>
>> On 06/09/2012 12:45 PM, John Stultz wrote:
>>
>>> On 06/07/2012 09:50 PM, KOSAKI Motohiro wrote:
>>>> (6/7/12 11:03 PM), John Stultz wrote:
>>>>
>>>>> So I'm falling back to using a shrinker for now, but I think Dmitry's
>>>>> point is an interesting one, and am interested in finding a better
>>>>> place to trigger purging volatile ranges from the mm code. If anyone
>>>>> has any
>>>>> suggestions, let me know, otherwise I'll go back to trying to better
>>>>> grok the mm code.
>>>> I hate vm feature to abuse shrink_slab(). because of, it was not
>>>> designed generic callback.
>>>> it was designed for shrinking filesystem metadata. Therefore, vm
>>>> keeping a balance between
>>>> page scanning and slab scanning. then, a lot of shrink_slab misuse may
>>>> lead to break balancing
>>>> logic. i.e. drop icache/dcache too many and makes perfomance impact.
>>>>
>>>> As far as a code impact is small, I'm prefer to connect w/ vm reclaim
>>>> code directly.
>>> I can see your concern about mis-using the shrinker code. Also your
>>> other email's point about the problem of having LRU range purging
>>> behavior on a NUMA system makes some sense too.  Unfortunately I'm not
>>> yet familiar enough with the reclaim core to sort out how to best track
>>> and connect the volatile range purging in the vm's reclaim core yet.
>>>
>>> So for now, I've moved the code back to using the shrinker (along with
>>> fixing a few bugs along the way).
>>> Thus, currently we manage the ranges as so:
>>>      [per fs volatile range lru head] ->  [volatile range] ->  [volatile
>>> range] ->  [volatile range]
>>> With the per-fs shrinker zaping the volatile ranges from the lru.
>>>
>>> I *think* ideally, the pages in a volatile range should be similar to
>>> non-dirty file-backed pages.  There is a cost to restore them, but
>>> freeing them is very cheap.  The trick is that volatile ranges
>>> introduces a new relationship between pages. Since the neighboring
>>> virtual pages in a volatile range are in effect tied together, purging
>>> one effectively ruins the value of keeping the others, regardless of
>>> which zone they are physically.
>>>
>>> So maybe the right appraoch give up the per-fs volatile range lru, and
>>> try a varient of what DaveC and DaveH have suggested: Letting the page
>>> based lru reclamation handle the selection on a physical page basis, but
>>> then zapping the entirety of the neighboring range if any one page is
>>> reclaimed.  In order to try to preserve the range based LRU behavior,
>>> activate all the pages in the range together when the range is marked
>>
>> You mean deactivation for fast reclaiming, not activation when memory
>> pressure happen?
> Yes. Sorry for mixing up terms here. The point is moving all the pages
> together to the inactive list to preserve relative LRU behavior for
> purging ranges.


No problem :)

> 
> 
> 
>>> volatile.  Since we assume ranges are un-touched when volatile, that
>>> should preserve LRU purging behavior on single node systems and on
>>> multi-node systems it will approximate fairly closely.
>>>
>>> My main concern with this approach is marking and unmarking volatile
>>> ranges needs to be fast, so I'm worried about the additional overhead of
>>> activating each of the containing pages on mark_volatile.
>>
>> Yes. it could be a problem if range is very large and populated already.
>> Why can't we make new hooks?
>>
>> Just concept for showing my intention..
>>
>> +int shrink_volatile_pages(struct zone *zone)
>> +{
>> +       int ret = 0;
>> +       if (zone_page_state(zone, NR_ZONE_VOLATILE))
>> +               ret = shmem_purge_one_volatile_range();
>> +       return ret;
>> +}
>> +
>>   static void shrink_zone(struct zone *zone, struct scan_control *sc)
>>   {
>>          struct mem_cgroup *root = sc->target_mem_cgroup;
>> @@ -1827,6 +1835,18 @@ static void shrink_zone(struct zone *zone,
>> struct scan_control *sc)
>>                  .priority = sc->priority,
>>          };
>>          struct mem_cgroup *memcg;
>> +       int ret;
>> +
>> +       /*
>> +        * Before we dive into trouble maker, let's look at easy-
>> +        * reclaimable pages and avoid costly-reclaim if possible.
>> +        */
>> +       do {
>> +               ret = shrink_volatile_pages();
>> +               if (ret)
>> +                       zone_watermark_ok(zone, sc->order, xxx);
>> +                               return;
>> +       } while(ret)
> 
> Hmm. I'm confused.
> This doesn't seem that different from the shrinker approach.


Shrinker is called after shrink_list so it means normal pages can be reclaimed
before we reclaim volatile pages. We shouldn't do that.
 

> How does this resolve the numa-unawareness issue that Kosaki-san brought
> up?


Basically, I think your shrink function should be more smart.

when fallocate is called, we can get mem_policy from shmem_inode_info and pass it to
volatile_range so that volatile_range can keep the information of NUMA.

When shmem_purge_one_volatile_range is called, it receives zone information.
So shmem_purge_one_volatile_range should find a range matched with NUMA policy and
passed zone.

Assumption:
  A range may include same node/zone pages if possible.

I am not familiar with NUMA handling code so KOSAKI/Rik can point out if I am wrong.

> 
> 
>>> The other question I have with this approach is if we're on a system
>>> that doesn't have swap, it *seems* (not totally sure I understand it
>>> yet) the tmpfs file pages will be skipped over when we call
>>> shrink_lruvec.  So it seems we may need to add a new lru_list enum and
>>> nr[] entry (maybe LRU_VOLATILE?).   So then it may be that when we mark
>>> a range as volatile, instead of just activating it, we move it to the
>>> volatile lru, and then when we shrink from that list, we call back to
>>> the filesystem to trigger the entire range purging.
>> Adding new LRU idea might make very slow fallocate(VOLATILE) so I hope
>> we can avoid that if possible.
> 
> Indeed. This is a major concern. I'm currently prototyping it out so I
> have a concrete sense of the performance cost.


If performance loss isn't big, that would be a approach!

> 
> thanks
> -john
> 



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

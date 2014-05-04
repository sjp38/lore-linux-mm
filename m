Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 78B376B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 16:16:39 -0400 (EDT)
Received: by mail-we0-f177.google.com with SMTP id x48so1314844wes.8
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:16:38 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id cz1si2288621wib.90.2014.05.04.13.16.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 May 2014 13:16:37 -0700 (PDT)
Received: by mail-wi0-f174.google.com with SMTP id r20so1307625wiv.13
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:16:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <53660ADC.8000306@oracle.com>
References: <alpine.LSU.2.11.1402232344280.1890@eggly.anvils>
 <1397336454-13855-1-git-send-email-ddstreet@ieee.org> <1397336454-13855-2-git-send-email-ddstreet@ieee.org>
 <20140423103400.GH23991@suse.de> <CALZtONCa3jLrYkPSFPNnV84zePxFtdkWJBu092ScgUe2AugMxQ@mail.gmail.com>
 <CAL1ERfP16T68OzHwhuN9S=QiqzuuVAyq5Wu=-pDEkiHrNNiH1g@mail.gmail.com>
 <CALZtONBDdo7KGKPZHuH-gHUS8ntBW+mYGPKKnh5GcQAsL5Zrfw@mail.gmail.com> <53660ADC.8000306@oracle.com>
From: Dan Streetman <ddstreet@ieee.org>
Date: Sun, 4 May 2014 16:16:16 -0400
Message-ID: <CALZtONCcr512UeNF7Ascy-XUL_xZbFY+Nw1KAH=M-YqaO38v0w@mail.gmail.com>
Subject: Re: [PATCH 1/2] swap: change swap_info singly-linked list to list_head
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Weijie Yang <weijie.yang.kh@gmail.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, xen-devel@lists.xenproject.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Christian Ehrhardt <ehrhardt@linux.vnet.ibm.com>, Shaohua Li <shli@fusionio.com>, Weijie Yang <weijieut@gmail.com>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, David Vrabel <david.vrabel@citrix.com>

On Sun, May 4, 2014 at 5:39 AM, Bob Liu <bob.liu@oracle.com> wrote:
>
> On 05/03/2014 04:00 AM, Dan Streetman wrote:
>> On Fri, Apr 25, 2014 at 12:15 AM, Weijie Yang <weijie.yang.kh@gmail.com> wrote:
>>> On Fri, Apr 25, 2014 at 2:48 AM, Dan Streetman <ddstreet@ieee.org> wrote:
>>>> On Wed, Apr 23, 2014 at 6:34 AM, Mel Gorman <mgorman@suse.de> wrote:
>>>>> On Sat, Apr 12, 2014 at 05:00:53PM -0400, Dan Streetman wrote:
>> <SNIP>
>>>>>> diff --git a/mm/frontswap.c b/mm/frontswap.c
>>>>>> index 1b24bdc..fae1160 100644
>>>>>> --- a/mm/frontswap.c
>>>>>> +++ b/mm/frontswap.c
>>>>>> @@ -327,15 +327,12 @@ EXPORT_SYMBOL(__frontswap_invalidate_area);
>>>>>>
>>>>>>  static unsigned long __frontswap_curr_pages(void)
>>>>>>  {
>>>>>> -     int type;
>>>>>>       unsigned long totalpages = 0;
>>>>>>       struct swap_info_struct *si = NULL;
>>>>>>
>>>>>>       assert_spin_locked(&swap_lock);
>>>>>> -     for (type = swap_list.head; type >= 0; type = si->next) {
>>>>>> -             si = swap_info[type];
>>>>>> +     list_for_each_entry(si, &swap_list_head, list)
>>>>>>               totalpages += atomic_read(&si->frontswap_pages);
>>>>>> -     }
>>>>>>       return totalpages;
>>>>>>  }
>>>>>>
>>>>>> @@ -347,11 +344,9 @@ static int __frontswap_unuse_pages(unsigned long total, unsigned long *unused,
>>>>>>       int si_frontswap_pages;
>>>>>>       unsigned long total_pages_to_unuse = total;
>>>>>>       unsigned long pages = 0, pages_to_unuse = 0;
>>>>>> -     int type;
>>>>>>
>>>>>>       assert_spin_locked(&swap_lock);
>>>>>> -     for (type = swap_list.head; type >= 0; type = si->next) {
>>>>>> -             si = swap_info[type];
>>>>>> +     list_for_each_entry(si, &swap_list_head, list) {
>>>>>>               si_frontswap_pages = atomic_read(&si->frontswap_pages);
>>>>>>               if (total_pages_to_unuse < si_frontswap_pages) {
>>>>>>                       pages = pages_to_unuse = total_pages_to_unuse;
>>>>>
>>>>> The frontswap shrink code looks suspicious. If the target is smaller than
>>>>> the total number of frontswap pages then it does nothing. The callers
>
> __frontswap_unuse_pages() is called only to get the correct value of
> pages_to_unuse which will pass to try_to_unuse(), perhaps we should
> rename it to __frontswap_unuse_pages_nr()..
>
> ------
> ret = __frontswap_shrink(target_pages, &pages_to_unuse, &type);
>         ->  __frontswap_unuse_pages(total_pages_to_unuse, pages_to_unuse, type);
>
> try_to_unuse(type, true, pages_to_unuse);
> ------
>
>>>>> appear to get this right at least. Similarly, if the first swapfile has
>>>>> fewer frontswap pages than the target then it does not unuse the target
>>>>> number of pages because it only handles one swap file. It's outside the
>>>>> scope of your patch to address this or wonder if xen balloon driver is
>>>>> really using it the way it's expected.
>>>>
>>>> I didn't look into the frontswap shrinking code, but I agree the
>>>> existing logic there doesn't look right.  I'll review frontswap in
>>>> more detail to see if it needs changing here, unless anyone else gets
>>>> it to first :-)
>>>>
>>>
>>> FYI, I drop the frontswap_shrink code in a patch
>>> see: https://lkml.org/lkml/2014/1/27/98
>>
>> frontswap_shrink() is actually used (only) by drivers/xen/xen-selfballoon.c.
>>
>> However, I completely agree with you that the backend should be doing
>> the shrinking, not from a frontswap api.  Forcing frontswap to shrink
>> is backwards - xen-selfballoon appears to be assuming that xem/tmem is
>> the only possible frontswap backend.  It certainly doensn't make any
>> sense for xen-selfballoon to force zswap to shrink itself, does it?
>>
>> If xen-selfballoon wants to shrink its frontswap backend tmem, it
>> should do that by telling tmem directly to shrink itself (which it
>> looks like tmem would have to implement, just like zswap sends its LRU
>> pages back to swapcache when it becomes full).
>>
>
> Yes, it's possible in theory, but tmem is located in xen(host) which
> can't put back pages to swap cache(in guest os) directly. Use
> frontswap_shrink() can make things simple and easier.
>
> And I think frontswap shrink isn't a blocker of this patch set, so
> please keep it.

I didn't mean to imply it was required for this patchset - just
commenting on Weijie's patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

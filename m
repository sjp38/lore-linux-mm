Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id ACA578E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 20:04:09 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id r9so8342227ybp.16
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 17:04:09 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id s19si18295652ybg.299.2019.01.11.17.04.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 17:04:07 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181217181148.GA3341@redhat.com>
 <20181217183443.GO10600@bombadil.infradead.org>
 <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com> <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com> <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
Date: Fri, 11 Jan 2019 17:04:05 -0800
MIME-Version: 1.0
In-Reply-To: <20190111165141.GB3190@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/11/19 8:51 AM, Jerome Glisse wrote:
> On Thu, Jan 10, 2019 at 06:59:31PM -0800, John Hubbard wrote:
>> On 1/3/19 6:44 AM, Jerome Glisse wrote:
>>> On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
>>>> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
>>>>> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
>>>>>> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
>>>>>>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
> 
> [...]
> 
>>>>> Now page_mkclean:
>>>>>
>>>>> int page_mkclean(struct page *page)
>>>>> {
>>>>>     int cleaned = 0;
>>>>> +   int real_mapcount = 0;
>>>>>     struct address_space *mapping;
>>>>>     struct rmap_walk_control rwc = {
>>>>>         .arg = (void *)&cleaned,
>>>>>         .rmap_one = page_mkclean_one,
>>>>>         .invalid_vma = invalid_mkclean_vma,
>>>>> +       .mapcount = &real_mapcount,
>>>>>     };
>>>>> +   int mapcount1, mapcount2;
>>>>>
>>>>>     BUG_ON(!PageLocked(page));
>>>>>
>>>>>     if (!page_mapped(page))
>>>>>         return 0;
>>>>>
>>>>>     mapping = page_mapping(page);
>>>>>     if (!mapping)
>>>>>         return 0;
>>>>>
>>>>> +   mapcount1 = page_mapcount(page);
>>>>>     // rmap_walk need to change to count mapping and return value
>>>>>     // in .mapcount easy one
>>>>>     rmap_walk(page, &rwc);
>>>>
>>>> So what prevents GUP_fast() to grab reference here and the test below would
>>>> think the page is not pinned? Or do you assume that every page_mkclean()
>>>> call will be protected by PageWriteback (currently it is not) so that
>>>> GUP_fast() blocks / bails out?
>>
>> Continuing this thread, still focusing only on the "how to maintain a PageDmaPinned
>> for each page" question (ignoring, for now, what to actually *do* in response to 
>> that flag being set):
>>
>> 1. Jan's point above is still a problem: PageWriteback != "page_mkclean is happening".
>> This is probably less troubling than the next point, but it does undermine all the 
>> complicated schemes involving PageWriteback, that try to synchronize gup() with
>> page_mkclean().
>>
>> 2. Also, the mapcount approach here still does not reliably avoid false negatives
>> (that is, a page may have been gup'd, but page_mkclean could miss that): gup()
>> can always jump in and increment the mapcount, while page_mkclean is in the middle
>> of making (wrong) decisions based on that mapcount. There's no lock to prevent that.
>>
>> Again: mapcount can go up *or* down, so I'm not seeing a true solution yet.
> 
> Both point is address by the solution at the end of this email.
> 
>>>
>>> So GUP_fast() becomes:
>>>
>>> GUP_fast_existing() { ... }
>>> GUP_fast()
>>> {
>>>     GUP_fast_existing();
>>>
>>>     for (i = 0; i < npages; ++i) {
>>>         if (PageWriteback(pages[i])) {
>>>             // need to force slow path for this page
>>>         } else {
>>>             SetPageDmaPinned(pages[i]);
>>>             atomic_inc(pages[i]->mapcount);
>>>         }
>>>     }
>>> }
>>>
>>> This is a minor slow down for GUP fast and it takes care of a
>>> write back race on behalf of caller. This means that page_mkclean
>>> can not see a mapcount value that increase. This simplify thing
>>> we can relax that. Note that what this is doing is making sure
>>> that GUP_fast never get lucky :) ie never GUP a page that is in
>>> the process of being write back but has not yet had its pte
>>> updated to reflect that.
>>>
>>>
>>>> But I think that detecting pinned pages with small false positive rate is
>>>> OK. The extra page bouncing will cost some performance but if it is rare,
>>>> then we are OK. So I think we can go for the simple version of detecting
>>>> pinned pages as you mentioned in some earlier email. We just have to be
>>>> sure there are no false negatives.
>>>
>>
>> Agree with that sentiment, but there are still false negatives and I'm not
>> yet seeing any solutions for that.
> 
> So here is the solution:
> 
> 
> Is a page pin ? With no false negative:
> =======================================
> 
> get_user_page*() aka GUP:
>      if (!PageAnon(page)) {
>         bool write_back = PageWriteback(page);
>         bool page_is_pin = PagePin(page);
>         if (write_back && !page_is_pin) {
>             /* Wait for write back a re-try GUP */
>             ...
>             goto retry;
>         }
> [G1]    smp_rmb();
> [G2]    atomic_inc(&page->_mapcount)
> [G3]    smp_wmb();
> [G4]    SetPagePin(page);
> [G5]    smp_wmb();
> [G6]    if (!write_back && !page_is_pin && PageWriteback(page)) {
>             /* Back-off as write back might have miss us */
>             atomic_dec(&page->_mapcount);
>             /* Wait for write back a re-try GUP */
>             ...
>             goto retry;
>         }
>      }
> 
> put_user_page() aka PUP:
> [P1] if (!PageAnon(page)) atomic_dec(&page->_mapcount);
> [P2] put_page(page);
> 
> page_mkclean():
> [C1] pined = TestClearPagePin(page);
> [C2] smp_mb();
> [C3] map_and_pin_count = atomic_read(&page->_mapcount)
> [C4] map_count = rmap_walk(page);
> [C5] if (pined && map_count < map_and_pin_count) SetPagePin(page);
> 
> So with above code we store the map and pin count inside struct page
> _mapcount field. The idea is that we can count the number of page
> table entry that point to the page when reverse walking all the page
> mapping in page_mkclean() [C4].
> 
> The issue is that GUP, PUP and page table entry zapping can all run
> concurrently with page_mkclean() and thus we can not get the real
> map and pin count and the real map count at a given point in time
> ([C5] for instance in the above). However we only care about avoiding
> false negative ie we do not want to report a page as unpin if in fact
> it is pin (it has active GUP). Avoiding false positive would be nice
> but it would need more heavy weight synchronization within GUP and
> PUP (we can mitigate it see the section on that below).
> 
> With the above scheme a page is _not_ pin (unpin) if and only if we
> have real_map_count == real_map_and_pin_count at a given point in
> time. In the above pseudo code the page is lock within page_mkclean()
> thus no new page table entry can be added and thus the number of page
> mapping can only go down (because of conccurent pte zapping). So no
> matter what happens at [C5] we have map_count <= real_map_count.
> 
> At [C3] we have two cases to consider:
>  [R1] A concurrent GUP after [C3] then we do not care what happens at
>       [C5] as the GUP would already have set the page pin flag. If it
>       raced before [C3] at [C1] with TestClearPagePin() then we would
>       have the map_and_pin_count reflect the GUP thanks to the memory
>       barrier [G3] and [C2].
>  [R2] No concurrent GUP after [C3] then we only have concurrent PUP to
>       worry about and thus the real_map_and_pin_count can only go down.
>       So because we first snap shot that value at [C5] we have:
>       real_map_and_pin_count <= map_and_pin_count.
> 
>       So at [C5] we end up with map_count <= real_map_count and with
>       real_map_and_pin_count <= map_pin_count but we also always have
>       real_map_count <= real_map_and_pin_count so it means we are in a
>       a <= b <= c <= d scenario and if a == d then b == c. So at [C5]
>       if map_count == map_pin_count then we know for sure that we have
>       real_map_count == real_map_and_pin_count and if that is the case
>       then the page is no longer pin. So at [C5] we will never miss a
>       pin page (no false negative).
> 
>       Another way to word this is that we always under-estimate the real
>       map count and over estimate the map and pin count and thus we can
>       never have false negative (map count equal to map and pin count
>       while in fact real map count is inferior to real map and pin count).
> 
> 
> PageWriteback() test and ordering with page_mkclean()
> =====================================================
> 
> In GUP we test for page write back flag to avoid pining a page that
> is under going write back. That flag is set after page_mkclean() so
> the filesystem code that will check for the pin flag need some memory
> barrier:
>     int __test_set_page_writeback(struct page *page, bool keep_write,
> +                                 bool *use_bounce_page)
>     {
>         ...
>   [T1]  TestSetPageWriteback(page);
> + [T2]  smp_wmb();
> + [T3]  *use_bounce_page = PagePin(page);
>         ...
>     }
> 
> That way if there is a concurrent GUP we either have:
>     [R1] GUP sees the write back flag set before [G1] so it back-off
>     [R2] GUP sees no write back before [G1] here either we have GUP
>          that sees the write back flag at [G6] or [T3] that sees the
>          pin flag thanks to the memory barrier [G5] and [T2].
> 
> So in all cases we never miss a pin or a write back.
> 
> 
> Mitigate false positive:
> ========================
> 
> If false positive is ever an issue we can improve the situation and to
> properly account conccurent pte zapping with the following changes:
> 
> page_mkclean():
> [C1] pined = TestClearPagePin(page);
> [C2] smp_mb();
> [C3] map_and_pin_count = atomic_read(&page->_mapcount)
> [C4] map_count = rmap_walk(page, &page_mkclean_one());
> [C5] if (pined && !PagePin(page) && map_count < map_and_pin_count) {
> [C6]    map_and_pin_count2 = atomic_read(&page->_mapcount)
> [C7]    map_count = rmap_walk(page, &page_map_count(), map_and_pin_count2);
> [C8]    if (map_count < map_and_pin_count2) SetPagePin(page);
>      }
> 
> page_map_count():
> [M1] if (pte_valid(pte) { map_count++; }
>      } else if (pte_special_zap(pte)) {
> [M2]    unsigned long map_count_at_zap = pte_special_zap_to_value(pte);
> [M3]    if (map_count_at_zap <= (map_and_pin_count & MASK)) map_count++;
>      }
> 
> And pte zapping of file back page will write a special pte entry which
> has the page map and pin count value at the time the pte is zap. Also
> page_mkclean_one() unconditionaly replace those special pte with pte
> none and ignore them altogether. We only want to detect pte zapping that
> happens after [C6] and before [C7] is done.
> 
> With [M3] we are counting all page table entry that have been zap after
> the map_and_pin_count value we read at [C6]. Again we have two cases:
>  [R1] A concurrent GUP after [C6] then we do not care what happens
>       at [C8] as the GUP would already have set the page pin flag.
>  [R2] No concurrent GUP then we only have concurrent PUP to worry
>       about. If they happen before [C6] they are included in [C6]
>       map_and_pin_count value. If after [C6] then we might miss a
>       page that is no longer pin ie we are over estimating the
>       map_and_pin_count (real_map_and_pin_count < map_and_pin_count
>       at [C8]). So no false negative just false positive.
> 
> Here we just get the accurate real_map_count at [C6] time so if the
> page was no longer pin at [C6] time we will correctly detect it and
> not set the flag at [C8]. If there is any concurrent GUP that GUP
> would set the flag properly.
> 
> There is one last thing to note about above code, the MASK in [M3].
> For special pte entry we might not have enough bits to store the
> whole map and pin count value (on 32bits arch). So we might expose
> ourself to wrap around. Again we do not care about [R1] case as any
> concurrent GUP will set the pin flag. So we only care if the only
> thing happening concurrently is either PUP or pte zapping. In both
> case its means that the map and pin count is going down so if there
> is a wrap around sometimes within [C7]/page_map_count() we have:
>   [t0] page_map_count() executed on some pte
>   [t1] page_map_count() executed on another pte after [t1]
> With:
>     (map_count_t0 & MASK) < (map_count_t1 & MASK)
> While in fact:
>     map_count_t0 > map_count_t1
> 
> So if that happens then we will under-estimate the map count ie we
> will ignore some of the concurrent pte zapping and not count them.
> So again we are only exposing our self to false positive not false
> negative.
> 
> 
> ---------------------------------------------------------------------
> 
> 
> Hopes this prove that this solution do work. The false positive is
> something that i believe is acceptable. We will get them only when
> they are racing GUP or PUP. For racing GUP it is safer to have false
> positive. For racing PUP it would be nice to catch them but hey some
> times you just get unlucky.
> 
> Note that any other solution will also suffer from false positive
> situation because anyway you are testing for the page pin status
> at a given point in time so it can always race with a PUP. So the
> only difference with any other solution would be how long is the
> false positive race window.
> 

Hi Jerome,

Looks good, in a conceptual sense. Let me do a brain dump of how I see it,
in case anyone spots a disastrous conceptual error (such as the lock_page
point), while I'm putting together the revised patchset.

I've studied this carefully, and I agree that using mapcount in 
this way is viable, *as long* as we use a lock (or a construct that looks just 
like one: your "memory barrier, check, retry" is really just a lock) in
order to hold off gup() while page_mkclean() is in progress. In other words,
nothing that increments mapcount may proceed while page_mkclean() is running.

I especially am intrigued by your idea about a fuzzy count that allows
false positives but no false negatives. To do that, we need to put a hard
lock protecting the increment operation, but we can be loose (no lock) on
decrement. That turns out to be a perfect match for the problem here, because
as I recall from my earlier efforts, put_user_page() must *not* take locks--
and that's where we just decrement. Sweet! See below.

The other idea that you and Dan (and maybe others) pointed out was a debug
option, which we'll certainly need in order to safely convert all the call
sites. (Mirror the mappings at a different kernel offset, so that put_page()
and put_user_page() can verify that the right call was made.)  That will be
a separate patchset, as you recommended.

I'll even go as far as recommending the page lock itself. I realize that this 
adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
that this (below) has similar overhead to the notes above--but is *much* easier
to verify correct. (If the page lock is unacceptable due to being so widely used,
then I'd recommend using another page bit to do the same thing.)

(Note that memory barriers will simply be built into the various Set|Clear|Read
operations, as is common with a few other page flags.)

page_mkclean():
===============
lock_page()
    page_mkclean()
        Count actual mappings
            if(mappings == atomic_read(&page->_mapcount))
                ClearPageDmaPinned 

gup_fast():
===========
for each page {
    lock_page() /* gup MUST NOT proceed until page_mkclean and writeback finish */

    atomic_inc(&page->_mapcount)
    SetPageDmaPinned()

    /* details of gup vs gup_fast not shown here... */


put_user_page():
================
    atomic_dec(&page->_mapcount); /* no locking! */
   

try_to_unmap() and other consumers of the PageDmaPinned flag:
=============================================================
lock_page() /* not required, but already done by existing callers */
    if(PageDmaPinned) {
        ...take appropriate action /* future patchsets */

page freeing:
============
ClearPageDmaPinned() /* It may not have ever had page_mkclean() run on it */



thanks,
-- 
John Hubbard
NVIDIA

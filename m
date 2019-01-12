Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAAC18E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 21:38:49 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id e14so3608619ybf.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 18:38:49 -0800 (PST)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id 203si48109564ywo.294.2019.01.11.18.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Jan 2019 18:38:47 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <20181218093017.GB18032@quack2.suse.cz>
 <9f43d124-2386-7bfd-d90b-4d0417f51ccd@nvidia.com>
 <20181219020723.GD4347@redhat.com> <20181219110856.GA18345@quack2.suse.cz>
 <20190103015533.GA15619@redhat.com> <20190103092654.GA31370@quack2.suse.cz>
 <20190103144405.GC3395@redhat.com>
 <a79b259b-3982-b271-025a-0656f70506f4@nvidia.com>
 <20190111165141.GB3190@redhat.com>
 <1b37061c-5598-1b02-2983-80003f1c71f2@nvidia.com>
 <20190112020228.GA5059@redhat.com>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
Date: Fri, 11 Jan 2019 18:38:44 -0800
MIME-Version: 1.0
In-Reply-To: <20190112020228.GA5059@redhat.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro,
 Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On 1/11/19 6:02 PM, Jerome Glisse wrote:
> On Fri, Jan 11, 2019 at 05:04:05PM -0800, John Hubbard wrote:
>> On 1/11/19 8:51 AM, Jerome Glisse wrote:
>>> On Thu, Jan 10, 2019 at 06:59:31PM -0800, John Hubbard wrote:
>>>> On 1/3/19 6:44 AM, Jerome Glisse wrote:
>>>>> On Thu, Jan 03, 2019 at 10:26:54AM +0100, Jan Kara wrote:
>>>>>> On Wed 02-01-19 20:55:33, Jerome Glisse wrote:
>>>>>>> On Wed, Dec 19, 2018 at 12:08:56PM +0100, Jan Kara wrote:
>>>>>>>> On Tue 18-12-18 21:07:24, Jerome Glisse wrote:
>>>>>>>>> On Tue, Dec 18, 2018 at 03:29:34PM -0800, John Hubbard wrote:
>>> [...]
>>
>> Hi Jerome,
>>
>> Looks good, in a conceptual sense. Let me do a brain dump of how I see it,
>> in case anyone spots a disastrous conceptual error (such as the lock_page
>> point), while I'm putting together the revised patchset.
>>
>> I've studied this carefully, and I agree that using mapcount in 
>> this way is viable, *as long* as we use a lock (or a construct that looks just 
>> like one: your "memory barrier, check, retry" is really just a lock) in
>> order to hold off gup() while page_mkclean() is in progress. In other words,
>> nothing that increments mapcount may proceed while page_mkclean() is running.
> 
> No, increment to page->_mapcount are fine while page_mkclean() is running.
> The above solution do work no matter what happens thanks to the memory
> barrier. By clearing the pin flag first and reading the page->_mapcount
> after (and doing the reverse in GUP) we know that a racing GUP will either
> have its pin page clear but the incremented mapcount taken into account by
> page_mkclean() or page_mkclean() will miss the incremented mapcount but
> it will also no clear the pin flag set concurrently by any GUP.
> 
> Here are all the possible time line:
> [T1]:
> GUP on CPU0                      | page_mkclean() on CPU1
>                                  |
> [G2] atomic_inc(&page->mapcount) |
> [G3] smp_wmb();                  |
> [G4] SetPagePin(page);           |
>                                 ...
>                                  | [C1] pined = TestClearPagePin(page);

It appears that you're using the "page pin is clear" to indicate that
page_mkclean() is running. The problem is, that approach leads to toggling
the PagePin flag, and so an observer (other than gup or page_mkclean) will
see intervals during which the PagePin flag is clear, when conceptually it
should be set.

Jan and other FS people, is it definitely the case that we only have to take
action (defer, wait, revoke, etc) for gup-pinned pages, in page_mkclean()?
Because I recall from earlier experiments that there were several places, not 
just page_mkclean().

One more quick question below...

>                                  | [C2] smp_mb();
>                                  | [C3] map_and_pin_count =
>                                  |        atomic_read(&page->mapcount)
> 
> It is fine because page_mkclean() will read the correct page->mapcount
> which include the GUP that happens before [C1]
> 
> 
> [T2]:
> GUP on CPU0                      | page_mkclean() on CPU1
>                                  |
>                                  | [C1] pined = TestClearPagePin(page);
>                                  | [C2] smp_mb();
>                                  | [C3] map_and_pin_count =
>                                  |        atomic_read(&page->mapcount)
>                                 ...
> [G2] atomic_inc(&page->mapcount) |
> [G3] smp_wmb();                  |
> [G4] SetPagePin(page);           |
> 
> It is fine because [G4] set the pin flag so it does not matter that [C3]
> did miss the mapcount increase from the GUP.
> 
> 
> [T3]:
> GUP on CPU0                      | page_mkclean() on CPU1
> [G4] SetPagePin(page);           | [C1] pined = TestClearPagePin(page);
> 
> No matter which CPU ordering we get ie either:
>     - [G4] is overwritten by [C1] in that case [C3] will see the mapcount
>       that was incremented by [G2] so we will map_count < map_and_pin_count
>       and we will set the pin flag again at the end of page_mkclean()
>     - [C1] is overwritten by [G4] in that case the pin flag is set and thus
>       it does not matter that [C3] also see the mapcount that was incremented
>       by [G2]
> 
> 
> This is totaly race free ie at the end of page_mkclean() the pin flag will
> be set for all page that are pin and for some page that are no longer pin.
> What matter is that they are no false negative.
> 
> 
>> I especially am intrigued by your idea about a fuzzy count that allows
>> false positives but no false negatives. To do that, we need to put a hard
>> lock protecting the increment operation, but we can be loose (no lock) on
>> decrement. That turns out to be a perfect match for the problem here, because
>> as I recall from my earlier efforts, put_user_page() must *not* take locks--
>> and that's where we just decrement. Sweet! See below.
> 
> You do not need lock, lock are easier to think with but they are not always
> necessary and in this case we do not need any lock. We can happily have any
> number of concurrent GUP, PUP or pte zapping. Worse case is false positive
> ie reporting a page as pin while it has just been unpin concurrently by a
> PUP.
> 
>> The other idea that you and Dan (and maybe others) pointed out was a debug
>> option, which we'll certainly need in order to safely convert all the call
>> sites. (Mirror the mappings at a different kernel offset, so that put_page()
>> and put_user_page() can verify that the right call was made.)  That will be
>> a separate patchset, as you recommended.
>>
>> I'll even go as far as recommending the page lock itself. I realize that this 
>> adds overhead to gup(), but we *must* hold off page_mkclean(), and I believe
>> that this (below) has similar overhead to the notes above--but is *much* easier
>> to verify correct. (If the page lock is unacceptable due to being so widely used,
>> then I'd recommend using another page bit to do the same thing.)
> 
> Please page lock is pointless and it will not work for GUP fast. The above
> scheme do work and is fine. I spend the day again thinking about all memory
> ordering and i do not see any issues.
> 

Why is it that page lock cannot be used for gup fast, btw?

> 
>> (Note that memory barriers will simply be built into the various Set|Clear|Read
>> operations, as is common with a few other page flags.)
>>
>> page_mkclean():
>> ===============
>> lock_page()
>>     page_mkclean()
>>         Count actual mappings
>>             if(mappings == atomic_read(&page->_mapcount))
>>                 ClearPageDmaPinned 
>>
>> gup_fast():
>> ===========
>> for each page {
>>     lock_page() /* gup MUST NOT proceed until page_mkclean and writeback finish */
>>
>>     atomic_inc(&page->_mapcount)
>>     SetPageDmaPinned()
>>
>>     /* details of gup vs gup_fast not shown here... */
>>
>>
>> put_user_page():
>> ================
>>     atomic_dec(&page->_mapcount); /* no locking! */
>>    
>>
>> try_to_unmap() and other consumers of the PageDmaPinned flag:
>> =============================================================
>> lock_page() /* not required, but already done by existing callers */
>>     if(PageDmaPinned) {
>>         ...take appropriate action /* future patchsets */
> 
> We can not block try_to_unmap() on pined page. What we want to block is
> fs using a different page for the same file offset the original pined
> page was pin (modulo truncate that we should not block). Everything else
> must keep working as if there was no pin. We can not fix that, driver
> doing long term GUP and not abiding to mmu notifier are hopelessly broken
> in front of many regular syscall (mremap, truncate, splice, ...) we can
> not block those syscall or failing them, doing so would mean breaking
> applications in a bad way.
> 
> The only thing we should do is avoid fs corruption and bug due to
> dirtying page after fs believe it has been clean.
> 
> 
>> page freeing:
>> ============
>> ClearPageDmaPinned() /* It may not have ever had page_mkclean() run on it */
> 
> Yeah this need to happen when we sanitize flags of free page.
> 


thanks,
-- 
John Hubbard
NVIDIA

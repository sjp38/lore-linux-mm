Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1A0BC6B0135
	for <linux-mm@kvack.org>; Thu,  8 May 2014 20:24:47 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id kx10so3560886pab.33
        for <linux-mm@kvack.org>; Thu, 08 May 2014 17:24:46 -0700 (PDT)
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
        by mx.google.com with ESMTPS id qa3si1327154pbb.192.2014.05.08.17.24.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 08 May 2014 17:24:46 -0700 (PDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so3507465pad.16
        for <linux-mm@kvack.org>; Thu, 08 May 2014 17:24:45 -0700 (PDT)
Message-ID: <536C2049.6020308@linaro.org>
Date: Thu, 08 May 2014 17:24:41 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] MADV_VOLATILE: Add MADV_VOLATILE/NONVOLATILE hooks
 and handle marking vmas
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org> <1398806483-19122-3-git-send-email-john.stultz@linaro.org> <20140508012142.GA5282@bbox> <536BB310.1050105@linaro.org> <20140508231259.GA25951@bbox> <536C168B.6090702@linaro.org> <20140509000752.GD25951@bbox>
In-Reply-To: <20140509000752.GD25951@bbox>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 05/08/2014 05:07 PM, Minchan Kim wrote:
> On Thu, May 08, 2014 at 04:43:07PM -0700, John Stultz wrote:
>> On 05/08/2014 04:12 PM, Minchan Kim wrote:
>>> On Thu, May 08, 2014 at 09:38:40AM -0700, John Stultz wrote:
>>>> On 05/07/2014 06:21 PM, Minchan Kim wrote:
>>>>> Hey John,
>>>>>
>>>>> On Tue, Apr 29, 2014 at 02:21:21PM -0700, John Stultz wrote:
>>>>>> This patch introduces MADV_VOLATILE/NONVOLATILE flags to madvise(),
>>>>>> which allows for specifying ranges of memory as volatile, and able
>>>>>> to be discarded by the system.
>>>>>>
>>>>>> This initial patch simply adds flag handling to madvise, and the
>>>>>> vma handling, splitting and merging the vmas as needed, and marking
>>>>>> them with VM_VOLATILE.
>>>>>>
>>>>>> No purging or discarding of volatile ranges is done at this point.
>>>>>>
>>>>>> This a simplified implementation which reuses some of the logic
>>>>>> from Minchan's earlier efforts. So credit to Minchan for his work.
>>>>> Remove purged argument is really good thing but I'm not sure merging
>>>>> the feature into madvise syscall is good idea.
>>>>> My concern is how we support user who don't want SIGBUS.
>>>>> I believe we should support them because someuser(ex, sanitizer) really
>>>>> want to avoid MADV_NONVOLATILE call right before overwriting their cache
>>>>> (ex, If there was purged page for cyclic cache, user should call NONVOLATILE
>>>>> right before overwriting to avoid SIGBUS).
>>>> So... Why not use MADV_FREE then for this case?
>>> MADV_FREE is one-shot operation. I mean we should call it again to make
>>> them lazyfree while vrange could preserve volatility.
>>> Pz, think about thread-sanitizer usecase. They do mmap 70TB once start up
>>> and want to mark the range as volatile. If they uses MADV_FREE instead of
>>> volatile, they should mark 70TB as lazyfree periodically, which is terrible
>>> because MADV_FREE's cost is O(N).
>> I still have had difficulty seeing the thread-sanitizer usage as a
>> generic enough model for other applications. I realize they want to
>> avoid marking and unmarking ranges (and they want that marking and
>> unmarking to be very cheap), but the zero-fill purged page (while still
>> preserving volatility) causes lots of *very* strange behavior:
>  
> I don't think it's for only thread-sanitizer.
> Pz, think following usecase.
>
> Let's assume big volatile cache.
> If there is request for cache, it should find a object in a cache
> and if it found, it should call vrange(NOVOLATILE) right before
> passing it to the user and investigate it was purged or not.
> If it wasn't purged, cache manager could pass the object to the user.
> But it's circular cache so if there is no request from user, cache manager
> always overwrites objects so it could encounter SIGBUS easily
> so as current sematic, cache manager always should call vrange(NOVOLATILE)
> right before the overwriting. Otherwise, it should register SIGBUS handler
> to unmark volatile by page unit. SIGH.
>
> If we support zero-fill, cache manager could overwrite object without
> SIGBUS handling or vrange(NOVOLATILE) call right before overwriting.
> Just what we need is vrange(NOVOLATILE) call right before passing it
> to user.

But that wouldn't work. If the page was purged half way through writing
it, we end up with a page of half zero data and half written data. What
would the page state be at that point? Purged? Not purged?

* If its not purged (since a write was done to the page after being
zero-filled), we will silently return to the user corrupted data.

* If it is considered purged, how do we store that data? Since we
currently detect purged pages by checking if they are present when we
mark non-volatile.


This sort of zero-fill behavior on volatile pages only seems to make
sense if pages are written atomically.

The SIGBUS handling solution you SIGH'ed at above actually seems
reasonable, because it would allow the page to be safely filled
atomically (marking it non-volatile, filling it and then re-marking it
volatile). Sure it would cost more, fast and wrong isn't really a valid
option.



>
>> * How do general applications know the difference between a purged page
>> and a valid empty page?
>> * When reading/writing a page, what happens if half-way the application
>> is preempted, and the page is purged?
>> * If a volatile page is purged, then zero-filled on a read or write,
>> what is its purged state when we're marking it non-volatile?
> Maybe above scenario goes your questions to VOID.

I'm not sure I understand this.


>
>> These use cases don't seem completely baked, or maybe I've just not been
>> able to comprehend them yet. But I don't quite understand the desire to
>> prioritize this style of usage over other simpler and more well
>> established usage?
> I think it's one of typical usecase of vrange syscall.

I apologize if I'm seeming stubborn, but I just can't see how it would
work sanely.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

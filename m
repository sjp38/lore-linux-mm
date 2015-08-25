Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id E3BFA6B0253
	for <linux-mm@kvack.org>; Tue, 25 Aug 2015 09:55:50 -0400 (EDT)
Received: by widdq5 with SMTP id dq5so15897537wid.0
        for <linux-mm@kvack.org>; Tue, 25 Aug 2015 06:55:50 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bk4si2071326wib.2.2015.08.25.06.55.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Aug 2015 06:55:49 -0700 (PDT)
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-4-git-send-email-emunson@akamai.com>
 <20150812115909.GA5182@dhcp22.suse.cz> <20150819213345.GB4536@akamai.com>
 <20150820075611.GD4780@dhcp22.suse.cz> <20150820170309.GA11557@akamai.com>
 <20150821072552.GF23723@dhcp22.suse.cz> <20150821183132.GA12835@akamai.com>
 <20150825134154.GB6285@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55DC73E2.6050509@suse.cz>
Date: Tue, 25 Aug 2015 15:55:46 +0200
MIME-Version: 1.0
In-Reply-To: <20150825134154.GB6285@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On 08/25/2015 03:41 PM, Michal Hocko wrote:
> On Fri 21-08-15 14:31:32, Eric B Munson wrote:
> [...]
>> I am in the middle of implementing lock on fault this way, but I cannot
>> see how we will hanlde mremap of a lock on fault region.  Say we have
>> the following:
>>
>>      addr = mmap(len, MAP_ANONYMOUS, ...);
>>      mlock(addr, len, MLOCK_ONFAULT);
>>      ...
>>      mremap(addr, len, 2 * len, ...)
>>
>> There is no way for mremap to know that the area being remapped was lock
>> on fault so it will be locked and prefaulted by remap.  How can we avoid
>> this without tracking per vma if it was locked with lock or lock on
>> fault?
>
> Yes mremap is a problem and it is very much similar to mmap(MAP_LOCKED).
> It doesn't guarantee the full mlock semantic because it leaves partially
> populated ranges behind without reporting any error.

Hm, that's right.

> Considering the current behavior I do not thing it would be terrible
> thing to do what Konstantin was suggesting and populate only the full
> ranges in a best effort mode (it is done so anyway) and document the
> behavior properly.
> "
>         If the memory segment specified by old_address and old_size is
>         locked (using mlock(2) or similar), then this lock is maintained
>         when the segment is resized and/or relocated. As a consequence,
>         the amount of memory locked by the process may change.
>
>         If the range is already fully populated and the range is
>         enlarged the new range is attempted to be fully populated
>         as well to preserve the full mlock semantic but there is no
>         guarantee this will succeed. Partially populated (e.g. created by
>         mlock(MLOCK_ONFAULT)) ranges do not have the full mlock semantic
>         so they are not populated on resize.
> "
>
> So what we have as a result is that partially populated ranges are
> preserved and fully populated ones work in the best effort mode the same
> way as they are now.
>
> Does that sound at least remotely reasonably?

I'll basically repeat what I said earlier:

- mremap scanning existing pte's to figure out the population would slow 
it down for no good reason
- it would be unreliable anyway:
   - example: was the area completely populated because MLOCK_ONFAULT 
was not used or because the  process faulted it already
   - example: was the area not completely populated because 
MLOCK_ONFAULT was used, or because mmap(MAP_LOCKED) failed to populate 
it fully?

I think the first point is a pointless regression for workloads that use 
just plain mlock() and don't want the onfault semantics. Unless there's 
some shortcut? Does vma have a counter of how much is populated? (I 
don't think so?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

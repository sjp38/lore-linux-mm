Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id BF7656B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:50:45 -0400 (EDT)
Received: by labia3 with SMTP id ia3so13415431lab.3
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:50:45 -0700 (PDT)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id n5si1835102lbl.45.2015.08.24.06.50.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 06:50:44 -0700 (PDT)
Received: by lalv9 with SMTP id v9so77728013lal.0
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 06:50:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55DB1C77.8070705@suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
	<1439097776-27695-4-git-send-email-emunson@akamai.com>
	<20150812115909.GA5182@dhcp22.suse.cz>
	<20150819213345.GB4536@akamai.com>
	<20150820075611.GD4780@dhcp22.suse.cz>
	<20150820170309.GA11557@akamai.com>
	<20150821072552.GF23723@dhcp22.suse.cz>
	<20150821183132.GA12835@akamai.com>
	<CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
	<55DB1C77.8070705@suse.cz>
Date: Mon, 24 Aug 2015 16:50:44 +0300
Message-ID: <CALYGNiNuZgQFzZ+_dQsPOvSJAX7QfZ38zbabn4wRc=oC5Lb9wA@mail.gmail.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Aug 24, 2015 at 4:30 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
> On 08/24/2015 12:17 PM, Konstantin Khlebnikov wrote:
>>>
>>>
>>> I am in the middle of implementing lock on fault this way, but I cannot
>>> see how we will hanlde mremap of a lock on fault region.  Say we have
>>> the following:
>>>
>>>      addr = mmap(len, MAP_ANONYMOUS, ...);
>>>      mlock(addr, len, MLOCK_ONFAULT);
>>>      ...
>>>      mremap(addr, len, 2 * len, ...)
>>>
>>> There is no way for mremap to know that the area being remapped was lock
>>> on fault so it will be locked and prefaulted by remap.  How can we avoid
>>> this without tracking per vma if it was locked with lock or lock on
>>> fault?
>>
>>
>> remap can count filled ptes and prefault only completely populated areas.
>
>
> Does (and should) mremap really prefault non-present pages? Shouldn't it
> just prepare the page tables and that's it?

As I see mremap prefaults pages when it extends mlocked area.

Also quote from manpage
: If  the memory segment specified by old_address and old_size is locked
: (using mlock(2) or similar), then this lock is maintained when the segment is
: resized and/or relocated.  As a  consequence, the amount of memory locked
: by the process may change.

>
>> There might be a problem after failed populate: remap will handle them
>> as lock on fault. In this case we can fill ptes with swap-like non-present
>> entries to remember that fact and count them as should-be-locked pages.
>
>
> I don't think we should strive to have mremap try to fix the inherent
> unreliability of mmap (MAP_POPULATE)?

I don't think so. MAP_POPULATE works only when mmap happens.
Flag MREMAP_POPULATE might be a good idea. Just for symmetry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

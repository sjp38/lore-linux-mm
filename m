Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 3DA876B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 14:53:39 -0400 (EDT)
Received: by lbbtg9 with SMTP id tg9so86235958lbb.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:53:38 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id 4si13961247laz.170.2015.08.24.11.53.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Aug 2015 11:53:37 -0700 (PDT)
Received: by lbbtg9 with SMTP id tg9so86235596lbb.1
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 11:53:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150824170028.GC17005@akamai.com>
References: <20150821072552.GF23723@dhcp22.suse.cz>
	<20150821183132.GA12835@akamai.com>
	<CALYGNiPcruTM+2KKNZr7ebCVCPsqytSrW8rSzSmj+1Qp4OqXEw@mail.gmail.com>
	<55DB1C77.8070705@suse.cz>
	<CALYGNiNuZgQFzZ+_dQsPOvSJAX7QfZ38zbabn4wRc=oC5Lb9wA@mail.gmail.com>
	<55DB29EB.1000308@suse.cz>
	<20150824150912.GA17005@akamai.com>
	<CALYGNiMO+bHCJxqC_f__iS_OgjxTWDUXF4XWVKdS4jGLenWX=g@mail.gmail.com>
	<20150824155503.GB17005@akamai.com>
	<CALYGNiPiZgac_TQVuU0907uA6G69wCmV6pBzgpa6sQ-wHLGvGQ@mail.gmail.com>
	<20150824170028.GC17005@akamai.com>
Date: Mon, 24 Aug 2015 21:53:36 +0300
Message-ID: <CALYGNiO3r9Yx7xeS-rZ_nVCR+BRP4d0-Fnd0omkBDdh1ftnExg@mail.gmail.com>
Subject: Re: [PATCH v7 3/6] mm: Introduce VM_LOCKONFAULT
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, dri-devel <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>

On Mon, Aug 24, 2015 at 8:00 PM, Eric B Munson <emunson@akamai.com> wrote:
> On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:
>
>> On Mon, Aug 24, 2015 at 6:55 PM, Eric B Munson <emunson@akamai.com> wrote:
>> > On Mon, 24 Aug 2015, Konstantin Khlebnikov wrote:
>> >
>> >> On Mon, Aug 24, 2015 at 6:09 PM, Eric B Munson <emunson@akamai.com> wrote:
>> >> > On Mon, 24 Aug 2015, Vlastimil Babka wrote:
>> >> >
>> >> >> On 08/24/2015 03:50 PM, Konstantin Khlebnikov wrote:
>> >> >> >On Mon, Aug 24, 2015 at 4:30 PM, Vlastimil Babka <vbabka@suse.cz> wrote:
>> >> >> >>On 08/24/2015 12:17 PM, Konstantin Khlebnikov wrote:
>> >> >> >>>>
>> >> >> >>>>
>> >> >> >>>>I am in the middle of implementing lock on fault this way, but I cannot
>> >> >> >>>>see how we will hanlde mremap of a lock on fault region.  Say we have
>> >> >> >>>>the following:
>> >> >> >>>>
>> >> >> >>>>      addr = mmap(len, MAP_ANONYMOUS, ...);
>> >> >> >>>>      mlock(addr, len, MLOCK_ONFAULT);
>> >> >> >>>>      ...
>> >> >> >>>>      mremap(addr, len, 2 * len, ...)
>> >> >> >>>>
>> >> >> >>>>There is no way for mremap to know that the area being remapped was lock
>> >> >> >>>>on fault so it will be locked and prefaulted by remap.  How can we avoid
>> >> >> >>>>this without tracking per vma if it was locked with lock or lock on
>> >> >> >>>>fault?
>> >> >> >>>
>> >> >> >>>
>> >> >> >>>remap can count filled ptes and prefault only completely populated areas.
>> >> >> >>
>> >> >> >>
>> >> >> >>Does (and should) mremap really prefault non-present pages? Shouldn't it
>> >> >> >>just prepare the page tables and that's it?
>> >> >> >
>> >> >> >As I see mremap prefaults pages when it extends mlocked area.
>> >> >> >
>> >> >> >Also quote from manpage
>> >> >> >: If  the memory segment specified by old_address and old_size is locked
>> >> >> >: (using mlock(2) or similar), then this lock is maintained when the segment is
>> >> >> >: resized and/or relocated.  As a  consequence, the amount of memory locked
>> >> >> >: by the process may change.
>> >> >>
>> >> >> Oh, right... Well that looks like a convincing argument for having a
>> >> >> sticky VM_LOCKONFAULT after all. Having mremap guess by scanning
>> >> >> existing pte's would slow it down, and be unreliable (was the area
>> >> >> completely populated because MLOCK_ONFAULT was not used or because
>> >> >> the process aulted it already? Was it not populated because
>> >> >> MLOCK_ONFAULT was used, or because mmap(MAP_LOCKED) failed to
>> >> >> populate it all?).
>> >> >
>> >> > Given this, I am going to stop working in v8 and leave the vma flag in
>> >> > place.
>> >> >
>> >> >>
>> >> >> The only sane alternative is to populate always for mremap() of
>> >> >> VM_LOCKED areas, and document this loss of MLOCK_ONFAULT information
>> >> >> as a limitation of mlock2(MLOCK_ONFAULT). Which might or might not
>> >> >> be enough for Eric's usecase, but it's somewhat ugly.
>> >> >>
>> >> >
>> >> > I don't think that this is the right solution, I would be really
>> >> > surprised as a user if an area I locked with MLOCK_ONFAULT was then
>> >> > fully locked and prepopulated after mremap().
>> >>
>> >> If mremap is the only problem then we can add opposite flag for it:
>> >>
>> >> "MREMAP_NOPOPULATE"
>> >> - do not populate new segment of locked areas
>> >> - do not copy normal areas if possible (anonymous/special must be copied)
>> >>
>> >> addr = mmap(len, MAP_ANONYMOUS, ...);
>> >> mlock(addr, len, MLOCK_ONFAULT);
>> >> ...
>> >> addr2 = mremap(addr, len, 2 * len, MREMAP_NOPOPULATE);
>> >> ...
>> >>
>> >
>> > But with this, the user must remember what areas are locked with
>> > MLOCK_LOCKONFAULT and which are locked the with prepopulate so the
>> > correct mremap flags can be used.
>> >
>>
>> Yep. Shouldn't be hard. You anyway have to do some changes in user-space.
>>
>
> Sorry if I wasn't clear enough in my last reply, I think forcing
> userspace to track this is the wrong choice.  The VM system is
> responsible for tracking these attributes and should continue to be.

Userspace tracks addresses and sizes of these areas. Plus mremap obviously
works only with page granularity so memory allocator in userspace have to know
a lot about these structures. So keeping one more bit isn't a rocket science.

>
>>
>> Much simpler for users-pace solution is a mm-wide flag which turns all further
>> mlocks and MAP_LOCKED into lock-on-fault. Something like
>> mlockall(MCL_NOPOPULATE_LOCKED).
>
> This set certainly adds the foundation for such a change if you think it
> would be useful.  That particular behavior was not part of my inital use
> case though.
>

This looks like much easier solution: you don't need new syscall and after
enabling that lock-on-fault mode userspace still can get old behaviour simply
by touching newly locked area.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

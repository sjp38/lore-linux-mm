Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5916B0038
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 06:54:43 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id g2so293783599pge.7
        for <linux-mm@kvack.org>; Mon, 13 Mar 2017 03:54:43 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w7si11102938pgw.107.2017.03.13.03.54.42
        for <linux-mm@kvack.org>;
        Mon, 13 Mar 2017 03:54:42 -0700 (PDT)
Date: Mon, 13 Mar 2017 10:54:33 +0000
From: Brian Starkey <brian.starkey@arm.com>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Message-ID: <20170313105433.GA12980@e106950-lin.cambridge.arm.com>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303132949.GC31582@dhcp22.suse.cz>
 <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz>
 <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
 <20170306105805.jsq44kfxhsvazkm6@sirena.org.uk>
 <20170306160437.sf7bksorlnw7u372@phenom.ffwll.local>
 <CA+M3ks77Am3Fx-ZNmgeM5tCqdM7SzV7rby4Es-p2F2aOhUco9g@mail.gmail.com>
 <26bc57ae-d88f-4ea0-d666-2c1a02bf866f@redhat.com>
 <CA+M3ks6R=n4n54wofK7pYcWoQKUhzyWQytBO90+pRDRrAhi3ww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <CA+M3ks6R=n4n54wofK7pYcWoQKUhzyWQytBO90+pRDRrAhi3ww@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Cc: Laura Abbott <labbott@redhat.com>, Mark Brown <broonie@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-arm-kernel@lists.infradead.org, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-mm@kvack.org

On Sun, Mar 12, 2017 at 02:34:14PM +0100, Benjamin Gaignard wrote:
>2017-03-09 18:38 GMT+01:00 Laura Abbott <labbott@redhat.com>:
>> On 03/09/2017 02:00 AM, Benjamin Gaignard wrote:
>>> 2017-03-06 17:04 GMT+01:00 Daniel Vetter <daniel@ffwll.ch>:
>>>> On Mon, Mar 06, 2017 at 11:58:05AM +0100, Mark Brown wrote:
>>>>> On Mon, Mar 06, 2017 at 11:40:41AM +0100, Daniel Vetter wrote:
>>>>>
>>>>>> No one gave a thing about android in upstream, so Greg KH just dumped it
>>>>>> all into staging/android/. We've discussed ION a bunch of times, recorded
>>>>>> anything we'd like to fix in staging/android/TODO, and Laura's patch
>>>>>> series here addresses a big chunk of that.
>>>>>
>>>>>> This is pretty much the same approach we (gpu folks) used to de-stage the
>>>>>> syncpt stuff.
>>>>>
>>>>> Well, there's also the fact that quite a few people have issues with the
>>>>> design (like Laurent).  It seems like a lot of them have either got more
>>>>> comfortable with it over time, or at least not managed to come up with
>>>>> any better ideas in the meantime.
>>>>
>>>> See the TODO, it has everything a really big group (look at the patch for
>>>> the full Cc: list) figured needs to be improved at LPC 2015. We don't just
>>>> merge stuff because merging stuff is fun :-)
>>>>
>>>> Laurent was even in that group ...
>>>> -Daniel
>>>
>>> For me those patches are going in the right direction.
>>>
>>> I still have few questions:
>>> - since alignment management has been remove from ion-core, should it
>>> be also removed from ioctl structure ?
>>
>> Yes, I think I'm going to go with the suggestion to fixup the ABI
>> so we don't need the compat layer and as part of that I'm also
>> dropping the align argument.
>>
>>> - can you we ride off ion_handle (at least in userland) and only
>>> export a dma-buf descriptor ?
>>
>> Yes, I think this is the right direction given we're breaking
>> everything anyway. I was debating trying to keep the two but
>> moving to only dma bufs is probably cleaner. The only reason
>> I could see for keeping the handles is running out of file
>> descriptors for dma-bufs but that seems unlikely.
>>>
>>> In the future how can we add new heaps ?
>>> Some platforms have very specific memory allocation
>>> requirements (just have a look in the number of gem custom allocator in drm)
>>> Do you plan to add heap type/mask for each ?
>>
>> Yes, that was my thinking.
>
>My concern is about the policy to adding heaps, will you accept
>"customs" heap per
>platforms ? per devices ? or only generic ones ?
>If you are too strict, we will have lot of out-of-tree heaps and if
>you accept of of them
>it will be a nightmare to maintain....
>

Are you concerned about actual heaps (e.g. a carveout at 0x80000000 vs
a carveout at 0x60000000) or heap types?

For heap types, I think the policy can be strict - if it's generally
useful then it should live in-tree in ion. Otherwise, it would be
out-of-tree. I'd expect most "custom" heaps to be parameterisable to
the point of being generally useful.

For actual heap instances, I would expect them to be communicated via
reserved-memory regions or something similar, and so the maintenance
burden is pretty low.

The existing query ioctl can allow heap IDs to get assigned
dynamically at runtime, so there's no need to reserve "bit 6" for
"CUSTOM_ACME_HEAP_1"

>Another point is how can we put secure rules (like selinux policy) on
>heaps since all the allocations
>go to the same device (/dev/ion) ? For example, until now, in Android
>we have to give the same
>access rights to all the process that use ION.
>It will become problem when we will add secure heaps because we won't
>be able to distinguish secure
>processes to standard ones or set specific policy per heaps.
>Maybe I'm wrong here but I have never see selinux policy checking an
>ioctl field but if that
>exist it could be a solution.
>

I might be thinking of a different type of "secure", but...

Should the security of secure heaps be enforced by OS-level
permissions? I don't know about other architectures, but at least on
arm/arm64 this is enforced in hardware; it doesn't matter who has
access to the ion heap, because only secure devices (or the CPU
running a secure process) is physically able to access the memory
backing the buffer.

In fact, in the use-cases I know of, the process asking for the ion
allocation is not a secure process, and so we wouldn't *want* to
restrict the secure heap to be allocated from only by secure
processes.

-Brian

>>
>>>
>>> Benjamin
>>>
>>
>> Thanks,
>> Laura
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

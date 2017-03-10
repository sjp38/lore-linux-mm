Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB3D6B0459
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 09:27:16 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id y17so166340467pgh.2
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 06:27:16 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i85si3124824pfi.35.2017.03.10.06.27.15
        for <linux-mm@kvack.org>;
        Fri, 10 Mar 2017 06:27:15 -0800 (PST)
Date: Fri, 10 Mar 2017 14:27:09 +0000
From: Brian Starkey <brian.starkey@arm.com>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of
 staging
Message-ID: <20170310142709.GB15945@e106950-lin.cambridge.arm.com>
References: <20170303132949.GC31582@dhcp22.suse.cz>
 <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz>
 <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
 <20170306105805.jsq44kfxhsvazkm6@sirena.org.uk>
 <20170306160437.sf7bksorlnw7u372@phenom.ffwll.local>
 <CA+M3ks77Am3Fx-ZNmgeM5tCqdM7SzV7rby4Es-p2F2aOhUco9g@mail.gmail.com>
 <26bc57ae-d88f-4ea0-d666-2c1a02bf866f@redhat.com>
 <20170310103112.GA15945@e106950-lin.cambridge.arm.com>
 <2e295c28-04d6-a071-cf16-164d02d679c5@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <2e295c28-04d6-a071-cf16-164d02d679c5@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robin Murphy <robin.murphy@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, devel@driverdev.osuosl.org, Rom Lemarchand <romlem@google.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Riley Andrews <riandrews@android.com>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Michal Hocko <mhocko@kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, linux-mm@kvack.org, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, Mark Brown <broonie@kernel.org>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Daniel Vetter <daniel.vetter@intel.com>, Sumit Semwal <sumit.semwal@linaro.org>, linux-arm-kernel@lists.infradead.org, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>

On Fri, Mar 10, 2017 at 11:46:42AM +0000, Robin Murphy wrote:
>On 10/03/17 10:31, Brian Starkey wrote:
>> Hi,
>>
>> On Thu, Mar 09, 2017 at 09:38:49AM -0800, Laura Abbott wrote:
>>> On 03/09/2017 02:00 AM, Benjamin Gaignard wrote:
>>
>> [snip]
>>
>>>>
>>>> For me those patches are going in the right direction.
>>>>
>>>> I still have few questions:
>>>> - since alignment management has been remove from ion-core, should it
>>>> be also removed from ioctl structure ?
>>>
>>> Yes, I think I'm going to go with the suggestion to fixup the ABI
>>> so we don't need the compat layer and as part of that I'm also
>>> dropping the align argument.
>>>
>>
>> Is the only motivation for removing the alignment parameter that
>> no-one got around to using it for something useful yet?
>> The original comment was true - different devices do have different
>> alignment requirements.
>>
>> Better alignment can help SMMUs use larger blocks when mapping,
>> reducing TLB pressure and the chance of a page table walk causing
>> display underruns.
>
>For that use-case, though, alignment alone doesn't necessarily help -
>you need the whole allocation granularity to match your block size (i.e.
>given a 1MB block size, asking for 17KB and getting back 17KB starting
>at a 1MB boundary doesn't help much - that whole 1MB needs to be
>allocated and everyone needs to know it to ensure that the whole lot can
>be mapped safely). Now, whether it's down to the callers or the heap
>implementations to decide and enforce that granularity is another
>question, but provided allocations are at least naturally aligned to
>whatever the granularity is (which is a reasonable assumption to bake
>in) then it's all good.
>
>Robin.

Agreed, alignment alone isn't enough. But lets assume that an app
knows what a "good" granularity is, and always asks for allocation
sizes which are suitably rounded to allow blocks to be used. Currently
it looks like a "standard" ION_HEAP_TYPE_CARVEOUT heap would give me
back just a PAGE_SIZE aligned buffer. So even *if* the caller knows
its desired block size, there's no way for it to get guaranteed better
alignment, which wouldn't be a bad feature to have.

Anyway as Daniel and Rob say, if the interface is designed properly
this kind of extension would be possible later, or you can have a
special heap with a larger granule.

I suppose it makes sense to remove it while there's no-one actually
implementing it, in case an alternate method proves more usable.

-Brian

>
>>
>> -Brian
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

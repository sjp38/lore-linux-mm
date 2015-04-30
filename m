Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id CEFB06B0032
	for <linux-mm@kvack.org>; Thu, 30 Apr 2015 05:50:59 -0400 (EDT)
Received: by lbbqq2 with SMTP id qq2so40203830lbb.3
        for <linux-mm@kvack.org>; Thu, 30 Apr 2015 02:50:59 -0700 (PDT)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id xa2si1358993lbb.156.2015.04.30.02.50.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Apr 2015 02:50:57 -0700 (PDT)
Message-ID: <5541FAF3.4080008@parallels.com>
Date: Thu, 30 Apr 2015 12:50:43 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] uffd: Introduce the v2 API
References: <5509D342.7000403@parallels.com> <5509D375.7000809@parallels.com> <20150421121817.GD4481@redhat.com> <55389133.8070701@parallels.com> <20150427211236.GB24035@redhat.com>
In-Reply-To: <20150427211236.GB24035@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux API <linux-api@vger.kernel.org>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>

On 04/28/2015 12:12 AM, Andrea Arcangeli wrote:
> Hello,
> 
> On Thu, Apr 23, 2015 at 09:29:07AM +0300, Pavel Emelyanov wrote:
>> So your proposal is to always report 16 bytes per PF from read() and
>> let userspace decide itself how to handle the result?
> 
> Reading 16bytes for each userfault (instead of 8) and sharing the same
> read(2) protocol (UFFD_API) for both the cooperative and
> non-cooperative usages, is something I just suggested for
> consideration after reading your patchset.
> 
> The pros of using a single protocol for both is that it would reduce
> amount of code and there would be just one file operation for the
> .read method. The cons is that it will waste 8 bytes per userfault in
> terms of memory footprint. The other major cons is that it would force
> us to define the format of the non cooperative protocol now despite it's
> not fully finished yet.
> 
> I'm also ok with two protocols if nobody else objects, but if we use
> two protocols, we should at least use different file operation methods
> and use __always_inline with constants passed as parameter to optimize
> away the branches at build time. This way we get the reduced memory
> footprint in the read syscall without other runtime overhead
> associated with it.

OK. I would go with two protocols then and will reshuffle the code to
use two ops.

>>>> +struct uffd_v2_msg {
>>>> +	__u64	type;
>>>> +	__u64	arg;
>>>> +};
>>>> +
>>>> +#define UFFD_PAGEFAULT	0x1
>>>> +
>>>> +#define UFFD_PAGEFAULT_BIT	(1 << (UFFD_PAGEFAULT - 1))
>>>> +#define __UFFD_API_V2_BITS	(UFFD_PAGEFAULT_BIT)
>>>> +
>>>> +/*
>>>> + * Lower PAGE_SHIFT bits are used to report those supported
>>>> + * by the pagefault message itself. Other bits are used to
>>>> + * report the message types v2 API supports
>>>> + */
>>>> +#define UFFD_API_V2_BITS	(__UFFD_API_V2_BITS << 12)
>>>> +
>>>
>>> And why exactly is this 12 hardcoded?
>>
>> Ah, it should have been the PAGE_SHIFT one, but I was unsure whether it
>> would be OK to have different shifts in different arches.
>>
>> But taking into account your comment that bits field id bad for these
>> values, if we introduce the new .features one for api message, then this
>> 12 will just go away.
> 
> Ok.
> 
>>> And which field should be masked
>>> with the bits? In the V1 protocol it was the "arg" (userfault address)
>>> not the "type". So this is a bit confusing and probably requires
>>> simplification.
>>
>> I see. Actually I decided that since bits higher than 12th (for x86) is
>> always 0 in api message (no bits allowed there, since pfn sits in this
>> place), it would be OK to put non-PF bits there.
> 
> That was ok yes.
> 
>> Should I better introduce another .features field in uffd API message?
> 
> What about renaming "uffdio_api.bits" to "uffdio_api.features"?

Yup, agreed, will do.

> And then we set uffdio_api.features to
> UFFD_FEATURE_WRITE|UFFD_FEATURE_WP|UFFD_FEATURE_FORK as needed.
> 
> UFFD_FEATURE_WRITE would always be enabled, it's there only in case we
> want to disable it later (mostly if some arch has trouble with it,
> which is unlikely, but qemu doesn't need that bit of information at
> all for example so qemu would be fine if UFFD_FEATURE_WRITE
> disappears).
> 
> UFFD_FEATURE_WP would signal also that the wrprotection feature (not
> implemented yet) is available (then later the register ioctl would
> also show the new wrprotection ioctl numbers available to mangle the
> wrprotection). The UFFD_FEATURE_WP feature in the cooperative usage
> (qemu live snapshotting) can use the UFFD_API first protocol too.
> 
> UFFD_FEATURE_FORK would be returned if the UFFD_API_V2 was set in
> uffdio.api, and it would be part of the incremental non-cooperative
> patchset.
> 
> We could also not define "UFFD_FEATURE_FORK" at all and imply that
> fork/mremap/MADV_DONTNEED are all available if UFFD_API_V2 uffdio_api
> ioctl succeeds... That's only doable if we keep two different read
> protocols though. UFFD_FEATURE_FORK (or UFFD_FEATURE_NON_COOPERATIVE)
> are really strictly needed only if we share the same read(2) protocol
> for both the cooperative and non-cooperative usages.
> 
> The idea is that there's not huge benefit of only having the "fork"
> feature supported but missing "mremap" and "madv_dontneed".
> 
> In fact if a new syscall that works like mremap is added later (call
> it mremap2), we would need to fail the UFFDIO_API_V2 and require a
> UFFDIO_API_V3 for such kernel that can return a new mremap2 type of
> event. Userland couldn't just assume it is ok to use postcopy live
> migration for containers, because
> UFFD_FEATURE_FORK|MREMAP|MADV_DONTNEED are present in the
> uffdio.features when it asked for API_V2. There shall be something
> that tells userland "hey there's a new mremap2 that the software
> inside the container can run on top of this kernel, so you are going
> to get a new mremap2 type of userfault event too".

But that's why I assumed to use per-sycall bits -- UFFD_FEATURE_FORK,
_MREMAP, _MWHATEVER so that userspace can read those bits and make sure
it contains only bits it understands with other bits set to zero.

If we had only one UFFD_API_NON_COOPERATIVE userspace would have no idea
what kind of messages it may receive.

> In any case, regardless of how we solve the above,
> "uffdio_api.features" sounds better than ".bits".
> 
> If we retain two different UFFD_API, we'll be able to freeze the
> current one and decide later if
> UFFD_FEATURE_FORK|UFFD_FEATURE_MREMAP|UFFD_FEATURE_MADV_DONTNEED shall
> be added to the .features, or if to rely on UFFD_API_V2 succeeding to
> let userland know that the non-cooperative usage is fully supported by
> the kernel.
> 
> Not having to freeze these details now is the main benefit of having
> two different UFFD_API after all...
> .
> 

-- Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0958E2808AC
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 08:56:35 -0500 (EST)
Received: by mail-qk0-f199.google.com with SMTP id 9so182713812qkk.6
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:56:35 -0800 (PST)
Received: from mail-yw0-x242.google.com (mail-yw0-x242.google.com. [2607:f8b0:4002:c05::242])
        by mx.google.com with ESMTPS id l9si1819615ywb.461.2017.03.10.05.56.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 10 Mar 2017 05:56:33 -0800 (PST)
Received: by mail-yw0-x242.google.com with SMTP id 2so3452672ywn.3
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:56:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170310124043.45hdu64wd4acf4it@phenom.ffwll.local>
References: <1488491084-17252-1-git-send-email-labbott@redhat.com>
 <20170303132949.GC31582@dhcp22.suse.cz> <cf383b9b-3cbc-0092-a071-f120874c053c@redhat.com>
 <20170306074258.GA27953@dhcp22.suse.cz> <20170306104041.zghsicrnadoap7lp@phenom.ffwll.local>
 <20170306105805.jsq44kfxhsvazkm6@sirena.org.uk> <20170306160437.sf7bksorlnw7u372@phenom.ffwll.local>
 <CA+M3ks77Am3Fx-ZNmgeM5tCqdM7SzV7rby4Es-p2F2aOhUco9g@mail.gmail.com>
 <26bc57ae-d88f-4ea0-d666-2c1a02bf866f@redhat.com> <20170310103112.GA15945@e106950-lin.cambridge.arm.com>
 <20170310124043.45hdu64wd4acf4it@phenom.ffwll.local>
From: Rob Clark <robdclark@gmail.com>
Date: Fri, 10 Mar 2017 08:56:32 -0500
Message-ID: <CAF6AEGtTicaJnApMSrmdQnriQd_rwQBW4H8rH+Xe9evkwZy8eg@mail.gmail.com>
Subject: Re: [RFC PATCH 00/12] Ion cleanup in preparation for moving out of staging
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Starkey <brian.starkey@arm.com>, Laura Abbott <labbott@redhat.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Mark Brown <broonie@kernel.org>, Michal Hocko <mhocko@kernel.org>, Sumit Semwal <sumit.semwal@linaro.org>, Riley Andrews <riandrews@android.com>, =?UTF-8?B?QXJ2ZSBIasO4bm5ldsOlZw==?= <arve@android.com>, Rom Lemarchand <romlem@google.com>, devel@driverdev.osuosl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, "linaro-mm-sig@lists.linaro.org" <linaro-mm-sig@lists.linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, Daniel Vetter <daniel.vetter@intel.com>, linux-mm <linux-mm@kvack.org>

On Fri, Mar 10, 2017 at 7:40 AM, Daniel Vetter <daniel@ffwll.ch> wrote:
> On Fri, Mar 10, 2017 at 10:31:13AM +0000, Brian Starkey wrote:
>> Hi,
>>
>> On Thu, Mar 09, 2017 at 09:38:49AM -0800, Laura Abbott wrote:
>> > On 03/09/2017 02:00 AM, Benjamin Gaignard wrote:
>>
>> [snip]
>>
>> > >
>> > > For me those patches are going in the right direction.
>> > >
>> > > I still have few questions:
>> > > - since alignment management has been remove from ion-core, should it
>> > > be also removed from ioctl structure ?
>> >
>> > Yes, I think I'm going to go with the suggestion to fixup the ABI
>> > so we don't need the compat layer and as part of that I'm also
>> > dropping the align argument.
>> >
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
> Extending ioctl uapi is easy, trying to get rid of bad uapi is much
> harder. Given that right now we don't have an ion allocator that does
> alignment I think removing it makes sense. And if we go with lots of
> heaps, we might as well have an ion heap per alignment that your hw needs,
> so there's different ways to implement this in the future.

slight correction:  if you plan ahead (and do things like zero init if
userspace passes in a smaller ioctl struct like drm_ioctl does),
extending ioctl uapi is easy.. might be something worth fixing from
the get-go..

BR,
-R

> At least from the unix device memory allocator pov it's probably simpler
> to encode stuff like this into the heap name, instead of having to pass
> heap + list of additional properties/constraints.
> -Daniel
> --
> Daniel Vetter
> Software Engineer, Intel Corporation
> http://blog.ffwll.ch
> _______________________________________________
> dri-devel mailing list
> dri-devel@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/dri-devel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

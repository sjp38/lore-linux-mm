Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 156F56B0253
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 06:07:39 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l66so158074026wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:07:39 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id j139si29683798wmg.65.2016.02.03.03.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 03:07:38 -0800 (PST)
Received: by mail-wm0-x229.google.com with SMTP id l66so158073433wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:07:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAFCwf10tLwQiZ0ROeuf2FHcWa9iTBwJ-0X_WWfU8tjTSvGH_0w@mail.gmail.com>
References: <20160128175536.GA20797@gmail.com> <1454460057.4788.117.camel@infradead.org>
 <CAFCwf11mtbOKJkde74g06ud7qpEckBFs3Ov3fYPyzt96rMgRmg@mail.gmail.com>
 <1454488853.4788.142.camel@infradead.org> <CAFCwf13VCoJvWbmxa7mZByseHc97VGzYZvi0zv6ww8_7hqF7Gw@mail.gmail.com>
 <1454494508.4788.154.camel@infradead.org> <CAFCwf10tLwQiZ0ROeuf2FHcWa9iTBwJ-0X_WWfU8tjTSvGH_0w@mail.gmail.com>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Wed, 3 Feb 2016 13:07:07 +0200
Message-ID: <CAFCwf12U2iQS2xUoRx4W7cVQJOcso+QK2_PdYYD-k_J1V8KJsQ@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>

On Wed, Feb 3, 2016 at 1:01 PM, Oded Gabbay <oded.gabbay@gmail.com> wrote:
> On Wed, Feb 3, 2016 at 12:15 PM, David Woodhouse <dwmw2@infradead.org> wr=
ote:
>> On Wed, 2016-02-03 at 11:21 +0200, Oded Gabbay wrote:
>>
>>> OK, so I think I got confused up a little, but looking at your code I
>>> see that you register SVM for the mm notifier (intel_mm_release),
>>> therefore I guess what you meant to say you don't want to call a
>>> device driver callback from your mm notifier callback, correct ? (like
>>> the amd_iommu_v2 does when it calls ev_state->inv_ctx_cb inside its
>>> mn_release)
>>
>> Right.
>>
>>> Because you can't really control what the device driver will do, i.e.
>>> if it decides to register itself to the mm notifier in its own code.
>>
>> Right. I can't *prevent* them from doing it. But I don't need to
>> encourage or facilitate it :)
>>
>>> And because you don't call the device driver, the driver can/will get
>>> errors for using this PASID (since you unbinded it) and the device
>>> driver is supposed to handle it. Did I understood that correctly ?
>>
>> In the case of an unclean exit, yes. In an orderly shutdown of the
>> process, one would hope that the device context is relinquished cleanly
>> rather than the process simply exiting.
>>
>> And yes, the device and its driver are expected to handle faults. If
>> they don't do that, they are broken :)
>>
>>> If I understood it correctly, doesn't it confuses between error/fault
>>> and normal unbinding ? Won't it be better to actively notify them and
>>> indeed *wait* until the device driver cleared its H/W pipeline before
>>> "pulling the carpet under their feet" ?
>>>
>>> In our case (AMD GPUs), if we have such an error it could make the GPU
>>> stuck. That's why we even reset the wavefronts inside the GPU, if we
>>> can't gracefully remove the work from the GPU (see
>>> kfd_unbind_process_from_device)
>>
>> But a rogue process can easily trigger faults =E2=80=94 just request acc=
ess to
>> an address that doesn't exist. My conversation with the hardware
>> designers was not about the peculiarities of any specific
>> implementation, but just getting them to confirm my assertion that if a
>> device *doesn't* cleanly handle faults on *one* PASID without screwing
>> over all the *other* PASIDs, then it is utterly broken by design and
>> should never get to production.
>
> Yes, that is agreed, address errors should not affect the H/W itself,
> nor other processes.
>
>>
>> I *do* anticipate broken hardware which will crap itself completely
>> when it takes a fault, and have implemented a callback from the fault
>> handler so that the driver gets notified when a fault *happens* (even
>> on a PASID which is still alive), and can prod the broken hardware if
>> it needs to.
>>
>> But I wasn't expecting it to be the norm.
>>
> Yeah, I guess that after a few H/W iterations the "correct"
> implementation will be the norm.
>
>>> In the patch's comment you wrote:
>>> "Hardware designers have confirmed that the resulting 'PASID not presen=
t'
>>> faults should be handled just as gracefully as 'page not present' fault=
s"
>>>
>>> Unless *all* the H/W that is going to use SVM is designed by the same
>>> company, I don't think we can say such a thing. And even then, from my
>>> experience, H/W designers can be "creative" sometimes.
>>
>> If we have to turn it into a 'page not present' fault instead of a
>> 'PASID not present' fault, that's easy enough to do by pointing it at a
>> dummy PML4 (the zero page will do).
>>
>> But I stand by my assertion that any hardware which doesn't handle at
>> least a 'page not present' fault in a given PASID without screwing over
>> all the other users of the hardware is BROKEN.
>
> Totally agreed!
>
>>
>> We could *almost* forgive hardware for stalling when it sees a 'PASID
>> not present' fault. Since that *does* require OS participation.
>>
>> --
>> David Woodhouse                            Open Source Technology Centre
>> David.Woodhouse@intel.com                              Intel Corporation
>>
>
> Another, perhaps trivial, question.
> When there is an address fault, who handles it ? the SVM driver, or
> each device driver ?
>
> In other words, is the model the same as (AMD) IOMMU where it binds
> amd_iommu driver to the IOMMU H/W, and that driver (amd_iommu/v2) is
> the only one which handles the PPR events ?
>
> If that is the case, then with SVM, how will the device driver be made
> aware of faults, if the SVM driver won't notify him about them,
> because it has already severed the connection between PASID and
> process ?
>
> If the model is that each device driver gets a direct fault
> notification (via interrupt or some other way) then that is a
> different story.
>
> Oded

And another question, if I may, aren't you afraid of "false positive"
prints to dmesg ? I mean, I'm pretty sure page faults / pasid faults
errors will be logged somewhere, probably to dmesg. Aren't you
concerned of the users seeing those errors and thinking they may have
a bug, while actually the errors were only caused by process
termination ?

Or in that case you say that the application is broken, because if it
still had something running in the H/W, it should not have closed
itself ?

I can accept that, I just want to know what is our answer when people
will start to complain :)

Thanks,

     Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

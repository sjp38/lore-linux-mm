Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 050B66B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 04:21:40 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id l66so60414887wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 01:21:39 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id ju2si8605131wjb.192.2016.02.03.01.21.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 01:21:38 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id l66so153900200wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 01:21:38 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454488853.4788.142.camel@infradead.org>
References: <20160128175536.GA20797@gmail.com> <1454460057.4788.117.camel@infradead.org>
 <CAFCwf11mtbOKJkde74g06ud7qpEckBFs3Ov3fYPyzt96rMgRmg@mail.gmail.com> <1454488853.4788.142.camel@infradead.org>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Wed, 3 Feb 2016 11:21:08 +0200
Message-ID: <CAFCwf13VCoJvWbmxa7mZByseHc97VGzYZvi0zv6ww8_7hqF7Gw@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>

On Wed, Feb 3, 2016 at 10:40 AM, David Woodhouse <dwmw2@infradead.org> wrot=
e:
> On Wed, 2016-02-03 at 10:13 +0200, Oded Gabbay wrote:
>>
>> > So on process exit, the MM doesn't die because the PASID binding still
>> > exists. The VMA of the mmap doesn't die because the MM still exists. S=
o
>> > the underlying file remains open because the VMA still exists. And the
>> > PASID binding thus doesn't die because the file is still open.
>> >
>> Why connect the PASID to the FD in the first place ?
>> Why not tie everything to the MM ?
>
> That's actually a question for the device driver in question, of
> course; it's not the generic SVM support code which chooses *when* to
> bind/unbind PASIDs. We just provide those functions for the driver to
> call.
>
> But the answer is that that's the normal resource tracking model.
> Resources hang off the file and are cleared up when the file is closed.
>
> (And exit_files() is called later than exit_mm()).
>
>> > I've posted a patch=C2=B9 which moves us closer to the amd_iommu_v2 mo=
del,
>> > although I'm still *strongly* resisting the temptation to call out int=
o
>> > device driver code from the mmu_notifier's release callback.
>>
>> You mean you are resisting doing this (taken from amdkfd):
>>
>> --------------
>> static const struct mmu_notifier_ops kfd_process_mmu_notifier_ops =3D {
>> .release =3D kfd_process_notifier_release,
>> };
>>
>> process->mmu_notifier.ops =3D &kfd_process_mmu_notifier_ops;
>> -----------
>>
>> Why, if I may ask ?
>
> The KISS principle, especially as it relates to device drivers.
> We just Do Not Want random device drivers being called in that context.
>
> It's OK for amdkfd where you have sufficient clue to deal with it =E2=80=
=94
> it's more than "just a device driver".
>
> But when we get discrete devices with PASID support (and the required
> TLP prefix support in our root ports at last!) we're going to see SVM
> supported in many more device drivers, and we should make it simple.
>
> Having the mmu_notifier release callback exposed to drivers is going to
> strongly encourage them to do the WRONG thing, because they need to
> interact with their hardware and *wait* for the PASID to be entirely
> retired through the pipeline before they tell the IOMMU to flush it.
>
> The patch at http://www.spinics.net/lists/linux-mm/msg100230.html
> addresses this by clearing the PASID from the PASID table (in core
> IOMMU code) when the process exits so that all subsequent accesses to
> that PASID then take faults. The device driver can then clean up its
> binding for that PASID in its own time.

OK, so I think I got confused up a little, but looking at your code I
see that you register SVM for the mm notifier (intel_mm_release),
therefore I guess what you meant to say you don't want to call a
device driver callback from your mm notifier callback, correct ? (like
the amd_iommu_v2 does when it calls ev_state->inv_ctx_cb inside its
mn_release)

Because you can't really control what the device driver will do, i.e.
if it decides to register itself to the mm notifier in its own code.

And because you don't call the device driver, the driver can/will get
errors for using this PASID (since you unbinded it) and the device
driver is supposed to handle it. Did I understood that correctly ?

If I understood it correctly, doesn't it confuses between error/fault
and normal unbinding ? Won't it be better to actively notify them and
indeed *wait* until the device driver cleared its H/W pipeline before
"pulling the carpet under their feet" ?

In our case (AMD GPUs), if we have such an error it could make the GPU
stuck. That's why we even reset the wavefronts inside the GPU, if we
can't gracefully remove the work from the GPU (see
kfd_unbind_process_from_device)

In the patch's comment you wrote:
"Hardware designers have confirmed that the resulting 'PASID not present'
faults should be handled just as gracefully as 'page not present' faults"

Unless *all* the H/W that is going to use SVM is designed by the same
company, I don't think we can say such a thing. And even then, from my
experience, H/W designers can be "creative" sometimes.

Just my 2 cents.

    Oded

>
> It is a fairly fundamental rule that faulting access to *one* PASID
> should not adversely affect behaviour for *other* PASIDs, of course.
>
> --
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

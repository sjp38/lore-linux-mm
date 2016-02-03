Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3142E6B0005
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 03:13:38 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id l66so151402294wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 00:13:38 -0800 (PST)
Received: from mail-wm0-x22e.google.com (mail-wm0-x22e.google.com. [2a00:1450:400c:c09::22e])
        by mx.google.com with ESMTPS id y190si28797097wme.93.2016.02.03.00.13.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 00:13:37 -0800 (PST)
Received: by mail-wm0-x22e.google.com with SMTP id 128so152997813wmz.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 00:13:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454460057.4788.117.camel@infradead.org>
References: <20160128175536.GA20797@gmail.com> <1454460057.4788.117.camel@infradead.org>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Wed, 3 Feb 2016 10:13:07 +0200
Message-ID: <CAFCwf11mtbOKJkde74g06ud7qpEckBFs3Ov3fYPyzt96rMgRmg@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>

On Wed, Feb 3, 2016 at 2:40 AM, David Woodhouse <dwmw2@infradead.org> wrote=
:
> On Thu, 2016-01-28 at 18:55 +0100, Jerome Glisse wrote:
>>
>> I would like to attend LSF/MM this year to discuss about HMM
>> (Heterogeneous Memory Manager) and more generaly all topics
>> related to GPU and heterogeneous memory architecture (including
>> persistent memory).
>>
>> I want to discuss how to move forward with HMM merging and i
>> hope that by MM summit time i will be able to share more
>> informations publicly on devices which rely on HMM.
>
> There are a few related issues here around Shared Virtual Memory, and
> lifetime management of the associated MM, and the proposal discussed at
> the Kernel Summit for "off-CPU tasks".
>
> I've hit a situation with the Intel SVM code in 4.4 where the device
> driver binds a PASID, and also has mmap() functionality on the same
> file descriptor that the PASID is associated with.
>
> So on process exit, the MM doesn't die because the PASID binding still
> exists. The VMA of the mmap doesn't die because the MM still exists. So
> the underlying file remains open because the VMA still exists. And the
> PASID binding thus doesn't die because the file is still open.
>
Why connect the PASID to the FD in the first place ?
Why not tie everything to the MM ?

> I've posted a patch=C2=B9 which moves us closer to the amd_iommu_v2 model=
,
> although I'm still *strongly* resisting the temptation to call out into
> device driver code from the mmu_notifier's release callback.

You mean you are resisting doing this (taken from amdkfd):

--------------
static const struct mmu_notifier_ops kfd_process_mmu_notifier_ops =3D {
.release =3D kfd_process_notifier_release,
};

process->mmu_notifier.ops =3D &kfd_process_mmu_notifier_ops;
-----------

Why, if I may ask ?

Oded
>
> I would like to attend LSF/MM this year so we can continue to work on
> those issues =E2=80=94 now that we actually have some hardware in the fie=
ld and
> a better idea of how we can build a unified access model for SVM across
> the different IOMMU types.
>
> --
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
>
>
> =C2=B9 http://www.spinics.net/lists/linux-mm/msg100230.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

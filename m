Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 048746B0009
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 06:42:24 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l66so66020091wml.0
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:42:23 -0800 (PST)
Received: from mail-wm0-x233.google.com (mail-wm0-x233.google.com. [2a00:1450:400c:c09::233])
        by mx.google.com with ESMTPS id p192si10483458wmd.30.2016.02.03.03.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 03:42:23 -0800 (PST)
Received: by mail-wm0-x233.google.com with SMTP id p63so160848892wmp.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 03:42:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1454499350.4788.170.camel@infradead.org>
References: <20160128175536.GA20797@gmail.com> <1454460057.4788.117.camel@infradead.org>
 <CAFCwf11mtbOKJkde74g06ud7qpEckBFs3Ov3fYPyzt96rMgRmg@mail.gmail.com>
 <1454488853.4788.142.camel@infradead.org> <CAFCwf13VCoJvWbmxa7mZByseHc97VGzYZvi0zv6ww8_7hqF7Gw@mail.gmail.com>
 <1454494508.4788.154.camel@infradead.org> <CAFCwf10tLwQiZ0ROeuf2FHcWa9iTBwJ-0X_WWfU8tjTSvGH_0w@mail.gmail.com>
 <CAFCwf12U2iQS2xUoRx4W7cVQJOcso+QK2_PdYYD-k_J1V8KJsQ@mail.gmail.com> <1454499350.4788.170.camel@infradead.org>
From: Oded Gabbay <oded.gabbay@gmail.com>
Date: Wed, 3 Feb 2016 13:41:53 +0200
Message-ID: <CAFCwf12hkEzLbdop760Vuc6t-J71Vb2pu=y-8GPYLPFoguFRbw@mail.gmail.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Woodhouse <dwmw2@infradead.org>
Cc: Jerome Glisse <j.glisse@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Joerg Roedel <joro@8bytes.org>

On Wed, Feb 3, 2016 at 1:35 PM, David Woodhouse <dwmw2@infradead.org> wrote=
:
> On Wed, 2016-02-03 at 13:07 +0200, Oded Gabbay wrote:
>> > Another, perhaps trivial, question.
>> > When there is an address fault, who handles it ? the SVM driver, or
>> > each device driver ?
>> >
>> > In other words, is the model the same as (AMD) IOMMU where it binds
>> > amd_iommu driver to the IOMMU H/W, and that driver (amd_iommu/v2) is
>> > the only one which handles the PPR events ?
>> >
>> > If that is the case, then with SVM, how will the device driver be made
>> > aware of faults, if the SVM driver won't notify him about them,
>> > because it has already severed the connection between PASID and
>> > process ?
>
> In the ideal case, there's no need for the device driver to get
> involved at all. When a page isn't found in the page tables, the IOMMU
> code calls handle_mm_fault() and either populates the page and sends a
> a 'success' response, or sends an 'invalid fault' response back.
>
> To account for broken hardware, we *have* added a callback into the
> device driver when these faults happen. Ideally it should never be
> used, of course.
>
> In the case where the process has gone away, the PASID is still
> assigned and we still hold mm_count on the MM, just not mm_users. This
> callback into the device driver still occurs if a fault happens during
> process exit between the exit_mm() and exit_files() stage.
>
>> And another question, if I may, aren't you afraid of "false positive"
>> prints to dmesg ? I mean, I'm pretty sure page faults / pasid faults
>> errors will be logged somewhere, probably to dmesg. Aren't you
>> concerned of the users seeing those errors and thinking they may have
>> a bug, while actually the errors were only caused by process
>> termination ?
>
> If that's the case, it's easy enough to silence them. We are already
> explicitly testing for the 'defunct mm' case in our fault handler, to
> prevent us from faulting more pages into an obsolescent MM after its
> mm_users reaches zero and its page tables are supposed to have been
> torn down. That's the 'if(!atomic_inc_not_zere(&svm->mm->mm_users))
> goto bad_req;' part.
>
>> Or in that case you say that the application is broken, because if it
>> still had something running in the H/W, it should not have closed
>> itself ?
>
> That's also true but it's still nice to avoid confusion. Even if only
> to disambiguate cause and effect =E2=80=94 we don't want people to see PA=
SID
> faults which were caused by the process crashing, and to think that
> they might be involved in *causing* that process to crash...

Yes, that's why in our model, we aim to kill all running waves
*before* the amd_iommu_v2 driver unbinds the PASID.

>
> --
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
>


It seems you have most of your bases covered. I'll stop harassing you now :=
)
But in seriousness, its interesting to see the different approaches
taken to handling pretty much the same type of H/W (IOMMU).

Thanks for your patience in answering my questions.

Oded

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

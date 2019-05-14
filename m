Return-Path: <SRS0=IoHm=TO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-12.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4FC3C04AB4
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:58:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6609C20873
	for <linux-mm@archiver.kernel.org>; Tue, 14 May 2019 21:58:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ecKhJl+i"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6609C20873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3173D6B0005; Tue, 14 May 2019 17:58:38 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C7E16B0006; Tue, 14 May 2019 17:58:38 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1B6696B0007; Tue, 14 May 2019 17:58:38 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id C59846B0005
	for <linux-mm@kvack.org>; Tue, 14 May 2019 17:58:37 -0400 (EDT)
Received: by mail-wr1-f71.google.com with SMTP id z13so208460wrn.14
        for <linux-mm@kvack.org>; Tue, 14 May 2019 14:58:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=9NVmY87YsNl5Doqv7XNGQ+SPMJOyZIesPiDpVpf5DtQ=;
        b=Ld0NYuPHFHIVSOUa1cphgMnknhaBDqCgiwL/7FmmrDIoh+5JSBS7tjwtxgi80YFQrO
         dMyC3bzBXMLnl9K1hCTbT1md+NDHu5myxkixdl36whhWC/JYvxN6o+emK46wL6svxVFp
         p02oAM+zedlV+9eCvXPWFxLYPTMzXpKqqwavDP8O4d5cK/dZzKkmw1re/5kenyrXffzo
         2f10X4jj5hSF2bpZLzuvEBr++OWCAXRtyCNukPICMG9XWwOxI9iZgXfrFszXFedVijBS
         bsxs4jYLCy6XCgzkLkSt8QA7TuWafLXZK3bvmFjZEM/ozw3jYI9+ZRIGPDxyeqOqJsIc
         1mdw==
X-Gm-Message-State: APjAAAVxKzfSpY8zAXvpDyGK7aahH4Yd+xOv5vTLee6eVtDe7lgAHVf0
	j85Yet5lAvvNGkb5cOM/NcIrNKrfYWQOKqoiBpgu2lNrAfEgrukOEq9rjnakHTl0qXLbYuL8reO
	f5kb3Of837CDf1lD1lEDIIdVK47oQsjacK9C4SxAxYZq6Ponk4qN6n6pKYMxTZZYWcw==
X-Received: by 2002:a1c:730c:: with SMTP id d12mr2179963wmb.47.1557871117242;
        Tue, 14 May 2019 14:58:37 -0700 (PDT)
X-Received: by 2002:a1c:730c:: with SMTP id d12mr2179940wmb.47.1557871116236;
        Tue, 14 May 2019 14:58:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557871116; cv=none;
        d=google.com; s=arc-20160816;
        b=0nFZW6zKO0+k+C1+l+pUae4stJePBS070wo/ORHgOByJL9+/hRnfRAlzXrlKHba2Ij
         FV7rM18YmDOa/V/OGTr68yI+BDMI9Q07SsROYf6NWn7MdGCUkAKC/eg1W7cimAuRNYek
         z1G94KhT4TuUTt4Ln13xBSPhSBxLVzc8SfX7iYyzPX4rGvxdK9J9+BLQuy+HUpnf5dOS
         xyPTXtce4CA2cay1l8vlVBumuhZXuhG6TYMOIZh/zUGD0qn7knpBPG/u7yJq9IjwvzAQ
         /ZuzGKXu0/iAP1g3wk52QH3iecnG68QOnBtWf0DMX0yX3lv7G2KgrMDJWz7tTm14fctC
         cUaw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=9NVmY87YsNl5Doqv7XNGQ+SPMJOyZIesPiDpVpf5DtQ=;
        b=Z4htSSRhLWqsSygNqHzW/tULZrHfTlNJmpDIArJ2h17tBuFmlHkEtzuY6nYYhku8Iz
         OGD7W1coOmmdKeLyrfSPcUKn2Ftgmol0IF1i9XoAb8jiCoKMhdnoy6jQKgzld7veJc6o
         FyTCNjZZmXzhsfmDwprz+sHdZhhb6pXTHq3j1gti0M4SGzbKUYlKNrAZrBzLvWw+crqB
         LZ2OiidSHn/EgIR51P7S6SGeRVZek3D2fNLAWrRNUyQc/kMnOF6BjXLpgN15iqFY4Gym
         bb+HBvOlLwgz/E7W+YE9QDBmL+VVotxOEk8dS1UqIAO11hTFzc0j+o9ngyiqgMsqQprA
         gTzQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ecKhJl+i;
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16sor39076wru.40.2019.05.14.14.58.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 14 May 2019 14:58:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ecKhJl+i;
       spf=pass (google.com: domain of alexdeucher@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexdeucher@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=9NVmY87YsNl5Doqv7XNGQ+SPMJOyZIesPiDpVpf5DtQ=;
        b=ecKhJl+imSaJo+zZms2mo6MckmfFL+/QNhjARw87RGRa/NK8KMH8shTz+qNgdpWZjv
         jhQA1BpOZ8djGF6ar2lVXqWnfYvMOVvRG/sCDTwFp7NxDVvEIrYl3YBD6eiEo2CVot0X
         C/Np9tZee7Ak7pc7FTtRBvM66mqbRpaMAAbzb5Umq2R1DcfEvxoDBIcU247owR9kr4Dz
         h1GrPo2vZy0MEf0P6mzDTozqzIoyv5IiL4TaqplHH5XT3FruVZ/Geh1wUsSt343Cyhzp
         izveqb2mRpa/VoDoWw8WRXVGg+V6Z3r6S9VubY0iOlFikc8HRImOACexjC/iLiPsM/Bj
         r6bQ==
X-Google-Smtp-Source: APXvYqzwNprXN29DZ7UGIYwaCejcGQrj8odhje28fvO/bO2B72vQuPKfuJUO5maKd2GmXcWawmIeZOQxcW/uFJwbcOk=
X-Received: by 2002:adf:f44b:: with SMTP id f11mr6854913wrp.128.1557871115739;
 Tue, 14 May 2019 14:58:35 -0700 (PDT)
MIME-Version: 1.0
References: <20190510195258.9930-1-Felix.Kuehling@amd.com> <20190510195258.9930-3-Felix.Kuehling@amd.com>
 <20190510201403.GG4507@redhat.com> <65328381-aa0d-353d-68dc-81060e7cebdf@amd.com>
 <BN6PR12MB1809F26E6AF74BE9F96DB22DF70F0@BN6PR12MB1809.namprd12.prod.outlook.com>
 <cf8bdc0c-96b9-8a73-69ca-a4aae11f36d5@amd.com>
In-Reply-To: <cf8bdc0c-96b9-8a73-69ca-a4aae11f36d5@amd.com>
From: Alex Deucher <alexdeucher@gmail.com>
Date: Tue, 14 May 2019 17:58:23 -0400
Message-ID: <CADnq5_N_h6c5bkLRA9pmbhr4fcSUMe=3GCaO7JvsAsrCJ3vdLA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for non-blocking
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: "Deucher, Alexander" <Alexander.Deucher@amd.com>, Jerome Glisse <jglisse@redhat.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, "airlied@gmail.com" <airlied@gmail.com>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"alex.deucher@amd.com" <alex.deucher@amd.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 14, 2019 at 5:12 PM Kuehling, Felix <Felix.Kuehling@amd.com> wr=
ote:
>
>
> On 2019-05-13 4:21 p.m., Deucher, Alexander wrote:
> > [CAUTION: External Email]
> > I reverted all the amdgpu HMM patches for 5.2 because they also
> > depended on this patch:
> > https://cgit.freedesktop.org/~agd5f/linux/commit/?h=3Ddrm-next-5.2-wip&=
id=3Dce05ef71564f7cbe270cd4337c36ee720ea534db
> > which did not have a clear line of sight for 5.2 either.
>
> When was that? I saw "Use HMM for userptr" in Dave's 5.2-rc1 pull
> request to Linus.

https://patchwork.kernel.org/patch/10875587/

Alex



>
>
> Regards,
>    Felix
>
>
> >
> > Alex
> > -----------------------------------------------------------------------=
-
> > *From:* amd-gfx <amd-gfx-bounces@lists.freedesktop.org> on behalf of
> > Kuehling, Felix <Felix.Kuehling@amd.com>
> > *Sent:* Monday, May 13, 2019 3:36 PM
> > *To:* Jerome Glisse
> > *Cc:* linux-mm@kvack.org; airlied@gmail.com;
> > amd-gfx@lists.freedesktop.org; dri-devel@lists.freedesktop.org;
> > alex.deucher@amd.com
> > *Subject:* Re: [PATCH 2/2] mm/hmm: Only set FAULT_FLAG_ALLOW_RETRY for
> > non-blocking
> > [CAUTION: External Email]
> >
> > Hi Jerome,
> >
> > Do you want me to push the patches to your branch? Or are you going to
> > apply them yourself?
> >
> > Is your hmm-5.2-v3 branch going to make it into Linux 5.2? If so, do yo=
u
> > know when? I'd like to coordinate with Dave Airlie so that we can also
> > get that update into a drm-next branch soon.
> >
> > I see that Linus merged Dave's pull request for Linux 5.2, which
> > includes the first changes in amdgpu using HMM. They're currently broke=
n
> > without these two patches.
> >
> > Thanks,
> >    Felix
> >
> > On 2019-05-10 4:14 p.m., Jerome Glisse wrote:
> > > [CAUTION: External Email]
> > >
> > > On Fri, May 10, 2019 at 07:53:24PM +0000, Kuehling, Felix wrote:
> > >> Don't set this flag by default in hmm_vma_do_fault. It is set
> > >> conditionally just a few lines below. Setting it unconditionally
> > >> can lead to handle_mm_fault doing a non-blocking fault, returning
> > >> -EBUSY and unlocking mmap_sem unexpectedly.
> > >>
> > >> Signed-off-by: Felix Kuehling <Felix.Kuehling@amd.com>
> > > Reviewed-by: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
> > >
> > >> ---
> > >>   mm/hmm.c | 2 +-
> > >>   1 file changed, 1 insertion(+), 1 deletion(-)
> > >>
> > >> diff --git a/mm/hmm.c b/mm/hmm.c
> > >> index b65c27d5c119..3c4f1d62202f 100644
> > >> --- a/mm/hmm.c
> > >> +++ b/mm/hmm.c
> > >> @@ -339,7 +339,7 @@ struct hmm_vma_walk {
> > >>   static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long ad=
dr,
> > >>                            bool write_fault, uint64_t *pfn)
> > >>   {
> > >> -     unsigned int flags =3D FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_REM=
OTE;
> > >> +     unsigned int flags =3D FAULT_FLAG_REMOTE;
> > >>        struct hmm_vma_walk *hmm_vma_walk =3D walk->private;
> > >>        struct hmm_range *range =3D hmm_vma_walk->range;
> > >>        struct vm_area_struct *vma =3D walk->vma;
> > >> --
> > >> 2.17.1
> > >>
> > _______________________________________________
> > amd-gfx mailing list
> > amd-gfx@lists.freedesktop.org
> > https://lists.freedesktop.org/mailman/listinfo/amd-gfx
> _______________________________________________
> amd-gfx mailing list
> amd-gfx@lists.freedesktop.org
> https://lists.freedesktop.org/mailman/listinfo/amd-gfx


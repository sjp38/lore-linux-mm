Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40DE0C4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:37:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E2A1D20882
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 14:37:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="E28SvG5d"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E2A1D20882
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 83EA96B026C; Tue,  2 Apr 2019 10:37:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EB466B0277; Tue,  2 Apr 2019 10:37:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6672B6B0278; Tue,  2 Apr 2019 10:37:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2C6C96B026C
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 10:37:22 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id x2so6958292pge.16
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 07:37:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AZM0NDA8LlxUlUA4BDtBxMo35ithERuB831S3MqOTmk=;
        b=XtS6samP4dLOF0Jv6aHHA3O4o6tXYwVBLuZWLnS+fQ0XXJdJ9lMCkfWhAstQUsnX55
         uJ9kDqehSs7WUGxBO4ziaua5FvKNE3mpq22FhGw8mUwyCBrKhhpqttIF5GNv6Bd6HqbM
         E8zQ6sAvjzaZzCXxiQPPc2UzauoFEkPv7MccJQL1i99ixXw//+bcVc0EjSZzOp1ddPvA
         tVoiOffycoIXMkn3OyHONlXrJh6b/6UBKdxkVP7avgSnyVZTKYn8gKfLoxPrGUVyqSLO
         zGwVPoT7BSZbiAifB9gP7RrxxQmOnjoZMCaEHNo9UcsECANe4oPsemr9dswFmVeQWAkd
         947w==
X-Gm-Message-State: APjAAAVQoFfh+6T9K4DBHw/PSaRrfy4KUo1rmhPUhgza46egpUvPllUk
	Os51CdMKycnUh49YuOsF6zgQYfqgfcYtHBFSw0RM+7DEdHCDZ1hK3fn7RehNd3eChVGP16c1z8z
	+pAwI316ePsLolLgVR474QLEb4Mts9RZgOLJLh0ZRlLxG6fs37NHGvht4kZpOVAHe1g==
X-Received: by 2002:a17:902:b484:: with SMTP id y4mr63548570plr.88.1554215841720;
        Tue, 02 Apr 2019 07:37:21 -0700 (PDT)
X-Received: by 2002:a17:902:b484:: with SMTP id y4mr63548482plr.88.1554215840711;
        Tue, 02 Apr 2019 07:37:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554215840; cv=none;
        d=google.com; s=arc-20160816;
        b=ECvGcgIR6y9mg0TaCmEoV4mBYU9mtMK+vnbtM+DR598d/IEArrwYx5XMtVBpBLU+4h
         sS4rGsOwwDZtS8aEUQ4U8srl0twM9feNWBjoi0e//w85joOTY9djTbIDbXf7ZC7BuCoW
         H21CYXDGcX8TcaiSF47fHxXiqmpvSM/tez186V4VtuSsLHX577mS7RNgmKeisTXHhCgr
         gOTcybikgjfbf8IGc11VQXNxKRN7384W7DOOOXW8GYwl2gipkFKowBWIGsA+XrItYxe8
         ihXAq1J2I11lKN43AJZiAzjP8HCec8dRlSrmStnoAd2NoJ+Aj6HVkEJMYLiiMLZ28fyb
         hieQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AZM0NDA8LlxUlUA4BDtBxMo35ithERuB831S3MqOTmk=;
        b=UssRoBBXBeelx93JS++2BFuKksA1fHl+GoJH5ervGcmXKU2NqXNIFGJyrRZfCUBlAH
         Zv6W2LHIGPfjG0ZkgKXd3N1RT42jDL68Z8vGIYJjwg6Yh6bSrEWgVcgN57iSI21z9h9T
         5/Pd1jSOQyvIIYpG7JyFIQtNFBpKnQ92JiqvtA3YHOsQSJgXci4f8I8RWROzsWJY9mNs
         cWLfpqqGZu41BCchA0NefYA3rkxOGgZU/BxLHGCJH6RUC+U6I3PlbLc123ipEpg/S1zz
         YSt27QhOG6NSAunQ2pcLOpWgZws8nwSBAO+H4qIKh6fajRcc3I1HVOhXaeTXmOvdwu5d
         TJ4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=E28SvG5d;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor15343832pln.23.2019.04.02.07.37.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 02 Apr 2019 07:37:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=E28SvG5d;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AZM0NDA8LlxUlUA4BDtBxMo35ithERuB831S3MqOTmk=;
        b=E28SvG5dm9izC+3mjpy3q8xFCHxoyu+qey1rLW7qQ0QxP93/QB6H4RCTfH6Qq90+Fc
         orupXRcR0c3gINBCpcAOPxJR7br/HOCpLjgZnpaJg0WHNcYmMLmxi/Z1L+tKanLn2KD/
         ovnRH/9UehjTF2zWXtRxF22eU5Vncrq1418ZpW8MIeX7PAIMlcXLBHAZMMGRVUlY+MED
         vN0LHoR53v7gw96/OO7JXdVlVy2J0duEFGYNyFt+3+k0NQSXc/i795xNrUYCY1xogcu6
         11b5Hoo1RME/5GD8UJu2JhSPQgRVBKE1OsXLA0Cz/pVkhpxJM80aiPOsjTvgQOulf00G
         v8Rg==
X-Google-Smtp-Source: APXvYqwf7ZfG3H65SinFpQJ6JCmP2a3SknI4Skw41NmgVRrjGVTTmaDiRJSBca6KdRWZXn45jyVCd0IkeB1uda+7vj0=
X-Received: by 2002:a17:902:586:: with SMTP id f6mr69482466plf.68.1554215839809;
 Tue, 02 Apr 2019 07:37:19 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com> <017804b2198a906463d634f84777b6087c9b4a40.1553093421.git.andreyknvl@google.com>
 <574648a3-3a05-bea7-3f4e-7d71adedf1dc@amd.com>
In-Reply-To: <574648a3-3a05-bea7-3f4e-7d71adedf1dc@amd.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 2 Apr 2019 16:37:08 +0200
Message-ID: <CAAeHK+yQG_oYbBpcZWO80Pr=tdAgEHe80wuAHwuTMWNr=on+Qw@mail.gmail.com>
Subject: Re: [PATCH v13 14/20] drm/amdgpu, arm64: untag user pointers in amdgpu_ttm_tt_get_user_pages
To: "Kuehling, Felix" <Felix.Kuehling@amd.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	"Deucher, Alexander" <Alexander.Deucher@amd.com>, "Koenig, Christian" <Christian.Koenig@amd.com>, 
	"Zhou, David(ChunMing)" <David1.Zhou@amd.com>, Yishai Hadas <yishaih@mellanox.com>, 
	Mauro Carvalho Chehab <mchehab@kernel.org>, Jens Wiklander <jens.wiklander@linaro.org>, 
	Alex Williamson <alex.williamson@redhat.com>, 
	"linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, 
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, "bpf@vger.kernel.org" <bpf@vger.kernel.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, 
	"linux-media@vger.kernel.org" <linux-media@vger.kernel.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, 
	"linux-kselftest@vger.kernel.org" <linux-kselftest@vger.kernel.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Lee Smith <Lee.Smith@arm.com>, Kostya Serebryany <kcc@google.com>, Dmitry Vyukov <dvyukov@google.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Evgeniy Stepanov <eugenis@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Mar 25, 2019 at 11:21 PM Kuehling, Felix <Felix.Kuehling@amd.com> wrote:
>
> On 2019-03-20 10:51 a.m., Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > amdgpu_ttm_tt_get_user_pages() uses provided user pointers for vma
> > lookups, which can only by done with untagged pointers.
> >
> > Untag user pointers in this function.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >   drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c | 5 +++--
> >   1 file changed, 3 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> > index 73e71e61dc99..891b027fa33b 100644
> > --- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> > +++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
> > @@ -751,10 +751,11 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
> >                * check that we only use anonymous memory to prevent problems
> >                * with writeback
> >                */
> > -             unsigned long end = gtt->userptr + ttm->num_pages * PAGE_SIZE;
> > +             unsigned long userptr = untagged_addr(gtt->userptr);
> > +             unsigned long end = userptr + ttm->num_pages * PAGE_SIZE;
> >               struct vm_area_struct *vma;
> >
> > -             vma = find_vma(mm, gtt->userptr);
> > +             vma = find_vma(mm, userptr);
> >               if (!vma || vma->vm_file || vma->vm_end < end) {
> >                       up_read(&mm->mmap_sem);
> >                       return -EPERM;
>
> We'll need to be careful that we don't break your change when the
> following commit gets applied through drm-next for Linux 5.2:
>
> https://cgit.freedesktop.org/~agd5f/linux/commit/?h=drm-next-5.2-wip&id=915d3eecfa23693bac9e54cdacf84fb4efdcc5c4
>
> Would it make sense to apply the untagging in amdgpu_ttm_tt_set_userptr
> instead? That would avoid this conflict and I think it would clearly put
> the untagging into the user mode code path where the tagged pointer
> originates.
>
> In amdgpu_gem_userptr_ioctl and amdgpu_amdkfd_gpuvm.c (init_user_pages)
> we also set up an MMU notifier with the (tagged) pointer from user mode.
> That should probably also use the untagged address so that MMU notifiers
> for the untagged address get correctly matched up with the right BO. I'd
> move the untagging further up the call stack to cover that. For the GEM
> case I think amdgpu_gem_userptr_ioctl would be the right place. For the
> KFD case, I'd do this in amdgpu_amdkfd_gpuvm_alloc_memory_of_gpu.

Will do in v14, thanks a lot for looking at this!

Is this applicable to the radeon driver (drivers/gpu/drm/radeon) as
well? It seems to be using very similar structure.

>
> Regards,
>    Felix
>


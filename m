Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_IN_DEF_DKIM_WL
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F1BC46470
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:53:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A85C2054F
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 13:53:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="kv7aGbZw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A85C2054F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D63656B0005; Mon,  6 May 2019 09:53:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D13356B0006; Mon,  6 May 2019 09:53:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C01F86B0007; Mon,  6 May 2019 09:53:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 898B56B0005
	for <linux-mm@kvack.org>; Mon,  6 May 2019 09:53:14 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id 94so5427820plc.19
        for <linux-mm@kvack.org>; Mon, 06 May 2019 06:53:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=DfsikH3ADmgNVGOW8dVHffAJXBPBy/1Drd0IdtpjjJ8=;
        b=e5gwJMDtTSiGweOSQYdkdVJ7tRYCv/bI3aeGM41EI12yiQTpVNm6uIFm+e5UpQ4x8G
         jXwxujozwCnXUhzdHoMcpmBEdQNqSkl100ee11STVZmUpNJKKRbUbweexgpbYmFUvd56
         5RUM4OfpmGZndSv/gpsSDVrnnagcqwkkF0XnS/TAg3VX3Fu1V0XdMdbPYi42q3XrPXJv
         zZaJWufcqFmlRS8JetNaBIs1SXZ7T09TIoR2MdDa7WzmXM5vKMT+WNOmzg+Cm6mLiviX
         gbFqlu620jPIX7TjNy6Y5/KELx9w/9YJ/zWBGKdxoOMu5Zc8DzzRwaxGnd6pHwhltvvc
         BaYg==
X-Gm-Message-State: APjAAAUTqHOlbU480u8usrWnr1Fd2ZtTH3HsHbnz4fpFJo57WNC+YZSj
	JPDfqQIXLz9sOZIm5UBTGuOE4/HTHTjK/T4hSNBP38Gpu2we8NLEVUkKPR7DO1mHT1aEo6tVmwK
	5O2ZEz1cyOKsuKSYESCveeAa5McVW928koYj9FtKoylOjPszorkqlK+ztzTz2Joph2g==
X-Received: by 2002:a63:570d:: with SMTP id l13mr32097486pgb.55.1557150794124;
        Mon, 06 May 2019 06:53:14 -0700 (PDT)
X-Received: by 2002:a63:570d:: with SMTP id l13mr32097400pgb.55.1557150793310;
        Mon, 06 May 2019 06:53:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557150793; cv=none;
        d=google.com; s=arc-20160816;
        b=T67s+agnav6Y8y/uRWBDMCSCWSNWEz3QLcPXw9b0OJt9seZai5spkhe03TvEIcMtHL
         iGJblTFFlM7+z6+vebyEkCtOMZSkNBCsM1LPCNiak7TteZtTTQ1OqEVECCyr/yjD97M7
         5cRdR2oYwH7+sPFoRpGra8v2fuEEGMyis30c+ct/PuehVMCAB+i+3JRWNBFAhSkugGzF
         bBHQYJU4rpg4v3TExvEbagjlCJUSziXTxNFHpCs6YJ7cJ1MD3r6ppjNEAeTn+pxD9LE1
         HjqAkUQSsIP6ZhHiCbN3RNs8frlnBtogL3deAK21MBYlqHoIdnRbfyiDgAcwfNeiDNYy
         O5YA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=DfsikH3ADmgNVGOW8dVHffAJXBPBy/1Drd0IdtpjjJ8=;
        b=QksBfTrtDeap0fxPUFMAzgupd/csySCh2rUR9bPQ9yctG8pLOl65QkQqjZ4qqoAk0c
         76KXtTExnC5N4MYUPsEYqhCoXuWahXHFhkEy5TBW2AxhFhV2kgFnSwFDeVpwrKnQYpAR
         Wli9/hpDgwHV7MwdSCLm3a5CkYkAIp420ZcIxY4fh6szhnCbO91O+DrPq73htUzUGg07
         vJk4MfsYebY8J2ybN2UkgLd4NtzsKJanFnXNDFhDdstF3dl6Kl1PhUUvnl9SERSZs3xP
         E2/F6REPTRHDtItF9Zt7XwA4IJDnfDFoc09ml82pyk5HcFwFTp+pbqSOJZCtdHNheoAI
         qknQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kv7aGbZw;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l7sor11990207pff.50.2019.05.06.06.53.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 06:53:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=kv7aGbZw;
       spf=pass (google.com: domain of andreyknvl@google.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=andreyknvl@google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=DfsikH3ADmgNVGOW8dVHffAJXBPBy/1Drd0IdtpjjJ8=;
        b=kv7aGbZwowOP86IiNXKGTzv02HGdI2dS555U/AmH12LgQOZnKLK39c4sVdRuufn96A
         qthFKSfdn7G60uj86be1sn6Yz08bEym7ZdQPS1mHAwXca2PX4G4xwzBsumjfQSNalrzf
         yL5bwTZ9P03pKULjLPyCJCemso/1RN2dFNxsJkh8Db8dDQ4uyTu4XB2OtIwgRdUtOIbE
         AyYkrbplUjKWiH4tJjgIH/K5mFuPdBD8NVSdZa64NURA8ieEyhpOBhaJlBUr1GIoMIGp
         v2ptbSyS2qLsf62uamUc0COAt9buSU1YrXxFbkm18U+53rgjezb09axtZoHwZgv8hVgU
         L1Yg==
X-Google-Smtp-Source: APXvYqz1fgwxD3Q1L0PJp0GBoiDCnAmVuD+UduBO6dKustad4HqnmYC98uMKFLNp2x7D5yl19BVMVIT9EGy2Pg34Ktk=
X-Received: by 2002:aa7:9116:: with SMTP id 22mr33262822pfh.165.1557150792655;
 Mon, 06 May 2019 06:53:12 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com> <8e20df035de677029b3f970744ba2d35e2df1db3.1556630205.git.andreyknvl@google.com>
 <20190503165113.GJ55449@arrakis.emea.arm.com>
In-Reply-To: <20190503165113.GJ55449@arrakis.emea.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Mon, 6 May 2019 15:53:01 +0200
Message-ID: <CAAeHK+wCyCa-5=bPNwfivP6sEODOXKE1bPjcjc2y_T4rN+-6gA@mail.gmail.com>
Subject: Re: [PATCH v14 08/17] mm, arm64: untag user pointers in get_vaddr_frames
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Linux ARM <linux-arm-kernel@lists.infradead.org>, 
	Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	"open list:KERNEL SELFTEST FRAMEWORK" <linux-kselftest@vger.kernel.org>, 
	Vincenzo Frascino <vincenzo.frascino@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kees Cook <keescook@chromium.org>, 
	Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, Felix <Felix.Kuehling@amd.com>, 
	Deucher@google.com, Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 3, 2019 at 6:51 PM Catalin Marinas <catalin.marinas@arm.com> wrote:
>
> On Tue, Apr 30, 2019 at 03:25:04PM +0200, Andrey Konovalov wrote:
> > This patch is a part of a series that extends arm64 kernel ABI to allow to
> > pass tagged user pointers (with the top byte set to something else other
> > than 0x00) as syscall arguments.
> >
> > get_vaddr_frames uses provided user pointers for vma lookups, which can
> > only by done with untagged pointers. Instead of locating and changing
> > all callers of this function, perform untagging in it.
> >
> > Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
> > ---
> >  mm/frame_vector.c | 2 ++
> >  1 file changed, 2 insertions(+)
> >
> > diff --git a/mm/frame_vector.c b/mm/frame_vector.c
> > index c64dca6e27c2..c431ca81dad5 100644
> > --- a/mm/frame_vector.c
> > +++ b/mm/frame_vector.c
> > @@ -46,6 +46,8 @@ int get_vaddr_frames(unsigned long start, unsigned int nr_frames,
> >       if (WARN_ON_ONCE(nr_frames > vec->nr_allocated))
> >               nr_frames = vec->nr_allocated;
> >
> > +     start = untagged_addr(start);
> > +
> >       down_read(&mm->mmap_sem);
> >       locked = 1;
> >       vma = find_vma_intersection(mm, start, start + 1);
>
> Is this some buffer that the user may have malloc'ed? I got lost when
> trying to track down the provenience of this buffer.

The caller that I found when I was looking at this:

drivers/gpu/drm/exynos/exynos_drm_g2d.c:482
exynos_g2d_set_cmdlist_ioctl()->g2d_map_cmdlist_gem()->g2d_userptr_get_dma_addr()->get_vaddr_frames()

>
> --
> Catalin


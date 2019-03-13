Return-Path: <SRS0=KVn2=RQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3432DC43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:02:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D80CC20643
	for <linux-mm@archiver.kernel.org>; Wed, 13 Mar 2019 16:02:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="y7/X111I"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D80CC20643
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 865C98E0004; Wed, 13 Mar 2019 12:02:16 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 814648E0001; Wed, 13 Mar 2019 12:02:16 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DC258E0004; Wed, 13 Mar 2019 12:02:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 34A808E0001
	for <linux-mm@kvack.org>; Wed, 13 Mar 2019 12:02:16 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id l8so976562otp.11
        for <linux-mm@kvack.org>; Wed, 13 Mar 2019 09:02:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=CkHX/D6Gyspe7lRDGtgIrSuJ+M2kMCxh6Af+/gLSlLg=;
        b=qaIbQ2EpT6MYyJu4erxws7dZpzqqduQqOUd2x3YSZH5FlTEglE6K9RtRKrZ3nqnB9L
         XbK73Is4kOBgsPvWjsJcx2IuFDMdLcTTgqwlVDJUVlJWzehFLCiSWxbQPfFSkkTjx1cM
         3fPDdv08591zfsijrjbcFJRDTUa00k/VAyR6Vygi4J4ahBbjZzAIyaM+RtxL7marSIH8
         OeB9kLDTS6bfQRUvDtALmEhhzFbCgyQt1f5mk14de+WoVJf8+FwpkbW8vlvOiDAaxy/l
         2iVRISVKVXUBHxnjg8Jq/yfABpopXhKgQ+Ch9IQuz+LHgVycqN3+tuJTegpwj6/8+BhM
         a5Ag==
X-Gm-Message-State: APjAAAX6bVW9xPu5rgcH5GqfjGPDgmSaukVQogVjy1gYtxfWHQ3r3YdF
	+H9cI2JFSc0m8pFhUAdMiKtFhJkESpHcdQdFKzRFKe9JEzNl1l2nfLfZZQ3uYySXleCBYQFz3OP
	plYx99fCDVMoCEzqSyuUJYJ9VL4kpJvsGQmbqduA63jUe99CAweDzJX6nSCyEN+t3WQ==
X-Received: by 2002:aca:4747:: with SMTP id u68mr2174758oia.38.1552492935671;
        Wed, 13 Mar 2019 09:02:15 -0700 (PDT)
X-Received: by 2002:aca:4747:: with SMTP id u68mr2174688oia.38.1552492934495;
        Wed, 13 Mar 2019 09:02:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552492934; cv=none;
        d=google.com; s=arc-20160816;
        b=A0rNBjjfHjwg4OIP1N2Nop9ltBTvl+T9w7JNGEq9kY0iMOIiWgs7ns0OjdlIuueOJN
         0ELKn3GBU32ksPduS/Df1g/aI/CF6DchHMAsCXtgJQemjqk0zApN3xaIYtXTGycFpWXN
         LKDrfsRydCRMdjLdjPg3Wn587rKyD0oGCXU7zyciY00LMQ5yuImaUnSJ6vimZmj+yY/P
         jpSOem2wVukonHt0mSAw4Q3/auRXftpCSFHhzKL3ZFsbwCGAZDWej3jio3hIvdxWqDaZ
         g3+XayvzYOOluhZjyb+TtxbESL0OCORcQ8ET7chIbZawlo9+9E5RGCvSJG1mYDMbjmzc
         TdZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=CkHX/D6Gyspe7lRDGtgIrSuJ+M2kMCxh6Af+/gLSlLg=;
        b=bCWDHYrNicVrgmxDzPEBbGb6E83DmklMvV9GJz3KhmJA7l/ji3rPF3vjwC7yFFr7bC
         qa7qbIgc2UQPPErQhHpIARUE76spCRm6bJxGMZEjLvrXxtGz5/hCoHNwLcfIvh7j/dbH
         rdzBdDMQfaiyJ2pvu8jeux9T3mXNty5CYx3NKSOZ+ZEzSsYq/4jyPyOlhpROQgl+XXVy
         0D3gzaTXmKEdeRWlY0TdDCjshw6Gv28CUshnfjEXwri31qy746ePrqEWgnXq/i5nQWVS
         klwmNeP1X/3gtiHsNrsrbieUFqjDTzKNzDzLtukjdJnF4Tn/MrfCC7Npm04ylGhqBgoS
         xrLg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="y7/X111I";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i64sor6912133oih.107.2019.03.13.09.02.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Mar 2019 09:02:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b="y7/X111I";
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=CkHX/D6Gyspe7lRDGtgIrSuJ+M2kMCxh6Af+/gLSlLg=;
        b=y7/X111Ih0XlFvwsxv16a+Tjs391cVrRbIsUC3mnj+Mm0qUMtN51FaB5lxBiCc118x
         376jJgarhHQvsy/V3septwJqefqHhb0cQ23r3YOFQrmojJ9aUNMM2lS4jburK7G8+GG8
         gLX4nRQ0AcUV/EHv4PXGES90G+wP03J35zdNnVsfr9Sd8cDALnBGvmFcrlIdyd2oACC4
         6Vli7jf+MBtZb2zuBBWWNh60FRCFh3G++jIyEbSKMpRZYiW3U6H06nM+z0YT2rJezvdu
         kISuyXLhhLUwFgCv7cTZwNyZ9U44tWtZX4l53equtM5zVwtwX0jcTZfkF0XQfcpPj1Md
         xpew==
X-Google-Smtp-Source: APXvYqyPiA57rePYTQvH7o4E3jUa42PR2QtmxRflPF8xI9QygvSu8+9pFaw4Gvfpl6WMz1l8+jLwg2xYW8j6yUg7b3c=
X-Received: by 2002:aca:54d8:: with SMTP id i207mr2191334oib.0.1552492933977;
 Wed, 13 Mar 2019 09:02:13 -0700 (PDT)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com>
 <20190228083522.8189-2-aneesh.kumar@linux.ibm.com> <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
 <CAPcyv4jhEvijybSVsy+wmvgqfvyxfePQ3PUqy1hhmVmPtJTyqQ@mail.gmail.com> <87k1hc8iqa.fsf@linux.ibm.com>
In-Reply-To: <87k1hc8iqa.fsf@linux.ibm.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 13 Mar 2019 09:02:03 -0700
Message-ID: <CAPcyv4ir4irASBQrZD_a6kMkEUt=XPUCuKajF75O7wDCgeG=7Q@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Oliver <oohall@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 6, 2019 at 1:18 AM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Dan Williams <dan.j.williams@intel.com> writes:
>
> > On Thu, Feb 28, 2019 at 1:40 AM Oliver <oohall@gmail.com> wrote:
> >>
> >> On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
> >> <aneesh.kumar@linux.ibm.com> wrote:
> >> >
> >> > Add a flag to indicate the ability to do huge page dax mapping. On architecture
> >> > like ppc64, the hypervisor can disable huge page support in the guest. In
> >> > such a case, we should not enable huge page dax mapping. This patch adds
> >> > a flag which the architecture code will update to indicate huge page
> >> > dax mapping support.
> >>
> >> *groan*
> >>
> >> > Architectures mostly do transparent_hugepage_flag = 0; if they can't
> >> > do hugepages. That also takes care of disabling dax hugepage mapping
> >> > with this change.
> >> >
> >> > Without this patch we get the below error with kvm on ppc64.
> >> >
> >> > [  118.849975] lpar: Failed hash pte insert with error -4
> >> >
> >> > NOTE: The patch also use
> >> >
> >> > echo never > /sys/kernel/mm/transparent_hugepage/enabled
> >> > to disable dax huge page mapping.
> >> >
> >> > Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> >> > ---
> >> > TODO:
> >> > * Add Fixes: tag
> >> >
> >> >  include/linux/huge_mm.h | 4 +++-
> >> >  mm/huge_memory.c        | 4 ++++
> >> >  2 files changed, 7 insertions(+), 1 deletion(-)
> >> >
> >> > diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> >> > index 381e872bfde0..01ad5258545e 100644
> >> > --- a/include/linux/huge_mm.h
> >> > +++ b/include/linux/huge_mm.h
> >> > @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
> >> >                         pud_t *pud, pfn_t pfn, bool write);
> >> >  enum transparent_hugepage_flag {
> >> >         TRANSPARENT_HUGEPAGE_FLAG,
> >> > +       TRANSPARENT_HUGEPAGE_DAX_FLAG,
> >> >         TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> >> >         TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
> >> >         TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> >> > @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
> >> >         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
> >> >                 return true;
> >> >
> >> > -       if (vma_is_dax(vma))
> >> > +       if (vma_is_dax(vma) &&
> >> > +           (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
> >> >                 return true;
> >>
> >> Forcing PTE sized faults should be fine for fsdax, but it'll break
> >> devdax. The devdax driver requires the fault size be >= the namespace
> >> alignment since devdax tries to guarantee hugepage mappings will be
> >> used and PMD alignment is the default. We can probably have devdax
> >> fall back to the largest size the hypervisor has made available, but
> >> it does run contrary to the design. Ah well, I suppose it's better off
> >> being degraded rather than unusable.
> >
> > Given this is an explicit setting I think device-dax should explicitly
> > fail to enable in the presence of this flag to preserve the
> > application visible behavior.
> >
> > I.e. if device-dax was enabled after this setting was made then I
> > think future faults should fail as well.
>
> Not sure I understood that. Now we are disabling the ability to map
> pages as huge pages. I am now considering that this should not be
> user configurable. Ie, this is something that platform can use to avoid
> dax forcing huge page mapping, but if the architecture can enable huge
> dax mapping, we should always default to using that.

No, that's an application visible behavior regression. The side effect
of this setting is that all huge-page configured device-dax instances
must be disabled.

> Now w.r.t to failures, can device-dax do an opportunistic huge page
> usage?

device-dax explicitly disclaims the ability to do opportunistic mappings.

> I haven't looked at the device-dax details fully yet. Do we make the
> assumption of the mapping page size as a format w.r.t device-dax? Is that
> derived from nd_pfn->align value?

Correct.

>
> Here is what I am working on:
> 1) If the platform doesn't support huge page and if the device superblock
> indicated that it was created with huge page support, we fail the device
> init.

Ok.

> 2) Now if we are creating a new namespace without huge page support in
> the platform, then we force the align details to PAGE_SIZE. In such a
> configuration when handling dax fault even with THP enabled during
> the build, we should not try to use hugepage. This I think we can
> achieve by using TRANSPARENT_HUGEPAEG_DAX_FLAG.

How is this dynamic property communicated to the guest?

>
> Also even if the user decided to not use THP, by
> echo "never" > transparent_hugepage/enabled , we should continue to map
> dax fault using huge page on platforms that can support huge pages.
>
> This still doesn't cover the details of a device-dax created with
> PAGE_SIZE align later booted with a kernel that can do hugepage dax.How
> should we handle that? That makes me think, this should be a VMA flag
> which got derived from device config? May be use VM_HUGEPAGE to indicate
> if device should use a hugepage mapping or not?

device-dax configured with PAGE_SIZE always gets PAGE_SIZE mappings.


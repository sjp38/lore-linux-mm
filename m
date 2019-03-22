Return-Path: <SRS0=SIh7=RZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0040FC43381
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:13:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93C9F21900
	for <linux-mm@archiver.kernel.org>; Fri, 22 Mar 2019 22:13:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="Zb9Bl7Bn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93C9F21900
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEBAA6B0005; Fri, 22 Mar 2019 18:13:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E703F6B0006; Fri, 22 Mar 2019 18:13:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D12466B0007; Fri, 22 Mar 2019 18:13:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC5556B0005
	for <linux-mm@kvack.org>; Fri, 22 Mar 2019 18:13:07 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id n15so2930625ioc.0
        for <linux-mm@kvack.org>; Fri, 22 Mar 2019 15:13:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=VnWfr5Cz9g8Ts5McgdJK3bb2nMan4nq5nXqWONnMsfs=;
        b=nR0SPk2KJHw++ud1lJKIBfxlB0c31aVsd2CnKGrHqfE78LryBHDTa+YG/tt5Reir5s
         ZKSCmvExF3Tvza2VCuUjbJ3UCYQg6P2mbi/9Ds0+q8eSibMZFY6CfeF6vWrj+8Gfcbpa
         6BVatf8GkHcIUptVuogvPoK/TOJMprRnsoNdB3EgCclH9bHg02PyDi7lAP+ta7fR/vJe
         +2JcJNpV+01J/CZjmKwfsLdKNcP66bCOxf4oD1qxND0IRiJ7X20Q2cybk4RjbEkOk+AV
         z1IygKJ+nJY8/sgjgnG48hpMLYNvYlu8UGnVkFgQdJe1uMCie2JPcwljmVISXPonwn/7
         yxWQ==
X-Gm-Message-State: APjAAAWWN3x/GQ6yb5ineIKNdEHwy8D7fXqAai4RmokDG1JPb7bTsxSB
	20ENwjtYKB6dmQbNRMQzeMiY1lAg6Jwg4Vf7JNRujgPHx9Eee3RqCusc7d+JEiWHuTqwegg49JF
	zRzYTJTW+q4n6HBbBL0U4YbzN6Mr88ih/hOIf0IbxaM7+9XpqJRcczIzo6zYGMGg=
X-Received: by 2002:a02:b008:: with SMTP id p8mr7750063jah.90.1553292787479;
        Fri, 22 Mar 2019 15:13:07 -0700 (PDT)
X-Received: by 2002:a02:b008:: with SMTP id p8mr7750023jah.90.1553292786843;
        Fri, 22 Mar 2019 15:13:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553292786; cv=none;
        d=google.com; s=arc-20160816;
        b=l5rAaE4V0yhJJ8/wOPndE+hoOwgIQoRvmC0TOlzVmpFP72tdiQhxnpWIrNFIKzAQlW
         dVaBz9qwSExihD7zpF45NlgVsNtS1VNQl0g7zz9kJs2K23MdsJanK3Ty1w7zkvKGMJrp
         NMr3/pZwEl2GD6Fm6oEtFPbUE+yApRgfPHdcdIQ1Z1VHdLtiNuNZ8KVgMbi6RN9/VP8P
         PBvpoBrw0tgIuXzryO6La3NGfnyTwHkrBMhzJ3DGMyI0EctyE2fcREoyZIZeZvO5tAYb
         KU5ka5h23lAQWQ+E+naPh32mDOL28AJI84a5kLbn9od0Ia2tR9E30TGGYwcm3zUTFWPV
         +2EQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=VnWfr5Cz9g8Ts5McgdJK3bb2nMan4nq5nXqWONnMsfs=;
        b=VDgkBRUHdz6MdkhAcwrSKCV6CyGzGN2MgHP8k3TBEvpSFOZU6Q44iC6gb1rDX82R3B
         0gvhQnBqZxlL9l0tpuLvppVX7b+RzimpQxsQ6WSWJJ2CnyS+X7G7daCY04YJNrwW72Bh
         39DD2vcdoiPwvgc+tzRq21eMaesxdou2myPmdsNiZCchJoo/1jeLJkpPpftrZ7ZkhTwJ
         MoGuIw0vfOS8WyCDsN6/E509OLckUINsuiI9yBDioVowP+ehfAt2e4ZzSaOttqQx66Nk
         h0UyIpgjlKGL3Hx+1WuKxruQ/ZQLKKEZ1zl52G0cKDEBLd9nv5gbKxiPevncq6460mgw
         IY7w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Zb9Bl7Bn;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n129sor24246469jaa.12.2019.03.22.15.13.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 22 Mar 2019 15:13:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=Zb9Bl7Bn;
       spf=pass (google.com: domain of dan.j.williams@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=VnWfr5Cz9g8Ts5McgdJK3bb2nMan4nq5nXqWONnMsfs=;
        b=Zb9Bl7Bn4sqZs4rM2mwfzJd7rKnn+/+6ONyGGwJqa1scMrXWXjmi9yoQBAbfMlLpgS
         RGV1LtFJyFJAtRyqt7x4phr5CYLMLHxyjOqtaGBIgKlABbih3LbLp5n0OYCbWIHRLaHd
         TTQ98w8krLJnK39QE8Dp0ik11E8+01Sgyn1wW72V9bUGSzJ08oA4QbCqRZA5AnJQLOtm
         o3basMsLTQYqNorbmDjd4KoyjPrND/z4P2rEoZfVYQnDMfAEdcsp9b63663QinvyZoJp
         HOu5mHwb07RCBU+1v7ChvrPznU5/HmjF8OEnSTsQgs+cld8MrdbVwNZKadLpnlT93nHs
         Yb2w==
X-Google-Smtp-Source: APXvYqwPCPjaWzKVXpURWg65K5fkBoLbrluPEoFqqgn2rT6o/InM1ko8UbBUfBaLU8H/oERd+79+VhkVDmrMWUaE2i4=
X-Received: by 2002:a02:c007:: with SMTP id y7mr8517902jai.1.1553292786464;
 Fri, 22 Mar 2019 15:13:06 -0700 (PDT)
MIME-Version: 1.0
References: <20190317183438.2057-1-ira.weiny@intel.com> <20190317183438.2057-5-ira.weiny@intel.com>
In-Reply-To: <20190317183438.2057-5-ira.weiny@intel.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 22 Mar 2019 15:12:55 -0700
Message-ID: <CAA9_cmcx-Bqo=CFuSj7Xcap3e5uaAot2reL2T74C47Ut6_KtQw@mail.gmail.com>
Subject: Re: [RESEND 4/7] mm/gup: Add FOLL_LONGTERM capability to GUP fast
To: ira.weiny@intel.com
Cc: Andrew Morton <akpm@linux-foundation.org>, John Hubbard <jhubbard@nvidia.com>, 
	Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, 
	Peter Zijlstra <peterz@infradead.org>, Jason Gunthorpe <jgg@ziepe.ca>, 
	Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, 
	"David S. Miller" <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, 
	Heiko Carstens <heiko.carstens@de.ibm.com>, Rich Felker <dalias@libc.org>, 
	Yoshinori Sato <ysato@users.sourceforge.jp>, Thomas Gleixner <tglx@linutronix.de>, 
	Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Ralf Baechle <ralf@linux-mips.org>, 
	James Hogan <jhogan@kernel.org>, linux-mm <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mips@vger.kernel.org, 
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>, linux-s390 <linux-s390@vger.kernel.org>, 
	Linux-sh <linux-sh@vger.kernel.org>, sparclinux@vger.kernel.org, 
	linux-rdma@vger.kernel.org, "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Mar 17, 2019 at 7:36 PM <ira.weiny@intel.com> wrote:
>
> From: Ira Weiny <ira.weiny@intel.com>
>
> DAX pages were previously unprotected from longterm pins when users
> called get_user_pages_fast().
>
> Use the new FOLL_LONGTERM flag to check for DEVMAP pages and fall
> back to regular GUP processing if a DEVMAP page is encountered.
>
> Signed-off-by: Ira Weiny <ira.weiny@intel.com>
> ---
>  mm/gup.c | 29 +++++++++++++++++++++++++----
>  1 file changed, 25 insertions(+), 4 deletions(-)
>
> diff --git a/mm/gup.c b/mm/gup.c
> index 0684a9536207..173db0c44678 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1600,6 +1600,9 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>                         goto pte_unmap;
>
>                 if (pte_devmap(pte)) {
> +                       if (unlikely(flags & FOLL_LONGTERM))
> +                               goto pte_unmap;
> +
>                         pgmap = get_dev_pagemap(pte_pfn(pte), pgmap);
>                         if (unlikely(!pgmap)) {
>                                 undo_dev_pagemap(nr, nr_start, pages);
> @@ -1739,8 +1742,11 @@ static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
>         if (!pmd_access_permitted(orig, flags & FOLL_WRITE))
>                 return 0;
>
> -       if (pmd_devmap(orig))
> +       if (pmd_devmap(orig)) {
> +               if (unlikely(flags & FOLL_LONGTERM))
> +                       return 0;
>                 return __gup_device_huge_pmd(orig, pmdp, addr, end, pages, nr);
> +       }
>
>         refs = 0;
>         page = pmd_page(orig) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
> @@ -1777,8 +1783,11 @@ static int gup_huge_pud(pud_t orig, pud_t *pudp, unsigned long addr,
>         if (!pud_access_permitted(orig, flags & FOLL_WRITE))
>                 return 0;
>
> -       if (pud_devmap(orig))
> +       if (pud_devmap(orig)) {
> +               if (unlikely(flags & FOLL_LONGTERM))
> +                       return 0;
>                 return __gup_device_huge_pud(orig, pudp, addr, end, pages, nr);
> +       }
>
>         refs = 0;
>         page = pud_page(orig) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
> @@ -2066,8 +2075,20 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
>                 start += nr << PAGE_SHIFT;
>                 pages += nr;
>
> -               ret = get_user_pages_unlocked(start, nr_pages - nr, pages,
> -                                             gup_flags);
> +               if (gup_flags & FOLL_LONGTERM) {
> +                       down_read(&current->mm->mmap_sem);
> +                       ret = __gup_longterm_locked(current, current->mm,
> +                                                   start, nr_pages - nr,
> +                                                   pages, NULL, gup_flags);
> +                       up_read(&current->mm->mmap_sem);
> +               } else {
> +                       /*
> +                        * retain FAULT_FOLL_ALLOW_RETRY optimization if
> +                        * possible
> +                        */
> +                       ret = get_user_pages_unlocked(start, nr_pages - nr,
> +                                                     pages, gup_flags);

I couldn't immediately grok why this path needs to branch on
FOLL_LONGTERM? Won't get_user_pages_unlocked(..., FOLL_LONGTERM) do
the right thing?


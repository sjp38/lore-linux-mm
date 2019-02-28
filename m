Return-Path: <SRS0=CyaI=RD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4A2BC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:40:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7C7952171F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Feb 2019 09:40:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="U0NSmVl8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7C7952171F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F11B8E0004; Thu, 28 Feb 2019 04:40:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 29E648E0001; Thu, 28 Feb 2019 04:40:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18E7F8E0004; Thu, 28 Feb 2019 04:40:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1C248E0001
	for <linux-mm@kvack.org>; Thu, 28 Feb 2019 04:40:41 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id w19so15171253ioa.15
        for <linux-mm@kvack.org>; Thu, 28 Feb 2019 01:40:41 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=S26r9EQQiDPxNxYvJmNZCbJAOL1UM5RvwiPMkziSBzg=;
        b=glvfOBU/VRG9KvnCOwFSfDu7oGjusIxhUJaDWRjbq2wL3/M8YzqqXq4So44+RH232v
         gNsXWL9MEwWfU/Hny5om99nZGLKxn3AYN3m3PvzT+wOIMiWZiR6ftaV4kRZYJD86vB9g
         z1vy1Iz6EAIH2PRjHJuBpEKh3IKThDjG/yI3aoEpWqhUId/nF9v4eePzpmNBhr4VUfij
         uT2Uq9XbzyajtQ4KJtOxctVcOHYU5azgYFlh14yyOPFwXWtV5aPjRObaDT1JS1WAUHwf
         CpII9swe8rF6g5WadxMmmiDKXOq2fFJX3gESpAH7u1uHU7yfiFKMqQTNkOuJGn3faoLB
         JahQ==
X-Gm-Message-State: APjAAAXNEyBAusgQxitOT42Ggxj1Dl7XQuevzrpeUP5yKA9de6uwiVpn
	5DLKNUM0bcZR74SSs1i5aXlZdFAbaJyHALaxYpaGNSF/MBVNyhE0D2Rax7KNxkpLrf1xTZHNbVD
	EswjxTa6D5NpSZ3/tFus11RTlkRl3VhqFyc/ESHQ8ty5ELHHiDUElTCzDnbctWVe1vJF3MOLVv0
	RG3MHFlTHwtPah5qnT7YgAx/bMoPr/7w0Gy7pi9KcEN7q3nLEs6AFsnUKeT6WtFLM5BBMY5ro1v
	CiSEzp95iskjD+iCh9s13t2C0bYm1M6qsklfkZL9EsgKv98TeewPS/0A1Rcp+oJue17pziUC0l1
	qgTtwEH8mWD8Zjio3ADSMEihYgegW/F1I5ASivuzJ7fm0us4VXGiGdX7uWX+h4uQ+Hoj8xgWT7u
	H
X-Received: by 2002:a6b:fd04:: with SMTP id c4mr1297454ioi.290.1551346841671;
        Thu, 28 Feb 2019 01:40:41 -0800 (PST)
X-Received: by 2002:a6b:fd04:: with SMTP id c4mr1297431ioi.290.1551346840845;
        Thu, 28 Feb 2019 01:40:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551346840; cv=none;
        d=google.com; s=arc-20160816;
        b=aI7BD567KS+Ie5xrkv60pLvD2vTDcTd6HkG8jKAC3H56n4DctlmINxpMUCXGQIaCry
         AmNIMCe+sHbA9QaQzxgcFPJztW+FxHehZId2VibGjn1soDr+tUGpqlwWhNVLX5H366S9
         Eb2noyOSNLwV0t76jIGj0VennDHDB8bhj6t+8gsGJtIpjwQJ4pvDtY9jCKYVG9ICxeSe
         of2127pF1oaM6raBlPTvY81TC0Grp+DrGfXGlf/n8q2YRjoauaIecUA5B51L6/lwXEvQ
         deIul8mwnxld6ylcX/PmXoMH8MgW4TPx6n1vDZl6GDwWhudDctL+RSxbFLdca9ZqkY5v
         gymA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=S26r9EQQiDPxNxYvJmNZCbJAOL1UM5RvwiPMkziSBzg=;
        b=r4NT40BZKU3VhBCSzseVAGYwPS/p7ARzxPgRhVKtlY6gXy/20uPNuibtGnFtSzrrJK
         8CAp1zsNbtyVkwZgpC1mdKLDzEK9Q5R5+WXbQ2MzVNSvAlw40bSYDlbsRbD3JN77t/dQ
         9dG4v+gJMIg4OODd7rYoR7FYFhHwCny4BHr3ZRQghmc4OYnt6vWh7/y3sKD+B88iH9T8
         frPuKk1ZzcPOUw+FPS6UxISyalEVJTY4Uw0zRtgUWDmRMar+oOwLlVW/UQhXMoWxTREi
         Mh7p+hA4Z1leYCi9EYzPrXIHZc5XAnhqI6PEGqZNlKIPU5Ci+SW/CH7QNUQHGiSZas/b
         YnSA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U0NSmVl8;
       spf=pass (google.com: domain of oohall@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oohall@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 10sor3427364itx.1.2019.02.28.01.40.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Feb 2019 01:40:40 -0800 (PST)
Received-SPF: pass (google.com: domain of oohall@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=U0NSmVl8;
       spf=pass (google.com: domain of oohall@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oohall@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=S26r9EQQiDPxNxYvJmNZCbJAOL1UM5RvwiPMkziSBzg=;
        b=U0NSmVl8J7o8diMWrXaBfCRVVO9hkRPtkZrl6aaI7DAn6GobljIhfpFjav5mIPIS8h
         Jk0/ckQ2BcKcJGSZvPPqxMlWGkVVCunbaOGBPIGjep6k6E67Fut0r+hD1iE5++BFqjW7
         GFWekBaixpATDluYe1h0LFj3/KwhqNt38di+s6OczOUlUI7ibcqMgSsAB/V8h2f/WN7e
         pezFFRymqiaSWEq7rnyCdFnjeYNigblLeWPm32VhX4TIdyBhcjaOdu+k3ZqXMLYzRVWp
         HOphgOgOJxLBW3x+LFR9N7yNccsd8OSEGxbuDGnfHw/ykkEdlnnOnCo+Kh+MTFIcWPku
         xp3Q==
X-Google-Smtp-Source: APXvYqyLNampIdRkpMVsvaM4M4JZbyfAswlr4iCIih/PAb6NXl9jqGpo35tzyFoMCexDlnISxW3EVxD6yAbte4aapG0=
X-Received: by 2002:a24:5ec1:: with SMTP id h184mr2240354itb.4.1551346840414;
 Thu, 28 Feb 2019 01:40:40 -0800 (PST)
MIME-Version: 1.0
References: <20190228083522.8189-1-aneesh.kumar@linux.ibm.com> <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
In-Reply-To: <20190228083522.8189-2-aneesh.kumar@linux.ibm.com>
From: Oliver <oohall@gmail.com>
Date: Thu, 28 Feb 2019 20:40:29 +1100
Message-ID: <CAOSf1CHjkyX2NTex7dc1AEHXSDcWA_UGYX8NoSyHpb5s_RkwXQ@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/dax: Don't enable huge dax mapping by default
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>, Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, 
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.cz>, 
	Michael Ellerman <mpe@ellerman.id.au>, Ross Zwisler <zwisler@kernel.org>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 28, 2019 at 7:35 PM Aneesh Kumar K.V
<aneesh.kumar@linux.ibm.com> wrote:
>
> Add a flag to indicate the ability to do huge page dax mapping. On architecture
> like ppc64, the hypervisor can disable huge page support in the guest. In
> such a case, we should not enable huge page dax mapping. This patch adds
> a flag which the architecture code will update to indicate huge page
> dax mapping support.

*groan*

> Architectures mostly do transparent_hugepage_flag = 0; if they can't
> do hugepages. That also takes care of disabling dax hugepage mapping
> with this change.
>
> Without this patch we get the below error with kvm on ppc64.
>
> [  118.849975] lpar: Failed hash pte insert with error -4
>
> NOTE: The patch also use
>
> echo never > /sys/kernel/mm/transparent_hugepage/enabled
> to disable dax huge page mapping.
>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
> ---
> TODO:
> * Add Fixes: tag
>
>  include/linux/huge_mm.h | 4 +++-
>  mm/huge_memory.c        | 4 ++++
>  2 files changed, 7 insertions(+), 1 deletion(-)
>
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index 381e872bfde0..01ad5258545e 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -53,6 +53,7 @@ vm_fault_t vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>                         pud_t *pud, pfn_t pfn, bool write);
>  enum transparent_hugepage_flag {
>         TRANSPARENT_HUGEPAGE_FLAG,
> +       TRANSPARENT_HUGEPAGE_DAX_FLAG,
>         TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>         TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG,
>         TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG,
> @@ -111,7 +112,8 @@ static inline bool __transparent_hugepage_enabled(struct vm_area_struct *vma)
>         if (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_FLAG))
>                 return true;
>
> -       if (vma_is_dax(vma))
> +       if (vma_is_dax(vma) &&
> +           (transparent_hugepage_flags & (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG)))
>                 return true;

Forcing PTE sized faults should be fine for fsdax, but it'll break
devdax. The devdax driver requires the fault size be >= the namespace
alignment since devdax tries to guarantee hugepage mappings will be
used and PMD alignment is the default. We can probably have devdax
fall back to the largest size the hypervisor has made available, but
it does run contrary to the design. Ah well, I suppose it's better off
being degraded rather than unusable.

>         if (transparent_hugepage_flags &
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index faf357eaf0ce..43d742fe0341 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -53,6 +53,7 @@ unsigned long transparent_hugepage_flags __read_mostly =
>  #ifdef CONFIG_TRANSPARENT_HUGEPAGE_MADVISE
>         (1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
>  #endif
> +       (1 << TRANSPARENT_HUGEPAGE_DAX_FLAG) |
>         (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG)|
>         (1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
>         (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
> @@ -475,6 +476,8 @@ static int __init setup_transparent_hugepage(char *str)
>                           &transparent_hugepage_flags);
>                 clear_bit(TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
>                           &transparent_hugepage_flags);
> +               clear_bit(TRANSPARENT_HUGEPAGE_DAX_FLAG,
> +                         &transparent_hugepage_flags);
>                 ret = 1;
>         }
>  out:

> @@ -753,6 +756,7 @@ static void insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>         spinlock_t *ptl;
>
>         ptl = pmd_lock(mm, pmd);
> +       /* should we check for none here again? */

VM_WARN_ON() maybe? If THP is disabled and we're here then something
has gone wrong.

>         entry = pmd_mkhuge(pfn_t_pmd(pfn, prot));
>         if (pfn_t_devmap(pfn))
>                 entry = pmd_mkdevmap(entry);
> --
> 2.20.1
>


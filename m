Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 60116C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:34:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07B7F2253D
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 01:34:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="NIHnQ29X"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07B7F2253D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A7BF08E0003; Tue, 23 Jul 2019 21:34:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A2CA08E0002; Tue, 23 Jul 2019 21:34:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 91B2E8E0003; Tue, 23 Jul 2019 21:34:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 697198E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 21:34:47 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id a198so17407486oii.15
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 18:34:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=U3S9mbYQLIeM0ynsPRK/801CRvgA1ufAcDvniZwp830=;
        b=rcHLhjVLh3q5lpdNuWgY7obEKLuzw0AhyO5m8G5OGBGmt8BJKjMVlhVU+vkvjJ29lj
         eT39OnjutS/alDrduTjJpa1Ls0T2uUzrMNhCv5apSJGN23x47Nc7OJt8B6v867b0ocWd
         hxOcKh0lbHmLr36lu8bdo1yqzm6w2CL0jVm/9NGsKqanMIkCeI36lLxfn2WUdLdAtk6S
         RXOUw43wQp8KaUPH7l7JC0FRLOGQPorgokdknRNKFoVSw6waj1/NpBWtMepK96pH0sRf
         rml177k+m3AAbw1OXmU80ECFo/WwxXdC4ziKgUw3KyhplTkj/Y0RfgjWDFIf7Gsz7IYW
         GpnA==
X-Gm-Message-State: APjAAAV3h1ZGCuitQK+ICLWh3GKsIolq7takEKVaHS0T4Eu5WpF4EKgM
	iWVoKJAgzYhb6jWv+ac/EaJ0CHovLqc/SydF5C7KtSy8n+4W9q+CeI6bJSqYEqDlUPDHBiD21mW
	POQQrQPdfaWO1KmEGcT4pnIrB/znKECKHas7sPKgCIBdoH7Cm1fXE0ik6/zDKZtZRng==
X-Received: by 2002:aca:5451:: with SMTP id i78mr38220335oib.85.1563932086908;
        Tue, 23 Jul 2019 18:34:46 -0700 (PDT)
X-Received: by 2002:aca:5451:: with SMTP id i78mr38220319oib.85.1563932086132;
        Tue, 23 Jul 2019 18:34:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563932086; cv=none;
        d=google.com; s=arc-20160816;
        b=huS6koKwqa3UYLyczAAo2u89fWbOd6J+NmvhxuFoBN6/Wi9/0/3bMoQR19WoR8i4Mg
         MXa5aqYBr08771++yMc/p/cl0/7TGvV5vxcY4/4QETuLMOy9J6K3F6eFDrfT2fuosaJi
         hL1yO0t28zdgkpvOJvjamjCmuBCK7tZ47y7mop0+Cdi1HuDlycJ7FTIBRP09musQSOfr
         ye4oFw5OfhfwFeNe2NrW69u6O95j+f2oDfW2NSX6jEa8FnYmx8NEFJhxcihHOA/67RJS
         qDbisJozqqxabU3IJvfsVKD2hArUVMdyr4ycDFhaT/XRfMTLPE5ytG9TXyN5Fb76+D1H
         ahJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=U3S9mbYQLIeM0ynsPRK/801CRvgA1ufAcDvniZwp830=;
        b=VaMsxvyufk3Ma5PV3HidrMcbAX/5UdEOMyU8V9VtK7ViARddy+pUu/9nZ3w4sYazYB
         zykIC13dOdwidTqbDzW7oEti7QPkVGbila3muvjs/OOO49TPc+tYuackJdJUfUFBhnvP
         FZinbassz677WHjWQ11uBoJvkNiPDmtRbBSoV+5HXED9JieVbvWE/kpbX5TFdStM5fbX
         VPL+v380Lzdy/v3tse6OEJAts+Aa/kL+oofBJ0IkP0161n49VDylgMaf7N8W4TirVRsT
         NI5KiLnyfE7d0cWnYqlTbYCBaxo8sLNFgMV7IYf3aFrEOcPRa/mWEJRMztqEz2uKsyZc
         LaTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NIHnQ29X;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z22sor23467471ote.183.2019.07.23.18.34.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 18:34:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=NIHnQ29X;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=U3S9mbYQLIeM0ynsPRK/801CRvgA1ufAcDvniZwp830=;
        b=NIHnQ29XndgfKPymWUi4yCNTFzpjOZnMhr6bsTZB/j9y6eMoCeLVi6Dm5xvBoVW+jE
         cu9IC2dU8ELh6LxXosO/8+NswDEPLR4BVdkJ/XSRLQTdO6SwWN61AksT6xo9Y0fi7WK4
         RZS4lBpADWJx1DCy0g3mNSKJNCpfvTBFjFJ1vAyDqPuGsjTQArJFxKs3nTsA7SlHVEWm
         w1gtupAQNyKPb3EMka9H+PVSrrilnnJWOJ0et2zG3p2ZdGZBMeZpozbnAe58eR1jtRYv
         6zIzbzA7RZKx5F+EVm58P7n81tvifE9nKmOufZseqqbEjPbnzNhMV4C2NO/gHodcAPow
         5ZZA==
X-Google-Smtp-Source: APXvYqyI2OHpoRJh8zDWQ9QMZXHOONWV8Hp51Nx/L3PkeNKCrW++Ku0GXVFb7qeDsjzjWfpEJO+K9adsMkakhDQxEd0=
X-Received: by 2002:a9d:7a9a:: with SMTP id l26mr53216650otn.71.1563932085858;
 Tue, 23 Jul 2019 18:34:45 -0700 (PDT)
MIME-Version: 1.0
References: <1563925110-19359-1-git-send-email-jane.chu@oracle.com>
In-Reply-To: <1563925110-19359-1-git-send-email-jane.chu@oracle.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 23 Jul 2019 18:34:35 -0700
Message-ID: <CAPcyv4hyvHFnSE4AUbXooxX_Ug-raxAJgzC7jzkHp_mSg_sCmg@mail.gmail.com>
Subject: Re: [PATCH] mm/memory-failure: Poison read receives SIGKILL instead
 of SIGBUS if mmaped more than once
To: Jane Chu <jane.chu@oracle.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux MM <linux-mm@kvack.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-nvdimm <linux-nvdimm@lists.01.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 4:49 PM Jane Chu <jane.chu@oracle.com> wrote:
>
> Mmap /dev/dax more than once, then read the poison location using address
> from one of the mappings. The other mappings due to not having the page
> mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
> over SIGBUS, so user process looses the opportunity to handle the UE.
>
> Although one may add MAP_POPULATE to mmap(2) to work around the issue,
> MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
> isn't always an option.
>
> Details -
>
> ndctl inject-error --block=10 --count=1 namespace6.0
>
> ./read_poison -x dax6.0 -o 5120 -m 2
> mmaped address 0x7f5bb6600000
> mmaped address 0x7f3cf3600000
> doing local read at address 0x7f3cf3601400
> Killed
>
> Console messages in instrumented kernel -
>
> mce: Uncorrected hardware memory error in user-access at edbe201400
> Memory failure: tk->addr = 7f5bb6601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> dev_pagemap_mapping_shift: page edbe201: no PUD
> Memory failure: tk->size_shift == 0
> Memory failure: Unable to find user space address edbe201 in read_poison
> Memory failure: tk->addr = 7f3cf3601000
> Memory failure: address edbe201: call dev_pagemap_mapping_shift
> Memory failure: tk->size_shift = 21
> Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of failure to unmap corrupted page
>   => to deliver SIGKILL
> Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memory corruption
>   => to deliver SIGBUS
>
> Signed-off-by: Jane Chu <jane.chu@oracle.com>
> ---
>  mm/memory-failure.c | 16 ++++++++++------
>  1 file changed, 10 insertions(+), 6 deletions(-)
>
> diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> index d9cc660..7038abd 100644
> --- a/mm/memory-failure.c
> +++ b/mm/memory-failure.c
> @@ -315,7 +315,6 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
>
>         if (*tkc) {
>                 tk = *tkc;
> -               *tkc = NULL;
>         } else {
>                 tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
>                 if (!tk) {
> @@ -331,16 +330,21 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
>                 tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
>
>         /*
> -        * In theory we don't have to kill when the page was
> -        * munmaped. But it could be also a mremap. Since that's
> -        * likely very rare kill anyways just out of paranoia, but use
> -        * a SIGKILL because the error is not contained anymore.
> +        * Indeed a page could be mmapped N times within a process. And it's possible
> +        * that not all of those N VMAs contain valid mapping for the page. In which
> +        * case we don't want to send SIGKILL to the process on behalf of the VMAs
> +        * that don't have the valid mapping, because doing so will eclipse the SIGBUS
> +        * delivered on behalf of the active VMA.
>          */
>         if (tk->addr == -EFAULT || tk->size_shift == 0) {
>                 pr_info("Memory failure: Unable to find user space address %lx in %s\n",
>                         page_to_pfn(p), tsk->comm);
> -               tk->addr_valid = 0;
> +               if (tk != *tkc)
> +                       kfree(tk);
> +               return;
>         }
> +       if (tk == *tkc)
> +               *tkc = NULL;
>         get_task_struct(tsk);
>         tk->tsk = tsk;
>         list_add_tail(&tk->nd, to_kill);

Concept and policy looks good to me, and I never did understand what
the mremap() case was trying to protect against.

The patch is a bit difficult to read (not your fault) because of the
odd way that add_to_kill() expects the first 'tk' to be pre-allocated.
May I ask for a lead-in cleanup that moves all the allocation internal
to add_to_kill() and drops the **tk argument?


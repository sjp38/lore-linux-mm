Return-Path: <SRS0=SBXn=SP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4CC25C282CE
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 15:11:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC0E02073F
	for <linux-mm@archiver.kernel.org>; Sat, 13 Apr 2019 15:11:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ot0ehbWH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC0E02073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 49C6F6B0005; Sat, 13 Apr 2019 11:11:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 424706B0007; Sat, 13 Apr 2019 11:11:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2C5FD6B0008; Sat, 13 Apr 2019 11:11:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id B8D906B0005
	for <linux-mm@kvack.org>; Sat, 13 Apr 2019 11:11:35 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id m85so2801103lje.19
        for <linux-mm@kvack.org>; Sat, 13 Apr 2019 08:11:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc
         :content-transfer-encoding;
        bh=Znuv7PRVSTefHhJ5YWIem4mXL9RvNBKhNffRq5l2N9M=;
        b=EhIK/qKIONAm6XRHxa6y6cK7elR/f/KuXHoL5kpoi/pJ3rUeSMvTYZ+3upGKMkjgYY
         tOGHCI/r3ItH4M/O6HtMm3C+7kiLcQRz39nBFm9ify36lqhMhV4PpxVSHsptyLp7SKX5
         oKjJj0OY7QeYd5MbAe5gYV2n3Znj0Sv3QwuGtYAyLuTq7I1V7x/GudHYUI51kbXwYmez
         tPe2S8blILan0WfbC79j5/eLkuBvbX0QR2es24vA67oxyRs3zUoFmZ7a4O1Kx5wXyNBT
         ACoY/6W5WyUKVkA5lrYJJTKsSI38DTPzzU0dQTNexw2zl9kLEpFAxKp31wyiIYiqVIzy
         G6xQ==
X-Gm-Message-State: APjAAAUS+5Q/YOuXTXk3zTBxFHyZAd1yEJwRdyuvHmm8gOAu96A/kiAr
	XPldzzc06cP4O9I32ikd5lKnZnDTbILdek8JsK8zxKjDIzS1xo9aLPO/p//+GJZKm0bq6nvX+K4
	WyO9Ak7i7IxeTxBXPbMyy5/YDSte+WsAislh/dVqn16a6TYEy5pglhStUxW6074TSaQ==
X-Received: by 2002:a2e:9d99:: with SMTP id c25mr8752154ljj.159.1555168294789;
        Sat, 13 Apr 2019 08:11:34 -0700 (PDT)
X-Received: by 2002:a2e:9d99:: with SMTP id c25mr8752082ljj.159.1555168292591;
        Sat, 13 Apr 2019 08:11:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555168292; cv=none;
        d=google.com; s=arc-20160816;
        b=AZN+X8Qud1vskmwND5XuYrTI2+94tDybjk+O0GjA9NTmtO+n3MVYUSX64ew+ZLEqcK
         BIPGvcPjAkHmveS+5aFUC0gtk6+7blwqB9lXQY+rhAnxj5TbF89Qp4SZltqZJTKWgWBN
         vAIuG88CmSMmUZxORiGaoIubhSwYiV43RnwkzKABR1DttzojVCpy9fMLPViOezZb1Eu5
         QqeI+Dxjl09XiFKD62G3uCYaSlki3QJlPjbHdtHZ/gouxe7MSQ9toYBZu70OS7Dl1orf
         fpcOXbKdhLxOdfHOJtCUYGH8v6xr55jyZi5TM3p6peRsIJNdnP76VYWeRvwkvqRTd0a7
         146Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=Znuv7PRVSTefHhJ5YWIem4mXL9RvNBKhNffRq5l2N9M=;
        b=P65UnG9wuRxZOhNK1wkqBidTrjc2/l/4ei3n+iWCa5b9wI8wjJhY4BwwMG2U3B6oLY
         3z69kNAtqUvTY/u00lYRe763f8gOeDPZk19a84AU1S0UsiPE274sN31zvUZdf1Hn2tf9
         ZuFDZdxCflkHaWJ3NtXKw3EXK2UF8nirMQWxVzqDwQABARqgmrjTrwy/zfioqvsb3kHn
         wY2n5wuXqr+G3Zk0mWDLwTKupvkcz8DiRvzwpji3/bjfPUw7YrE4cb7nh5Odvhom49gW
         E/BtTRjwtFO0Pp7a/JHQO6qkB5iuT1G1yIItbVEV8FgA/qRFlJvkgKpyLcIjT8Fsm8jV
         44Pw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ot0ehbWH;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i10sor12477969lfl.61.2019.04.13.08.11.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 13 Apr 2019 08:11:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Ot0ehbWH;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc:content-transfer-encoding;
        bh=Znuv7PRVSTefHhJ5YWIem4mXL9RvNBKhNffRq5l2N9M=;
        b=Ot0ehbWHVvNTRoG3jW64k8a8+ejKS2yDG8ws3t/UJwpif1let11nCitLi6A/LlbrWC
         0upz97XBXiOh9Osu2b/41yd+RXaSXt2C3g2l0FEXR6lI4a7Gnqx2ZabtNIX1rvKCkGqx
         JVwy4vL9ENhMDA36yw/w3Kxn2Mu9cHAQWGSvI1bZ53U3D2LyrrnHgGuyNNOwSvBAXkXP
         spb9V4HQkuWDkYkTuSfXskp5wr0+rGU3CeHyFAh7OCo2S/Ua1Ca/HTga1NijBnOThj0V
         QBVMp0/fDHeSD36N3AMziCVA5r7t9uJfZ0lSDPz2WWsFSqPA6Wf3pe/fpLFtIYstZoGp
         uKbw==
X-Google-Smtp-Source: APXvYqwNYDXdPuWjq1Rfv9JH1RToFW+aPmIH0F3dPFNb8v+Tg3fGnDTl+SifrN7AkqwiDgRRR4Lo0zz5M8x090OQb3s=
X-Received: by 2002:ac2:490b:: with SMTP id n11mr3934378lfi.24.1555168291660;
 Sat, 13 Apr 2019 08:11:31 -0700 (PDT)
MIME-Version: 1.0
References: <20190412160338.64994-1-thellstrom@vmware.com> <20190412160338.64994-2-thellstrom@vmware.com>
In-Reply-To: <20190412160338.64994-2-thellstrom@vmware.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 13 Apr 2019 20:41:19 +0530
Message-ID: <CAFqt6zb4qBdrWev1KEruDzPJt5wP4ax_7hUyz+JMV9zLxd_iiw@mail.gmail.com>
Subject: Re: [PATCH 1/9] mm: Allow the [page|pfn]_mkwrite callbacks to drop
 the mmap_sem
To: Thomas Hellstrom <thellstrom@vmware.com>
Cc: "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	Linux-graphics-maintainer <Linux-graphics-maintainer@vmware.com>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Matthew Wilcox <willy@infradead.org>, Will Deacon <will.deacon@arm.com>, 
	Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@surriel.com>, 
	Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 12, 2019 at 9:34 PM Thomas Hellstrom <thellstrom@vmware.com> wr=
ote:
>
> Driver fault callbacks are allowed to drop the mmap_sem when expecting
> long hardware waits to avoid blocking other mm users. Allow the mkwrite
> callbacks to do the same by returning early on VM_FAULT_RETRY.
>
> In particular we want to be able to drop the mmap_sem when waiting for
> a reservation object lock on a GPU buffer object. These locks may be
> held while waiting for the GPU.
>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Rik van Riel <riel@surriel.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Huang Ying <ying.huang@intel.com>
> Cc: Souptick Joarder <jrdr.linux@gmail.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org
>
> Signed-off-by: Thomas Hellstrom <thellstrom@vmware.com>
> ---
>  mm/memory.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/mm/memory.c b/mm/memory.c
> index e11ca9dd823f..a95b4a3b1ae2 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2144,7 +2144,7 @@ static vm_fault_t do_page_mkwrite(struct vm_fault *=
vmf)
>         ret =3D vmf->vma->vm_ops->page_mkwrite(vmf);
>         /* Restore original flags so that caller is not surprised */
>         vmf->flags =3D old_flags;
> -       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)))
> +       if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_RETRY | VM_FAULT_NO=
PAGE)))

With this patch there will multiple instances of (VM_FAULT_ERROR |
VM_FAULT_RETRY | VM_FAULT_NOPAGE)
in mm/memory.c. Does it make sense to wrap it in a macro and use it ?

>                 return ret;
>         if (unlikely(!(ret & VM_FAULT_LOCKED))) {
>                 lock_page(page);
> @@ -2419,7 +2419,7 @@ static vm_fault_t wp_pfn_shared(struct vm_fault *vm=
f)
>                 pte_unmap_unlock(vmf->pte, vmf->ptl);
>                 vmf->flags |=3D FAULT_FLAG_MKWRITE;
>                 ret =3D vma->vm_ops->pfn_mkwrite(vmf);
> -               if (ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE))
> +               if (ret & (VM_FAULT_ERROR | VM_FAULT_RETRY | VM_FAULT_NOP=
AGE))
>                         return ret;
>                 return finish_mkwrite_fault(vmf);
>         }
> @@ -2440,7 +2440,8 @@ static vm_fault_t wp_page_shared(struct vm_fault *v=
mf)
>                 pte_unmap_unlock(vmf->pte, vmf->ptl);
>                 tmp =3D do_page_mkwrite(vmf);
>                 if (unlikely(!tmp || (tmp &
> -                                     (VM_FAULT_ERROR | VM_FAULT_NOPAGE))=
)) {
> +                                     (VM_FAULT_ERROR | VM_FAULT_RETRY |
> +                                      VM_FAULT_NOPAGE)))) {
>                         put_page(vmf->page);
>                         return tmp;
>                 }
> @@ -3494,7 +3495,8 @@ static vm_fault_t do_shared_fault(struct vm_fault *=
vmf)
>                 unlock_page(vmf->page);
>                 tmp =3D do_page_mkwrite(vmf);
>                 if (unlikely(!tmp ||
> -                               (tmp & (VM_FAULT_ERROR | VM_FAULT_NOPAGE)=
))) {
> +                               (tmp & (VM_FAULT_ERROR | VM_FAULT_RETRY |
> +                                       VM_FAULT_NOPAGE)))) {
>                         put_page(vmf->page);
>                         return tmp;
>                 }
> --
> 2.20.1
>


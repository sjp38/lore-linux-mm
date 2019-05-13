Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 262DCC04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 20:51:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D189F208CA
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 20:51:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oLh+2ZIc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D189F208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 70C006B0007; Mon, 13 May 2019 16:51:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6BD5C6B0008; Mon, 13 May 2019 16:51:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5D24C6B000A; Mon, 13 May 2019 16:51:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E34E6B0007
	for <linux-mm@kvack.org>; Mon, 13 May 2019 16:51:25 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id d64so13941173qkg.20
        for <linux-mm@kvack.org>; Mon, 13 May 2019 13:51:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=XCE4d8xgzTj+ApLSy6o790tUBnnwQ8aL8gQD+z65Npk=;
        b=e8fs7kV1ISX48GFjxnKhvX1P5g4Zo4I/m0+6q1/luB87dJ1NKOLzqxfuFlqOMKmb5z
         s+epv3coEL1WMfRrUE2i9uJbUrS/4h6Oe0cb5uxlBTgIvmqKdgNiCm+DeCp9+BIDqLzT
         whNPEuUdQWrRHCvWsSx2dDnLS1/G6hFq4+AJVmkiiyZdITWoOMsWLISCj0klDAoO67AZ
         3QoOsQPtHYW8Dor+jgrkppg8ym+I4BUsrEM419m7YE8EcYdQRlRyNGdLMxIPYZ7NO5RZ
         36kVAoGOS/YmHjWWEld3pTw7lPGkv5s2WuTUvbsCeM89tr8h1dFhAIjaS8pbuQjdCrht
         bwow==
X-Gm-Message-State: APjAAAWImQS8QeUqgUU70nGi0lb7gx2t7byc0x4VX6bEDrJitHZj1qFF
	70P+fPJMtLJmBXGfsjujcuYnRA4O5mNXWM3uujeDiQ0vnJU2nH8qhmDKKor9JKt/UcZQFYPa1dL
	hTL1r3BemIFD/FB8o+G87GfTObkP0Wy1fvs2nxd767p6dvo/JRMDcpmsOcRypmAlgTQ==
X-Received: by 2002:a37:d243:: with SMTP id f64mr24210962qkj.270.1557780685005;
        Mon, 13 May 2019 13:51:25 -0700 (PDT)
X-Received: by 2002:a37:d243:: with SMTP id f64mr24210879qkj.270.1557780683565;
        Mon, 13 May 2019 13:51:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557780683; cv=none;
        d=google.com; s=arc-20160816;
        b=1INchZ1zpdVFr2TYN/HCj27VCsXS5MizooRjv9kaAYxw9IA0ucfKaTZM7wzGhncW6g
         vlwmJHg27Uy0Q2Lx520e9lZGlGa1p1nksiV+U4YWSiwyOzDKhTXsClcmLDwAto2p7Zzd
         3a9p3t5ADmhwTt5bbgTJCJYxiz870IBSVNQiX0YHzi2WQSKOYTiePZ9e0aHnIRGdR715
         wuh3klaabPtE/L+HbVS90JuHaV2PCaYNGGcF94TGk3yKcR6FE478GfhN2L3uurf2MdX6
         hTnCIgVxMpsYNfdoA/kesuPp/Wa+OpG4XkD225IKUa26aNf4kk6M04nie4SKQbJNu+wY
         if2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=XCE4d8xgzTj+ApLSy6o790tUBnnwQ8aL8gQD+z65Npk=;
        b=Zt25sdhoUeAPJS3frAUBwJAp8Nh0yl5nMZikrhNHl1oddCI7RPYviwSk3rNivkSIfK
         g9IjkD9RqUX+69ksH/8AX5+1XOsdR12ct8+U7s0iZnOsSzxV+avquihGeVhnNEXAhus2
         RXYLL7Gq/bGI7hMK3AzTd39VgBq8Bgvcve9Fnuo61UCzgMRq8VZ0mPMa2eVFaU7q4Psz
         uh3/1hKMGZhsDYETBDDW28MXVgSGnGAbtIDukpQDfyVruH25mh+m7g4cEcAsUklM7/AN
         sVYrf71D3tJuWKsKhjHQG/2mIxFUdbuL0vRkz1juwY/W71u+HdMGrf+CvQOjKQMnfMMU
         XcNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oLh+2ZIc;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l186sor8298029qkc.76.2019.05.13.13.51.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 13:51:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oLh+2ZIc;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=XCE4d8xgzTj+ApLSy6o790tUBnnwQ8aL8gQD+z65Npk=;
        b=oLh+2ZIchTkJsYFpfOt6mDG7Qlmj8hhwZ37YhDZ3T6yP9/oj2Dn1vLkvQHGjZhCNiN
         CMSWAaRfEeNFfc5LoIf3C/TwQAaiP/GItx0N87zeAd/5T3NDE6ybh3ZTEmyIdM4pIBzN
         1ZHo3k+EWsNZTl2XMjKisrEjkMSP1j+kZH1rn2YnkFYXb4AoJp4zz84JfTnYjO1mNZHU
         EIYNI0Krj+TaT1G8VTe17uDP2NxOQVBCj6/aF+FvxwkMIe8AMLZxN91EliK9yejNxJLc
         S3jA2kM27zz5cePmEdvLxZHiZR8kuoZF7oj0OzPPdVj5miw2MV/fvdzgGhi2p8XYHPug
         YN2Q==
X-Google-Smtp-Source: APXvYqxQh6WZy5oCWKNPUfpXQqG9DnbT/SEaHqEZSWogFepFB58/JMQdXePG+PB5GllTaHmvbD0Xts9KXCezVzbT7cs=
X-Received: by 2002:a37:8241:: with SMTP id e62mr23333121qkd.355.1557780683264;
 Mon, 13 May 2019 13:51:23 -0700 (PDT)
MIME-Version: 1.0
References: <1557305432-4940-1-git-send-email-rppt@linux.ibm.com>
In-Reply-To: <1557305432-4940-1-git-send-email-rppt@linux.ibm.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Mon, 13 May 2019 16:51:12 -0400
Message-ID: <CAPhsuW6fGS9OerFBYiyV=j_biQz6JGLoMm7mxzBf7mO9w1ZMEA@mail.gmail.com>
Subject: Re: [PATCH] mm/mprotect: fix compilation warning because of unused
 'mm' varaible
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 8, 2019 at 4:50 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
>
> Since commit 0cbe3e26abe0 ("mm: update ptep_modify_prot_start/commit to
> take vm_area_struct as arg") the only place that uses the local 'mm'
> variable in change_pte_range() is the call to set_pte_at().
>
> Many architectures define set_pte_at() as macro that does not use the 'mm'
> parameter, which generates the following compilation warning:
>
>  CC      mm/mprotect.o
> mm/mprotect.c: In function 'change_pte_range':
> mm/mprotect.c:42:20: warning: unused variable 'mm' [-Wunused-variable]
>   struct mm_struct *mm = vma->vm_mm;
>                     ^~
>
> Fix it by passing vma->mm to set_pte_at() and dropping the local 'mm'
> variable in change_pte_range().
>
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  mm/mprotect.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
>
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index 028c724..61bfe24 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>                 unsigned long addr, unsigned long end, pgprot_t newprot,
>                 int dirty_accountable, int prot_numa)
>  {
> -       struct mm_struct *mm = vma->vm_mm;
>         pte_t *pte, oldpte;
>         spinlock_t *ptl;
>         unsigned long pages = 0;
> @@ -136,7 +135,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
>                                 newpte = swp_entry_to_pte(entry);
>                                 if (pte_swp_soft_dirty(oldpte))
>                                         newpte = pte_swp_mksoft_dirty(newpte);
> -                               set_pte_at(mm, addr, pte, newpte);
> +                               set_pte_at(vma->mm, addr, pte, newpte);

This should be vma->vm_mm.

Thanks,
Song

>
>                                 pages++;
>                         }
> --
> 2.7.4
>


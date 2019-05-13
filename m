Return-Path: <SRS0=GvbC=TN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9EF9C04AA7
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 20:54:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 76A6F206A3
	for <linux-mm@archiver.kernel.org>; Mon, 13 May 2019 20:54:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lslEtF8e"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 76A6F206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 227CB6B000A; Mon, 13 May 2019 16:54:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B2A76B000C; Mon, 13 May 2019 16:54:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0A0246B000D; Mon, 13 May 2019 16:54:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id DCFF36B000A
	for <linux-mm@kvack.org>; Mon, 13 May 2019 16:54:20 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id w41so7063221qth.20
        for <linux-mm@kvack.org>; Mon, 13 May 2019 13:54:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=GV7j3IwADc2IK9aPyb1FTWLuR7lOkwLuIpIclPsDCIk=;
        b=ejzxFJ9JfpfsGNNgnR8Bs0a3U54JwNC1vGf0kYlh2Wn+xtey/0ORIMec83DOBfWPsg
         IYCFWq3pNqRfOCwihQHE1oNROa8CpxZ1kl3GEAVUWiISUuHVBFkmdFyQeQBR3sui5v62
         gmaM1hw/evAZXv8m8/E5/MOCM9Qjftbkx8dAHMWMd3rYJX3xAqpWy7FkMjZukkn8X9Gg
         4pUR6NN/0tXkwhXgo8R/OXGKhaEX1fvPhXsh6ANuz32jh6c4k8xhcJgoJ2xeEw0Rn6RO
         irzDL2rt35NMftr8keHkrovnliLKAcryuFWATlmdKPI0EK7Iv/TuN2LWV79KpDFCW6hX
         Lc9Q==
X-Gm-Message-State: APjAAAUDPcs9a1f8dgwAFRHWgHnxjtC5Z4+pJ71TiLT9s16d8sPbLWzy
	MaBjMUtlOno9RKJwJp2n1ar7TxZSBarSZfhdQXSBXwzKcLP6AnhSe7xV56NEFW2OnAGy4cEg25G
	2WNuQcihzuc1LX4rD8f8WDi1r8PyPz8yXqypKNlDXxD0/kMWVX2IJNhzlnmJWG2sYEw==
X-Received: by 2002:ac8:2f98:: with SMTP id l24mr26344016qta.78.1557780860682;
        Mon, 13 May 2019 13:54:20 -0700 (PDT)
X-Received: by 2002:ac8:2f98:: with SMTP id l24mr26343978qta.78.1557780860228;
        Mon, 13 May 2019 13:54:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557780860; cv=none;
        d=google.com; s=arc-20160816;
        b=ds4uf28gccp+Q7AHd+7xbDWP1Gt+i+49kckeAR27FXqKKuO103peghFDzK8v/vRihj
         D60WwuqilJS94stqHTqDf4yFifOhiuNTguuypAYVKhs01hMRVFInE7A034RmEIBP1d0k
         irW8/w4FmYvYOWPNZBkJE37XqvZ5UWEi/EadwYZOHKZi+kFs+BgNWrEFAGn/ZZqzf+kC
         aPmRspR08SdTAF+Mj4vmVLu3jj10A1YG7PcctV4REAZw7gHpDJVAaR2CetYNcg4cUvNI
         v11s0ZeqXCdiPOKVCAuc1qQ1dUNEjODmF6MLY7hnIhpT6HrzzTxbMQtgbt3ajOkfFOOR
         7Rkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=GV7j3IwADc2IK9aPyb1FTWLuR7lOkwLuIpIclPsDCIk=;
        b=R+L02b3oW3bqknRlwBghNkiube8QLFwfa6KrDwU/V00JX9nZMPxLkwnQ1ta1NC3RyR
         vVRBCTej8DdQlNyFFU//9prZ8o0EGPDOsEmbmkzQQxHP4i8cy3fO/a2BHQPbYXEehv6C
         byW02k1kO2A3sEiOpEsndvUeN0ZVKMvXaumM1fmNkWR2Wm9n0U7qG+oYGOHUDtS5d6Rl
         blfEzf5jFMXX8nT9DAMCNNz3ODN28pW0+DpwHys7EJOOKa3+YENpwC9seeZtF4mOoVUf
         k22aPFqlwfDIhEifIJhOEXrts9xSm+8XXwi0OrAIyVawYBtpFNqG44Ds/5hGgxz7mj0n
         Zwxg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lslEtF8e;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n11sor18837682qtc.28.2019.05.13.13.54.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 May 2019 13:54:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=lslEtF8e;
       spf=pass (google.com: domain of liu.song.a23@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=liu.song.a23@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=GV7j3IwADc2IK9aPyb1FTWLuR7lOkwLuIpIclPsDCIk=;
        b=lslEtF8etDwNwO1gZ5L7yyJiqWgTs8kJoWVYDjRI+Rm/HFLhIfWFpPueiL9emVlz0P
         MJKYOcKSb3iUAOCIwnHuW9O+Yp58WWW5sUrWQOLYqJUynpAuBjLQdkVnR4isNuyY/2yS
         kAKZnzAy1zNM+PHfr7nAy9t6PzgZR6pJAcTHIh5hUW2VPdOF9Joj459O1h220ZSm6mwn
         fEypJ9dO14zrolTQsAOu72OQVBHmcpNS2cTceeRuTb+Xjc9C/xD0ljYDcuZqrRq2KKgw
         bm19rdIL/mxwmsGpFQtDrfHqX5LGW5nVYfCuO+30Vb7hU0JvWvsy40rZUZynNLwqS15t
         Jtsw==
X-Google-Smtp-Source: APXvYqw2UGe93fIFT4dC2dptqn3S524F8i6IWlZt13XobCabG2I51MNNaroyGLGdfc08s9b3cChABSASQjtGsvbovMU=
X-Received: by 2002:aed:3b0a:: with SMTP id p10mr4502304qte.194.1557780860006;
 Mon, 13 May 2019 13:54:20 -0700 (PDT)
MIME-Version: 1.0
References: <1557305432-4940-1-git-send-email-rppt@linux.ibm.com> <CAPhsuW6fGS9OerFBYiyV=j_biQz6JGLoMm7mxzBf7mO9w1ZMEA@mail.gmail.com>
In-Reply-To: <CAPhsuW6fGS9OerFBYiyV=j_biQz6JGLoMm7mxzBf7mO9w1ZMEA@mail.gmail.com>
From: Song Liu <liu.song.a23@gmail.com>
Date: Mon, 13 May 2019 16:54:08 -0400
Message-ID: <CAPhsuW6wcQgYLHNdBdw6m0YiR4RWsS4XzfpSKU7wBLLeOCTbpw@mail.gmail.com>
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

On Mon, May 13, 2019 at 4:51 PM Song Liu <liu.song.a23@gmail.com> wrote:
>
> On Wed, May 8, 2019 at 4:50 AM Mike Rapoport <rppt@linux.ibm.com> wrote:
> >
> > Since commit 0cbe3e26abe0 ("mm: update ptep_modify_prot_start/commit to
> > take vm_area_struct as arg") the only place that uses the local 'mm'
> > variable in change_pte_range() is the call to set_pte_at().
> >
> > Many architectures define set_pte_at() as macro that does not use the 'mm'
> > parameter, which generates the following compilation warning:
> >
> >  CC      mm/mprotect.o
> > mm/mprotect.c: In function 'change_pte_range':
> > mm/mprotect.c:42:20: warning: unused variable 'mm' [-Wunused-variable]
> >   struct mm_struct *mm = vma->vm_mm;
> >                     ^~
> >
> > Fix it by passing vma->mm to set_pte_at() and dropping the local 'mm'
> > variable in change_pte_range().
> >
> > Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> > ---
> >  mm/mprotect.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> >
> > diff --git a/mm/mprotect.c b/mm/mprotect.c
> > index 028c724..61bfe24 100644
> > --- a/mm/mprotect.c
> > +++ b/mm/mprotect.c
> > @@ -39,7 +39,6 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >                 unsigned long addr, unsigned long end, pgprot_t newprot,
> >                 int dirty_accountable, int prot_numa)
> >  {
> > -       struct mm_struct *mm = vma->vm_mm;
> >         pte_t *pte, oldpte;
> >         spinlock_t *ptl;
> >         unsigned long pages = 0;
> > @@ -136,7 +135,7 @@ static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
> >                                 newpte = swp_entry_to_pte(entry);
> >                                 if (pte_swp_soft_dirty(oldpte))
> >                                         newpte = pte_swp_mksoft_dirty(newpte);
> > -                               set_pte_at(mm, addr, pte, newpte);
> > +                               set_pte_at(vma->mm, addr, pte, newpte);
>
> This should be vma->vm_mm.

And we need to fix another reference to mm:

diff --git i/mm/mprotect.c w/mm/mprotect.c
index 8bdba81685d6..bf38dfbbb4b4 100644
--- i/mm/mprotect.c
+++ w/mm/mprotect.c
@@ -135,7 +135,7 @@ static unsigned long change_pte_range(struct
vm_area_struct *vma, pmd_t *pmd,
                                newpte = swp_entry_to_pte(entry);
                                if (pte_swp_soft_dirty(oldpte))
                                        newpte = pte_swp_mksoft_dirty(newpte);
-                               set_pte_at(vma->mm, addr, pte, newpte);
+                               set_pte_at(vma->vm_mm, addr, pte, newpte);

                                pages++;
                        }
@@ -149,7 +149,7 @@ static unsigned long change_pte_range(struct
vm_area_struct *vma, pmd_t *pmd,
                                 */
                                make_device_private_entry_read(&entry);
                                newpte = swp_entry_to_pte(entry);
-                               set_pte_at(mm, addr, pte, newpte);
+                               set_pte_at(vma->vm_mm, addr, pte, newpte);

                                pages++;
                        }


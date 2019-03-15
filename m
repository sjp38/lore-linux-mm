Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS,URIBL_BLOCKED autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D3763C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:01:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 857F22064A
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:01:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AYWvseix"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 857F22064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0DB236B02A3; Fri, 15 Mar 2019 15:01:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 08B656B02A4; Fri, 15 Mar 2019 15:01:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EBB6B6B02A5; Fri, 15 Mar 2019 15:01:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 88BB56B02A3
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:01:16 -0400 (EDT)
Received: by mail-lf1-f70.google.com with SMTP id s26so948171lfc.7
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:01:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yesOFHHDBY3QkCI/a9ODnYSonunyDSZhtIejo7P4ch0=;
        b=PRGAQctgZvdSiQSh2SUTcTFRMmPx0mtrpTFL97NXL2gsD39ae3oAUAcPhwgc7C6Iha
         TP0kReMV4qAF8S5h0QR9WxuDtNOXKRNs/A4IzjjIqyBMHj06OPQIh0JhsAW673ogB+bv
         szQpPJwIoegRAIGNC8X0IszX4uC6Y/zeIyI491Poy2N4c5xuiLWOEq2/0pVrSb7+mg1n
         5vXuAgqQDRNuC9YLQgAUsEj320X+ddTc6F/yqbvBrrgxbnrZE3lDNBaAIOXYaRfehG/Q
         S205UQmBTu0dmOt4x/SXB1301tAA64N7uC1jz17zMwEFRteUnlf/QMqmqsHYQVm3PucH
         O2jw==
X-Gm-Message-State: APjAAAXH0VRt+4kSG5+nK8DGkR6hwaPiw4uZ0dC4fn1dHUqtU++pGLBA
	g2moumg3JaP2IsUTVUgPEDk+ctHZZwXjPLgP7bukohHoPyS12q87r8pJokWqTFy5gyeo1xiFgDI
	HZLdvTG2C2LDDEBkhpHOT/1NIKmX5Jx0kNCKB2RpAJX4J2vswitAQJBZjyNo30/iCaQ==
X-Received: by 2002:a2e:425b:: with SMTP id p88mr2936327lja.78.1552676475835;
        Fri, 15 Mar 2019 12:01:15 -0700 (PDT)
X-Received: by 2002:a2e:425b:: with SMTP id p88mr2936274lja.78.1552676474265;
        Fri, 15 Mar 2019 12:01:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552676474; cv=none;
        d=google.com; s=arc-20160816;
        b=kGDvmwjATcIRe1HfasCJjMLYJnjMGsJqNW29BEgXW8rhC64vLoSetWCLhhKnbJTtEj
         pIMh0hCYGRukjbGo3sAUgtNWPh4XFiSl39Z53umTJoLY+KGx93AG6frungsl5Q7SWuVD
         mKGjllOrIjokP7jwwQeUE/1rsVQRJQqSHuC1ahf5UfaujAnhS1fbcf95+ogyG+F/Tfh2
         3Kt7l6ZLvbhpUaUJMqWelM+qU6X7DnU2n7gQgE4GqwZ2DDRRz9SVRz7VB/EgkXWW5PgQ
         wcziXlBo88m4FmwS/9rPIgYlNURMgthxPnEytZSO3ZsgU7J8qwuoDrohS3M1heAswdRv
         UnSw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yesOFHHDBY3QkCI/a9ODnYSonunyDSZhtIejo7P4ch0=;
        b=uSu8/bPfeQNuBhb+iXbxJxY3aZ37kzSv0V2VKVa/d46U9vSEXaQnGZyclVFWuuf7L0
         INeRiZ+O/JPzj+3PSRxKC5KFeYGkMA8RfXRIgbqjbJ/JXDZpN0orNR6X2nDg119fI4VW
         kweB0bJUUjmVHD9nVweglUAXIAo5naA/JjQ3WLq4XC68NtvTS7IpOuRKW5V7LnqbX77p
         PASOYNI3visCFjs1En9uhx/kUvE2OOnxFTqhZMX/m0ZI+FPPMxckMQdbm4k6ih3OZ6x5
         iWyp0ocmGynP6m5gt0PUFFgzNlQWo6D2g+B2xZhdyG0TUirLLqDF7W4nMDzWz2n9yN4L
         7dKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AYWvseix;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s19sor2065501ljs.28.2019.03.15.12.01.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:01:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AYWvseix;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yesOFHHDBY3QkCI/a9ODnYSonunyDSZhtIejo7P4ch0=;
        b=AYWvseixV2GFDujELCi41k4cxxBpvBExorfgtyEBfxe2MvHSXwZJCDenPNO31Q+aqM
         iP6MtImJUUutMErdXrKSjwxWn/tWklmfl7Mb4Il+gDimQacOc/lvoXoa50AJ+RxGUVrc
         zLr4v85sPJA1VdS1HiVJVGpBsYr0Dgzc0dCIoGiSAJdGKHFjCG7gpsF10WR9NsU1QpHV
         omFdJO1HcmiXuoO89VVn9M7Du2jz+kM8nlCzWh1VGbok2QA2zvpvTII04m2Kc6I7oAx+
         wVbTzakAna+jQ+Co6DjoohoM6q14c1HcLiyB8g/OtROS5ec1i0U+rdofmVvbhXEjvtzO
         wLzQ==
X-Google-Smtp-Source: APXvYqzxdACwe10cqCQ6v30ixuPB1+IrIlbx/VIYIXm/YzG/CFFOY/ktNEq4MES1VVdU2v4CgAG8owa9gdbB4i0Eu7k=
X-Received: by 2002:a2e:8793:: with SMTP id n19mr3077313lji.9.1552676473554;
 Fri, 15 Mar 2019 12:01:13 -0700 (PDT)
MIME-Version: 1.0
References: <201903140301.VeDCo2VR%lkp@intel.com> <CAFqt6zaA1t1+vPL8hk7Rm6B4ZqG6maK+Z1HAkL0aF93=q4MeOQ@mail.gmail.com>
 <20190314160052.GM19508@bombadil.infradead.org>
In-Reply-To: <20190314160052.GM19508@bombadil.infradead.org>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Sat, 16 Mar 2019 00:35:37 +0530
Message-ID: <CAFqt6za4x8DCoRdyFDcmR8A+CczebqNRKDKhvkz06JRN5_Hnrg@mail.gmail.com>
Subject: Re: mm/memory.c:3968:21: sparse: incorrect type in assignment
 (different base types)
To: Matthew Wilcox <willy@infradead.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-kernel@vger.kernel.org, 
	William Kucharski <william.kucharski@oracle.com>, Mike Rapoport <rppt@linux.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, 
	Linux Memory Management List <linux-mm@kvack.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Matthew,

On Thu, Mar 14, 2019 at 9:30 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Thu, Mar 14, 2019 at 03:10:19PM +0530, Souptick Joarder wrote:
> > > >> mm/memory.c:3968:21: sparse: incorrect type in assignment (different base types) @@    expected restricted vm_fault_t [usertype] ret @@    got e] ret @@
> > >    mm/memory.c:3968:21:    expected restricted vm_fault_t [usertype] ret
> > >    mm/memory.c:3968:21:    got int
> >
> > Looking into https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> > hugetlb_fault() is converted to return vm_fault_t. Not sure, why sparse is
> > still throwing warnings.
>
> Because there are two definitions of hugetlb_fault():
>
> $ git grep -wn hugetlb_fault
> include/linux/hugetlb.h:108:vm_fault_t hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
> include/linux/hugetlb.h:206:#define hugetlb_fault(mm, vma, addr, flags) ({ BUG(); 0; })

make ARCH=x86_64 allmodconfig will set CONFIG_HUGETLB_PAGE =y
which means it shouldn't use the hugetlb_fault() macro in this case.
With *make ARCH=x86_64 allmodconfig* I am unable to reproduce the issue.

But consider the warnings, does the below change is fine ?

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 087fd5f4..0ee502a 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -203,7 +203,6 @@ static inline void hugetlb_show_meminfo(void)
 #define pud_huge(x)    0
 #define is_hugepage_only_range(mm, addr, len)  0
 #define hugetlb_free_pgd_range(tlb, addr, end, floor, ceiling) ({BUG(); 0; })
-#define hugetlb_fault(mm, vma, addr, flags)    ({ BUG(); 0; })
 #define hugetlb_mcopy_atomic_pte(dst_mm, dst_pte, dst_vma, dst_addr, \
                                src_addr, pagep)        ({ BUG(); 0; })
 #define huge_pte_offset(mm, address, sz)       0
@@ -234,6 +233,13 @@ static inline void __unmap_hugepage_range(struct
mmu_gather *tlb,
 {
        BUG();
 }
+static inline vm_fault_t hugetlb_fault(struct mm_struct *mm,
+                               struct vm_area_struct *vma, unsigned
long address,
+                               unsigned int flags)
+{
+       BUG();
+       return 0;
+}

 #endif /* !CONFIG_HUGETLB_PAGE */


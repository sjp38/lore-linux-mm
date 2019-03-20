Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC029C10F05
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 05:53:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 79BAB2184E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 05:53:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Xj4zuUr9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 79BAB2184E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3244E6B0003; Wed, 20 Mar 2019 01:53:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D4EC6B0006; Wed, 20 Mar 2019 01:53:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EA756B0007; Wed, 20 Mar 2019 01:53:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id A92EB6B0003
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 01:53:18 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id e5so240274lja.23
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:53:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=yrhmhnerAXj/SZsxSHirvl1vkT1GSqQY7yzk8uh02jY=;
        b=ew0y2AM80VDFOFjsV9EEP16Z6EnGaq19ku4KP9x1zT2ueD3jhjcsQBfV778glfux9j
         lEoBdRMldPnc/tXec0qqsmqQsSEYFJGUX3TCQFRA5KskPJK+lgwrLlGch/GeCfBJRIrx
         gDPeY2Blmbf8jwNXhIsYbhP7BreflgSt4A3Sh9tndOBjc35LlwqChyDksw62Y699VYgf
         LgQ+kywWBk4b3llZhJ8AsdV4zOmqQnbpfuQbThIhaACrZk7JxTnRdm10+2F8XD8e8TXV
         vYgMF+4geqwqsxGYkSBN+1O2ZA5+NYXt4DNYE01WfLX8WQCLNtBqRS2pLIvJusOfVO3a
         HNfg==
X-Gm-Message-State: APjAAAVervVQIZI1ujfjl6R/njcTPyyPHkSJRb+wV8okdChJDZbd0PUt
	BAc5JPtWe/OuOKrEEVQsFGeaTAXJzatgGkPfUpcW9KznTsylRwhkCmGdMs4TtTePBI+SQgfGH4C
	eWniuPuOpZnJSXJPYJzdavzFcRGSzHGJHIcXTXwu2pQ3uupSwAEdXkPADE69m2Eg9TQ==
X-Received: by 2002:a2e:9a83:: with SMTP id p3mr15090153lji.35.1553061197794;
        Tue, 19 Mar 2019 22:53:17 -0700 (PDT)
X-Received: by 2002:a2e:9a83:: with SMTP id p3mr15090103lji.35.1553061196637;
        Tue, 19 Mar 2019 22:53:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553061196; cv=none;
        d=google.com; s=arc-20160816;
        b=JNbR5B90f9pPXBJ2KUTo/y1mEFTS8AvajlMuPA2HdsO4bcpwqw81Mo6puNF2q+gUD8
         VTRRJAvr5BizCW+J3mUIWD+EfMURtuezjdGc7bbkB8ur4mUCGPk/w8l5o+MYlz6/aPqS
         v32rYlquch4ivZEKLgmNztKf4GLYC77hqYe1beFvcP5wXMXl03JrBQZLAnnX5tGJH//y
         kzAKzTAbK8F4lrCiYhjLnJKsMsWL2BDMN+9T4gyPw7nFxkL3j4aknNV4Fnri6BXVwdgp
         jd/dMOmurE5oHh1or6xNyxGk1tqf8n0E7SIizIIvSIF/pnk2kOnkVZ23g0Rz+JIvzxXi
         Vhug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=yrhmhnerAXj/SZsxSHirvl1vkT1GSqQY7yzk8uh02jY=;
        b=mUf6q3TPoxxjznytAfyimMb7xgx7fbpR7tRJIKi/ZPeVBDPG3T/cVLeTUQj+1FTFce
         sF+rAFjlqXehw2NZKFIMlgwhSpI6PFVsChFfZg2u68O5RQmoXfRHiQ4Q8qzZ3cA7p/Fa
         2dgmMbKcrmMHHDIUP5Lk99Xq1sU8rqJ2ZDR9NKFkaJ030nWdNM0E66RjTV4bLjhp6q4d
         12vGKhYPse7Jdg4EGdcQvjDsaP0iB6tZY6F7tB1NgzOLg2PUCT+TCLITwVy77mXyuzLt
         TrKgZ86yMlNsDf+EopEgJqtdFBeKcquEE6eFz/5jLaWCXcXPoxWWPGyZ/ofgVusudXKY
         arXw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xj4zuUr9;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5sor207443lfm.7.2019.03.19.22.53.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Mar 2019 22:53:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=Xj4zuUr9;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=yrhmhnerAXj/SZsxSHirvl1vkT1GSqQY7yzk8uh02jY=;
        b=Xj4zuUr98OpasG7ah5S6m/IZLTrbkieWNTt5llwR10nog7jZETfbKKdqVAN4z2OxzI
         RTA/9KsUysn39iuVosElnuKvmZQPT5+EPwRRmV6OcR4Bu+kGORCBqlMwYOIm+QqKIoVE
         iVU4ERm38j9Q6qAL/f1RFYy3Rsqvo9xTKQ4d3T74w4DZoabdl9VBaYobqIaBfxfII1tO
         3awZpxOsPG6Dw0tQuNorv8/OhmYlSK7OHzdP9n5vWr0p6zO3JkjEn0+cWqmfcIK0FMPq
         j1kDzh5x9+bSzb1fY11jRhz9bhscFcJfDkZE70MdcvOMAyTdKHSlGCZ1cwrcOLMqzxNp
         CbaA==
X-Google-Smtp-Source: APXvYqxgqzV3haY+bjC0EJsuQF2V4L7AiGTBk+6GIup+L1XXx4Zbko4sL98kKqS34vkUcJOBPbm1cpOF3Cle54Dvd8Q=
X-Received: by 2002:ac2:44c3:: with SMTP id d3mr10371452lfm.14.1553061196224;
 Tue, 19 Mar 2019 22:53:16 -0700 (PDT)
MIME-Version: 1.0
References: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
In-Reply-To: <1553020556-38583-1-git-send-email-yang.shi@linux.alibaba.com>
From: Souptick Joarder <jrdr.linux@gmail.com>
Date: Wed, 20 Mar 2019 11:23:03 +0530
Message-ID: <CAFqt6zbqYyzVB3HbYXv19jo8=3hGC=XZAkwvE8PCVdLOKTeG1g@mail.gmail.com>
Subject: Re: [PATCH] mm: mempolicy: make mbind() return -EIO when
 MPOL_MF_STRICT is specified
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: chrubis@suse.cz, Vlastimil Babka <vbabka@suse.cz>, kirill@shutemov.name, 
	osalvador@suse.de, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org, 
	Linux-MM <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 20, 2019 at 12:06 AM Yang Shi <yang.shi@linux.alibaba.com> wrote:
>
> When MPOL_MF_STRICT was specified and an existing page was already
> on a node that does not follow the policy, mbind() should return -EIO.
> But commit 6f4576e3687b ("mempolicy: apply page table walker on
> queue_pages_range()") broke the rule.
>
> And, commit c8633798497c ("mm: mempolicy: mbind and migrate_pages
> support thp migration") didn't return the correct value for THP mbind()
> too.
>
> If MPOL_MF_STRICT is set, ignore vma_migratable() to make sure it reaches
> queue_pages_to_pte_range() or queue_pages_pmd() to check if an existing
> page was already on a node that does not follow the policy.  And,
> non-migratable vma may be used, return -EIO too if MPOL_MF_MOVE or
> MPOL_MF_MOVE_ALL was specified.
>
> Tested with https://github.com/metan-ucw/ltp/blob/master/testcases/kernel/syscalls/mbind/mbind02.c
>
> Fixes: 6f4576e3687b ("mempolicy: apply page table walker on queue_pages_range()")
> Reported-by: Cyril Hrubis <chrubis@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: stable@vger.kernel.org
> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>
> Signed-off-by: Oscar Salvador <osalvador@suse.de>
> ---
>  mm/mempolicy.c | 40 +++++++++++++++++++++++++++++++++-------
>  1 file changed, 33 insertions(+), 7 deletions(-)
>
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index abe7a67..401c817 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -447,6 +447,13 @@ static inline bool queue_pages_required(struct page *page,
>         return node_isset(nid, *qp->nmask) == !(flags & MPOL_MF_INVERT);
>  }
>
> +/*
> + * The queue_pages_pmd() may have three kind of return value.
> + * 1 - pages are placed on he right node or queued successfully.

Minor typo -> s/he/the ?

> + * 0 - THP get split.
> + * -EIO - is migration entry or MPOL_MF_STRICT was specified and an existing
> + *        page was already on a node that does not follow the policy.
> + */
>  static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>                                 unsigned long end, struct mm_walk *walk)
>  {
> @@ -456,7 +463,7 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>         unsigned long flags;
>
>         if (unlikely(is_pmd_migration_entry(*pmd))) {
> -               ret = 1;
> +               ret = -EIO;
>                 goto unlock;
>         }
>         page = pmd_page(*pmd);
> @@ -473,8 +480,15 @@ static int queue_pages_pmd(pmd_t *pmd, spinlock_t *ptl, unsigned long addr,
>         ret = 1;
>         flags = qp->flags;
>         /* go to thp migration */
> -       if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +       if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +               if (!vma_migratable(walk->vma)) {
> +                       ret = -EIO;
> +                       goto unlock;
> +               }
> +
>                 migrate_page_add(page, qp->pagelist, flags);
> +       } else
> +               ret = -EIO;
>  unlock:
>         spin_unlock(ptl);
>  out:
> @@ -499,8 +513,10 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>         ptl = pmd_trans_huge_lock(pmd, vma);
>         if (ptl) {
>                 ret = queue_pages_pmd(pmd, ptl, addr, end, walk);
> -               if (ret)
> +               if (ret > 0)
>                         return 0;
> +               else if (ret < 0)
> +                       return ret;
>         }
>
>         if (pmd_trans_unstable(pmd))
> @@ -521,11 +537,16 @@ static int queue_pages_pte_range(pmd_t *pmd, unsigned long addr,
>                         continue;
>                 if (!queue_pages_required(page, qp))
>                         continue;
> -               migrate_page_add(page, qp->pagelist, flags);
> +               if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL)) {
> +                       if (!vma_migratable(vma))
> +                               break;
> +                       migrate_page_add(page, qp->pagelist, flags);
> +               } else
> +                       break;
>         }
>         pte_unmap_unlock(pte - 1, ptl);
>         cond_resched();
> -       return 0;
> +       return addr != end ? -EIO : 0;
>  }
>
>  static int queue_pages_hugetlb(pte_t *pte, unsigned long hmask,
> @@ -595,7 +616,12 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>         unsigned long endvma = vma->vm_end;
>         unsigned long flags = qp->flags;
>
> -       if (!vma_migratable(vma))
> +       /*
> +        * Need check MPOL_MF_STRICT to return -EIO if possible
> +        * regardless of vma_migratable
> +        */
> +       if (!vma_migratable(vma) &&
> +           !(flags & MPOL_MF_STRICT))
>                 return 1;
>
>         if (endvma > end)
> @@ -622,7 +648,7 @@ static int queue_pages_test_walk(unsigned long start, unsigned long end,
>         }
>
>         /* queue pages from current vma */
> -       if (flags & (MPOL_MF_MOVE | MPOL_MF_MOVE_ALL))
> +       if (flags & MPOL_MF_VALID)
>                 return 0;
>         return 1;
>  }
> --
> 1.8.3.1
>


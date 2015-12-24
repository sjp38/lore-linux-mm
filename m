Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f181.google.com (mail-yk0-f181.google.com [209.85.160.181])
	by kanga.kvack.org (Postfix) with ESMTP id 379FD82F99
	for <linux-mm@kvack.org>; Thu, 24 Dec 2015 13:51:44 -0500 (EST)
Received: by mail-yk0-f181.google.com with SMTP id x184so230271185yka.3
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 10:51:44 -0800 (PST)
Received: from mail-yk0-x22a.google.com (mail-yk0-x22a.google.com. [2607:f8b0:4002:c07::22a])
        by mx.google.com with ESMTPS id g204si15031508ywa.284.2015.12.24.10.51.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Dec 2015 10:51:43 -0800 (PST)
Received: by mail-yk0-x22a.google.com with SMTP id p130so228249282yka.1
        for <linux-mm@kvack.org>; Thu, 24 Dec 2015 10:51:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
References: <1450957883-96356-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1450957883-96356-3-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 24 Dec 2015 10:51:43 -0800
Message-ID: <CAPcyv4iRPEw7tPT7bCBX+0eYbrTU679moLZ+zff1RXUvoDmCoA@mail.gmail.com>
Subject: Re: [PATCH 2/4] thp: fix regression in handling mlocked pages in __split_huge_pmd()
From: Dan Williams <dan.j.williams@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, Linux MM <linux-mm@kvack.org>

On Thu, Dec 24, 2015 at 3:51 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> This patch fixes regression caused by patch
>  "mm, dax: dax-pmd vs thp-pmd vs hugetlbfs-pmd"
>
> The patch makes pmd_trans_huge() check and "page = pmd_page(*pmd)" after
> __split_huge_pmd_locked(). It can never succeed, since the pmd already
> points to a page table. As result the page is never get munlocked.
>
> It causes crashes like this:
>  http://lkml.kernel.org/r/5661FBB6.6050307@oracle.com
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> ---
>  mm/huge_memory.c | 8 +++-----
>  1 file changed, 3 insertions(+), 5 deletions(-)
>
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 99f2a0ecb621..1a988d9b86ef 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3024,14 +3024,12 @@ void __split_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>         ptl = pmd_lock(mm, pmd);
>         if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
>                 goto out;
> -       __split_huge_pmd_locked(vma, pmd, haddr, false);
> -
> -       if (pmd_trans_huge(*pmd))
> -               page = pmd_page(*pmd);
> -       if (page && PageMlocked(page))
> +       page = pmd_page(*pmd);
> +       if (PageMlocked(page))
>                 get_page(page);
>         else
>                 page = NULL;
> +       __split_huge_pmd_locked(vma, pmd, haddr, false);

Since dax pmd mappings may not have a backing struct page I think this
additionally needs the following:

8<-----
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 4eae97325e95..c4eccfa836f4 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3025,11 +3025,13 @@ void __split_huge_pmd(struct vm_area_struct
*vma, pmd_t *pmd,
       ptl = pmd_lock(mm, pmd);
       if (unlikely(!pmd_trans_huge(*pmd) && !pmd_devmap(*pmd)))
               goto out;
-       page = pmd_page(*pmd);
-       if (PageMlocked(page))
-               get_page(page);
-       else
-               page = NULL;
+       else if (pmd_trans_huge(*pmd)) {
+               page = pmd_page(*pmd);
+               if (PageMlocked(page))
+                       get_page(page);
+               else
+                       page = NULL;
+       }
       __split_huge_pmd_locked(vma, pmd, haddr, false);
out:
       spin_unlock(ptl);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

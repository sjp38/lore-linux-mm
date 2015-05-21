Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id B8D2F82966
	for <linux-mm@kvack.org>; Thu, 21 May 2015 19:35:55 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so3259569pdb.1
        for <linux-mm@kvack.org>; Thu, 21 May 2015 16:35:55 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id s8si445073pdp.253.2015.05.21.16.35.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 May 2015 16:35:55 -0700 (PDT)
Date: Thu, 21 May 2015 16:35:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm/hugetlb: handle races in alloc_huge_page and
 hugetlb_reserve_pages
Message-Id: <20150521163553.987ac88a9541036a4cc9bc0e@linux-foundation.org>
In-Reply-To: <1431971349-6668-3-git-send-email-mike.kravetz@oracle.com>
References: <1431971349-6668-1-git-send-email-mike.kravetz@oracle.com>
	<1431971349-6668-3-git-send-email-mike.kravetz@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Kravetz <mike.kravetz@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, Luiz Capitulino <lcapitulino@redhat.com>

On Mon, 18 May 2015 10:49:09 -0700 Mike Kravetz <mike.kravetz@oracle.com> wrote:

> alloc_huge_page and hugetlb_reserve_pages use region_chg to
> calculate the number of pages which will be added to the reserve
> map.  Subpool and global reserve counts are adjusted based on
> the output of region_chg.  Before the pages are actually added
> to the reserve map, these routines could race and add fewer
> pages than expected.  If this happens, the subpool and global
> reserve counts are not correct.
> 
> Compare the number of pages actually added (region_add) to those
> expected to added (region_chg).  If fewer pages are actually added,
> this indicates a race and adjust counters accordingly.
> 
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1374,13 +1374,16 @@ static long vma_commit_reservation(struct hstate *h,
>  		return 0;
>  }
>  
> +/* Forward declaration */
> +static int hugetlb_acct_memory(struct hstate *h, long delta);
> +

Its best to put forward declarations at top-of-file.  Otherwise we can
end up with multiple forward declarations if someone later needs the
symbol at an earlier site in the file.

Had you done that you might have noticed that hugetlb_acct_memory() was
already declared ;)

--- a/mm/hugetlb.c~mm-hugetlb-handle-races-in-alloc_huge_page-and-hugetlb_reserve_pages-fix
+++ a/mm/hugetlb.c
@@ -1475,9 +1475,6 @@ static long vma_commit_reservation(struc
 		return 0;
 }
 
-/* Forward declaration */
-static int hugetlb_acct_memory(struct hstate *h, long delta);
-
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
_


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

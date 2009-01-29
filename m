Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 102F76B0044
	for <linux-mm@kvack.org>; Thu, 29 Jan 2009 07:35:38 -0500 (EST)
Received: by wa-out-1112.google.com with SMTP id k22so1379178waf.22
        for <linux-mm@kvack.org>; Thu, 29 Jan 2009 04:35:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1233193736.8760.199.camel@lts-notebook>
References: <20090128102841.GA24924@barrios-desktop>
	 <1233156832.8760.85.camel@lts-notebook>
	 <20090128235514.GB24924@barrios-desktop>
	 <1233193736.8760.199.camel@lts-notebook>
Date: Thu, 29 Jan 2009 21:35:36 +0900
Message-ID: <2f11576a0901290435p1bdb41b3o7171384250b93c08@mail.gmail.com>
Subject: Re: [BUG] mlocked page counter mismatch
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: MinChan Kim <minchan.kim@gmail.com>, linux mm <linux-mm@kvack.org>, linux kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Hi

> I think I see it.  In try_to_unmap_anon(), called from try_to_munlock(),
> we have:
>
>         list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
>                if (MLOCK_PAGES && unlikely(unlock)) {
>                        if (!((vma->vm_flags & VM_LOCKED) &&
> !!! should be '||' ?                                      ^^
>                              page_mapped_in_vma(page, vma)))
>                                continue;  /* must visit all unlocked vmas */
>                        ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
>                } else {
>                        ret = try_to_unmap_one(page, vma, migration);
>                        if (ret == SWAP_FAIL || !page_mapped(page))
>                                break;
>                }
>                if (ret == SWAP_MLOCK) {
>                        mlocked = try_to_mlock_page(page, vma);
>                        if (mlocked)
>                                break;  /* stop if actually mlocked page */
>                }
>        }
>
> or that clause [under if (MLOCK_PAGES && unlikely(unlock))]
> might be clearer as:
>
>               if ((vma->vm_flags & VM_LOCKED) && page_mapped_in_vma(page, vma))
>                      ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
>               else
>                      continue;  /* must visit all unlocked vmas */
>
> Do you agree?

Hmmm.
I don't think so.

>                        if (!((vma->vm_flags & VM_LOCKED) &&
>                              page_mapped_in_vma(page, vma)))
>                                continue;  /* must visit all unlocked vmas */

is already equivalent to

>               if ((vma->vm_flags & VM_LOCKED) && page_mapped_in_vma(page, vma))
>                      ret = SWAP_MLOCK;  /* saw at least one mlocked vma */
>               else
>                      continue;  /* must visit all unlocked vmas */


> And, I wonder if we need a similar check for
> page_mapped_in_vma(page, vma) up in try_to_unmap_one()?

because page_mapped_in_vma() can return 0 if vma is anon vma only.

In the other word,
struct adress_space (for file) gurantee that unrelated vma doesn't chained.
but struct anon_vma (for anon) doesn't gurantee that unrelated vma
doesn't chained.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 57F526B0170
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 12:18:34 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id z10so880858pdj.33
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 09:18:34 -0800 (PST)
Received: from psmtp.com ([74.125.245.171])
        by mx.google.com with SMTP id dk5si3320987pbc.196.2013.11.07.09.18.31
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 09:18:32 -0800 (PST)
Message-ID: <527BCB4A.8030801@oracle.com>
Date: Thu, 07 Nov 2013 10:18:02 -0700
From: Khalid Aziz <khalid.aziz@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: hugetlbfs: fix hugetlbfs optimization
References: <20131105221017.GI3835@redhat.com>
In-Reply-To: <20131105221017.GI3835@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: gregkh@linuxfoundation.org, bhutchings@solarflare.com, pshelar@nicira.com, cl@linux.com, hannes@cmpxchg.org, mel@csn.ul.ie, riel@redhat.com, minchan@kernel.org, andi@firstfloor.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, linux-mm@kvack.org

On 11/05/2013 03:10 PM, Andrea Arcangeli wrote:
> Hi,
>
> this patch is an alternative implementation of the hugetlbfs directio
> optimization discussed earlier. We've been looking into this with
> Khalid last week and an earlier version of this patch (fully
> equivalent as far as CPU overhead is concerned) was benchmarked by
> Khalid and it didn't degrade performance compared to the PageHuge
> check in current upstream code, so we should be good.
>
> The patch applies cleanly only after reverting
> 7cb2ef56e6a8b7b368b2e883a0a47d02fed66911, it's much easier to review
> it in this form as it avoids all the alignment changes. I'll resend to
> Andrew against current upstream by squashing it with the revert after
> reviews.
>
> I wished to remove the _mapcount tailpage refcounting for slab and
> hugetlbfs tails too, but if the last put_page of a slab tail happens
> after the slab page isn't a slab page anymore (but still compound as
> it wasn't freed yet because of the tail pin), a VM_BUG_ON would
> trigger during the last (unpinning) put_page(slab_tail) with the
> mapcount underflow:
>
> 			VM_BUG_ON(page_mapcount(page) <= 0);
>
> Not even sure if any driver is doing anything like that, but the
> current code would allow it, Pravin should know more about when
> exactly in which conditions the last put_page is done on slab tail
> pages.
>
> It shall be possible to remove the _mapcount refcounting anyway, as it
> is only read by split_huge_page and so it doesn't actually matter if
> it underflows, but I prefer to keep the VM_BUG_ON. In fact I added one
> more VM_BUG_ON(!PageHead()) even in this patch.
>
> I also didn't notice we missed a PageHead check before calling
> __put_single_page(page_head), so I corrected that. It sounds very
> unlikely that it could have ever triggered but still better to fix it.
>
> I just booted it... not very well tested yet. Help with the testing
> appreciated :).
>

Hi Andrea,

I ran performance tests on this patch. I am seeing 4.5% degradation with 
1M random reads, 9.2% degradation with 64K random reads and 13.8% 
degradation with 8K using the orion tool. Just to double check, I 
repeated the same tests with the last version of patch we had exchanged 
before some of the final tweaks you made and degradation with that patch 
is 0.7% for 1M, 2.3% with 64K and 3% for 8K. Actual numbers are in the 
table below (all numbers are in MB/s):

              3.12.0      3.12.0+this_patch      3.12.0+prev_patch
              -------     ------------------     -----------------
1M            8467        8087 (-4.5%)           8409 (-0.7%)
64K           4049        3675 (-9.2%)           3957 (-2.3%)
8K            732         631 (-13.8%)           710 (-3.0%)

One of the tweaks is causing problems. I will try to isolate which one.

--
Khalid


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

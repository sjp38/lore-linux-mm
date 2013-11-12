Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id E79746B00B4
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 14:22:53 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id up7so7327144pbc.26
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 11:22:53 -0800 (PST)
Received: from psmtp.com ([74.125.245.174])
        by mx.google.com with SMTP id gg8si18521pac.147.2013.11.12.11.22.51
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 11:22:52 -0800 (PST)
Received: by mail-vb0-f54.google.com with SMTP id q4so1710749vbe.27
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 11:22:50 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131105221017.GI3835@redhat.com>
References: <20131105221017.GI3835@redhat.com>
Date: Tue, 12 Nov 2013 11:22:50 -0800
Message-ID: <CALnjE+prqCg2ZAMLQBQjY0OqmW2ofjioUoS25pa8Y93somc8Gg@mail.gmail.com>
Subject: Re: [PATCH] mm: hugetlbfs: fix hugetlbfs optimization
From: Pravin Shelar <pshelar@nicira.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, gregkh@linuxfoundation.org, Ben Hutchings <bhutchings@solarflare.com>, Christoph Lameter <cl@linux.com>, hannes@cmpxchg.org, mel@csn.ul.ie, riel@redhat.com, minchan@kernel.org, andi@firstfloor.org, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, linux-mm@kvack.org

On Tue, Nov 5, 2013 at 2:10 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
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
>                         VM_BUG_ON(page_mapcount(page) <= 0);
>
> Not even sure if any driver is doing anything like that, but the
> current code would allow it, Pravin should know more about when
> exactly in which conditions the last put_page is done on slab tail
> pages.
>
Yes, This can happen when slab object is directly passed for IO and it
is done in few filesystems (ocfs, xfs) when I checked last time.

> It shall be possible to remove the _mapcount refcounting anyway, as it
> is only read by split_huge_page and so it doesn't actually matter if
> it underflows, but I prefer to keep the VM_BUG_ON. In fact I added one
> more VM_BUG_ON(!PageHead()) even in this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

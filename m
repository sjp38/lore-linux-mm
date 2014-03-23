Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f46.google.com (mail-oa0-f46.google.com [209.85.219.46])
	by kanga.kvack.org (Postfix) with ESMTP id C4E196B00FE
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 13:50:27 -0400 (EDT)
Received: by mail-oa0-f46.google.com with SMTP id i7so4757362oag.5
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 10:50:27 -0700 (PDT)
Received: from mail-oa0-x22e.google.com (mail-oa0-x22e.google.com [2607:f8b0:4003:c02::22e])
        by mx.google.com with ESMTPS id kg1si15365855oeb.131.2014.03.23.10.50.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 10:50:27 -0700 (PDT)
Received: by mail-oa0-f46.google.com with SMTP id i7so4757356oag.5
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 10:50:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395436655-21670-3-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-3-git-send-email-john.stultz@linaro.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 23 Mar 2014 10:50:06 -0700
Message-ID: <CAHGf_=rUJwtM-DJ4-Xw9WR3UN3gsA6UdcEvwen=Ku7B03j_2JA@mail.gmail.com>
Subject: Re: [PATCH 2/5] vrange: Add purged page detection on setting memory non-volatile
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

> +/**
> + * vrange_check_purged_pte - Checks ptes for purged pages
> + *
> + * Iterates over the ptes in the pmd checking if they have
> + * purged swap entries.
> + *
> + * Sets the vrange_walker.pages_purged to 1 if any were purged.
> + */
> +static int vrange_check_purged_pte(pmd_t *pmd, unsigned long addr,
> +                                       unsigned long end, struct mm_walk *walk)
> +{
> +       struct vrange_walker *vw = walk->private;
> +       pte_t *pte;
> +       spinlock_t *ptl;
> +
> +       if (pmd_trans_huge(*pmd))
> +               return 0;
> +       if (pmd_trans_unstable(pmd))
> +               return 0;
> +
> +       pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
> +       for (; addr != end; pte++, addr += PAGE_SIZE) {
> +               if (!pte_present(*pte)) {
> +                       swp_entry_t vrange_entry = pte_to_swp_entry(*pte);
> +
> +                       if (unlikely(is_vpurged_entry(vrange_entry))) {
> +                               vw->page_was_purged = 1;
> +                               break;

This function only detect there is vpurge entry or not. But
VRANGE_NONVOLATILE should remove all vpurge entries.
Otherwise, non-volatiled range still makes SIGBUS.

> +                       }
> +               }
> +       }
> +       pte_unmap_unlock(pte - 1, ptl);
> +       cond_resched();
> +
> +       return 0;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

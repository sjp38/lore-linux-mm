Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 08DE66B0037
	for <linux-mm@kvack.org>; Wed,  9 Apr 2014 14:29:28 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id v10so2765577pde.25
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 11:29:28 -0700 (PDT)
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
        by mx.google.com with ESMTPS id my16si840894pab.197.2014.04.09.11.29.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 09 Apr 2014 11:29:27 -0700 (PDT)
Received: by mail-pb0-f42.google.com with SMTP id rr13so2858885pbb.15
        for <linux-mm@kvack.org>; Wed, 09 Apr 2014 11:29:26 -0700 (PDT)
Message-ID: <53459182.5090506@linaro.org>
Date: Wed, 09 Apr 2014 11:29:22 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] vrange: Add purged page detection on setting memory
 non-volatile
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-3-git-send-email-john.stultz@linaro.org> <CAHGf_=rUJwtM-DJ4-Xw9WR3UN3gsA6UdcEvwen=Ku7B03j_2JA@mail.gmail.com> <CALAqxLVR4PQCZ-UsGhh+486D5PgVVtu3Tk7878zA9oG0yNU_Eg@mail.gmail.com> <CAHGf_=qC1aUdoUg1QJc8DukXzkHVoJA+5rH6SLmj0x+cibxtig@mail.gmail.com>
In-Reply-To: <CAHGf_=qC1aUdoUg1QJc8DukXzkHVoJA+5rH6SLmj0x+cibxtig@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/23/2014 02:50 PM, KOSAKI Motohiro wrote:
> On Sun, Mar 23, 2014 at 1:26 PM, John Stultz <john.stultz@linaro.org> wrote:
>> On Sun, Mar 23, 2014 at 10:50 AM, KOSAKI Motohiro
>> <kosaki.motohiro@gmail.com> wrote:
>>>> +/**
>>>> + * vrange_check_purged_pte - Checks ptes for purged pages
>>>> + *
>>>> + * Iterates over the ptes in the pmd checking if they have
>>>> + * purged swap entries.
>>>> + *
>>>> + * Sets the vrange_walker.pages_purged to 1 if any were purged.
>>>> + */
>>>> +static int vrange_check_purged_pte(pmd_t *pmd, unsigned long addr,
>>>> +                                       unsigned long end, struct mm_walk *walk)
>>>> +{
>>>> +       struct vrange_walker *vw = walk->private;
>>>> +       pte_t *pte;
>>>> +       spinlock_t *ptl;
>>>> +
>>>> +       if (pmd_trans_huge(*pmd))
>>>> +               return 0;
>>>> +       if (pmd_trans_unstable(pmd))
>>>> +               return 0;
>>>> +
>>>> +       pte = pte_offset_map_lock(walk->mm, pmd, addr, &ptl);
>>>> +       for (; addr != end; pte++, addr += PAGE_SIZE) {
>>>> +               if (!pte_present(*pte)) {
>>>> +                       swp_entry_t vrange_entry = pte_to_swp_entry(*pte);
>>>> +
>>>> +                       if (unlikely(is_vpurged_entry(vrange_entry))) {
>>>> +                               vw->page_was_purged = 1;
>>>> +                               break;
>>> This function only detect there is vpurge entry or not. But
>>> VRANGE_NONVOLATILE should remove all vpurge entries.
>>> Otherwise, non-volatiled range still makes SIGBUS.
>> So in the following patch (3/5), we only SIGBUS if the swap entry
>> is_vpurged_entry()  && the vma is still marked volatile, so this
>> shouldn't be an issue.
> When VOLATILE -> NON-VOLATILE -> VOLATILE transition happen,
> the page immediately marked "was purged"?
>
> I don't understand why vma check help.

Ok, you have a good point here. I've changed the code in my tree to
traverse all the ptes being unmarked and zap any psudo swp entries. This
is more expensive, but does provide simpler semantics for these corner
cases.

Thanks again for the great review!
-john



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

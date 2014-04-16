Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 525D36B0092
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 14:43:51 -0400 (EDT)
Received: by mail-qg0-f49.google.com with SMTP id e89so3816309qgf.8
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:43:51 -0700 (PDT)
Received: from mail-qa0-f50.google.com (mail-qa0-f50.google.com [209.85.216.50])
        by mx.google.com with ESMTPS id d8si9510104qao.92.2014.04.16.11.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 11:43:50 -0700 (PDT)
Received: by mail-qa0-f50.google.com with SMTP id ih12so10863449qab.23
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 11:43:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140414025150.GC30991@bbox>
References: <1397247340-3365-1-git-send-email-john.stultz@linaro.org>
	<1397247340-3365-5-git-send-email-john.stultz@linaro.org>
	<20140414025150.GC30991@bbox>
Date: Wed, 16 Apr 2014 11:43:50 -0700
Message-ID: <CALAqxLXqEhBDdzbq4iNa81w1fzTudL3o3ny4nGOOQdoM-DK=qA@mail.gmail.com>
Subject: Re: [PATCH 4/4] mvolatile: Add page purging logic & SIGBUS trap
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sun, Apr 13, 2014 at 7:51 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Fri, Apr 11, 2014 at 01:15:40PM -0700, John Stultz wrote:
>> @@ -3643,6 +3644,8 @@ static int handle_pte_fault(struct mm_struct *mm,
>>
>>       entry = *pte;
>>       if (!pte_present(entry)) {
>> +             swp_entry_t mvolatile_entry;
>> +
>>               if (pte_none(entry)) {
>>                       if (vma->vm_ops) {
>>                               if (likely(vma->vm_ops->fault))
>> @@ -3652,6 +3655,11 @@ static int handle_pte_fault(struct mm_struct *mm,
>>                       return do_anonymous_page(mm, vma, address,
>>                                                pte, pmd, flags);
>>               }
>> +
>> +             mvolatile_entry = pte_to_swp_entry(entry);
>> +             if (unlikely(is_purged_entry(mvolatile_entry)))
>> +                     return VM_FAULT_SIGBUS;
>> +
>
> There is no pte lock so that is_purged_entry isn't safe so if race happens,
> do_swap_page could have a problem so it would be better to handle it
> do_swap_page with pte lock because we used swp_pte to indicate purged pte.
>
> I tried to solve it while we were in Napa(you could remember I sent
> crap patchset to you privately but failed to fix and I still didn't get
> a time to fix it :( ) but I'd like to inform this problem.

Thanks for the review and the reminder! I'll move the check appropriately.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

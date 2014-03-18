Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 11BE66B00E2
	for <linux-mm@kvack.org>; Mon, 17 Mar 2014 20:37:01 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id uo5so6443120pbc.32
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 17:37:00 -0700 (PDT)
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
        by mx.google.com with ESMTPS id qe9si8307053pbb.312.2014.03.17.17.36.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Mar 2014 17:37:00 -0700 (PDT)
Received: by mail-pa0-f45.google.com with SMTP id kl14so6479591pab.32
        for <linux-mm@kvack.org>; Mon, 17 Mar 2014 17:36:59 -0700 (PDT)
Message-ID: <53279525.7090101@linaro.org>
Date: Mon, 17 Mar 2014 17:36:53 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] vrange: Add vrange syscall and handle splitting/merging
 and marking vmas
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org> <1394822013-23804-2-git-send-email-john.stultz@linaro.org> <20140317092118.GA2210@quack.suse.cz> <20140317094339.GC2210@quack.suse.cz>
In-Reply-To: <20140317094339.GC2210@quack.suse.cz>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 03/17/2014 02:43 AM, Jan Kara wrote:
> On Mon 17-03-14 10:21:18, Jan Kara wrote:
>> On Fri 14-03-14 11:33:31, John Stultz wrote:
>>> +	for (;;) {
>>> +		unsigned long new_flags;
>>> +		pgoff_t pgoff;
>>> +		unsigned long tmp;
>>> +
>>> +		if (!vma)
>>> +			goto out;
>>> +
>>> +		if (vma->vm_flags & (VM_SPECIAL|VM_LOCKED|VM_MIXEDMAP|
>>> +					VM_HUGETLB))
>>> +			goto out;
>>> +
>>> +		/* We don't support volatility on files for now */
>>> +		if (vma->vm_file) {
>>> +			ret = -EINVAL;
>>> +			goto out;
>>> +		}
>>> +
>>> +		new_flags = vma->vm_flags;
>>> +
>>> +		if (start < vma->vm_start) {
>>> +			start = vma->vm_start;
>>> +			if (start >= end)
>>> +				goto out;
>>> +		}
>   One more question: This seems to silently skip any holes between VMAs. Is
> that really intended? I'd expect that marking unmapped range as volatile /
> non-volatile should return error... In any case what happens should be
> defined in the description.

So.. initially it was by design, but as I look at madvise and think
about it further, it does make more sense to throw errors if memory in
the range is not mapped.

I'll try to rework things to adapt to this.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

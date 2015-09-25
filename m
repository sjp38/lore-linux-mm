Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4356B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 19:19:00 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so120305031pac.2
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 16:18:59 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id ey7si8654007pab.142.2015.09.25.16.18.57
        for <linux-mm@kvack.org>;
        Fri, 25 Sep 2015 16:18:58 -0700 (PDT)
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com> <20150924093026.GA29699@gmail.com>
 <560435B4.1010603@sr71.net> <20150925071119.GB15753@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <5605D660.8000009@sr71.net>
Date: Fri, 25 Sep 2015 16:18:56 -0700
MIME-Version: 1.0
In-Reply-To: <20150925071119.GB15753@gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>

On 09/25/2015 12:11 AM, Ingo Molnar wrote:
>>> > > Btw., how does pkey support interact with hugepages?
>> > 
>> > Surprisingly little.  I've made sure that everything works with huge pages and 
>> > that the (huge) PTEs and VMAs get set up correctly, but I'm not sure I had to 
>> > touch the huge page code at all.  I have test code to ensure that it works the 
>> > same as with small pages, but everything worked pretty naturally.
> Yeah, so the reason I'm asking about expectations is that this code:
> 
> +       follow_ret = follow_pte(tsk->mm, address, &ptep, &ptl);
> +       if (!follow_ret) {
> +               /*
> +                * On a successful follow, make sure to
> +                * drop the lock.
> +                */
> +               pte = *ptep;
> +               pte_unmap_unlock(ptep, ptl);
> +               ret = pte_pkey(pte);
> 
> is visibly hugepage-unsafe: if a vma is hugepage mapped, there are no ptes, only 
> pmds - and the protection key index lives in the pmd. We don't seem to recover 
> that information properly.

You got me on this one.  I assumed that follow_pte() handled huge pages.
 It does not.

But, the code still worked.  Since follow_pte() fails for all huge
pages, it just falls back to pulling the protection key out of the VMA,
which _does_ work for huge pages.

I've actually removed the PTE walking and I just now use the VMA
directly.  I don't see a ton of additional value from walking the page
tables when we can get what we need from the VMA.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

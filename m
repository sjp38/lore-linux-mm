Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id DCF596B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 08:19:52 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id r5so1993043qcx.12
        for <linux-mm@kvack.org>; Thu, 02 Oct 2014 05:19:52 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k9si5970929qch.25.2014.10.02.05.19.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Oct 2014 05:19:51 -0700 (PDT)
Date: Thu, 2 Oct 2014 14:19:03 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH V4 1/6] mm: Introduce a general RCU get_user_pages_fast.
Message-ID: <20141002121902.GA2342@redhat.com>
References: <1411740233-28038-1-git-send-email-steve.capper@linaro.org>
 <1411740233-28038-2-git-send-email-steve.capper@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1411740233-28038-2-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: linux-arm-kernel@lists.infradead.org, catalin.marinas@arm.com, linux@arm.linux.org.uk, linux-arch@vger.kernel.org, linux-mm@kvack.org, will.deacon@arm.com, gary.robertson@linaro.org, christoffer.dall@linaro.org, peterz@infradead.org, anders.roxell@linaro.org, akpm@linux-foundation.org, dann.frazier@canonical.com, mark.rutland@arm.com, mgorman@suse.de, hughd@google.com

Hi Steve,

On Fri, Sep 26, 2014 at 03:03:48PM +0100, Steve Capper wrote:
> This patch provides a general RCU implementation of get_user_pages_fast
> that can be used by architectures that perform hardware broadcast of
> TLB invalidations.
> 
> It is based heavily on the PowerPC implementation by Nick Piggin.

It'd be nice if you could also at the same time apply it to sparc and
powerpc in this same patchset to show the effectiveness of having a
generic version. Because if it's not a trivial drop-in replacement,
then this should go in arch/arm* instead of mm/gup.c...

Also I wonder if it wouldn't be better to add it to mm/util.c along
with the __weak gup_fast but then this is ok too. I'm just saying
because we never had sings of gup_fast code in mm/gup.c so far but
then this isn't exactly a __weak version of it... so I don't mind
either ways.

> +		down_read(&mm->mmap_sem);
> +		ret = get_user_pages(current, mm, start,
> +				     nr_pages - nr, write, 0, pages, NULL);
> +		up_read(&mm->mmap_sem);

This has a collision with a patchset I posted, but it's trivial to
solve, the above three lines need to be replaced with:

+		ret = get_user_pages_unlocked(current, mm, start,
+				     nr_pages - nr, write, 0, pages);

And then arm gup_fast will also page fault with FOLL_FAULT_ALLOW_RETRY
the first time to release the mmap_sem before I/O.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

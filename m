Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 1396C6B00F6
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:37:14 -0400 (EDT)
Received: by mail-qc0-f170.google.com with SMTP id x13so781822qcv.1
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:37:13 -0700 (PDT)
Received: from mail-qa0-f48.google.com (mail-qa0-f48.google.com [209.85.216.48])
        by mx.google.com with ESMTPS id s10si1228442qak.106.2014.04.02.12.37.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 12:37:13 -0700 (PDT)
Received: by mail-qa0-f48.google.com with SMTP id m5so643158qaj.7
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:37:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140402180707.GT14688@cmpxchg.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
	<20140401212102.GM4407@cmpxchg.org>
	<533B8C2D.9010108@linaro.org>
	<20140402163013.GP14688@cmpxchg.org>
	<533C3BB4.8020904@zytor.com>
	<533C3CDD.9090400@zytor.com>
	<20140402171812.GR14688@cmpxchg.org>
	<533C4B7E.6030807@sr71.net>
	<CALAqxLUR4ucQ_zOp5i3Y0+WpCWiwm2oR6Dp7aeD2XN1pjiELEQ@mail.gmail.com>
	<20140402180707.GT14688@cmpxchg.org>
Date: Wed, 2 Apr 2014 12:37:13 -0700
Message-ID: <CALAqxLX1EADOVw_OrB4eP9c__7eftpCgWPU=u6gH6bZ5u3FCMQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 2, 2014 at 11:07 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Wed, Apr 02, 2014 at 10:48:03AM -0700, John Stultz wrote:
>> I suspect handling the SIGBUS and patching up the purged page you
>> trapped on is likely much to complicated for most use cases. But I do
>> think SIGBUS is preferable to zero-fill on purged page access, just
>> because its likely to be easier to debug applications.
>
> Fully agreed, but it seems a bit overkill to add a separate syscall, a
> range-tree on top of shmem address_spaces, and an essentially new
> programming model based on SIGBUS userspace fault handling (incl. all
> the complexities and confusion this inevitably will bring when people
> DO end up passing these pointers into kernel space) just to be a bit
> nicer about use-after-free bugs in applications.

Its more about making an interface that has graspable semantics to
userspace, instead of having the semantics being a side-effect of the
implementation.

Tying volatility to the page-clean state and page-was-purged to
page-present seems problematic to me, because there are too many ways
to change the page-clean or page-present outside of the interface
being proposed.

I feel this causes a cascade of corner cases that have to be explained
to users of the interface.

Also I disagree we're adding a new programming model, as SIGBUSes can
already be caught, just that there's not usually much one can do,
where with volatile pages its more likely something could be done. And
again, its really just a side-effect of having semantics (SIGBUS on
purged page access) that are more helpful from a applications
perspective.

As for the separate syscall: Again, this is mainly needed to handle
allocation failures that happen mid-way through modifying the range.
There may still be a way to do the allocation first and only after it
succeeds do the modification. The vma merge/splitting logic doesn't
make this easy but if we can be sure that on a failed split of 1 vma
-> 3 vmas (which may fail half way) we can re-merge w/o allocation and
error out (without having to do any other allocations), this might be
avoidable. I'm still wanting to look at this. If so, it would be
easier to re-add this support under madvise, if folks really really
don't like the new syscall.   For the most part, having the separate
syscall allows us to discuss other details of the semantics, which to
me are more important then the syscall naming.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id DED026B005A
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 00:04:01 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so10542884pdj.13
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 21:04:01 -0700 (PDT)
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
        by mx.google.com with ESMTPS id nd6si385835pbc.325.2014.04.01.21.04.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 21:04:01 -0700 (PDT)
Received: by mail-pd0-f175.google.com with SMTP id x10so10425666pdj.6
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 21:04:00 -0700 (PDT)
Message-ID: <533B8C2D.9010108@linaro.org>
Date: Tue, 01 Apr 2014 21:03:57 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org>
In-Reply-To: <20140401212102.GM4407@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/01/2014 02:21 PM, Johannes Weiner wrote:
> [ I tried to bring this up during LSFMM but it got drowned out.
>   Trying again :) ]
>
> On Fri, Mar 21, 2014 at 02:17:30PM -0700, John Stultz wrote:
>> Optimistic method:
>> 1) Userland marks a large range of data as volatile
>> 2) Userland continues to access the data as it needs.
>> 3) If userland accesses a page that has been purged, the kernel will
>> send a SIGBUS
>> 4) Userspace can trap the SIGBUS, mark the affected pages as
>> non-volatile, and refill the data as needed before continuing on
> As far as I understand, if a pointer to volatile memory makes it into
> a syscall and the fault is trapped in kernel space, there won't be a
> SIGBUS, the syscall will just return -EFAULT.
>
> Handling this would mean annotating every syscall invocation to check
> for -EFAULT, refill the data, and then restart the syscall.  This is
> complicated even before taking external libraries into account, which
> may not propagate syscall returns properly or may not be reentrant at
> the necessary granularity.
>
> Another option is to never pass volatile memory pointers into the
> kernel, but that too means that knowledge of volatility has to travel
> alongside the pointers, which will either result in more complexity
> throughout the application or severely limited scope of volatile
> memory usage.
>
> Either way, optimistic volatile pointers are nowhere near as
> transparent to the application as the above description suggests,
> which makes this usecase not very interesting, IMO.  If we can support
> it at little cost, why not, but I don't think we should complicate the
> common usecases to support this one.

So yea, thanks again for all the feedback at LSF-MM! I'm trying to get
things integrated for a v13 here shortly (although with visitors in town
this week it may not happen until next week).


So, maybe its best to ignore the fact that folks want to do semi-crazy
user-space faulting via SIGBUS. At least to start with. Lets look at the
semantic for the "normal" mark volatile, never touch the pages until you
mark non-volatile - basically where accessing volatile pages is similar
to a use-after-free bug.

So, for the most part, I'd say the proposed SIGBUS semantics don't
complicate things for this basic use-case, at least when compared with
things like zero-fill.  If an applications accidentally accessed a
purged volatile page, I think SIGBUS is the right thing to do. They most
likely immediately crash, but its better then them moving along with
silent corruption because they're mucking with zero-filled pages.

So between zero-fill and SIGBUS, I think SIGBUS makes the most sense. If
you have a third option you're thinking of, I'd of course be interested
in hearing it.

Now... once you've chosen SIGBUS semantics, there will be folks who will
try to exploit the fact that we get SIGBUS on purged page access (at
least on the user-space side) and will try to access pages that are
volatile until they are purged and try to then handle the SIGBUS to fix
things up. Those folks exploiting that will have to be particularly
careful not to pass volatile data to the kernel, and if they do they'll
have to be smart enough to handle the EFAULT, etc. That's really all
their problem, because they're being clever. :)

I've maybe made a mistake in talking at length about those use cases,
because I wanted to make sure folks didn't have suggestions on how to
better address those cases (so far I've not heard any), and it sort of
helps wrap folks heads around at least some of the potential variations
on the desired purging semantics (lru based cold page purging, or entire
object based purging).

Now, one other potential variant, which Keith brought up at LSF-MM, and
others have mentioned before, is to have *any* volatile page access
(purged or not) return a SIGBUS. This seems "safe" in that it protects
developers from themselves, and makes application behavior more
deterministic (rather then depending on memory pressure). However it
also has the overhead of setting up the pte swp entries for each page in
order to trip the SIGBUS.  Since folks have explicitly asked for it,
allowing non-purged volatile page access seems more flexible. And its
cheaper. So that's what I've been leaning towards.

thanks again!
-john


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

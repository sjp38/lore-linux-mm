Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 72E126B0106
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 16:13:39 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so699522pab.9
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:13:39 -0700 (PDT)
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
        by mx.google.com with ESMTPS id xk5si50628pbc.357.2014.04.02.13.13.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 13:13:38 -0700 (PDT)
Received: by mail-pd0-f170.google.com with SMTP id v10so673659pde.15
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 13:13:38 -0700 (PDT)
Message-ID: <533C6F6E.4080601@linaro.org>
Date: Wed, 02 Apr 2014 13:13:34 -0700
From: John Stultz <john.stultz@linaro.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <20140401212102.GM4407@cmpxchg.org> <533B313E.5000403@zytor.com> <533B4555.3000608@sr71.net> <533B8E3C.3090606@linaro.org> <20140402163638.GQ14688@cmpxchg.org> <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com> <20140402175852.GS14688@cmpxchg.org> <CALAqxLXs+tB3h6wqZ3m5qOFWfgeJcH03k-0dsj+NUoB5D5LEgQ@mail.gmail.com> <20140402194708.GV14688@cmpxchg.org>
In-Reply-To: <20140402194708.GV14688@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 04/02/2014 12:47 PM, Johannes Weiner wrote:
> On Wed, Apr 02, 2014 at 12:01:00PM -0700, John Stultz wrote:
>> On Wed, Apr 2, 2014 at 10:58 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>>> On Wed, Apr 02, 2014 at 10:40:16AM -0700, John Stultz wrote:
>>>> That point beside, I think the other problem with the page-cleaning
>>>> volatility approach is that there are other awkward side effects. For
>>>> example: Say an application marks a range as volatile. One page in the
>>>> range is then purged. The application, due to a bug or otherwise,
>>>> reads the volatile range. This causes the page to be zero-filled in,
>>>> and the application silently uses the corrupted data (which isn't
>>>> great). More problematic though, is that by faulting the page in,
>>>> they've in effect lost the purge state for that page. When the
>>>> application then goes to mark the range as non-volatile, all pages are
>>>> present, so we'd return that no pages were purged.  From an
>>>> application perspective this is pretty ugly.
>>>>
>>>> Johannes: Any thoughts on this potential issue with your proposal? Am
>>>> I missing something else?
>>> No, this is accurate.  However, I don't really see how this is
>>> different than any other use-after-free bug.  If you access malloc
>>> memory after free(), you might receive a SIGSEGV, you might see random
>>> data, you might corrupt somebody else's data.  This certainly isn't
>>> nice, but it's not exactly new behavior, is it?
>> The part that troubles me is that I see the purged state as kernel
>> data being corrupted by userland in this case. The kernel will tell
>> userspace that no pages were purged, even though they were. Only
>> because userspace made an errant read of a page, and got garbage data
>> back.
> That sounds overly dramatic to me.  First of all, this data still
> reflects accurately the actions of userspace in this situation.  And
> secondly, the kernel does not rely on this data to be meaningful from
> a userspace perspective to function correctly.
<insert dramatic-chipmunk video w/ text overlay "errant read corrupted
volatile page purge state!!!!1">

Maybe you're right, but I feel this is the sort of thing application
developers would be surprised and annoyed by.


> It's really nothing but a use-after-free bug that has consequences for
> no-one but the faulty application.  The thing that IS new is that even
> a read is enough to corrupt your data in this case.
>
> MADV_REVIVE could return 0 if all pages in the specified range were
> present, -Esomething if otherwise.  That would be semantically sound
> even if userspace messes up.

So its semantically more of just a combined mincore+dirty operation..
and nothing more?

What are other folks thinking about this? Although I don't particularly
like it, I probably could go along with Johannes' approach, forgoing
SIGBUS for zero-fill and adapting the semantics that are in my mind a
bit stranger. This would allow for ashmem-like style behavior w/ the
additional  write-clears-volatile-state and read-clears-purged-state
constraints (which I don't think would be problematic for Android, but
am not totally sure).

But I do worry that these semantics are easier for kernel-mm-developers
to grasp, but are much much harder for application developers to
understand.

Additionally unless we could really leave access-after-volatile as a
total undefined behavior, this would lock us into O(page) behavior and
would remove the possibility of O(log(ranges)) behavior Minchan and I
were able to get (admittedly with more complicated code - but something
I was hoping we'd be able to get back to after the base semantics and
interface behavior was understood and merged). I since applications will
have bugs and will access after volatile, we won't be able to get away
with that sort of behavioral flexibility.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

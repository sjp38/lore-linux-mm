Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 389666B0114
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 14:07:51 -0400 (EDT)
Received: by mail-ve0-f182.google.com with SMTP id jw12so7601508veb.13
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:07:50 -0700 (PDT)
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
        by mx.google.com with ESMTPS id sq9si2824773vdc.71.2014.03.18.11.07.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 11:07:50 -0700 (PDT)
Received: by mail-vc0-f169.google.com with SMTP id ik5so7746576vcb.14
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:07:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140318151113.GA10724@gmail.com>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
	<20140318151113.GA10724@gmail.com>
Date: Tue, 18 Mar 2014 11:07:50 -0700
Message-ID: <CALAqxLV=uRV825taKrnH2=p_kAf5f1PbQ7=J5MopFt9ATj=a3A@mail.gmail.com>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 18, 2014 at 8:11 AM, Minchan Kim <minchan@kernel.org> wrote:
> 1) SIGBUS
>
> It's one of the arguable issue because some user want to get a
> SIGBUS(ex, Firefox) while other want a just zero page(ex, Google
> address sanitizer) without signal so it should be option.
>
>         int vrange(start, len, VRANGE_VOLATILE|VRANGE_ZERO, &purged);
>         int vrange(start, len, VRANGE_VOLATILE|VRANGE_SIGNAL, &purged);

So, the zero-fill on volatile access feels like a *very* special case
to me, since a null page could be valid data in many cases. Since
support/interest for volatile ranges has been middling at best, I want
to start culling the stranger use cases. I'm open in the future to
adding a special flag or something if it really make sense, but at
this point, lets just get the more general volatile range use cases
supported.


> 2) Accouting
>
> The one of problem I have thought is lack of accouting of vrange pages.
> I mean we need some statistics for vrange pages and it should be number
> of pages rather than vma size. Without that, user space couldn't see
> current status and then they couldn't control the system's memory
> consumption. It's alredy known problem for other OS which have support
> similar thing(ex, MADV_FREE).
>
> For accouting, we should account how many of existing pages are the range
> when vrange syscall is called. It could increase syscall overhead
> but user could have accurate statistics information. It's just trade-off.

Agreed. As I've been looking at handling anonymous page aging on
swapless systems, the naive method causes performance issues as we
scan and scan and scan the anonymous list trying to page things out to
nowhere. Providing the number of volatile pages would allow the
scanning to stop at a sensible time.

> 3) Aging
>
> I think vrange pages should be discarded eariler than other hot pages
> so want to move pages to tail of inactive LRU when syscall is called.
> We could do by using deactivate_page with some tweak while we accouts
> pages in syscall context.
>
> But if user want to treat vrange pages with other hot pages equally
> he could ask so that we could skip deactivating.
>
>         vrange(start, len, VRANGE_VOLATILE|VRANGE_ZERO|VRANGE_AGING, &purged)
>         or
>         vrange(start, len, VRANGE_VOLATILE|VRANGE_SIGNAL|VRANGE_AGING, &purged)
>
> It could be convenient for Moz usecase if they want to age vrange
> pages.

Again, I want to keep the scope small for now, so I'd rather not add
more options just yet. I think we should come up with a sensable
default and give that time to be used, and if there need to be more
options later, we can open those up. I think activating on volatile
(so the pages are purged together) is the right default approach, but
I'm open to discuss this further.


> 4) Permanency
>
> Like MCL_FUTURE of mlockall, it would be better to make the range
> have permanent property until called VRANGE_NOVOLATILE.
> I mean pages faulted on the range in future since syscall is called
> should be volatile automatically so that user could avoid frequent
> syscall to make them volatile.

I'm not sure I followed this. Is this with respect to the issue of
unmapped holes in the range?

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

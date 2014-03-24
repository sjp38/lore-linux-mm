Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f50.google.com (mail-oa0-f50.google.com [209.85.219.50])
	by kanga.kvack.org (Postfix) with ESMTP id CC42B6B003C
	for <linux-mm@kvack.org>; Sun, 23 Mar 2014 20:01:50 -0400 (EDT)
Received: by mail-oa0-f50.google.com with SMTP id i7so4996295oag.37
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 17:01:50 -0700 (PDT)
Received: from mail-ob0-x236.google.com (mail-ob0-x236.google.com [2607:f8b0:4003:c01::236])
        by mx.google.com with ESMTPS id yv5si16103185oeb.108.2014.03.23.17.01.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 23 Mar 2014 17:01:50 -0700 (PDT)
Received: by mail-ob0-f182.google.com with SMTP id uz6so5014279obc.27
        for <linux-mm@kvack.org>; Sun, 23 Mar 2014 17:01:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1395436655-21670-5-git-send-email-john.stultz@linaro.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org> <1395436655-21670-5-git-send-email-john.stultz@linaro.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Sun, 23 Mar 2014 17:01:29 -0700
Message-ID: <CAHGf_=qMSKTG0_2hAETm_KPgovObJE=kXY4RTN5wWN7SuPgVBA@mail.gmail.com>
Subject: Re: [PATCH 4/5] vrange: Set affected pages referenced when marking volatile
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Mar 21, 2014 at 2:17 PM, John Stultz <john.stultz@linaro.org> wrote:
> One issue that some potential users were concerned about, was that
> they wanted to ensure that all the pages from one volatile range
> were purged before we purge pages from a different volatile range.
> This would prevent the case where they have 4 large objects, and
> the system purges one page from each object, casuing all of the
> objects to have to be re-created.
>
> The counter-point to this case, is when an application is using the
> SIGBUS semantics to continue to access pages after they have been
> marked volatile. In that case, the desire was that the most recently
> touched pages be purged last, and only the "cold" pages be purged
> from the specified range.
>
> Instead of adding option flags for the various usage model (at least
> initially), one way of getting a solutoin for both uses would be to
> have the act of marking pages as volatile in effect mark the pages
> as accessed. Since all of the pages in the range would be marked
> together, they would be of the same "age" and would (approximately)
> be purged together. Further, if any pages in the range were accessed
> after being marked volatile, they would be moved to the end of the
> lru and be purged later.

If you run after two hares, you will catch neither. I suspect this patch
doesn't make happy any user.
I suggest to aim former case (object level caching) and aim latter by
another patch-kit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

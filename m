Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id 41E846B00CA
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 13:48:04 -0400 (EDT)
Received: by mail-qg0-f50.google.com with SMTP id q108so563602qgd.9
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 10:48:04 -0700 (PDT)
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
        by mx.google.com with ESMTPS id q42si1113409qga.81.2014.04.02.10.48.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 10:48:03 -0700 (PDT)
Received: by mail-qa0-f52.google.com with SMTP id m5so517825qaj.11
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 10:48:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <533C4B7E.6030807@sr71.net>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
	<20140401212102.GM4407@cmpxchg.org>
	<533B8C2D.9010108@linaro.org>
	<20140402163013.GP14688@cmpxchg.org>
	<533C3BB4.8020904@zytor.com>
	<533C3CDD.9090400@zytor.com>
	<20140402171812.GR14688@cmpxchg.org>
	<533C4B7E.6030807@sr71.net>
Date: Wed, 2 Apr 2014 10:48:03 -0700
Message-ID: <CALAqxLUR4ucQ_zOp5i3Y0+WpCWiwm2oR6Dp7aeD2XN1pjiELEQ@mail.gmail.com>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
From: John Stultz <john.stultz@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 2, 2014 at 10:40 AM, Dave Hansen <dave@sr71.net> wrote:
> On 04/02/2014 10:18 AM, Johannes Weiner wrote:
>> Hence my follow-up question in the other mail about how large we
>> expect such code caches to become in practice in relationship to
>> overall system memory.  Are code caches interesting reclaim candidates
>> to begin with?  Are they big enough to make the machine thrash/swap
>> otherwise?
>
> A big chunk of the use cases here are for swapless systems anyway, so
> this is the *only* way for them to reclaim anonymous memory.  Their
> choices are either to be constantly throwing away and rebuilding these
> objects, or to leave them in memory effectively pinned.
>
> In practice I did see ashmem (the Android thing that we're trying to
> replace) get used a lot by the Android web browser when I was playing
> with it.  John said that it got used for storing decompressed copies of
> images.

Although images are a simpler case where its easier to not touch
volatile pages. I think Johannes is mostly concerned about cases where
volatile pages are being accessed while they are volatile, which the
Mozilla folks are so far the only viable case (in my mind... folks may
have others) where they intentionally want to access pages while
they're volatile and thus require SIGBUS semantics.

I suspect handling the SIGBUS and patching up the purged page you
trapped on is likely much to complicated for most use cases. But I do
think SIGBUS is preferable to zero-fill on purged page access, just
because its likely to be easier to debug applications.

thanks
-john

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

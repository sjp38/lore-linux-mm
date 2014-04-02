Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f48.google.com (mail-bk0-f48.google.com [209.85.214.48])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0A46B00F7
	for <linux-mm@kvack.org>; Wed,  2 Apr 2014 15:47:32 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id mx12so84153bkb.35
        for <linux-mm@kvack.org>; Wed, 02 Apr 2014 12:47:32 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id d3si1523820bko.20.2014.04.02.12.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 02 Apr 2014 12:47:31 -0700 (PDT)
Date: Wed, 2 Apr 2014 15:47:08 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Message-ID: <20140402194708.GV14688@cmpxchg.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
 <20140401212102.GM4407@cmpxchg.org>
 <533B313E.5000403@zytor.com>
 <533B4555.3000608@sr71.net>
 <533B8E3C.3090606@linaro.org>
 <20140402163638.GQ14688@cmpxchg.org>
 <CALAqxLUNKJQs+q__fwqggaRtqLz5sJtuxKdVPja8X0htDyaT6A@mail.gmail.com>
 <20140402175852.GS14688@cmpxchg.org>
 <CALAqxLXs+tB3h6wqZ3m5qOFWfgeJcH03k-0dsj+NUoB5D5LEgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALAqxLXs+tB3h6wqZ3m5qOFWfgeJcH03k-0dsj+NUoB5D5LEgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: Dave Hansen <dave@sr71.net>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Apr 02, 2014 at 12:01:00PM -0700, John Stultz wrote:
> On Wed, Apr 2, 2014 at 10:58 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> > On Wed, Apr 02, 2014 at 10:40:16AM -0700, John Stultz wrote:
> >> That point beside, I think the other problem with the page-cleaning
> >> volatility approach is that there are other awkward side effects. For
> >> example: Say an application marks a range as volatile. One page in the
> >> range is then purged. The application, due to a bug or otherwise,
> >> reads the volatile range. This causes the page to be zero-filled in,
> >> and the application silently uses the corrupted data (which isn't
> >> great). More problematic though, is that by faulting the page in,
> >> they've in effect lost the purge state for that page. When the
> >> application then goes to mark the range as non-volatile, all pages are
> >> present, so we'd return that no pages were purged.  From an
> >> application perspective this is pretty ugly.
> >>
> >> Johannes: Any thoughts on this potential issue with your proposal? Am
> >> I missing something else?
> >
> > No, this is accurate.  However, I don't really see how this is
> > different than any other use-after-free bug.  If you access malloc
> > memory after free(), you might receive a SIGSEGV, you might see random
> > data, you might corrupt somebody else's data.  This certainly isn't
> > nice, but it's not exactly new behavior, is it?
> 
> The part that troubles me is that I see the purged state as kernel
> data being corrupted by userland in this case. The kernel will tell
> userspace that no pages were purged, even though they were. Only
> because userspace made an errant read of a page, and got garbage data
> back.

That sounds overly dramatic to me.  First of all, this data still
reflects accurately the actions of userspace in this situation.  And
secondly, the kernel does not rely on this data to be meaningful from
a userspace perspective to function correctly.

It's really nothing but a use-after-free bug that has consequences for
no-one but the faulty application.  The thing that IS new is that even
a read is enough to corrupt your data in this case.

MADV_REVIVE could return 0 if all pages in the specified range were
present, -Esomething if otherwise.  That would be semantically sound
even if userspace messes up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

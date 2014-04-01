Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f45.google.com (mail-bk0-f45.google.com [209.85.214.45])
	by kanga.kvack.org (Postfix) with ESMTP id 743396B0069
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 17:22:08 -0400 (EDT)
Received: by mail-bk0-f45.google.com with SMTP id na10so1337836bkb.4
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 14:22:07 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id nt9si66448bkb.319.2014.04.01.14.22.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 01 Apr 2014 14:22:06 -0700 (PDT)
Date: Tue, 1 Apr 2014 17:21:02 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Message-ID: <20140401212102.GM4407@cmpxchg.org>
References: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

[ I tried to bring this up during LSFMM but it got drowned out.
  Trying again :) ]

On Fri, Mar 21, 2014 at 02:17:30PM -0700, John Stultz wrote:
> Optimistic method:
> 1) Userland marks a large range of data as volatile
> 2) Userland continues to access the data as it needs.
> 3) If userland accesses a page that has been purged, the kernel will
> send a SIGBUS
> 4) Userspace can trap the SIGBUS, mark the affected pages as
> non-volatile, and refill the data as needed before continuing on

As far as I understand, if a pointer to volatile memory makes it into
a syscall and the fault is trapped in kernel space, there won't be a
SIGBUS, the syscall will just return -EFAULT.

Handling this would mean annotating every syscall invocation to check
for -EFAULT, refill the data, and then restart the syscall.  This is
complicated even before taking external libraries into account, which
may not propagate syscall returns properly or may not be reentrant at
the necessary granularity.

Another option is to never pass volatile memory pointers into the
kernel, but that too means that knowledge of volatility has to travel
alongside the pointers, which will either result in more complexity
throughout the application or severely limited scope of volatile
memory usage.

Either way, optimistic volatile pointers are nowhere near as
transparent to the application as the above description suggests,
which makes this usecase not very interesting, IMO.  If we can support
it at little cost, why not, but I don't think we should complicate the
common usecases to support this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

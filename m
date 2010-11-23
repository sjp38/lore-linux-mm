Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 20FCB6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:02:07 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAN921sW000622
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 23 Nov 2010 18:02:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F6A645DD76
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:02:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 82F8745DD73
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:02:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 71C4E1DB803A
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:02:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B2691DB8038
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 18:02:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 1/2] deactive invalidated pages
In-Reply-To: <AANLkTi=ibOd3OUZ5D-V60iaNcP0_eND2VrcJB+PBo8mD@mail.gmail.com>
References: <20101123165240.7BC2.A69D9226@jp.fujitsu.com> <AANLkTi=ibOd3OUZ5D-V60iaNcP0_eND2VrcJB+PBo8mD@mail.gmail.com>
Message-Id: <20101123175948.7BD1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 23 Nov 2010 18:02:00 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

> On Tue, Nov 23, 2010 at 5:01 PM, KOSAKI Motohiro
> <kosaki.motohiro@jp.fujitsu.com> wrote:
> >> Hi KOSAKI,
> >>
> >> 2010/11/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> >> >> By Other approach, app developer uses POSIX_FADV_DONTNEED.
> >> >> But it has a problem. If kernel meets page is writing
> >> >> during invalidate_mapping_pages, it can't work.
> >> >> It is very hard for application programmer to use it.
> >> >> Because they always have to sync data before calling
> >> >> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> >> >> be discardable. At last, they can't use deferred write of kernel
> >> >> so that they could see performance loss.
> >> >> (http://insights.oetiker.ch/linux/fadvise.html)
> >> >
> >> > If rsync use the above url patch, we don't need your patch.
> >> > fdatasync() + POSIX_FADV_DONTNEED should work fine.
> >>
> >> It works well. But it needs always fdatasync before calling fadvise.
> >> For small file, it hurt performance since we can't use the deferred write.
> >
> > I doubt rsync need to call fdatasync. Why?
> >
> > If rsync continue to do following loop, some POSIX_FADV_DONTNEED
> > may not drop some dirty pages. But they can be dropped at next loop's
> > POSIX_FADV_DONTNEED. Then, It doesn't make serious issue.
> >
> > 1) read
> > 2) write
> > 3) POSIX_FADV_DONTNEED
> > 4) goto 1
> 
> fadvise need pair (offset and len).
> if the pair in next turn is different with one's previous turn, it
> couldn't be dropped.

invalidate_mapping_pages() are using pagevec_lookup() and pagevec_lookup()
are using radix tree lookup. Then, Even if rsync always use [0, inf) pair, I don't think
it makes much slowdown.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

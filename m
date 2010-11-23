Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D9A456B0085
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 02:47:50 -0500 (EST)
Date: Mon, 22 Nov 2010 23:42:57 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-Id: <20101122234257.f14bad44.akpm@linux-foundation.org>
In-Reply-To: <AANLkTinZmv540r+EkjwUu6cd9c1u7qG9iR+pvp3YqZC1@mail.gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122143817.E242.A69D9226@jp.fujitsu.com>
	<AANLkTinZmv540r+EkjwUu6cd9c1u7qG9iR+pvp3YqZC1@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 16:40:03 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi KOSAKI,
> 
> 2010/11/23 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>:
> >> By Other approach, app developer uses POSIX_FADV_DONTNEED.
> >> But it has a problem. If kernel meets page is writing
> >> during invalidate_mapping_pages, it can't work.
> >> It is very hard for application programmer to use it.
> >> Because they always have to sync data before calling
> >> fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
> >> be discardable. At last, they can't use deferred write of kernel
> >> so that they could see performance loss.
> >> (http://insights.oetiker.ch/linux/fadvise.html)
> >
> > If rsync use the above url patch, we don't need your patch.
> > fdatasync() + POSIX_FADV_DONTNEED should work fine.
> 
> It works well. But it needs always fdatasync before calling fadvise.
> For small file, it hurt performance since we can't use the deferred write.

fdatasync() is (much) better than nothing, but a userspace application
which is carefully managing its IO scheduling should use
sync_file_range(SYNC_FILE_RANGE_WRITE) to push data at the disk and
should then run fadvise(DONTNEED) against the same data a few seconds
later, after the IO has completed.

That way, the application won't block against the write I/O at all,
unless of course someone else is thrashing the disk as well, etc.

If the app is doing a lot of file I/O (eg, rsync) then this shouldn't
be too hard to arrange.  Although the payback will be pretty small
unless the IO-intensive process is also compute-intensive at times. 
And such applications are a) fairly rare and b) poorly designed:
shouldn't be doing heavy IO and heavy compute in the same thread!


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

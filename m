Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 279036B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 00:26:43 -0500 (EST)
Date: Mon, 22 Nov 2010 21:22:20 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 1/2] deactive invalidated pages
Message-Id: <20101122212220.ae26d9a5.akpm@linux-foundation.org>
In-Reply-To: <AANLkTin62R1=2P+Sh0YKJ3=KAa6RfLQLKJcn2VEtoZfG@mail.gmail.com>
References: <bdd6628e81c06f6871983c971d91160fca3f8b5e.1290349672.git.minchan.kim@gmail.com>
	<20101122141449.9de58a2c.akpm@linux-foundation.org>
	<AANLkTimk4JL7hDvLWuHjiXGNYxz8GJ_TypWFC=74Xt1Q@mail.gmail.com>
	<20101122210132.be9962c7.akpm@linux-foundation.org>
	<AANLkTin62R1=2P+Sh0YKJ3=KAa6RfLQLKJcn2VEtoZfG@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>
List-ID: <linux-mm.kvack.org>

On Tue, 23 Nov 2010 14:23:33 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:

> On Tue, Nov 23, 2010 at 2:01 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Tue, 23 Nov 2010 13:52:05 +0900 Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> >> +/*
> >> >> + * Function used to forecefully demote a page to the head of the inactive
> >> >> + * list.
> >> >> + */
> >> >
> >> > This comment is wrong? __The page gets moved to the _tail_ of the
> >> > inactive list?
> >>
> >> No. I add it in _head_ of the inactive list intentionally.
> >> Why I don't add it to _tail_ is that I don't want to be aggressive.
> >> The page might be real working set. So I want to give a chance to
> >> activate it again.
> >
> > Well.. __why? __The user just tried to toss the page away altogether. __If
> > the kernel wasn't able to do that immediately, the best it can do is to
> > toss the page away asap?
> >
> >> If it's not working set, it can be reclaimed easily and it can prevent
> >> active page demotion since inactive list size would be big enough for
> >> not calling shrink_active_list.
> >
> > What is "working set"? __Mapped and unmapped pagecache, or are you
> > referring solely to mapped pagecache?
> 
> I mean it's mapped by other processes.
> 
> >
> > If it's mapped pagecache then the user was being a bit silly (or didn't
> > know that some other process had mapped the file). __In which case we
> > need to decide what to do - leave the page alone, deactivate it, or
> > half-deactivate it as this patch does.
> 
> 
> What I want is the half-deactivate.
> 
> Okay. We will use the result of invalidate_inode_page.
> If fail happens by page_mapped, we can do half-deactivate.
> But if fail happens by dirty(ex, writeback), we can add it to tail.
> Does it make sense?

Spose so.  It's unobvious.

If the page is dirty or under writeback then reclaim will immediately
move it to the head of the LRU anyway.  But given that the user has
just freed a bunch of pages with invalidate(), it's unlikely that
reclaim will be running soon.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

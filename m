Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5DB406B01B0
	for <linux-mm@kvack.org>; Mon, 28 Jun 2010 15:11:51 -0400 (EDT)
Date: Mon, 28 Jun 2010 12:10:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Patch] Call cond_resched() at bottom of main look in
 balance_pgdat()
Message-Id: <20100628121056.408cbca2.akpm@linux-foundation.org>
In-Reply-To: <AANLkTin-dYU245QH3WJWzLAx713o0pJLYozRO6tin3rq@mail.gmail.com>
References: <20100622112416.B554.A69D9226@jp.fujitsu.com>
	<AANLkTilN3EcYq400ajA2-rf3Xs4MhD-sKCg44fjzKlX1@mail.gmail.com>
	<20100622114739.B563.A69D9226@jp.fujitsu.com>
	<AANLkTimleJIOdYquPwJvgGK3Dj_JDijoNjCQh4dfXxAY@mail.gmail.com>
	<20100622213301.GA26285@cmpxchg.org>
	<AANLkTin-dYU245QH3WJWzLAx713o0pJLYozRO6tin3rq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 23 Jun 2010 08:07:34 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> Reviewed-by: Rik van Riel <riel@redhat.com>
> Reviewed-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>

The patch is a bit sucky, isn't it?

a) the cond_resched() which Larry's patch adds is very special.  It
   _looks_ like a random preemption point but it's actually critical to
   the correct functioning of the system.  That's utterly unobvious to
   anyone who reads the code, so a comment explaining this *must* be
   included.

b) cond_resched() is a really crappy way of solving the problem
   which Larry described.  It will sit there chewing away CPU time
   until kswapd's timeslice expires.

I suppose we can live with b) although it _does_ suck and I'd suggest
that the comment include a big FIXME, so someone might fix it.

Larry, please fix a), gather the acks and reviewed-by's, update the
changelog to identify the commit which broke it and resend?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

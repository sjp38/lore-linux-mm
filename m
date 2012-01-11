Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 87E1E6B004D
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 18:15:46 -0500 (EST)
Date: Wed, 11 Jan 2012 15:15:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH -mm] make swapin readahead skip over holes
Message-Id: <20120111151545.4636bc49.akpm@linux-foundation.org>
In-Reply-To: <CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com>
References: <20120109181023.7c81d0be@annuminas.surriel.com>
	<4F0B7D1F.7040802@gmail.com>
	<4F0BABE0.8080107@redhat.com>
	<CAHGf_=qtpA5VTw5W0zaAhB2WCX1+-k59szTnDLnqDJeg+q9Jsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>

On Wed, 11 Jan 2012 02:14:32 -0500
KOSAKI Motohiro <kosaki.motohiro@gmail.com> wrote:

> > Another factor is that swapping on modern systems is often a
> > temporary thing. During a load spike, things get swapped out
> > and run slowly. After the load spike is over, or some memory
> > hog process got killed, we want the system to recover to normal
> > performance as soon as possible. __This often involves swapping
> > everything back into memory.
> 
> Hmmm.... OK, I have to agree this.
> But if so, to skip hole is not best way. I think we should always makes
> one big IO, even if the swap cluster have some holes. one big IO is
> usually faster than multiple small IOs. Isn't it?

Not necessarily.  If we have two requests in the disk for blocks 0-3
and 8-11, one would hope that the disk is smart enough to read both
blocks within a single rotation.

If the kernel were to recognise this situation and request the entire
12 blocks then we'd see lower command overhead but higher transfer
costs.

Still, Rik's testing shows that either approach would be superior to
what we have at present, which is to not read blocks 8-11 at all!


It sounds like Rik will be doing a v2 with some minor updates?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

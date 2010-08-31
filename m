Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 5A6136B0047
	for <linux-mm@kvack.org>; Tue, 31 Aug 2010 17:35:42 -0400 (EDT)
Date: Tue, 31 Aug 2010 16:35:37 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 03/10] Use percpu stats
In-Reply-To: <1283290106.2198.26.camel@edumazet-laptop>
Message-ID: <alpine.DEB.2.00.1008311635100.867@router.home>
References: <1281374816-904-1-git-send-email-ngupta@vflare.org>  <1281374816-904-4-git-send-email-ngupta@vflare.org>  <alpine.DEB.2.00.1008301114460.10316@router.home>  <AANLkTikdhnr12uU8Wp60BygZwH770RBfxyfLNMzUsQje@mail.gmail.com>
 <1283290106.2198.26.camel@edumazet-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Nitin Gupta <ngupta@vflare.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <greg@kroah.com>, Linux Driver Project <devel@driverdev.osuosl.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Aug 2010, Eric Dumazet wrote:

> > Yes, this_cpu_add() seems sufficient. I can't recall why I used u64_stats_*
> > but if it's not required for atomic access to 64-bit then why was it added to
> > the mainline in the first place?
>
> Because we wanted to have fast 64bit counters, even on 32bit arches, and
> this has litle to do with 'atomic' on one entity, but a group of
> counters. (check drivers/net/loopback.c, lines 91-94). No lock prefix
> used in fast path.
>
> We also wanted readers to read correct values, not a value being changed
> by a writer, with inconsistent 32bit halves. SNMP applications want
> monotonically increasing counters.
>
> this_cpu_add()/this_cpu_read() doesnt fit.
>
> Even for single counter, this_cpu_read(64bit) is not using an RMW
> (cmpxchg8) instruction, so you can get very strange results when low
> order 32bit wraps.

How about fixing it so that everyone benefits?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

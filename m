Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 56D0A8D0039
	for <linux-mm@kvack.org>; Mon, 28 Feb 2011 18:07:42 -0500 (EST)
Date: Tue, 1 Mar 2011 00:07:12 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm: compaction: Minimise the time IRQs are
 disabled while isolating pages for migration
Message-ID: <20110228230712.GR22700@random.random>
References: <1298664299-10270-1-git-send-email-mel@csn.ul.ie>
 <1298664299-10270-3-git-send-email-mel@csn.ul.ie>
 <20110228230131.GB1896@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110228230131.GB1896@barrios-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Arthur Marsh <arthur.marsh@internode.on.net>, Clemens Ladisch <cladisch@googlemail.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Mar 01, 2011 at 08:01:31AM +0900, Minchan Kim wrote:
> I am not sure it's good if we release the lock whenever lru->lock was contended
> unconditionally? There are many kinds of lru_lock operations(add to lru, 
> del from lru, isolation, reclaim, activation, deactivation and so on).

This is mostly to mirror cond_resched_lock (which actually uses
spin_needbreak but it's ok to have it also when preempt is off). I
doubt it makes a big difference but I tried to mirror
cond_resched_lock.

> Do we really need to release the lock whenever all such operations were contened?
> I think what we need is just spin_is_contended_irqcontext.
> Otherwise, please write down the comment for justifying for it.

What is spin_is_contended_irqcontext?

> This patch is for reducing for irq latency but do we have to check signal 
> in irq hold time?

I think it's good idea to check the signal in case the loop is very
long and this is run in direct compaction context.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

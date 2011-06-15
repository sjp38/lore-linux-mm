Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id F3C906B0012
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 20:37:19 -0400 (EDT)
Date: Tue, 14 Jun 2011 17:36:00 -0700
From: Andi Kleen <ak@linux.intel.com>
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
Message-ID: <20110615003600.GA9602@tassilo.jf.intel.com>
References: <1308097798.17300.142.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1308097798.17300.142.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>

> On 2.6.39, the contention of anon_vma->lock occupies 3.25% of cpu.
> However, after the switch of the lock to mutex on 3.0-rc2, the mutex
> acquisition jumps to 18.6% of cpu.  This seems to be the main cause of
> the 52% throughput regression.
> 
This patch makes the mutex in Tim's workload take a bit less CPU time
(4% down) but it doesn't really fix the regression. When spinning for a 
value it's always better to read it first before attempting to write it.
This saves expensive operations on the interconnect.

So it's not really a fix for this, but may be a slight improvement for 
other workloads.

-Andi

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id C2E156B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 07:53:14 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <1308101214.15392.151.camel@sli10-conroe>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308101214.15392.151.camel@sli10-conroe>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 15 Jun 2011 13:52:30 +0200
Message-ID: <1308138750.15315.62.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "ak@linux.intel.com" <ak@linux.intel.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>

On Wed, 2011-06-15 at 09:26 +0800, Shaohua Li wrote:

> On Wed, 2011-06-15 at 08:29 +0800, Tim Chen wrote:
> >          + 7.30% anon_vma_clone_batch

> what are you testing? I didn't see Andi's batch anon->lock for fork
> patches are merged in 2.6.39.=20

Good spot that certainly isn't plain .39.

It looks like those (http://marc.info/?l=3Dlinux-mm&m=3D130533041726258) ar=
e
similar to Linus' patch, except Linus takes the hard line that the root
lock should stay the same. Let me try Linus' patch first to see if this
workload can trigger his WARN.

/me mutters something about patches in attachments and rebuilds.

OK, the WARN doesn't trigger, but it also doesn't improve things (quite
the opposite in fact):

-tip            260.092 messages/sec/core
    +sirq-rcu   271.078 messages/sec/core
    +linus      262.435 messages/sec/core

So Linus' patch makes the throughput drop from 271 to 262, weird.

/me goes re-test without the sirq-rcu bits mixed in just to make sure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 36CEC6B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 16:57:32 -0400 (EDT)
Message-ID: <4DF91CB9.5080504@linux.intel.com>
Date: Wed, 15 Jun 2011 13:57:29 -0700
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: REGRESSION: Performance regressions from switching anon_vma->lock
 to mutex
References: <1308097798.17300.142.camel@schen9-DESK>	 <1308101214.15392.151.camel@sli10-conroe> <1308138750.15315.62.camel@twins>	 <20110615161827.GA11769@tassilo.jf.intel.com>	 <1308156337.2171.23.camel@laptop>  <1308163398.17300.147.camel@schen9-DESK> <1308169937.15315.88.camel@twins>
In-Reply-To: <1308169937.15315.88.camel@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Shaohua Li <shaohua.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, "Luck, Tony" <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, "Shi, Alex" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>


>       7.44%        exim  [kernel.kallsyms]              [k] format_decode
>                    |
>                    --- format_decod


This is a glibc issue. exim calls libdb and libdb asks sysconf for the 
number of CPUs to tune
its locking, and glibc reads /proc/stat.  And /proc/stat is incredible slow.

I would blame glibc, but in this case it's really the kernel to blame 
for not providing proper
interface.

This was my motivation for the sysconf() syscall I submitted some time ago.
https://lkml.org/lkml/2011/5/13/455

Anyways a quick workaround is to use this LD_PRELOAD: 
http://halobates.de/smallsrc/sysconf.c
But it's not 100% equivalent.

-Andi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

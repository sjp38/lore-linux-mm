Content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch 0/3] no MAX_ARG_PAGES -v2
Date: Wed, 13 Jun 2007 16:36:13 -0700
Message-ID: <617E1C2C70743745A92448908E030B2A01AF860A@scsmsx411.amr.corp.intel.com>
In-Reply-To: <20070613100334.635756997@chello.nl>
From: "Luck, Tony" <tony.luck@intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org
Cc: Ollie Wild <aaw@google.com>, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

> This patch-set aims at removing the current limit on argv+env space aka.
> MAX_ARG_PAGES.

Running with this patch shows that /bin/bash has some unpleasant
O(n^2) performance issues with long argument lists.  I made a
1Mbyte file full of pathnames, then timed the execution of:

$ /bin/echo `cat megabyte` | wc
$ /bin/echo `cat megabyte megabyte` | wc
   etc. ...

System time was pretty much linear as the arglist grew
(and only got up to 0.144 seconds at 5Mbytes).

But user time ~= real time (in seconds) looks like:

1 5.318
2 18.871
3 40.620
4 70.819
5 108.911

Above 5Mbytes, I started seeing problems.  The line/word/char
counts from "wc" started being "0 0 0".  Not sure if this is
a problem in "wc" dealing with a single line >5MBytes, or some
other problem (possibly I was exceeding the per-process stack
limit which is only 8MB on that machine).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

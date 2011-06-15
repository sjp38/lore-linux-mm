Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 3CBC76B0012
	for <linux-mm@kvack.org>; Wed, 15 Jun 2011 06:59:16 -0400 (EDT)
Subject: Re: REGRESSION: Performance regressions from switching
 anon_vma->lock to mutex
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1308134200.15315.32.camel@twins>
References: <1308097798.17300.142.camel@schen9-DESK>
	 <1308134200.15315.32.camel@twins>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Wed, 15 Jun 2011 12:58:15 +0200
Message-ID: <1308135495.15315.38.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Russell King <rmk@arm.linux.org.uk>, Paul Mundt <lethal@linux-sh.org>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@kernel.dk>, Namhyung Kim <namhyung@gmail.com>, ak@linux.intel.com, shaohua.li@intel.com, alex.shi@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Rafael J. Wysocki" <rjw@sisk.pl>, paulmck <paulmck@linux.vnet.ibm.com>

On Wed, 2011-06-15 at 12:36 +0200, Peter Zijlstra wrote:
> On Tue, 2011-06-14 at 17:29 -0700, Tim Chen wrote:
> > MOSBENCH test suite.
>=20
> Argh, I'm trying to get this thing to run, but its all snake poo..
>=20
> /me takes up a heavy club and goes snake hunting, should make a pretty
> hat or something.

Sweet, I've got meself a snake-skin hat!

The first thing that stood out when running it was:

31694 root      20   0 26660 1460 1212 S 17.5  0.0   0:01.97 exim=20
    7 root      -2  19     0    0    0 S 12.7  0.0   0:06.14 rcuc0=20
   24 root      -2  19     0    0    0 S 11.7  0.0   0:04.15 rcuc3=20
   34 root      -2  19     0    0    0 S 11.7  0.0   0:04.10 rcuc5=20
   39 root      -2  19     0    0    0 S 11.7  0.0   0:06.38 rcuc6=20
   44 root      -2  19     0    0    0 S 11.7  0.0   0:04.53 rcuc7=20
   49 root      -2  19     0    0    0 S 11.7  0.0   0:04.11 rcuc8=20
   79 root      -2  19     0    0    0 S 11.7  0.0   0:03.91 rcuc14=20
   89 root      -2  19     0    0    0 S 11.7  0.0   0:03.90 rcuc16=20
  110 root      -2  19     0    0    0 S 11.7  0.0   0:03.90 rcuc20=20
  120 root      -2  19     0    0    0 S 11.7  0.0   0:03.82 rcuc22=20
   13 root      -2  19     0    0    0 S 10.7  0.0   0:04.37 rcuc1=20
   19 root      -2  19     0    0    0 S 10.7  0.0   0:04.19 rcuc2=20
   29 root      -2  19     0    0    0 S 10.7  0.0   0:04.12 rcuc4=20
   54 root      -2  19     0    0    0 S 10.7  0.0   0:04.11 rcuc9=20
   59 root      -2  19     0    0    0 S 10.7  0.0   0:04.40 rcuc10=20
   64 root      -2  19     0    0    0 R 10.7  0.0   0:04.17 rcuc11=20
   69 root      -2  19     0    0    0 R 10.7  0.0   0:04.23 rcuc12=20
   84 root      -2  19     0    0    0 S 10.7  0.0   0:03.90 rcuc15=20
   95 root      -2  19     0    0    0 S 10.7  0.0   0:03.99 rcuc17=20
  100 root      -2  19     0    0    0 S 10.7  0.0   0:03.88 rcuc18=20
  105 root      -2  19     0    0    0 S 10.7  0.0   0:04.14 rcuc19=20
  125 root      -2  19     0    0    0 S 10.7  0.0   0:03.79 rcuc23=20
   74 root      -2  19     0    0    0 S  9.7  0.0   0:04.33 rcuc13=20
  115 root      -2  19     0    0    0 R  9.7  0.0   0:03.82 rcuc21=20

Which is an impressive amount of RCU usage..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

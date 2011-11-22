Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 18DF96B0069
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 22:18:57 -0500 (EST)
Date: Mon, 21 Nov 2011 21:18:52 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: WARNING: at mm/slub.c:3357, kernel BUG at mm/slub.c:3413
In-Reply-To: <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
Message-ID: <alpine.DEB.2.00.1111212105330.19606@router.home>
References: <20111121131531.GA1679@x4.trippels.de>  <1321884966.10470.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121153621.GA1678@x4.trippels.de>  <1321890510.10470.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121161036.GA1679@x4.trippels.de>
  <1321894353.10470.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <1321895706.10470.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121173556.GA1673@x4.trippels.de>  <1321900743.10470.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>  <20111121185215.GA1673@x4.trippels.de>
  <20111121195113.GA1678@x4.trippels.de> <1321907275.13860.12.camel@pasglop> <alpine.DEB.2.01.1111211617220.8000@trent.utfs.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christian Kujau <lists@nerdbynature.de>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Markus Trippelsdorf <markus@trippelsdorf.de>, Eric Dumazet <eric.dumazet@gmail.com>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Mon, 21 Nov 2011, Christian Kujau wrote:

> On Tue, 22 Nov 2011 at 07:27, Benjamin Herrenschmidt wrote:
> > Note that I hit a similar looking crash (sorry, I couldn't capture a
> > backtrace back then) on a PowerMac G5 (ppc64) while doing a large rsync
> > transfer yesterday with -rc2-something (cfcfc9ec) and
> > Christian Kujau (CC) seems to be able to reproduce something similar on
> > some other ppc platform (Christian, what is your setup ?)
>
> I seem to hit it with heavy disk & cpu IO is in progress on this PowerBook
> G4. Full dmesg & .config: http://nerdbynature.de/bits/3.2.0-rc1/oops/
>
> I've enabled some debug options and now it really points to slub.c:2166

Hmmm... That means that c->page points to page not frozen. Per cpu
partial pages are frozen until they are reused or until the partial list
is flushed.

Does this ever happen on x86 or only on other platforms? In put_cpu_partial() the
this_cpu_cmpxchg really needs really to be irq safe. this_cpu_cmpxchg is
only preempt safe.

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-21 21:15:41.575673204 -0600
+++ linux-2.6/mm/slub.c	2011-11-21 21:16:33.442336849 -0600
@@ -1969,7 +1969,7 @@
 		page->pobjects = pobjects;
 		page->next = oldpage;

-	} while (this_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
+	} while (irqsafe_cpu_cmpxchg(s->cpu_slab->partial, oldpage, page) != oldpage);
 	stat(s, CPU_PARTIAL_FREE);
 	return pobjects;
 }

x

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

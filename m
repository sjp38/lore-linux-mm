Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 256426B009B
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 14:46:17 -0500 (EST)
Date: Tue, 22 Nov 2011 13:46:11 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: Lockout validation scans during freeing of object
In-Reply-To: <20111122193231.GB1627@x4.trippels.de>
Message-ID: <alpine.DEB.2.00.1111221340320.30368@router.home>
References: <alpine.DEB.2.00.1111221033350.28197@router.home> <alpine.DEB.2.00.1111221040300.28197@router.home> <alpine.DEB.2.00.1111221052130.28197@router.home> <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <alpine.DEB.2.00.1111221139240.28197@router.home>
 <20111122185540.GA1627@x4.trippels.de> <alpine.DEB.2.00.1111221319070.30368@router.home> <20111122193231.GB1627@x4.trippels.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011, Markus Trippelsdorf wrote:

> > Could you get me the value of the "slabs" field for the slabs showing the
> > wierd values. I.e. do
> >
> > cat /sys/kernel/slab/signal_cache/slabs
> >
> > > signal_cache               268     920   360.4K 18446744073709551614/7/24   17 2  31  68 A
> >
>
> It's quite easy to explain. You're using unsigned ints in:
> snprintf(dist_str, 40, "%lu/%lu/%d", s->slabs - s->cpu_slabs, s->partial, s->cpu_slabs);
>
> and  (s->slabs - s->cpu_slabs) can get negative. For example:
>
> task_struct                269    1504   557.0K 18446744073709551601/5/32   21 3  29  72
>
> Here s-slabs is 17 and s->cpu_slabs is 32.
> That gives: 17-32=18446744073709551601.

s->cpu_slabs includes the number of per cpu partial slabs since 3.2. And
that calculation is broken it seems. It adds up the number of objects instead
of the number of slab pages.

So much for review and having that stuff in -next for a long time. Sigh.


Subject: slub: Fix per cpu partial statistics

Support for SO_OBJECTS was not properly added to show_slab_objects().

If SO_OBJECTS is not set then the number of slab pages needs to be
returned not the number of objects in the partial slabs.
We do not have that number so just return 1 until we find a better
way to determine that.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/slub.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-22 13:42:23.000000000 -0600
+++ linux-2.6/mm/slub.c	2011-11-22 13:43:56.000000000 -0600
@@ -4451,7 +4451,7 @@ static ssize_t show_slab_objects(struct
 				continue;

 			if (c->page) {
-					if (flags & SO_TOTAL)
+				if (flags & SO_TOTAL)
 						x = c->page->objects;
 				else if (flags & SO_OBJECTS)
 					x = c->page->inuse;
@@ -4464,7 +4464,11 @@ static ssize_t show_slab_objects(struct
 			page = c->partial;

 			if (page) {
-				x = page->pobjects;
+				if (flags & SO_OBJECTS)
+					x = page->pobjects;
+				else
+					/* Assume one */
+					x = 1;
                                 total += x;
                                 nodes[c->node] += x;
 			}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

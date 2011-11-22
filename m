Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A5EDE6B0088
	for <linux-mm@kvack.org>; Tue, 22 Nov 2011 12:59:27 -0500 (EST)
Date: Tue, 22 Nov 2011 11:59:22 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: Lockout validation scans during freeing of object
In-Reply-To: <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Message-ID: <alpine.DEB.2.00.1111221144580.28197@router.home>
References: <alpine.DEB.2.00.1111221033350.28197@router.home>  <alpine.DEB.2.00.1111221040300.28197@router.home>  <alpine.DEB.2.00.1111221052130.28197@router.home> <1321982484.18002.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>, Christian Kujau <lists@nerdbynature.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, "Alex,Shi" <alex.shi@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>

On Tue, 22 Nov 2011, Eric Dumazet wrote:

> This seems better, but I still have some warnings :
>
> [  162.117574] SLUB: selinux_inode_security 136 slabs counted but counter=137
> [  179.879907] SLUB: task_xstate 1 slabs counted but counter=2

This is the total # of slabs that mismatches. Some slabs are not on the
partial list and are neither on the full list since they are currently
on the per cpu partial lists. Thats an accounting issue introduced in 3.2
with the per cpu pages. Need to find some way to count the per cpu partial
pages correctly. Could just force the per cpu pages to be empty?


Subject: Switch per cpu partial page support off for debugging

Otherwise we have accounting issues.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/slub.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: linux-2.6/mm/slub.c
===================================================================
--- linux-2.6.orig/mm/slub.c	2011-11-22 11:57:21.000000000 -0600
+++ linux-2.6/mm/slub.c	2011-11-22 11:57:55.000000000 -0600
@@ -3027,7 +3027,9 @@ static int kmem_cache_open(struct kmem_c
 	 *    per node list when we run out of per cpu objects. We only fetch 50%
 	 *    to keep some capacity around for frees.
 	 */
-	if (s->size >= PAGE_SIZE)
+	if (kmem_cache_debug(s))
+		s->cpu_partial = 0;
+	else if (s->size >= PAGE_SIZE)
 		s->cpu_partial = 2;
 	else if (s->size >= 1024)
 		s->cpu_partial = 6;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

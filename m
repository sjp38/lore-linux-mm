Date: Mon, 7 May 2007 19:48:32 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 16/17] SLUB: Include lifetime stats and sets of cpus /
 nodes in tracking output
In-Reply-To: <20070507212411.097801338@sgi.com>
Message-ID: <Pine.LNX.4.64.0705071942180.27156@schroedinger.engr.sgi.com>
References: <20070507212240.254911542@sgi.com> <20070507212411.097801338@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

32 bit cannot perform 64 bit division.

Replace division by div_long_long.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-mm1/mm/slub.c
===================================================================
--- linux-2.6.21-mm1.orig/mm/slub.c	2007-05-07 19:40:06.000000000 -0700
+++ linux-2.6.21-mm1/mm/slub.c	2007-05-07 19:42:00.000000000 -0700
@@ -2990,12 +2990,14 @@ static int list_locations(struct kmem_ca
 		else
 			n += sprintf(buf + n, "<not-available>");
 
-		if (l->sum_time != l->min_time)
+		if (l->sum_time != l->min_time) {
+			unsigned long remainder;
+
 			n += sprintf(buf + n, " age=%ld/%ld/%ld",
 			l->min_time,
-			(unsigned long)(l->sum_time / l->count),
+			div_long_long_rem(l->sum_time, l->count, &remainder),
 			l->max_time);
-		else
+		} else
 			n += sprintf(buf + n, " age=%ld",
 				l->min_time);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

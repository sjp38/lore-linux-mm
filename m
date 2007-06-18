Date: Mon, 18 Jun 2007 12:19:05 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 00/26] Current slab allocator / SLUB patch queue
In-Reply-To: <6bffcb0e0706181209p49f4ae86xce5418b7c9b3edbb@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0706181217350.8899@schroedinger.engr.sgi.com>
References: <20070618095838.238615343@sgi.com>  <46767346.2040108@googlemail.com>
  <Pine.LNX.4.64.0706180936280.4751@schroedinger.engr.sgi.com>
 <6bffcb0e0706181038j107e2357o89c525261cf671a@mail.gmail.com>
 <Pine.LNX.4.64.0706181102280.6596@schroedinger.engr.sgi.com>
 <6bffcb0e0706181158l739864e0t6fb5bc564444f23c@mail.gmail.com>
 <Pine.LNX.4.64.0706181159430.1896@schroedinger.engr.sgi.com>
 <6bffcb0e0706181209p49f4ae86xce5418b7c9b3edbb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, suresh.b.siddha@intel.com
List-ID: <linux-mm.kvack.org>

Stupid me. n on both sides of the comparison. Tried to run your script 
here but I cannot trigger it.

Next attempt: Sorry for the churn.

SLUB: Fix behavior if the text output of list_locations overflows PAGE_SIZE

If slabs are allocated or freed from a large set of call sites (typical
for the kmalloc area) then we may create more output than fits into
a single PAGE and sysfs only gives us one page. The output should be
truncated. This patch fixes the checks to do the truncation properly.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.22-rc4-mm2/mm/slub.c
===================================================================
--- linux-2.6.22-rc4-mm2.orig/mm/slub.c	2007-06-18 12:13:48.000000000 -0700
+++ linux-2.6.22-rc4-mm2/mm/slub.c	2007-06-18 12:15:10.000000000 -0700
@@ -3649,13 +3649,15 @@ static int list_locations(struct kmem_ca
 			n += sprintf(buf + n, " pid=%ld",
 				l->min_pid);
 
-		if (num_online_cpus() > 1 && !cpus_empty(l->cpus)) {
+		if (num_online_cpus() > 1 && !cpus_empty(l->cpus) &&
+				n < PAGE_SIZE - 60) {
 			n += sprintf(buf + n, " cpus=");
 			n += cpulist_scnprintf(buf + n, PAGE_SIZE - n - 50,
 					l->cpus);
 		}
 
-		if (num_online_nodes() > 1 && !nodes_empty(l->nodes)) {
+		if (num_online_nodes() > 1 && !nodes_empty(l->nodes) &&
+				n < PAGE_SIZE - 60) {
 			n += sprintf(buf + n, " nodes=");
 			n += nodelist_scnprintf(buf + n, PAGE_SIZE - n - 50,
 					l->nodes);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

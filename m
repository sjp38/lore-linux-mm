Date: Tue, 31 Jul 2007 19:52:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
In-Reply-To: <20070731192241.380e93a0.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Andrew Morton wrote:

> >
> > +#define for_each_node_state(node, __state) \
> > +	for ( (node) = 0; (node) != 0; (node) = 1)
> 
> That looks weird.

Yup and we have committed the usual sin of not testing !NUMA.

Loop needs to be executed for node = 0 but have node = 1 on exit. We 
want to avoid increments so that the compiler can optimize better.

As it is the loop as is is not executed at all and we have node = 0 when 
the loop is done. 

---
 include/linux/nodemask.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6/include/linux/nodemask.h
===================================================================
--- linux-2.6.orig/include/linux/nodemask.h	2007-07-31 19:46:00.000000000 -0700
+++ linux-2.6/include/linux/nodemask.h	2007-07-31 19:46:29.000000000 -0700
@@ -404,7 +404,7 @@ static inline int num_node_state(enum no
 }
 
 #define for_each_node_state(node, __state) \
-	for ( (node) = 0; (node) != 0; (node) = 1)
+	for ( (node) = 0; (node) == 0; (node) = 1)
 
 #define first_online_node	0
 #define next_online_node(nid)	(MAX_NUMNODES)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

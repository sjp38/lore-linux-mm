Date: Fri, 9 May 2003 11:15:35 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm3
Message-ID: <20030509181535.GZ8978@holomorphy.com>
References: <20030508013958.157b27b7.akpm@digeo.com> <20030509181257.GB8931@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030509181257.GB8931@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 09, 2003 at 11:12:57AM -0700, William Lee Irwin III wrote:
> topology.h has a syntactic hygiene issue where it has a for () loop with
> an if () in the body defined as a macro:
> #define foo(...) for (...) if (...)
> This patch prepares some of the bitop definitions used for the loop
> mechanics to be usable in headers where BITS_PER_LONG is not guaranteed
> to be defined for some reason. It removes the #ifdef on BITS_PER_LONG
> in favor of if (sizeof(...) == ...) tests so hweight_long() will be
> defined even when BITS_PER_LONG is not. unsigned long is also used for
> some variables and/or return types that changed size with BITS_PER_LONG.
> The 32-bit generic_hweight64() also changed its argument from a pointer
> to a u64, which actually makes for a consistent interface in both cases.
> The follow-up will make use of this to clean up the hygiene issue above
> and correct a compilation error in topology.h


diff -urpN mm3-2.5.69-1/include/linux/topology.h mm3-2.5.69-2/include/linux/topology.h
--- mm3-2.5.69-1/include/linux/topology.h	2003-05-09 09:22:16.000000000 -0700
+++ mm3-2.5.69-2/include/linux/topology.h	2003-05-09 10:29:08.000000000 -0700
@@ -32,8 +32,15 @@
 
 #define nr_cpus_node(node)	(hweight_long(node_to_cpumask(node)))
 
+static inline int __next_node_with_cpus(int node)
+{
+	do
+		++node;
+	while (!nr_cpus_node(node) && node < numnodes);
+	return node;
+}
+
 #define for_each_node_with_cpus(node) \
-	for (node = 0; node < numnodes; node++) \
-		if (nr_cpus_node(node)
+	for (node = 0; node < numnodes; node = __next_node_with_cpus(node))
 
 #endif /* _LINUX_TOPOLOGY_H */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

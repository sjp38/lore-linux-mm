Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id C31286B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 16:08:15 -0400 (EDT)
Message-ID: <4F97082B.9040903@redhat.com>
Date: Tue, 24 Apr 2012 16:08:11 -0400
From: Larry Woodman <lwoodman@redhat.com>
Reply-To: lwoodman@redhat.com
MIME-Version: 1.0
Subject: Re: [PATCH -mm V2] do_migrate_pages() calls migrate_to_node() even
 if task is already on a correct node
References: <4F96CDE1.5000909@redhat.com> <4F96D27A.2050005@gmail.com> <4F96DFE0.6040306@redhat.com> <alpine.DEB.2.00.1204241317170.26005@router.home>
In-Reply-To: <alpine.DEB.2.00.1204241317170.26005@router.home>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Motohiro Kosaki <mkosaki@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

On 04/24/2012 02:17 PM, Christoph Lameter wrote:
> On Tue, 24 Apr 2012, Larry Woodman wrote:
>
>> How does this look:
>
> Could you please send the patches inline? Its difficult to quote the
> attachment.
>

Sorry all of these email clients are different.


diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index f563fa3..b76b49a 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1012,6 +1012,24 @@ int do_migrate_pages(struct mm_struct *mm,
                 int dest = 0;

                 for_each_node_mask(s, tmp) {
+
+                       /*
+                        * IFF there is an equal number of source and
+                        * destination nodes, maintain relative node 
distance
+                        * even when source and destination nodes overlap.
+                        * However, when the node weight is 
unequal/there are
+                        * a different number of source and destination 
nodes,
+                        * never move memory out of a source node that 
is also
+                        * a destination node.
+                        *
+                        * Example: [2,3,4] -> [3,4,5] moves everything.
+                        *          [0-7] - > [3,4,5] moves only 0,1,2,6,7.
+                        */
+
+                       if ((nodes_weight(*from_nodes) != 
nodes_weight(*to_nodes)) &&
+                                               (node_isset(s, *to_nodes)))
+                               continue;
+
                         d = node_remap(s, *from_nodes, *to_nodes);
                         if (s == d)
                                 continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

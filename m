Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1416B004D
	for <linux-mm@kvack.org>; Wed, 26 Aug 2009 14:02:29 -0400 (EDT)
Subject: Re: [PATCH 4/5] hugetlb:  add per node hstate attributes
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090826101122.GD10955@csn.ul.ie>
References: <20090824192437.10317.77172.sendpatchset@localhost.localdomain>
	 <20090824192902.10317.94512.sendpatchset@localhost.localdomain>
	 <20090825101906.GB4427@csn.ul.ie>
	 <1251233369.16229.1.camel@useless.americas.hpqcorp.net>
	 <20090826101122.GD10955@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 26 Aug 2009 14:02:27 -0400
Message-Id: <1251309747.4409.45.camel@useless.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-numa@vger.kernel.org, akpm@linux-foundation.org, Nishanth Aravamudan <nacc@us.ibm.com>, David Rientjes <rientjes@google.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2009-08-26 at 11:11 +0100, Mel Gorman wrote:
> On Tue, Aug 25, 2009 at 04:49:29PM -0400, Lee Schermerhorn wrote:
> > > > 
> > > > +static nodemask_t *nodes_allowed_from_node(int nid)
> > > > +{
> > > 
> > > This name is a bit weird. It's creating a nodemask with just a single
> > > node allowed.
> > > 
> > > Is there something wrong with using the existing function
> > > nodemask_of_node()? If stack is the problem, prehaps there is some macro
> > > magic that would allow a nodemask to be either declared on the stack or
> > > kmalloc'd.
> > 
> > Yeah.  nodemask_of_node() creates an on-stack mask, invisibly, in a
> > block nested inside the context where it's invoked.  I would be
> > declaring the nodemask in the compound else clause and don't want to
> > access it [via the nodes_allowed pointer] from outside of there.
> > 
> 
> So, the existance of the mask on the stack is the problem. I can
> understand that, they are potentially quite large.
> 
> Would it be possible to add a helper along side it like
> init_nodemask_of_node() that does the same work as nodemask_of_node()
> but takes a nodemask parameter? nodemask_of_node() would reuse the
> init_nodemask_of_node() except it declares the nodemask on the stack.
> 

<snip>

Here's the patch that introduces the helper function that I propose.
I'll send an update of the subject patch that uses this macro and, I
think, addresses your other issues via a separate message.  This patch
applies just before the "register per node attributes" patch.  Once we
can agree on these [or subsequent] changes, I'll repost the entire
updated series.

Lee

---

PATCH 4/6 - hugetlb:  introduce alloc_nodemask_of_node()

Against: 2.6.31-rc6-mmotm-090820-1918

Introduce nodemask macro to allocate a nodemask and 
initialize it to contain a single node, using existing
nodemask_of_node() macro.  Coded as a macro to avoid header
dependency hell.

This will be used to construct the huge pages "nodes_allowed"
nodemask for a single node when a persistent huge page
pool page count is modified via a per node sysfs attribute.

Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/nodemask.h |   10 ++++++++++
 1 file changed, 10 insertions(+)

Index: linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h
===================================================================
--- linux-2.6.31-rc6-mmotm-090820-1918.orig/include/linux/nodemask.h	2009-08-24 10:16:56.000000000 -0400
+++ linux-2.6.31-rc6-mmotm-090820-1918/include/linux/nodemask.h	2009-08-26 12:38:31.000000000 -0400
@@ -257,6 +257,16 @@ static inline int __next_node(int n, con
 	m;								\
 })
 
+#define alloc_nodemask_of_node(node)					\
+({									\
+	typeof(_unused_nodemask_arg_) *nmp;				\
+	nmp = kmalloc(sizeof(*nmp), GFP_KERNEL);			\
+	if (nmp)							\
+		*nmp = nodemask_of_node(node);				\
+	nmp;								\
+})
+
+
 #define first_unset_node(mask) __first_unset_node(&(mask))
 static inline int __first_unset_node(const nodemask_t *maskp)
 {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 988EF8D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 13:48:30 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <alpine.DEB.2.00.1104191213120.17888@router.home>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
	 <alpine.LSU.2.00.1104171952040.22679@sister.anvils>
	 <20110418100131.GD8925@tiehlicka.suse.cz>
	 <20110418135637.5baac204.akpm@linux-foundation.org>
	 <20110419111004.GE21689@tiehlicka.suse.cz>
	 <1303228009.3171.18.camel@mulgrave.site>
	 <BANLkTimYrD_Sby_u-fPSwn-RJJyEVavU5w@mail.gmail.com>
	 <1303233088.3171.26.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104191213120.17888@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 19 Apr 2011 12:48:26 -0500
Message-ID: <1303235306.3171.33.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, David Rientjes <rientjes@google.com>

On Tue, 2011-04-19 at 12:15 -0500, Christoph Lameter wrote:
> On Tue, 19 Apr 2011, James Bottomley wrote:
> 
> > On Tue, 2011-04-19 at 20:05 +0300, Pekka Enberg wrote:
> > > > It seems to be a random intermittent mm crash because the next reboot
> > > > crashed with the same trace but after the fsck had completed and the
> > > > third came up to the login prompt.
> > >
> > > Looks like a genuine SLUB problem on parisc. Christoph?
> >
> > Looking through the slub code, it seems to be making invalid
> > assumptions.  All of the node stuff is dependent on CONFIG_NUMA.
> > However, we're CONFIG_DISCONTIGMEM (with CONFIG_NUMA not set): on the
> > machines I and Dave Anglin have, our physical memory ranges are 0-1GB
> > and 64-65GB, so I think slub crashes when we get a page from the high
> > memory range ... because it's not expecting a non-zero node number.
> 
> Right !NUMA systems only have node 0.

That's rubbish.  Discontigmem uses the nodes field to identify the
discontiguous region.  page_to_nid() returns this value.  Your code
wrongly assumes this is zero for non NUMA.

This simple program triggers the problem instantly because it forces
allocation up into the upper discontigmem range:

#include <stdlib.h>

void main(void)
{
  const long size = 1024*1024*1024;
  char *a = malloc(size);
  int i;

  for (i=0; i < size; i += 4096)
    a[i] = '\0';
}

I can fix the panic by hard coding get_nodes() to return the zero node
for the non-numa case ... however, presumably it's more than just this
that's broken in slub?

James

---

diff --git a/mm/slub.c b/mm/slub.c
index 94d2a33..243bd9c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -235,7 +235,11 @@ int slab_is_available(void)
 
 static inline struct kmem_cache_node *get_node(struct kmem_cache *s, int node)
 {
+#ifdef CONFIG_NUMA
 	return s->node[node];
+#else
+	return s->node[0];
+#endif
 }
 
 /* Verify that a pointer has an address that is valid within a slab page */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

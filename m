Date: Wed, 11 Jun 2008 15:29:22 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH -mm 13/25] Noreclaim LRU Infrastructure
Message-ID: <20080611062922.GA30983@linux-sh.org>
References: <20080608135704.a4b0dbe1.akpm@linux-foundation.org> <20080608173244.0ac4ad9b@bree.surriel.com> <20080608162208.a2683a6c.akpm@linux-foundation.org> <20080608193420.2a9cc030@bree.surriel.com> <20080608165434.67c87e5c.akpm@linux-foundation.org> <Pine.LNX.4.64.0806101214190.17798@schroedinger.engr.sgi.com> <20080610153702.4019e042@cuia.bos.redhat.com> <20080610143334.c53d7d8a.akpm@linux-foundation.org> <20080611050914.GA27488@linux-sh.org> <20080610231642.6b4b5a53.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080610231642.6b4b5a53.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, clameter@sgi.com, linux-kernel@vger.kernel.org, lee.schermerhorn@hp.com, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, eric.whitney@hp.com, Andi Kleen <andi@firstfloor.org>, Ingo Molnar <mingo@elte.hu>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 10, 2008 at 11:16:42PM -0700, Andrew Morton wrote:
> On Wed, 11 Jun 2008 14:09:15 +0900 Paul Mundt <lethal@linux-sh.org> wrote:
> > On Tue, Jun 10, 2008 at 02:33:34PM -0700, Andrew Morton wrote:
> > > Maybe it's time to bite the bullet and kill i386 NUMA support.  afaik
> > > it's just NUMAQ and a 2-node NUMAish machine which IBM made (as400?)
> > > 
> > > arch/sh uses NUMA for 32-bit, I believe. But I don't know what its
> > > maximum node count is.  The default for sh NODES_SHIFT is 3.  
> > 
> > In terms of memory nodes, systems vary from 2 up to 16 or so. It gets
> > gradually more complex in the SMP cases where we are 3-4 levels deep in
> > various types of memories that we expose as nodes (ie, 4-8 CPUs with a
> > dozen different memories or so at various interconnect levels).
> 
> Thanks.
> 
> Andi has suggested that we can remove the node-ID encoding from
> page.flags on x86 because that info is available elsewhere, although a
> bit more slowly.
> 
> <looks at page_zone(), wonders whether we care about performance anyway>
> 
> There wouldn't be much point in doing that unless we did it for all
> 32-bit architectures.  How much trouble would it cause sh?
> 
At first glance I don't think that should be too bad. We only do NUMA
through sparsemem anyways, and we have pretty much no overlap in any of
the ranges, so simply setting NODE_NOT_IN_PAGE_FLAGS should be ok there.
Given the relatively small number of pages we have, the added cost of
page_to_nid() referencing section_to_node_table should still be
tolerable. I'll give it a go and see what the numbers look like.

> > As far as testing goes, it's part of the regular build and regression
> > testing for a number of boards, which we verify on a daily basis
> > (although admittedly -mm gets far less testing, even though that's where
> > most of the churn in this area tends to be).
> 
> Oh well, that's what -rc is for :(
> 
> It would be good if someone over there could start testing linux-next. 
> Once I get my act together that will include most-of-mm anyway.
> 
Agreed. This is something we're attempting to add in to our automated
testing at present.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

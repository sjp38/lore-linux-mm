Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 91B026B005A
	for <linux-mm@kvack.org>; Mon, 21 Sep 2009 13:29:39 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
Subject: Re: [PATCH 1/3] powerpc: Allocate per-cpu areas for node IDs for
 SLQB to use as per-node areas
From: Daniel Walker <dwalker@fifo99.com>
In-Reply-To: <20090921102418.4692d62c.rdunlap@xenotime.net>
References: <1253549426-917-1-git-send-email-mel@csn.ul.ie>
	 <1253549426-917-2-git-send-email-mel@csn.ul.ie>
	 <1253553472.9654.236.camel@desktop>
	 <20090921102418.4692d62c.rdunlap@xenotime.net>
Content-Type: text/plain
Date: Mon, 21 Sep 2009 10:29:41 -0700
Message-Id: <1253554181.9654.238.camel@desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
To: Randy Dunlap <rdunlap@xenotime.net>
Cc: Mel Gorman <mel@csn.ul.ie>, Nick Piggin <npiggin@suse.de>, Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-09-21 at 10:24 -0700, Randy Dunlap wrote:
> On Mon, 21 Sep 2009 10:17:52 -0700 Daniel Walker wrote:
> 
> > On Mon, 2009-09-21 at 17:10 +0100, Mel Gorman wrote:
> > > SLQB uses DEFINE_PER_CPU to define per-node areas. An implicit
> > > assumption is made that all valid node IDs will have matching valid CPU
> > > ids. In memoryless configurations, it is possible to have a node ID with
> > > no CPU having the same ID. When this happens, a per-cpu are is not
> > > created and the value of paca[cpu].data_offset is some random value.
> > > This is later deferenced and the system crashes after accessing some
> > > invalid address.
> > > 
> > > This patch hacks powerpc to allocate per-cpu areas for node IDs that
> > > have no corresponding CPU id. This gets around the immediate problem but
> > > it should be discussed if there is a requirement for a DEFINE_PER_NODE
> > > and how it should be implemented.
> > > 
> > > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> > > ---
> > >  arch/powerpc/kernel/setup_64.c |   20 ++++++++++++++++++++
> > >  1 files changed, 20 insertions(+), 0 deletions(-)
> > > 
> > > diff --git a/arch/powerpc/kernel/setup_64.c b/arch/powerpc/kernel/setup_64.c
> > > index 1f68160..a5f52d4 100644
> > > --- a/arch/powerpc/kernel/setup_64.c
> > > +++ b/arch/powerpc/kernel/setup_64.c
> > > @@ -588,6 +588,26 @@ void __init setup_per_cpu_areas(void)
> > >  		paca[i].data_offset = ptr - __per_cpu_start;
> > >  		memcpy(ptr, __per_cpu_start, __per_cpu_end - __per_cpu_start);
> > >  	}
> > > +#ifdef CONFIG_SLQB
> > > +	/* 
> > > +	 * SLQB abuses DEFINE_PER_CPU to setup a per-node area. This trick
> > > +	 * assumes that ever node ID will have a CPU of that ID to match.
> > > +	 * On systems with memoryless nodes, this may not hold true. Hence,
> > > +	 * we take a second pass initialising a "per-cpu" area for node-ids
> > > +	 * that SLQB can use
> > > +	 */
> > 
> > Very trivial, but there's a little trailing whitespace in the first line
> > of the comment (checkpatch warns on it.) You also spelled initializing
> > wrong.
> 
> re: spelling.  Not really.  Think internationally.

Yeah, I realized that after I sent it .. So misspelled in the American
sense I guess.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

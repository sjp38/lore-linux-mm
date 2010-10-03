Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 07E576B0089
	for <linux-mm@kvack.org>; Sun,  3 Oct 2010 14:17:32 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o93I2KWo001937
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:02:20 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o93IHVsN299576
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:17:31 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o93IHUBW011963
	for <linux-mm@kvack.org>; Sun, 3 Oct 2010 14:17:31 -0400
Date: Sun, 3 Oct 2010 23:47:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH][RESEND] nommu: add anonymous page memcg accounting
Message-ID: <20101003181728.GH7896@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <WC20101001143139.810346@digidescorp.com>
 <1285929315-2856-1-git-send-email-steve@digidescorp.com>
 <5206.1285943095@redhat.com>
 <5867.1285945621@redhat.com>
 <1285951267.2558.69.camel@iscandar.digidescorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1285951267.2558.69.camel@iscandar.digidescorp.com>
Sender: owner-linux-mm@kvack.org
To: "Steven J. Magnani" <steve@digidescorp.com>
Cc: David Howells <dhowells@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Steven J. Magnani <steve@digidescorp.com> [2010-10-01 11:41:07]:

> On Fri, 2010-10-01 at 16:07 +0100, David Howells wrote: 
> > Steve Magnani <steve@digidescorp.com> wrote:
> > 
> > > If anything I think nommu is one of the better applications of memcg. Since
> > > nommu typically embedded, being able to put potential memory pigs in a
> > > sandbox so they can't destabilize the system is a Good Thing. That was my
> > > motivation for doing this in the first place and it works quite well.
> > 
> > I suspect it's not useful for a few reasons:
> > 
> >  (1) You don't normally run many applications on a NOMMU system.  Typically,
> >      you'll run just one, probably threaded app, I think.
> 
> Not always.
> 
> > 
> >  (2) In general, you won't be able to cull processes to make space.  If the OOM
> >      killer runs your application has a bug in it.
> 
> Not always. Every now and then applications have to deal with
> user-supplied input of some sort. 
> 
> In our case it's a user-formatted disk drive that can have some
> arbitrarily-sized FAT32 partition on which we are required to run
> dosfsck. Now, dosfsck is the epitome of a memory pig; its memory
> requirements scale with partition size, number of dentries, and any
> damage encountered - none of which can be predicted. There is a set of
> partitions we are able to check with no problem, but no guarantee the
> user won't present us with one that would bring down the whole system,
> were the OOM killer to get involved. Putting just dosfsck in its own
> sandbox ensures this can't happen. See also my response to #4 below.
> 
> > 
> >  (3) memcg has a huge overhead.  20 bytes per page!  On a 4K page 32-bit
> >      system, that's nearly 5% of your RAM, assuming I understand the
> >      CGROUP_MEM_RES_CTLR config help text correctly.
> 
> When you use 16K pages, 20 bytes/page isn't so huge :)
> 
> > 
> >  (4) There's no swapping, no page faults, no migration and little shareable
> >      memory.  Being able to allocate large blocks of contiguous memory is much
> >      more important and much more of a bottleneck than this.  The 5% of RAM
> >      lost makes that just that little bit harder.
> > 
> > If it's memory sandboxing you require, ulimit might be sufficient for NOMMU
> > mode.
> 
> dosfsck is written to handle memory allocation failures properly
> (bailing out) but I have not been able to get this code to execute when
> the system runs out of memory - the OOM killer gets invoked and that's
> all she wrote. Will a ulimit violation return control back to the
> process, or terminate it in some graceful manner? 
> 
> > 
> > However, I suppose there's little harm in letting the patch in.  I would guess
> > the additions all optimise away if memcg isn't enabled.
> > 
> > A question for you: why does struct page_cgroup need a page pointer?  If an
> > array of page_cgroup structs is allocated per array of page structs, then you
> > should be able to use the array index to map between them.
> 
> Kame is probably better able to answer this.
>

To answer David's question: We have no notion of pfn in page_cgroup,
how do we do the indexing? BTW, we are moving to cgroup ids that will
take just 16 bits instead of 64 on a 64 bit system.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Date: Fri, 26 Oct 2007 18:11:19 +0100
Subject: Re: RFC/POC Make Page Tables Relocatable
Message-ID: <20071026171119.GC19443@skynet.ie>
References: <d43160c70710250816l44044f31y6dd20766d1f2840b@mail.gmail.com> <1193330774.4039.136.camel@localhost> <d43160c70710251040u23feeaf9l16fafc2685b2ce52@mail.gmail.com> <1193335725.24087.19.camel@localhost> <20071026161007.GA19443@skynet.ie> <d43160c70710260951q351a6864ye5bb49e1b8a96aa3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d43160c70710260951q351a6864ye5bb49e1b8a96aa3@mail.gmail.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ross Biro <rossb@google.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, linux-mm@kvack.org, Mel Gorman <MELGOR@ie.ibm.com>
List-ID: <linux-mm.kvack.org>

On (26/10/07 12:51), Ross Biro didst pronounce:
> On 10/26/07, Mel Gorman <mel@skynet.ie> wrote:
> > I suspect this might be overkill from a memory fragmentation
> > perspective. When grouping pages by mobility, page table pages are
> > currently considered MIGRATE_UNMOVABLE. From what I have seen, they are
> 
> I may be being dense, but the page migration code looks to me like it
> just moves pages in a process from one node to another node with no
> effort to touch the page tables. 

Exactly, if it was able to move arbitrary pagetable pages too, it would
be useful. Page migrations traditional case is to move pages between
nodes but memory hot-remove also uses it to move pages around a zone and
there has been at least one other case which I'm coming to.

> It would be easy to hook the code I
> wrote into the page migration code, what I don't understand is when
> the page tables should be migrated? 

>From an external fragmentation point of view, they would be moved when a
high-order allocation failued. Patches exist that do this sort of thing
under the title "Memory Compaction" but they are not merged because they
don't have a demonstratable use-case yet[1].

> Only when the whole process is
> being migrated?  When all the pages pointed to a page table are being
> migrated?  When any page pointed to by the page table is being
> migrated?
> 

If it was external fragmentation you were dealing with, a pagetable apge
would be moved once it was found to be preventing a high-order (e.gh.
hugepage) allocation from succeeding.

[1] Intuitively, the use case would be that a hugepage allocation
    happened faster when moving pages around than reclaiming them.
    This situation does not happen often enough to justify the 
    complexity of the code though.

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

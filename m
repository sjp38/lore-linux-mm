From: Daniel Phillips <phillips@arcor.de>
Subject: Re: [RFC] Distributed mmap API
Date: Wed, 3 Mar 2004 08:06:20 -0500
References: <20040216190927.GA2969@us.ibm.com> <200403022200.39633.phillips@arcor.de> <20040302191539.6bffc687.akpm@osdl.org>
In-Reply-To: <20040302191539.6bffc687.akpm@osdl.org>
MIME-Version: 1.0
Content-Disposition: inline
Message-Id: <200403030800.35612.phillips@arcor.de>
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: paulmck@us.ibm.com, sct@redhat.com, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 02 March 2004 22:15, Andrew Morton wrote:
> Daniel Phillips <phillips@arcor.de> wrote:
> > Here is a rearranged zap_pte_range that avoids any operations for
> > out-of-range pfns.
>
> Please remind us why Linux needs this patch?

The is purely to support mmap, including MAP_PRIVATE, accurately on 
distributed filesystems, where "accurately" is defined as "with local 
filesystem semantics".

If the same file region is mmapped by more than one node, only one of them is 
allowed to have a given page of the mmap valid in the page tables at any 
time.  When a memory write occurs on one of the other nodes, it must fault so 
that the distributed filesystem can arrange for exclusive ownership of the 
file page (or as GFS currently implements it, the whole file) to change from 
one node to the other.  At this time, any pages already faulted in must be 
unmapped so that future memory accesses will properly fault.  This unmapping 
is done by zap_page_range, which has nearly the semantics we want except that 
it will also unmap private pages of a MAP_PRIVATE mapping, destroying the 
only copy of that data.  A user would observe the privately written data 
spontaneously revert to the current file contents.  The purpose of this patch 
is to fix that.

This patch allows a distributed filesystem to unmap file-backed memory without 
unmapping anonymous pages or deleting swap cache, avoiding the above data 
destruction.  Since zap_page_range is the only function that knows how to 
unmap memory, it needs to be taught how to skip anonymous pages.

An alternative to this patch is simply to export zap_page_range, then the 
distributed filesystem can walk the lists of mmapped vmas itself, skipping 
any that are MAP_PRIVATE.  This achieves Posix local filesystem semantics, 
but not Linux local filesystem semantics, because updates to the mmap from 
other nodes become visible unpredictably.  Earlier this year, Linus said that 
he wants tighter semantics for distributed MAP_PRIVATE.

This patch presses zap_page_range into service in a way that was not 
originally intended, that is, for invalidation as opposed to destruction of 
memory regions.  The requirements are identical except for the MAP_PRIVATE 
detail.  Forking the whole zap_ chain would be even more distasteful than 
grafting on this option flag.  It's also impractical to implement a zap_ 
variant within a dfs module because of the heavy use of per-arch APIs.  As
far I can see, this patch is the minimum cost of having accurate semantics
for distributed MAP_PRIVATE mmap.

I'll take the opportunity to beat my chest a once again about the fact that 
this doesn't benefit anything other than distributed filesystems.  On the 
other hand, the cost is  miniscule: 54 bytes, a little stack and likely no 
measureable cpu.

> I forget what `all' does?  anon+swapcache as well as pagecache?

Yes

> A bit of API documentation here would be appropriate.

Oops, sorry:

/**
 * zap_page_range - remove user pages in a given range
 * @vma: vm_area_struct holding the applicable pages
 * @address: starting address of pages to zap
 * @size: number of bytes to zap
 * @all: also unmap anonymous pages
 */
void zap_page_range(struct vm_area_struct *vma,
                    unsigned long address, unsigned long size, int all)

Regards,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

Message-Id: <200102270326.f1R3QII16835@eng1.sequent.com>
Reply-To: Gerrit Huizenga <gerrit@us.ibm.com>
From: Gerrit Huizenga <gerrit@us.ibm.com>
Subject: Re: 2.5 page cache improvement idea 
In-reply-to: Your message of Mon, 26 Feb 2001 21:49:22 EST.
             <Pine.LNX.4.30.0102262142500.9589-100000@today.toronto.redhat.com>
Date: Mon, 26 Feb 2001 19:26:18 -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ben LaHaise <bcrl@redhat.com>
Cc: Chuck Lever <Charles.Lever@netapp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

If you are considering NUMA architectures as a case of frequently
accesses pages, e.g. glibc or text pages of commonly used executables,
it is probably better to do page replication per node on demand than
to worry about optimizing the page lookups for limited bus traffic.

Most NUMA machines are relatively rich in physical memory, and cross
node traffic is relatively expensive.  As a result, wasting a small
number of physical pages on duplicate read-only pages cuts down node
to node traffic in most cases.  Many NUMA systems have a cache for
remote memory (some cache only remote pages, some cache local and remote
pages in the same cache - icky but cheaper).  As that cache cycles,
it is cheaper to replace read-only text pages from the local node
rather than the remote.  So, for things like kernel text (e.g. one of
the SGI patches) and for glibc's text, as well as the text of other
common shared libraries, it winds up being a significant win to replicate
those text pages (on demand!) in local memory.

gerrit

> On Mon, 26 Feb 2001, Chuck Lever wrote:
> 
> > didn't andrea archangeli try this with red-black trees a couple of years
> > ago?
> 
> Yes.  However, keep in mind that red-black are not particularly well
> suited to the cache design of most modern cpus.
> 
> > instead of hashing or b*trees, let me recommend self-organizing data
> > structures. using a splay tree might improve locality of reference and
> > optimize the tree so that frequently used pages appear close to the
> > root.
> 
> splay trees might well be an option, however keep in mind the benefits of
> the hybrid hash/b*tree structure: for the typical case of a small number
> of entries (ie a small file), the hash buckets will provide optimal O(1)
> performance.  Once we move into larger data files, the operation becomes
> slightly more overhead (but still tunable according by increasing the hash
> size) but still relatively low (2 cache misses for a two level b*tree
> which maps a *lot* of data).  The problem with something like a splay tree
> is that it will generate bus traffic for the common case of reading from
> the data file, which is something we don't want for a frequently accessed
> mapping like glibc on a NUMA system.  B*trees, while originally designed
> for use on disks, apply quite well to modern cache heirarchies.
> 
>           -ben
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

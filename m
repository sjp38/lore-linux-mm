Date: Mon, 26 Feb 2001 21:49:22 -0500 (EST)
From: Ben LaHaise <bcrl@redhat.com>
Subject: Re: 2.5 page cache improvement idea
In-Reply-To: <00db01c0a066$dfc7de60$0beda8c0@netapp.com>
Message-ID: <Pine.LNX.4.30.0102262142500.9589-100000@today.toronto.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <Charles.Lever@netapp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 26 Feb 2001, Chuck Lever wrote:

> didn't andrea archangeli try this with red-black trees a couple of years
> ago?

Yes.  However, keep in mind that red-black are not particularly well
suited to the cache design of most modern cpus.

> instead of hashing or b*trees, let me recommend self-organizing data
> structures. using a splay tree might improve locality of reference and
> optimize the tree so that frequently used pages appear close to the
> root.

splay trees might well be an option, however keep in mind the benefits of
the hybrid hash/b*tree structure: for the typical case of a small number
of entries (ie a small file), the hash buckets will provide optimal O(1)
performance.  Once we move into larger data files, the operation becomes
slightly more overhead (but still tunable according by increasing the hash
size) but still relatively low (2 cache misses for a two level b*tree
which maps a *lot* of data).  The problem with something like a splay tree
is that it will generate bus traffic for the common case of reading from
the data file, which is something we don't want for a frequently accessed
mapping like glibc on a NUMA system.  B*trees, while originally designed
for use on disks, apply quite well to modern cache heirarchies.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/

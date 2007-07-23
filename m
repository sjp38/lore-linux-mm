Message-ID: <46A44BA0.6020400@gmx.net>
Date: Mon, 23 Jul 2007 08:33:04 +0200
From: Michael Kerrisk <mtk-manpages@gmx.net>
MIME-Version: 1.0
Subject: set_mempolicy.2 man page patch
References: <1180467234.5067.52.camel@localhost>	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>
In-Reply-To: <1180732544.5278.158.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: ak@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Andi, Christoph

Could you please review these changes by Lee to the set_mempolicy.2 page?
Patch against man-pages-2.63 (available from
http://www.kernel.org/pub/linux/docs/manpages).

Cheers,

Michael



--- set_mempolicy.2.orig        2007-06-23 09:18:02.000000000 +0200
+++ set_mempolicy.2     2007-07-21 09:17:44.000000000 +0200
@@ -1,4 +1,5 @@
 .\" Copyright 2003,2004 Andi Kleen, SuSE Labs.
+.\" and Copyright (C) 2007 Lee Schermerhorn <Lee.Schermerhorn@hp.com>
 .\"
 .\" Permission is granted to make and distribute verbatim copies of this
 .\" manual provided the copyright notice and this permission notice are
@@ -18,93 +19,161 @@
 .\" the source, must acknowledge the copyright and authors of this work.
 .\"
 .\" 2006-02-03, mtk, substantial wording changes and other improvements
+.\" 2007-06-01, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
+.\"     more precise specification of behavior.
 .\"
-.TH SET_MEMPOLICY 2 2006-02-07 "Linux" "Linux Programmer's Manual"
+.TH SET_MEMPOLICY 2 2007-07-20 Linux "Linux Programmer's Manual"
 .SH NAME
-set_mempolicy \- set default NUMA memory policy for a process and its
children.
+set_mempolicy \- set default NUMA memory policy for a process
+and its children
 .SH SYNOPSIS
 .nf
 .B "#include <numaif.h>"
 .sp
-.BI "int set_mempolicy(int " policy ", unsigned long *" nodemask ,
+.BI "int set_mempolicy(int " mode ", unsigned long *" nodemask ,
 .BI "                  unsigned long " maxnode );
+.sp
+Link with \fI\-lnuma\fP.
 .fi
 .SH DESCRIPTION
 .BR set_mempolicy ()
-sets the NUMA memory policy of the calling process to
-.IR policy .
+sets the NUMA memory policy of the calling process,
+which consists of a policy mode and zero or more nodes,
+to the values specified by the
+.IR mode ,
+.I nodemask
+and
+.IR maxnode
+arguments.

 A NUMA machine has different
 memory controllers with different distances to specific CPUs.
-The memory policy defines in which node memory is allocated for
+The memory policy defines the node on which memory is allocated for
 the process.

-This system call defines the default policy for the process;
-in addition a policy can be set for specific memory ranges using
+This system call defines the default policy for the process.
+The process policy governs allocation of pages in the process's
+address space outside of memory ranges
+controlled by a more specific policy set by
 .BR mbind (2).
+The process default policy also controls allocation of any pages for
+memory mapped files mapped using the
+.BR mmap (2)
+call with the
+.B MAP_PRIVATE
+flag and that are only read [loaded] by the task,
+and of memory mapped files mapped using the
+.BR mmap (2)
+call with the
+.B MAP_SHARED
+flag, regardless of the access type.
 The policy is only applied when a new page is allocated
 for the process.
 For anonymous memory this is when the page is first
 touched by the application.

-Available policies are
+The
+.I mode
+argument must specify one of
 .BR MPOL_DEFAULT ,
 .BR MPOL_BIND ,
-.BR MPOL_INTERLEAVE ,
+.B MPOL_INTERLEAVE
+or
 .BR MPOL_PREFERRED .
-All policies except
+All modes except
 .B MPOL_DEFAULT
-require the caller to specify the nodes to which the policy applies in the
+require the caller to specify one of more nodes to which the mode
+applies, via the
 .I nodemask
-parameter.
+argument.
+
 .I nodemask
-is pointer to a bit field of nodes that contains up to
+points to a bit mask of node IDs that contains up to
 .I maxnode
 bits.
-The bit field size is rounded to the next multiple of
+The actual number of bytes transferred via
+.I nodemask
+is rounded up to the next multiple of
 .IR "sizeof(unsigned long)" ,
 but the kernel will only use bits up to
 .IR maxnode .
+A NULL value for
+.IR nodemask ,
+or a
+.I maxnode
+value of zero specifies the empty set of nodes.
+If the value of
+.I maxnode
+is zero,
+the
+.I nodemask
+argument is ignored.

 The
 .B MPOL_DEFAULT
-policy is the default and means to allocate memory locally,
-i.e., on the node of the CPU that triggered the allocation.
+mode is the default and means to allocate memory locally
+(i.e., on the node of the CPU that triggered the allocation).
 .I nodemask
-should be specified as NULL.
+must be specified as NULL.
+If the "local node" contains no free memory, the system will
+attempt to allocate memory from a "nearby" node.

 The
 .B MPOL_BIND
-policy is a strict policy that restricts memory allocation to the
+mode defines a strict policy that restricts memory allocation to the
 nodes specified in
 .IR nodemask .
-There won't be allocations on other nodes.
+If
+.I nodemask
+specifies more than one node, page allocations will come from
+the node with the lowest numeric node ID first, until that node
+contains no free memory.
+Allocations will then come from the node with the next highest
+node ID specified in
+.I nodemask
+and so forth, until none of the specified nodes contain free memory.
+Pages will not be allocated from any node not specified in the
+.IR nodemask .

 .B MPOL_INTERLEAVE
-interleaves allocations to the nodes specified in
-.IR nodemask .
-This optimizes for bandwidth instead of latency.
-To be effective the memory area should be fairly large,
-at least 1MB or bigger.
+interleaves page allocations across the nodes specified in
+.I nodemask
+in numeric node ID order.
+This optimizes for bandwidth instead of latency
+by spreading out pages and memory accesses to those pages across
+multiple nodes.
+However, accesses to a single page will still be limited to
+the memory bandwidth of a single node.
+.\" NOTE:  the following sentence doesn't make sense in the context
+.\" of set_mempolicy() -- no memory area specified.
+.\" To be effective the memory area should be fairly large,
+.\" at least 1MB or bigger.

 .B MPOL_PREFERRED
 sets the preferred node for allocation.
-The kernel will try to allocate in this
-node first and fall back to other nodes if the preferred node is low on free
+The kernel will try to allocate pages from this node first
+and fall back to "nearby" nodes if the preferred node is low on free
 memory.
-Only the first node in the
+If
 .I nodemask
-is used.
-If no node is set in the mask, then the memory is allocated on
-the node of the CPU that triggered the allocation allocation (like
+specifies more than one node ID, the first node in the
+mask will be selected as the preferred node.
+If the
+.I nodemask
+and
+.I maxnode
+arguments specify the empty set, then the memory is allocated on
+the node of the CPU that triggered the allocation (like
 .BR MPOL_DEFAULT ).

-The memory policy is preserved across an
+The process memory policy is preserved across an
 .BR execve (2),
 and is inherited by child processes created using
 .BR fork (2)
 or
 .BR clone (2).
+.SH CONFORMING TO
+This system call is Linux specific.
 .SH RETURN VALUE
 On success,
 .BR set_mempolicy ()
@@ -112,21 +181,62 @@
 on error, \-1 is returned and
 .I errno
 is set to indicate the error.
-.\" .SH ERRORS
-.\" FIXME no errors are listed on this page
-.\" .
-.\" .TP
-.\" .B EINVAL
-.\" .I mode is invalid.
-.SH CONFORMING TO
-This system call is Linux specific.
+.SH ERRORS
+.TP
+.B EINVAL
+.I mode is invalid.
+Or,
+.I mode
+is
+.B MPOL_DEFAULT
+and
+.I nodemask
+is non-empty,
+or
+.I mode
+is
+.B MPOL_BIND
+or
+.B MPOL_INTERLEAVE
+and
+.I nodemask
+is empty.
+Or,
+.I maxnode
+specifies more than a page worth of bits.
+Or,
+.I nodemask
+specifies one or more node IDs that are
+greater than the maximum supported node ID,
+or are not allowed in the calling task's context.
+.\" "calling task's context" refers to cpusets.
+.\" No man page avail to ref. --Lee Schermerhorn
+Or, none of the node IDs specified by
+.I nodemask
+are on-line, or none of the specified nodes contain memory.
+.TP
+.B EFAULT
+Part or all of the memory range specified by
+.I nodemask
+and
+.I maxnode
+points outside your accessible address space.
+.TP
+.B ENOMEM
+Insufficient kernel memory was available.
 .SH NOTES
 Process policy is not remembered if the page is swapped out.
+When such a page is paged back in, it will use the policy of
+the process or memory range that is in effect at the time the
+page is allocated.
 .SS "Versions and Library Support"
 See
 .BR mbind (2).
+.SH CONFORMING TO
+This system call is Linux specific.
 .SH SEE ALSO
-.BR mbind (2),
 .BR get_mempolicy (2),
-.BR numactl (8),
-.BR numa (3)
+.BR mbind (2),
+.BR mmap (2),
+.BR numa (3),
+.BR numactl (8)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

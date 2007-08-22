Subject: [PATCH] Mempolicy Man Pages 2.64 2/3 - set_mempolicy.2
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070822041050.158210@gmx.net>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>
	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>
	 <46A44B98.8060807@gmx.net> <46AB0CDB.8090600@gmx.net>
	 <20070816200520.GB16680@bingen.suse.de>  <20070818055026.265030@gmx.net>
	 <1187711147.5066.13.camel@localhost>  <20070822041050.158210@gmx.net>
Content-Type: text/plain
Date: Wed, 22 Aug 2007 12:10:26 -0400
Message-Id: <1187799027.5166.15.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <mtk-manpages@gmx.net>
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

[PATCH] Mempolicy Man Pages 2.64 2/3 - set_mempolicy.2

Against:  man pages 2.64

Changes:

+ changed the "policy" parameter to "mode" through out the
  descriptions in an attempt to promote the concept that the memory
  policy is a tuple consisting of a mode and optional set of nodes.

+ added requirement to link '-lnuma' to synopsis

+ rewrite portions of description for clarification.

  ++ clarify interaction of policy with mmap()'d files.

  ++ defined how "empty set of nodes" specified and what this
     means for MPOL_PREFERRED.

  ++ mention what happens if local/target node contains no
     free memory.

  ++ clarify semantics of multiple nodes to BIND policy.
     Note:  subject to change.  We'll fix the man pages when/if
            this happens.

+ added all errors currently returned by sys call.

+ added mmap(2) to See Also list.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: Linux/man2/set_mempolicy.2
===================================================================
--- Linux.orig/man2/set_mempolicy.2	2007-06-13 17:48:16.000000000 -0400
+++ Linux/man2/set_mempolicy.2	2007-08-10 12:30:14.000000000 -0400
@@ -18,6 +18,7 @@
 .\" the source, must acknowledge the copyright and authors of this work.
 .\"
 .\" 2006-02-03, mtk, substantial wording changes and other improvements
+.\" 2007-06-01, lts, more precise specification of behavior.
 .\"
 .TH SET_MEMPOLICY 2 2006-02-07 "Linux" "Linux Programmer's Manual"
 .SH NAME
@@ -26,80 +27,141 @@ set_mempolicy \- set default NUMA memory
 .nf
 .B "#include <numaif.h>"
 .sp
-.BI "int set_mempolicy(int " policy ", unsigned long *" nodemask ,
+.BI "int set_mempolicy(int " mode ", unsigned long *" nodemask ,
 .BI "                  unsigned long " maxnode );
+.sp
+.BI "cc ... \-lnuma"
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
+The memory policy defines from which node memory is allocated for
 the process.
 
-This system call defines the default policy for the process;
-in addition a policy can be set for specific memory ranges using
+This system call defines the default policy for the process.
+The process policy governs allocation of pages in the process'
+address space outside of memory ranges
+controlled by a more specific policy set by
 .BR mbind (2).
+The process default policy also controls allocation of any pages for
+memory mapped files mapped using the
+.BR mmap (2)
+call with the
+.B MAP_PRIVATE
+flag and that are only read [loaded] from by the task
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
+require the caller to specify via the
 .I nodemask
-parameter.
+parameter
+one or more nodes.
+
 .I nodemask
-is pointer to a bit field of nodes that contains up to
+points to a bit mask of node ids that contains up to
 .I maxnode
 bits.
-The bit field size is rounded to the next multiple of
+The bit mask size is rounded to the next multiple of
 .IR "sizeof(unsigned long)" ,
 but the kernel will only use bits up to
 .IR maxnode .
+A NULL value of
+.I nodemask
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
+mode is the default and means to allocate memory locally,
 i.e., on the node of the CPU that triggered the allocation.
 .I nodemask
-should be specified as NULL.
+must be specified as NULL.
+If the "local node" contains no free memory, the system will
+attempt to allocate memory from a "near by" node.
 
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
+the node with the lowest numeric node id first, until that node
+contains no free memory.
+Allocations will then come from the node with the next highest
+node id specified in
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
+in numeric node id order.
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
+and fall back to "near by" nodes if the preferred node is low on free
 memory.
-Only the first node in the
+If
+.I nodemask
+specifies more than one node id, the first node in the
+mask will be selected as the preferred node.
+If the
 .I nodemask
-is used.
-If no node is set in the mask, then the memory is allocated on
-the node of the CPU that triggered the allocation allocation (like
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
@@ -112,21 +174,62 @@ returns 0;
 on error, \-1 is returned and
 .I errno
 is set to indicate the error.
-.\" .SH ERRORS
-.\" FIXME no errors are listed on this page
-.\" .
-.\" .TP
-.\" .B EINVAL
-.\" .I mode is invalid.
+.SH ERRORS
+.TP
+.B EINVAL
+.I mode is invalid.
+Or,
+.I mode
+is
+.I MPOL_DEFAULT
+and
+.I nodemask
+is non-empty,
+or
+.I mode
+is
+.I MPOL_BIND
+or
+.I MPOL_INTERLEAVE
+and
+.I nodemask
+is empty.
+Or,
+.I maxnode
+specifies more than a page worth of bits.
+Or,
+.I nodemask
+specifies one or more node ids that are
+greater than the maximum supported node id,
+or are not allowed in the calling task's context.
+.\" "calling task's context" refers to cpusets.  No man page avail to ref. --lts
+Or, none of the node ids specified by
+.I nodemask
+are on-line, or none of the specified nodes contain memory.
+.TP
+.B EFAULT
+Part of all of the memory range specified by
+.I nodemask
+and
+.I maxnode
+points outside your accessible address space.
+.TP
+.B ENOMEM
+Insufficient kernel memory was available.
+
 .SH CONFORMING TO
 This system call is Linux specific.
 .SH NOTES
 Process policy is not remembered if the page is swapped out.
+When such a page is paged back in, it will use the policy of
+the process or memory range that is in effect at the time the
+page is allocated.
 .SS "Versions and Library Support"
 See
 .BR mbind (2).
 .SH SEE ALSO
 .BR mbind (2),
+.BR mmap (2),
 .BR get_mempolicy (2),
 .BR numactl (8),
 .BR numa (3)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

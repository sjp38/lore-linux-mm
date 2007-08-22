Subject: [PATCH] Mempolicy Man Pages 2.64  1/3 - mbind.2
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
Date: Wed, 22 Aug 2007 12:08:23 -0400
Message-Id: <1187798903.5166.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <mtk-manpages@gmx.net>
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

I've separated the mempolicy man page updates into 3 separate patches,
against the 2.64 man pages.  I've added a slightly less terse
description of the changes for the change log.  

Here's the first of the 3--mbind.2.   I updated the description of the
interaction with MAP_SHARED to the wording you suggested. a while back.

---------------------------------

[PATCH]  Mempolicy Man Pages 2.64  1/3 - mbind.2

Against:  man pages 2.64

Changes:

+ changed the "policy" parameter to "mode" through out the
  descriptions in an attempt to promote the concept that the memory
  policy is a tuple consisting of a mode and optional set of nodes.

+ rewrite portions of description for clarification.

  ++ clarify interaction of policy with mmap()'d files and shared
     memory regions, including SHM_HUGE regions.

  ++ defined how "empty set of nodes" specified and what this
     means for MPOL_PREFERRED.

  ++ mention what happens if local/target node contains no
     free memory.

  ++ clarify semantics of multiple nodes to BIND policy.
     Note:  subject to change.  We'll fix the man pages when/if
            this happens.

+ added all errors currently returned by sys call.

+ added mmap(2), shmget(2), shmat(2) to See Also list.



 man2/mbind.2 |  338 +++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 248 insertions(+), 90 deletions(-)

Index: Linux/man2/mbind.2
===================================================================
--- Linux.orig/man2/mbind.2	2007-08-22 11:22:00.000000000 -0400
+++ Linux/man2/mbind.2	2007-08-22 11:56:58.000000000 -0400
@@ -18,15 +18,16 @@
 .\" the source, must acknowledge the copyright and authors of this work.
 .\"
 .\" 2006-02-03, mtk, substantial wording changes and other improvements
+.\" 2007-06-01, lts, more precise specification of behavior.
 .\"
-.TH MBIND 2 2006-02-07 "Linux" "Linux Programmer's Manual"
+.TH MBIND 2 "2007-06-01" "SuSE Labs" "Linux Programmer's Manual"
 .SH NAME
 mbind \- Set memory policy for a memory range
 .SH SYNOPSIS
 .nf
 .B "#include <numaif.h>"
 .sp
-.BI "int mbind(void *" start ", unsigned long " len  ", int " policy ,
+.BI "int mbind(void *" start ", unsigned long " len  ", int " mode ,
 .BI "          unsigned long *" nodemask  ", unsigned long " maxnode ,
 .BI "          unsigned " flags );
 .sp
@@ -34,76 +35,178 @@ mbind \- Set memory policy for a memory 
 .fi
 .SH DESCRIPTION
 .BR mbind ()
-sets the NUMA memory
-.I policy
+sets the NUMA memory policy,
+which consists of a policy mode and zero or more nodes,
 for the memory range starting with
 .I start
 and continuing for
 .IR len
 bytes.
 The memory of a NUMA machine is divided into multiple nodes.
-The memory policy defines in which node memory is allocated.
+The memory policy defines from which node memory is allocated.
+
+If the memory range specified by the
+.IR start " and " len
+arguments includes an "anonymous" region of memory\(emthat is
+a region of memory created using the
+.BR mmap (2)
+system call with the
+.BR MAP_ANONYMOUS \(emor
+a memory mapped file, mapped using the
+.BR mmap (2)
+system call with the
+.B MAP_PRIVATE
+flag, pages will only be allocated according to the specified
+policy when the application writes [stores] to the page.
+For anonymous regions, an initial read access will use a shared
+page in the kernel containing all zeros.
+For a file mapped with
+.BR MAP_PRIVATE ,
+an initial read access will allocate pages according to the
+process policy of the process that causes the page to be allocated.
+This may not be the process that called
+.BR mbind ().
+
+The specified policy will be ignored for any
+.B MAP_SHARED
+mappings in the specified memory range.
+Rather the pages will be allocated according to the process policy
+of the process that caused the page to be allocated.
+Again, this may not be the process that called
+.BR mbind ().
+
+If the specified memory range includes a shared memory region
+created using the
+.BR shmget (2)
+system call and attached using the
+.BR shmat (2)
+system call,
+pages allocated for the anonymous or shared memory region will
+be allocated according to the policy specified, regardless which
+process attached to the shared memory segment causes the allocation.
+If, however, the shared memory region was created with the
+.B SHM_HUGETLB
+flag,
+the huge pages will be allocated according to the policy specified
+only if the page allocation is caused by the task that calls
+.BR mbind ()
+for that region.
+
+By default,
 .BR mbind ()
 only has an effect for new allocations; if the pages inside
 the range have been already touched before setting the policy,
 then the policy has no effect.
+This default behavior may be overridden by the
+.BR MPOL_MF_MOVE
+and
+.B MPOL_MF_MOVE_ALL
+flags described below.
 
-Available policies are
+The
+.I mode
+argument must specify one of
 .BR MPOL_DEFAULT ,
 .BR MPOL_BIND ,
-.BR MPOL_INTERLEAVE ,
-and
+.B MPOL_INTERLEAVE
+or
 .BR MPOL_PREFERRED .
-All policies except
+All policy modes except
 .B MPOL_DEFAULT
-require the caller to specify the nodes to which the policy applies in the
+require the caller to specify via the
 .I nodemask
-parameter.
+parameter,
+the node or nodes to which the mode applies.
+
 .I nodemask
-is a bit mask of nodes containing up to
+points to a bitmask of nodes containing up to
 .I maxnode
 bits.
-The actual number of bytes transferred via this argument
-is rounded up to the next multiple of
+The bit mask size is rounded to the next multiple of
 .IR "sizeof(unsigned long)" ,
 but the kernel will only use bits up to
 .IR maxnode .
-A NULL argument means an empty set of nodes.
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
-policy is the default and means to use the underlying process policy
-(which can be modified with
-.BR set_mempolicy (2)).
-Unless the process policy has been changed this means to allocate
-memory on the node of the CPU that triggered the allocation.
+mode specifies that the default policy be used.
+When applied to a range of memory via
+.IR mbind (),
+this means to use the process policy,
+ which may have been set with
+.BR set_mempolicy (2).
+If the mode of the process policy is also
+.BR MPOL_DEFAULT ,
+the system-wide default policy will be used.
+The system-wide default policy will allocate
+pages on the node of the CPU that triggers the allocation.
+For
+.BR MPOL_DEFAULT ,
+the
 .I nodemask
-should be specified as NULL.
+and
+.I maxnode
+arguments must be specify the empty set of nodes.
 
 The
 .B MPOL_BIND
-policy is a strict policy that restricts memory allocation to the
-nodes specified in
+mode specifies a strict policy that restricts memory allocation to
+the nodes specified in
+.IR nodemask .
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
 .IR nodemask .
-There won't be allocations on other nodes.
 
+The
 .B MPOL_INTERLEAVE
-interleaves allocations to the nodes specified in
+mode specifies that page allocations be interleaved across the
+set of nodes specified in
 .IR nodemask .
-This optimizes for bandwidth instead of latency.
+This optimizes for bandwidth instead of latency
+by spreading out pages and memory accesses to those pages across
+multiple nodes.
 To be effective the memory area should be fairly large,
-at least 1MB or bigger.
+at least 1MB or bigger with a fairly uniform access pattern.
+Accesses to a single page of the area will still be limited to
+the memory bandwidth of a single node.
 
 .B MPOL_PREFERRED
 sets the preferred node for allocation.
-The kernel will try to allocate in this
+The kernel will try to allocate pages from this
 node first and fall back to other nodes if the
 preferred nodes is low on free memory.
-Only the first node in the
+If
+.I nodemask
+specifies more than one node id, the first node in the
+mask will be selected as the preferred node.
+If the
 .I nodemask
-is used.
-If no node is set in the mask, then the memory is allocated on
-the node of the CPU that triggered the allocation allocation).
+and
+.I maxnode
+arguments specify the empty set, then the memory is allocated on
+the node of the CPU that triggered the allocation.
+This is the only way to specify "local allocation" for a
+range of memory via
+.IR mbind (2).
 
 If
 .B MPOL_MF_STRICT
@@ -115,17 +218,18 @@ is not
 .BR MPOL_DEFAULT ,
 then the call will fail with the error
 .B EIO
-if the existing pages in the mapping don't follow the policy.
-In 2.6.16 or later the kernel will also try to move pages
-to the requested node with this flag.
+if the existing pages in the memory range don't follow the policy.
+.\" According to the kernel code, the following is not true --lts
+.\" In 2.6.16 or later the kernel will also try to move pages
+.\" to the requested node with this flag.
 
 If
 .B MPOL_MF_MOVE
-is passed in
+is specified in
 .IR flags ,
-then an attempt will be made  to
-move all the pages in the mapping so that they follow the policy.
-Pages that are shared with other processes are not moved.
+then the kernel will attempt to move all the existing pages
+in the memory range so that they follow the policy.
+Pages that are shared with other processes will not be moved.
 If
 .B MPOL_MF_STRICT
 is also specified, then the call will fail with the error
@@ -136,8 +240,8 @@ If
 .B MPOL_MF_MOVE_ALL
 is passed in
 .IR flags ,
-then all pages in the mapping will be moved regardless of whether
-other processes use the pages.
+then the kernel will attempt to move all existing pages in the memory range
+regardless of whether other processes use the pages.
 The calling process must be privileged
 .RB ( CAP_SYS_NICE )
 to use this flag.
@@ -146,6 +250,7 @@ If
 is also specified, then the call will fail with the error
 .B EIO
 if some pages could not be moved.
+.\" ---------------------------------------------------------------
 .SH RETURN VALUE
 On success,
 .BR mbind ()
@@ -153,11 +258,9 @@ returns 0;
 on error, \-1 is returned and
 .I errno
 is set to indicate the error.
+.\" ---------------------------------------------------------------
 .SH ERRORS
-.TP
-.B EFAULT
-There was a unmapped hole in the specified memory range
-or a passed pointer was not valid.
+.\"  I think I got all of the error returns.  --lts
 .TP
 .B EINVAL
 An invalid value was specified for
@@ -169,55 +272,102 @@ or
 was less than
 .IR start ;
 or
-.I policy
-was
-.B MPOL_DEFAULT
+.I start
+is not a multiple of the system page size.
+Or,
+.I mode
+is
+.I MPOL_DEFAULT
 and
 .I nodemask
-pointed to a non-empty set;
+specified a non-empty set;
 or
-.I policy
-was
-.B MPOL_BIND
+.I mode
+is
+.I MPOL_BIND
 or
-.B MPOL_INTERLEAVE
+.I MPOL_INTERLEAVE
 and
 .I nodemask
-pointed to an empty set,
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
+Or, there was a unmapped hole in the specified memory range.
 .TP
 .B ENOMEM
-System out of memory.
+Insufficient kernel memory was available.
 .TP
 .B EIO
 .B MPOL_MF_STRICT
 was specified and an existing page was already on a node
-that does not follow the policy.
-.SH CONFORMING TO
-This system call is Linux specific.
+that does not follow the policy;
+or
+.B MPOL_MF_MOVE
+or
+.B MPOL_MF_MOVE_ALL
+was specified and the kernel was unable to move all existing
+pages in the range.
+.TP
+.B EPERM
+The
+.I flags
+argument included the
+.B MPOL_MF_MOVE_ALL
+flag and the caller does not have the
+.B CAP_SYS_NICE
+privilege.
+.\" ---------------------------------------------------------------
 .SH NOTES
-NUMA policy is not supported on file mappings.
+NUMA policy is not supported on a memory mapped file range
+that was mapped with the
+.I MAP_SHARED
+flag.
 
 .B MPOL_MF_STRICT
-is  ignored  on  huge page mappings right now.
+is ignored on huge page mappings.
 
-It is unfortunate that the same flag,
+The
 .BR MPOL_DEFAULT ,
-has different effects for
+mode has different effects for
 .BR mbind (2)
 and
 .BR set_mempolicy (2).
-To select "allocation on the node of the CPU that
-triggered the allocation" (like
-.BR set_mempolicy (2)
-.BR MPOL_DEFAULT )
-when calling
+When
+.B MPOL_DEFAULT
+is specified for a range of memory using
 .BR mbind (),
+any pages subsequently allocated for that range will use
+the process' policy, as set by
+.BR set_mempolicy (2).
+This effectively removes the explicit policy from the
+specified range.
+To select "local allocation" for a memory range,
 specify a
-.I policy
+.I mode
 of
 .B MPOL_PREFERRED
-with an empty
-.IR nodemask .
+with an empty set of nodes.
+This method will work for
+.BR set_mempolicy (2),
+as well.
+.\" ---------------------------------------------------------------
 .SS "Versions and Library Support"
 The
 .BR mbind (),
@@ -228,16 +378,18 @@ system calls were added to the Linux ker
 They are only available on kernels compiled with
 .BR CONFIG_NUMA .
 
-Support for huge page policy was added with 2.6.16.
-For interleave policy to be effective on huge page mappings the
-policied memory needs to be tens of megabytes or larger.
-
-.B MPOL_MF_MOVE
-and
-.B MPOL_MF_MOVE_ALL
-are only available on Linux 2.6.16 and later.
+You can link with
+.I -lnuma
+to get system call definitions.
+.I libnuma
+and the required
+.I numaif.h
+header.
+are available in the
+.I numactl
+package.
 
-These system calls should not be used directly.
+However, applications should not use these system calls directly.
 Instead, the higher level interface provided by the
 .BR numa (3)
 functions in the
@@ -247,20 +399,26 @@ The
 .I numactl
 package is available at
 .IR ftp://ftp.suse.com/pub/people/ak/numa/ .
-
-You can link with
-.I \-lnuma
-to get system call definitions.
-.I libnuma
-is available in the
-.I numactl
+The package is also included in some Linux distributions.
+Some distributions include the development library and header
+in the separate
+.I numactl-devel
 package.
-This package also has the
-.I numaif.h
-header.
+
+Support for huge page policy was added with 2.6.16.
+For interleave policy to be effective on huge page mappings the
+policied memory needs to be tens of megabytes or larger.
+
+.B MPOL_MF_MOVE
+and
+.B MPOL_MF_MOVE_ALL
+are only available on Linux 2.6.16 and later.
+
 .SH SEE ALSO
 .BR numa (3),
 .BR numactl (8),
 .BR set_mempolicy (2),
 .BR get_mempolicy (2),
-.BR mmap (2)
+.BR mmap (2),
+.BR shmget (2),
+.BR shmat (2).


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

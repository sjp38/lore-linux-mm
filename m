Message-ID: <46A44699.3040105@gmx.net>
Date: Mon, 23 Jul 2007 08:11:37 +0200
From: Michael Kerrisk <mtk-manpages@gmx.net>
MIME-Version: 1.0
Subject: Re: [PATCH]  enhance memory policy sys call man pages v1
References: <1180467234.5067.52.camel@localhost>	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>
In-Reply-To: <1180732544.5278.158.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: ak@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, clameter@sgi.com, Samuel Thibault <samuel.thibault@ens-lyon.org>
List-ID: <linux-mm.kvack.org>

Lee, (and Andi, Christoph),

Sorry that I have not replied sooner.

The patches you have written look like a great piece of work.  Thanks!   I
have made some light edits to improve wording and grammar, and added a
small fix that came in independently from Samuel Thibault for mbind.2.

I have also rebased the patches to include a few small changes that have
occurred between man-pages-2.51 and man-pages-2.63.  These changes are all
minor, and are formatting changes, reodering of a few sections, and similar.

Andi, Christoph: please see below.

Lee Schermerhorn wrote:
> Subject was:  Re: [PATCH] Document Linux Memory Policy
> 
> On Thu, 2007-05-31 at 10:20 +0200, Michael Kerrisk wrote:
>>>>> The docs are wrong. This is fully supported.
>>>> Yes, I gave up on that one and the warning in the manpage should be 
>>>> probably dropped 
>>> OK.  I'll work with the man page maintainers. 
>> Hi Lee,
>>
>> If you could write a patch for the man page, that would be ideal.
>> Location of current tarball is in the .sig.
> 
> [PATCH]  enhance memory policy sys call man pages v1
> 
> Against man pages 2.51
> 
> This patch enhances the 3 memory policy system call man pages
> to add description of missing semantics, error return values,
> etc.  The descriptions match the semantics of the kernel circa
> 2.6.21/22, as gleaned from the source code.
> 
> I have changed the "policy" parameter to "mode" through out the
> descriptions in an attempt to promote the concept that the memory
> policy is a tuple consisting of a mode and optional set of nodes.
> Also matches internal name and <numaif.h> prototypes for mbind()
> and set_mempolicy().
> 
> I think I've covered all of the existing errno returns, but may
> have missed a few.  
> 
> These pages definitely need proofing by other sets of eyes...

Andi, Christoph: I don't have enough understanding of these system calls to
technically review the changes that Lee has made.  Can one or both of you
please help?  I will forward the revised patches as three separate mails
following this one.  (NOTE: ignore the patch below; it is now stale.)

Cheers,

Michael


> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
>  man2/get_mempolicy.2 |  222 +++++++++++++++++++++------------
>  man2/mbind.2         |  335 +++++++++++++++++++++++++++++++++++++--------------
>  man2/set_mempolicy.2 |  173 +++++++++++++++++++++-----
>  3 files changed, 526 insertions(+), 204 deletions(-)
> 
> Index: Linux/man2/mbind.2
> ===================================================================
> --- Linux.orig/man2/mbind.2	2007-05-11 19:07:02.000000000 -0400
> +++ Linux/man2/mbind.2	2007-06-01 12:28:06.000000000 -0400
> @@ -18,15 +18,16 @@
>  .\" the source, must acknowledge the copyright and authors of this work.
>  .\"
>  .\" 2006-02-03, mtk, substantial wording changes and other improvements
> +.\" 2007-06-01, lts, more precise specification of behavior.
>  .\"
> -.TH MBIND 2 "2006-02-07" "SuSE Labs" "Linux Programmer's Manual"
> +.TH MBIND 2 "2007-06-01" "SuSE Labs" "Linux Programmer's Manual"
>  .SH NAME
>  mbind \- Set memory policy for a memory range
>  .SH SYNOPSIS
>  .nf
>  .B "#include <numaif.h>"
>  .sp
> -.BI "int mbind(void *" start ", unsigned long " len  ", int " policy ,
> +.BI "int mbind(void *" start ", unsigned long " len  ", int " mode ,
>  .BI "          unsigned long *" nodemask  ", unsigned long " maxnode ,
>  .BI "          unsigned " flags );
>  .sp
> @@ -34,76 +35,179 @@ mbind \- Set memory policy for a memory 
>  .fi
>  .SH DESCRIPTION
>  .BR mbind ()
> -sets the NUMA memory
> -.I policy
> +sets the NUMA memory policy,
> +which consists of a policy mode and zero or more nodes,
>  for the memory range starting with
>  .I start
>  and continuing for
>  .IR len
>  bytes.
>  The memory of a NUMA machine is divided into multiple nodes.
> -The memory policy defines in which node memory is allocated.
> +The memory policy defines from which node memory is allocated.
> +
> +If the memory range specified by the
> +.IR start " and " len
> +arguments includes an "anonymous" region of memory\(emthat is
> +a region of memory created using the
> +.BR mmap (2)
> +system call with the
> +.BR MAP_ANONYMOUS \(emor
> +a memory mapped file, mapped using the
> +.BR mmap (2)
> +system call with the
> +.B MAP_PRIVATE
> +flag, pages will only be allocated according to the specified
> +policy when the application writes [stores] to the page.
> +For anonymous regions, an initial read access will use a shared
> +page in the kernel containing all zeros.
> +For a file mapped with
> +.BR MAP_PRIVATE ,
> +an initial read access will allocate pages according to the
> +process policy of the process that causes the page to be allocated.
> +This may not be the process that called
> +.BR mbind ().
> +
> +If the specified memory range includes a memory mapped file,
> +mapped using the
> +.BR mmap (2)
> +system call with the
> +.B MAP_SHARED
> +flag, the specified policy will be ignored for all page allocations
> +in this range.
> +Rather the pages will be allocated according to the process policy
> +of the process that caused the page to be allocated.
> +Again, this may not be the process that called
> +.BR mbind ().
> +
> +If the specified memory range includes a shared memory region
> +created using the
> +.BR shmget (2)
> +system call and attached using the
> +.BR shmat (2)
> +system call,
> +pages allocated for the anonymous or shared memory region will
> +be allocated according to the policy specified, regardless which
> +process attached to the shared memory segment causes the allocation.
> +If, however, the shared memory region was created with the
> +.B SHM_HUGETLB
> +flag,
> +the huge pages will be allocated according to the policy specified
> +only if the page allocation is caused by the task that calls
> +.BR mbind ()
> +for that region.
> +
> +By default,
>  .BR mbind ()
>  only has an effect for new allocations; if the pages inside
>  the range have been already touched before setting the policy,
>  then the policy has no effect.
> +This default behavior may be overridden by the
> +.BR MPOL_MF_MOVE
> +and
> +.B MPOL_MF_MOVE_ALL
> +flags described below.
>  
> -Available policies are
> +The
> +.I mode
> +argument must specify one of
>  .BR MPOL_DEFAULT ,
>  .BR MPOL_BIND ,
> -.BR MPOL_INTERLEAVE ,
> -and
> +.B MPOL_INTERLEAVE
> +or
>  .BR MPOL_PREFERRED .
> -All policies except
> +All policy modes except
>  .B MPOL_DEFAULT
> -require the caller to specify the nodes to which the policy applies in the
> +require the caller to specify via the
>  .I nodemask
> -parameter.
> +parameter,
> +the node or nodes to which the mode applies.
> +
>  .I nodemask
> -is a bitmask of nodes containing up to
> +points to a bitmask of nodes containing up to
>  .I maxnode
>  bits.
> -The actual number of bytes transferred via this argument
> -is rounded up to the next multiple of
> +The bit mask size is rounded to the next multiple of
>  .IR "sizeof(unsigned long)" ,
>  but the kernel will only use bits up to
>  .IR maxnode .
> -A NULL argument means an empty set of nodes.
> +A NULL value of
> +.I nodemask
> +or a
> +.I maxnode
> +value of zero specifies the empty set of nodes.
> +If the value of
> +.I maxnode
> +is zero,
> +the
> +.I nodemask
> +argument is ignored.
>  
>  The
>  .B MPOL_DEFAULT
> -policy is the default and means to use the underlying process policy
> -(which can be modified with
> -.BR set_mempolicy (2)).
> -Unless the process policy has been changed this means to allocate
> -memory on the node of the CPU that triggered the allocation.
> +mode specifies the default policy.
> +When applied to a range of memory via
> +.IR mbind (),
> +this means to use the process policy,
> + which may have been set with
> +.BR set_mempolicy (2).
> +If the mode of the process policy is also
> +.B MPOL_DEFAULT
> +pages will be allocated on the node of the CPU that triggers the allocation.
> +For
> +.BR MPOL_DEFAULT ,
> +the
>  .I nodemask
> -should be specified as NULL.
> +and
> +.I maxnode
> +arguments must be specify the empty set of nodes.
>  
>  The
>  .B MPOL_BIND
> -policy is a strict policy that restricts memory allocation to the
> -nodes specified in
> +mode specifies a strict policy that restricts memory allocation to
> +the nodes specified in
>  .IR nodemask .
> +If
> +.I nodemask
> +specifies more than one node, page allocations will come from
> +the node with the lowest numeric node id first, until that node
> +contains no free memory.
> +Allocations will then come from the node with the next highest
> +node id specified in
> +.I nodemask
> +and so forth, until none of the specified nodes contain free memory.
>  There won't be allocations on other nodes.
>  
> +The
>  .B MPOL_INTERLEAVE
> -interleaves allocations to the nodes specified in
> +mode specifies that page allocations be interleaved across the
> +set of nodes specified in
>  .IR nodemask .
> -This optimizes for bandwidth instead of latency.
> +This optimizes for bandwidth instead of latency
> +by spreading out pages and memory accesses to those pages across
> +multiple nodes.
>  To be effective the memory area should be fairly large,
> -at least 1MB or bigger.
> +at least 1MB or bigger with a fairly uniform access pattern.
> +Accesses to a single page of the area will still be limited to
> +the memory bandwidth of a single node.
>  
>  .B MPOL_PREFERRED
>  sets the preferred node for allocation.
> -The kernel will try to allocate in this
> +The kernel will try to allocate pages from this
>  node first and fall back to other nodes if the
>  preferred nodes is low on free memory.
> -Only the first node in the
> +If
>  .I nodemask
> -is used.
> -If no node is set in the mask, then the memory is allocated on
> -the node of the CPU that triggered the allocation allocation).
> +specifies more than one node id, the first node in the
> +mask will be selected as the preferred node.
> +If the
> +.I nodemask
> +and
> +.I maxnode
> +arguments specify the empty set, then the memory is allocated on
> +the node of the CPU that triggered the allocation.
> +This is the only way to specify "local allocation" for a
> +range of memory via
> +.IR mbind (2).
>  
>  If
>  .B MPOL_MF_STRICT
> @@ -115,17 +219,18 @@ is not
>  .BR MPOL_DEFAULT ,
>  then the call will fail with the error
>  .B EIO
> -if the existing pages in the mapping don't follow the policy.
> -In 2.6.16 or later the kernel will also try to move pages
> -to the requested node with this flag.
> +if the existing pages in the memory range don't follow the policy.
> +.\" According to the kernel code, the following is not true --lts
> +.\" In 2.6.16 or later the kernel will also try to move pages
> +.\" to the requested node with this flag.
>  
>  If
>  .B MPOL_MF_MOVE
> -is passed in
> +is specified in
>  .IR flags ,
> -then an attempt will be made  to
> -move all the pages in the mapping so that they follow the policy.
> -Pages that are shared with other processes are not moved.
> +then the kernel will attempt to move all the existing pages
> +in the memory range so that they follow the policy.
> +Pages that are shared with other processes will not be moved.
>  If
>  .B MPOL_MF_STRICT
>  is also specified, then the call will fail with the error
> @@ -136,8 +241,8 @@ If
>  .B MPOL_MF_MOVE_ALL
>  is passed in
>  .IR flags ,
> -then all pages in the mapping will be moved regardless of whether
> -other processes use the pages.
> +then the kernel will attempt to move all existing pages in the memory range
> +regardless of whether other processes use the pages.
>  The calling process must be privileged
>  .RB ( CAP_SYS_NICE )
>  to use this flag.
> @@ -146,6 +251,7 @@ If
>  is also specified, then the call will fail with the error
>  .B EIO
>  if some pages could not be moved.
> +.\" ---------------------------------------------------------------
>  .SH RETURN VALUE
>  On success,
>  .BR mbind ()
> @@ -153,11 +259,9 @@ returns 0;
>  on error, \-1 is returned and
>  .I errno
>  is set to indicate the error.
> +.\" ---------------------------------------------------------------
>  .SH ERRORS
> -.TP
> -.B EFAULT
> -There was a unmapped hole in the specified memory range
> -or a passed pointer was not valid.
> +.\"  I think I got all of the error returns.  --lts
>  .TP
>  .B EINVAL
>  An invalid value was specified for
> @@ -169,53 +273,102 @@ or
>  was less than
>  .IR start ;
>  or
> -.I policy
> -was
> -.B MPOL_DEFAULT
> +.I start
> +is not a multiple of the system page size.
> +Or,
> +.I mode
> +is
> +.I MPOL_DEFAULT
>  and
>  .I nodemask
> -pointed to a non-empty set;
> +specified a non-empty set;
>  or
> -.I policy
> -was
> -.B MPOL_BIND
> +.I mode
> +is
> +.I MPOL_BIND
>  or
> -.B MPOL_INTERLEAVE
> +.I MPOL_INTERLEAVE
>  and
>  .I nodemask
> -pointed to an empty set,
> +is empty.
> +Or,
> +.I maxnode
> +specifies more than a page worth of bits.
> +Or,
> +.I nodemask
> +specifies one or more node ids that are
> +greater than the maximum supported node id,
> +or are not allowed in the calling task's context.
> +.\" "calling task's context" refers to cpusets.  No man page avail to ref. --lts
> +Or, none of the node ids specified by
> +.I nodemask
> +are on-line, or none of the specified nodes contain memory.
> +.TP
> +.B EFAULT
> +Part of all of the memory range specified by
> +.I nodemask
> +and
> +.I maxnode
> +points outside your accessible address space.
> +Or, there was a unmapped hole in the specified memory range.
>  .TP
>  .B ENOMEM
> -System out of memory.
> +Insufficient kernel memory was available.
>  .TP
>  .B EIO
>  .B MPOL_MF_STRICT
>  was specified and an existing page was already on a node
> -that does not follow the policy.
> +that does not follow the policy;
> +or
> +.B MPOL_MF_MOVE
> +or
> +.B MPOL_MF_MOVE_ALL
> +was specified and the kernel was unable to move all existing
> +pages in the range.
> +.TP
> +.B EPERM
> +The
> +.I flags
> +argument included the
> +.B MPOL_MF_MOVE_ALL
> +flag and the caller does not have the
> +.B CAP_SYS_NICE
> +privilege.
> +.\" ---------------------------------------------------------------
>  .SH NOTES
> -NUMA policy is not supported on file mappings.
> +NUMA policy is not supported on a memory mapped file range
> +that was mapped with the
> +.I MAP_SHARED
> +flag.
>  
>  .B MPOL_MF_STRICT
> -is  ignored  on  huge page mappings right now.
> +is ignored on huge page mappings.
>  
> -It is unfortunate that the same flag,
> +The
>  .BR MPOL_DEFAULT ,
> -has different effects for
> +mode has different effects for
>  .BR mbind (2)
>  and
>  .BR set_mempolicy (2).
> -To select "allocation on the node of the CPU that
> -triggered the allocation" (like
> -.BR set_mempolicy (2)
> -.BR MPOL_DEFAULT )
> -when calling
> +When
> +.B MPOL_DEFAULT
> +is specified for a range of memory using
>  .BR mbind (),
> +any pages subsequently allocated for that range will use
> +the process' policy, as set by
> +.BR set_mempolicy (2).
> +This effectively removes the explicit policy from the
> +specified range.
> +To select "local allocation" for a memory range,
>  specify a
> -.I policy
> +.I mode
>  of
>  .B MPOL_PREFERRED
> -with an empty
> -.IR nodemask .
> +with an empty set of nodes.
> +This method will work for
> +.BR set_mempolicy (2),
> +as well.
> +.\" ---------------------------------------------------------------
>  .SH "VERSIONS AND LIBRARY SUPPORT"
>  The
>  .BR mbind (),
> @@ -226,16 +379,18 @@ system calls were added to the Linux ker
>  They are only available on kernels compiled with
>  .BR CONFIG_NUMA .
>  
> -Support for huge page policy was added with 2.6.16.
> -For interleave policy to be effective on huge page mappings the
> -policied memory needs to be tens of megabytes or larger.
> -
> -.B MPOL_MF_MOVE
> -and
> -.B MPOL_MF_MOVE_ALL
> -are only available on Linux 2.6.16 and later.
> +You can link with
> +.I -lnuma
> +to get system call definitions.
> +.I libnuma
> +and the required
> +.I numaif.h
> +header.
> +are available in the
> +.I numactl
> +package.
>  
> -These system calls should not be used directly.
> +However, applications should not use these system calls directly.
>  Instead, the higher level interface provided by the
>  .BR numa (3)
>  functions in the
> @@ -245,17 +400,21 @@ The
>  .I numactl
>  package is available at
>  .IR ftp://ftp.suse.com/pub/people/ak/numa/ .
> -
> -You can link with
> -.I -lnuma
> -to get system call definitions.
> -.I libnuma
> -is available in the
> -.I numactl
> +The package is also included in some Linux distributions.
> +Some distributions include the development library and header
> +in the separate
> +.I numactl-devel
>  package.
> -This package also has the
> -.I numaif.h
> -header.
> +
> +Support for huge page policy was added with 2.6.16.
> +For interleave policy to be effective on huge page mappings the
> +policied memory needs to be tens of megabytes or larger.
> +
> +.B MPOL_MF_MOVE
> +and
> +.B MPOL_MF_MOVE_ALL
> +are only available on Linux 2.6.16 and later.
> +
>  .SH CONFORMING TO
>  This system call is Linux specific.
>  .SH SEE ALSO
> @@ -263,4 +422,6 @@ This system call is Linux specific.
>  .BR numactl (8),
>  .BR set_mempolicy (2),
>  .BR get_mempolicy (2),
> -.BR mmap (2)
> +.BR mmap (2),
> +.BR shmget (2),
> +.BR shmat (2).
> Index: Linux/man2/get_mempolicy.2
> ===================================================================
> --- Linux.orig/man2/get_mempolicy.2	2007-04-12 18:42:49.000000000 -0400
> +++ Linux/man2/get_mempolicy.2	2007-06-01 12:29:00.000000000 -0400
> @@ -18,6 +18,7 @@
>  .\" the source, must acknowledge the copyright and authors of this work.
>  .\"
>  .\" 2006-02-03, mtk, substantial wording changes and other improvements
> +.\" 2007-06-01, lts, more precise specification of behavior.
>  .\"
>  .TH GET_MEMPOLICY 2 "2006-02-07" "SuSE Labs" "Linux Programmer's Manual"
>  .SH SYNOPSIS
> @@ -26,9 +27,11 @@ get_mempolicy \- Retrieve NUMA memory po
>  .B "#include <numaif.h>"
>  .nf
>  .sp
> -.BI "int get_mempolicy(int *" policy ", unsigned long *" nodemask ,
> +.BI "int get_mempolicy(int *" mode ", unsigned long *" nodemask ,
>  .BI "                  unsigned long " maxnode ", unsigned long " addr ,
>  .BI "                  unsigned long " flags );
> +.sp
> +.BI "cc ... \-lnuma"
>  .fi
>  .\" TBD rewrite this. it is confusing.
>  .SH DESCRIPTION
> @@ -39,7 +42,7 @@ depending on the setting of
>  
>  A NUMA machine has different
>  memory controllers with different distances to specific CPUs.
> -The memory policy defines in which node memory is allocated for
> +The memory policy defines from which node memory is allocated for
>  the process.
>  
>  If
> @@ -58,58 +61,75 @@ then information is returned about the p
>  address given in
>  .IR addr .
>  This policy may be different from the process's default policy if
> -.BR set_mempolicy (2)
> -has been used to establish a policy for the page containing
> +.BR mbind (2)
> +or one of the helper functions described in
> +.BR numa(3)
> +has been used to establish a policy for the memory range containing
>  .IR addr .
>  
> -If
> -.I policy
> -is not NULL, then it is used to return the policy.
> +If the
> +.I mode
> +argument is not NULL, then
> +.IR get_mempolicy ()
> +will store the policy mode of the requested NUMA policy in the location
> +pointed to by this argument.
>  If
>  .IR nodemask
> -is not NULL, then it is used to return the nodemask associated
> -with the policy.
> +is not NULL, then the nodemask associated with the policy will be stored
> +in the location pointed to by this argument.
>  .I maxnode
> -is the maximum bit number plus one that can be stored into
> -.IR nodemask .
> -The bit number is always rounded to a multiple of
> -.IR "unsigned long" .
> -.\"
> -.\" If
> -.\" .I flags
> -.\" specifies both
> -.\" .B MPOL_F_NODE
> -.\" and
> -.\" .BR MPOL_F_ADDR ,
> -.\" then
> -.\" .I policy
> -.\" instead returns the number of the node on which the address
> -.\" .I addr
> -.\" is allocated.
> -.\"
> -.\" If
> -.\" .I flags
> -.\" specifies
> -.\" .B MPOL_F_NODE
> -.\" but not
> -.\" .BR MPOL_F_ADDR ,
> -.\" and the process's current policy is
> -.\" .BR MPOL_INTERLEAVE ,
> -.\" then
> -.\" checkme: Andi's text below says that the info is returned in
> -.\" 'nodemask', not 'policy':
> -.\" .I policy
> -.\" instead returns the number of the next node that will be used for
> -.\" interleaving allocation.
> -.\" FIXME .
> -.\" The other valid flag is
> -.\" .I MPOL_F_NODE.
> -.\" It is only valid when the policy is
> -.\" .I MPOL_INTERLEAVE.
> -.\" In this case not the interleave mask, but an unsigned long with the next
> -.\" node that would be used for interleaving is returned in
> -.\" .I nodemask.
> -.\" Other flag values are reserved.
> +specifies the number of node ids
> +that can be stored into
> +.IR nodemask \(emthat
> +is, the maximum node id plus one.
> +The value specified by
> +.I maxnode
> +is always rounded to a multiple of
> +.IR "sizeof(unsigned long)" .
> +
> +If
> +.I flags
> +specifies both
> +.B MPOL_F_NODE
> +and
> +.BR MPOL_F_ADDR ,
> +.IR get_mempolicy ()
> +will return the node id of the node on which the address
> +.I addr
> +is allocated into the location pointed to by
> +.IR mode .
> +If no page has yet been allocated for the specified address,
> +.IR get_mempolicy ()
> +will allocate a page as if the process had performed a read
> +[load] access to that address, and return the id of the node
> +where that page was allocated.
> +
> +If
> +.I flags
> +specifies
> +.BR MPOL_F_NODE ,
> +but not
> +.BR MPOL_F_ADDR ,
> +and the process's current policy is
> +.BR MPOL_INTERLEAVE ,
> +then
> +.IR get_mempolicy ()
> +will return in the location pointed to by a non-NULL
> +.I mode
> +argument,
> +the node id of the next node that will be used for
> +interleaving of internal kernel pages allocated on behalf of the process.
> +.\" Note:  code returns next interleave node via 'mode' argument -lts
> +These allocations include pages for memory mapped files in
> +process memory ranges mapped using the
> +.IR mmap (2)
> +call with the
> +.I MAP_PRIVATE
> +flag for read accesses, and in memory ranges mapped with the
> +.I MAP_SHARED
> +flag for all accesses.
> +
> +Other flag values are reserved.
>  
>  For an overview of the possible policies see
>  .BR set_mempolicy (2).
> @@ -120,40 +140,77 @@ returns 0;
>  on error, \-1 is returned and
>  .I errno
>  is set to indicate the error.
> -.\" .SH ERRORS
> -.\" FIXME writeme -- no errors are listed on this page
> -.\" .
> -.\" .TP
> -.\" .B EINVAL
> -.\" .I nodemask
> -.\" is non-NULL, and
> -.\" .I maxnode
> -.\" is too small;
> -.\" or
> -.\" .I flags
> -.\" specified values other than
> -.\" .B MPOL_F_NODE
> -.\" or
> -.\" .BR MPOL_F_ADDR ;
> -.\" or
> -.\" .I flags
> -.\" specified
> -.\" .B MPOL_F_ADDR
> -.\" and
> -.\" .I addr
> -.\" is NULL.
> -.\" (And there are other EINVAL cases.)
> +.SH ERRORS
> +.TP
> +.B EINVAL
> +The value specified by
> +.I maxnode
> +is less than the number of node ids supported by the system.
> +Or
> +.I flags
> +specified values other than
> +.B MPOL_F_NODE
> +or
> +.BR MPOL_F_ADDR ;
> +or
> +.I flags
> +specified
> +.B MPOL_F_ADDR
> +and
> +.I addr
> +is NULL,
> +or
> +.I flags
> +did not specify
> +.B MPOL_F_ADDR
> +and
> +.I addr
> +is not NULL.
> +Or,
> +.I flags
> +specified
> +.B MPOL_F_NODE
> +but not
> +.B MPOL_F_ADDR
> +and the current process policy is not
> +.BR MPOL_INTERLEAVE .
> +(And there are other EINVAL cases.)
> +.TP
> +.B EFAULT
> +Part of all of the memory range specified by
> +.I nodemask
> +and
> +.I maxnode
> +points outside your accessible address space.
>  .SH NOTES
> -This manual page is incomplete:
> -it does not document the details the
> -.BR MPOL_F_NODE
> -flag,
> -which modifies the operation of
> -.BR get_mempolicy ().
> -This is deliberate: this flag is not intended for application use,
> -and its operation may change or it may be removed altogether in
> -future kernel versions.
> -.B Do not use it.
> +If the mode of the process policy or the policy governing allocations at the
> +specified address is
> +.I MPOL_PREFERRED
> +and this policy was installed with an empty
> +.IR nodemask \(emspecifying
> +local allocation,
> +.IR get_mempolicy ()
> +will return the mask of on-line node ids in the location pointed to by
> +a non-NULL
> +.I nodemask
> +argument.
> +This mask does not take into consideration any adminstratively imposed
> +restrictions on the process' context.
> +.\" "context" above refers to cpusets.  No man page to reference. --lts
> +
> +.\"  Christoph says the following is untrue.  These are "fully supported."
> +.\"  Andi concedes that he has lost this battle and approves [?]
> +.\"  updating the man pages to document the behavior.  --lts
> +.\" This manual page is incomplete:
> +.\" it does not document the details the
> +.\" .BR MPOL_F_NODE
> +.\" flag,
> +.\" which modifies the operation of
> +.\" .BR get_mempolicy ().
> +.\" This is deliberate: this flag is not intended for application use,
> +.\" and its operation may change or it may be removed altogether in
> +.\" future kernel versions.
> +.\" .B Do not use it.
>  .SH "VERSIONS AND LIBRARY SUPPORT"
>  See
>  .BR mbind (2).
> @@ -161,6 +218,7 @@ See
>  This system call is Linux specific.
>  .SH SEE ALSO
>  .BR mbind (2),
> +.BR mmap (2),
>  .BR set_mempolicy (2),
>  .BR numactl (8),
>  .BR numa (3)
> Index: Linux/man2/set_mempolicy.2
> ===================================================================
> --- Linux.orig/man2/set_mempolicy.2	2007-04-12 18:42:49.000000000 -0400
> +++ Linux/man2/set_mempolicy.2	2007-06-01 12:28:49.000000000 -0400
> @@ -18,6 +18,7 @@
>  .\" the source, must acknowledge the copyright and authors of this work.
>  .\"
>  .\" 2006-02-03, mtk, substantial wording changes and other improvements
> +.\" 2007-06-01, lts, more precise specification of behavior.
>  .\"
>  .TH SET_MEMPOLICY 2 "2006-02-07" "SuSE Labs" "Linux Programmer's Manual"
>  .SH NAME
> @@ -26,80 +27,141 @@ set_mempolicy \- set default NUMA memory
>  .nf
>  .B "#include <numaif.h>"
>  .sp
> -.BI "int set_mempolicy(int " policy ", unsigned long *" nodemask ,
> +.BI "int set_mempolicy(int " mode ", unsigned long *" nodemask ,
>  .BI "                  unsigned long " maxnode );
> +.sp
> +.BI "cc ... \-lnuma"
>  .fi
>  .SH DESCRIPTION
>  .BR set_mempolicy ()
> -sets the NUMA memory policy of the calling process to
> -.IR policy .
> +sets the NUMA memory policy of the calling process,
> +which consists of a policy mode and zero or more nodes,
> +to the values specified by the
> +.IR mode ,
> +.I nodemask
> +and
> +.IR maxnode
> +arguments.
>  
>  A NUMA machine has different
>  memory controllers with different distances to specific CPUs.
> -The memory policy defines in which node memory is allocated for
> +The memory policy defines from which node memory is allocated for
>  the process.
>  
> -This system call defines the default policy for the process;
> -in addition a policy can be set for specific memory ranges using
> +This system call defines the default policy for the process.
> +The process policy governs allocation of pages in the process'
> +address space outside of memory ranges
> +controlled by a more specific policy set by
>  .BR mbind (2).
> +The process default policy also controls allocation of any pages for
> +memory mapped files mapped using the
> +.BR mmap (2)
> +call with the
> +.B MAP_PRIVATE
> +flag and that are only read [loaded] from by the task
> +and of memory mapped files mapped using the
> +.BR mmap (2)
> +call with the
> +.B MAP_SHARED
> +flag, regardless of the access type.
>  The policy is only applied when a new page is allocated
>  for the process.
>  For anonymous memory this is when the page is first
>  touched by the application.
>  
> -Available policies are
> +The
> +.I mode
> +argument must specify one of
>  .BR MPOL_DEFAULT ,
>  .BR MPOL_BIND ,
> -.BR MPOL_INTERLEAVE ,
> +.B MPOL_INTERLEAVE
> +or
>  .BR MPOL_PREFERRED .
> -All policies except
> +All modes except
>  .B MPOL_DEFAULT
> -require the caller to specify the nodes to which the policy applies in the
> +require the caller to specify via the
>  .I nodemask
> -parameter.
> +parameter
> +one or more nodes.
> +
>  .I nodemask
> -is pointer to a bit field of nodes that contains up to
> +points to a bit mask of node ids that contains up to
>  .I maxnode
>  bits.
> -The bit field size is rounded to the next multiple of
> +The bit mask size is rounded to the next multiple of
>  .IR "sizeof(unsigned long)" ,
>  but the kernel will only use bits up to
>  .IR maxnode .
> +A NULL value of
> +.I nodemask
> +or a
> +.I maxnode
> +value of zero specifies the empty set of nodes.
> +If the value of
> +.I maxnode
> +is zero,
> +the
> +.I nodemask
> +argument is ignored.
>  
>  The
>  .B MPOL_DEFAULT
> -policy is the default and means to allocate memory locally,
> +mode is the default and means to allocate memory locally,
>  i.e., on the node of the CPU that triggered the allocation.
>  .I nodemask
> -should be specified as NULL.
> +must be specified as NULL.
> +If the "local node" contains no free memory, the system will
> +attempt to allocate memory from a "near by" node.
>  
>  The
>  .B MPOL_BIND
> -policy is a strict policy that restricts memory allocation to the
> +mode defines a strict policy that restricts memory allocation to the
>  nodes specified in
>  .IR nodemask .
> -There won't be allocations on other nodes.
> +If
> +.I nodemask
> +specifies more than one node, page allocations will come from
> +the node with the lowest numeric node id first, until that node
> +contains no free memory.
> +Allocations will then come from the node with the next highest
> +node id specified in
> +.I nodemask
> +and so forth, until none of the specified nodes contain free memory.
> +Pages will not be allocated from any node not specified in the
> +.IR nodemask .
>  
>  .B MPOL_INTERLEAVE
> -interleaves allocations to the nodes specified in
> -.IR nodemask .
> -This optimizes for bandwidth instead of latency.
> -To be effective the memory area should be fairly large,
> -at least 1MB or bigger.
> +interleaves page allocations across the nodes specified in
> +.I nodemask
> +in numeric node id order.
> +This optimizes for bandwidth instead of latency
> +by spreading out pages and memory accesses to those pages across
> +multiple nodes.
> +However, accesses to a single page will still be limited to
> +the memory bandwidth of a single node.
> +.\" NOTE:  the following sentence doesn't make sense in the context
> +.\" of set_mempolicy() -- no memory area specified.
> +.\" To be effective the memory area should be fairly large,
> +.\" at least 1MB or bigger.
>  
>  .B MPOL_PREFERRED
>  sets the preferred node for allocation.
> -The kernel will try to allocate in this
> -node first and fall back to other nodes if the preferred node is low on free
> +The kernel will try to allocate pages from this node first
> +and fall back to "near by" nodes if the preferred node is low on free
>  memory.
> -Only the first node in the
> +If
> +.I nodemask
> +specifies more than one node id, the first node in the
> +mask will be selected as the preferred node.
> +If the
>  .I nodemask
> -is used.
> -If no node is set in the mask, then the memory is allocated on
> -the node of the CPU that triggered the allocation allocation (like
> +and
> +.I maxnode
> +arguments specify the empty set, then the memory is allocated on
> +the node of the CPU that triggered the allocation (like
>  .BR MPOL_DEFAULT ).
>  
> -The memory policy is preserved across an
> +The process memory policy is preserved across an
>  .BR execve (2),
>  and is inherited by child processes created using
>  .BR fork (2)
> @@ -107,6 +169,9 @@ or
>  .BR clone (2).
>  .SH NOTES
>  Process policy is not remembered if the page is swapped out.
> +When such a page is paged back in, it will use the policy of
> +the process or memory range that is in effect at the time the
> +page is allocated.
>  .SH RETURN VALUE
>  On success,
>  .BR set_mempolicy ()
> @@ -114,12 +179,49 @@ returns 0;
>  on error, \-1 is returned and
>  .I errno
>  is set to indicate the error.
> -.\" .SH ERRORS
> -.\" FIXME writeme -- no errors are listed on this page
> -.\" .
> -.\" .TP
> -.\" .B EINVAL
> -.\" .I mode is invalid.
> +.SH ERRORS
> +.TP
> +.B EINVAL
> +.I mode is invalid.
> +Or,
> +.I mode
> +is
> +.I MPOL_DEFAULT
> +and
> +.I nodemask
> +is non-empty,
> +or
> +.I mode
> +is
> +.I MPOL_BIND
> +or
> +.I MPOL_INTERLEAVE
> +and
> +.I nodemask
> +is empty.
> +Or,
> +.I maxnode
> +specifies more than a page worth of bits.
> +Or,
> +.I nodemask
> +specifies one or more node ids that are
> +greater than the maximum supported node id,
> +or are not allowed in the calling task's context.
> +.\" "calling task's context" refers to cpusets.  No man page avail to ref. --lts
> +Or, none of the node ids specified by
> +.I nodemask
> +are on-line, or none of the specified nodes contain memory.
> +.TP
> +.B EFAULT
> +Part of all of the memory range specified by
> +.I nodemask
> +and
> +.I maxnode
> +points outside your accessible address space.
> +.TP
> +.B ENOMEM
> +Insufficient kernel memory was available.
> +
>  .SH "VERSIONS AND LIBRARY SUPPORT"
>  See
>  .BR mbind (2).
> @@ -127,6 +229,7 @@ See
>  This system call is Linux specific.
>  .SH SEE ALSO
>  .BR mbind (2),
> +.BR mmap (2),
>  .BR get_mempolicy (2),
>  .BR numactl (8),
>  .BR numa (3)
> 
> 

-- 
Michael Kerrisk
maintainer of Linux man pages Sections 2, 3, 4, 5, and 7

Want to help with man page maintenance?  Grab the latest tarball at
http://www.kernel.org/pub/linux/docs/manpages/
read the HOWTOHELP file and grep the source files for 'FIXME'.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

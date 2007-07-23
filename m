Subject: Re: mbind.2 man page patch
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <46A44B8D.2040200@gmx.net>
References: <1180467234.5067.52.camel@localhost>
	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>
	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>
	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>
	 <46A44B8D.2040200@gmx.net>
Content-Type: text/plain
Date: Mon, 23 Jul 2007 10:26:08 -0400
Message-Id: <1185200768.5074.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Michael Kerrisk <mtk-manpages@gmx.net>
Cc: ak@suse.de, clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, Samuel Thibault <samuel.thibault@ens-lyon.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-07-23 at 08:32 +0200, Michael Kerrisk wrote:
> Andi, Christoph
> 
> Could you please review these changes by Lee to the mbind.2 page?  Patch
> against man-pages-2.63 (available from
> http://www.kernel.org/pub/linux/docs/manpages).
> 
> Andi / Christoph / Lee: There are a few points marked FIXME about which I'd
> particularly like some input.
> 
> Lee: aside from the changes tha you made, plus my edits, I added a sentence
> to this page that cam in independently from Samuel Thibau;t (marked below).
> 
> Cheers,
> 
> Michael
> 
> --- mbind.2.orig        2007-07-01 06:22:24.000000000 +0200
> +++ mbind.2     2007-07-21 09:18:05.000000000 +0200
> @@ -1,4 +1,5 @@
>  .\" Copyright 2003,2004 Andi Kleen, SuSE Labs.
> +.\" and Copyright (C) 2007 Lee Schermerhorn <Lee.Schermerhorn@hp.com>
>  .\"
>  .\" Permission is granted to make and distribute verbatim copies of this
>  .\" manual provided the copyright notice and this permission notice are
> @@ -18,92 +19,214 @@
>  .\" the source, must acknowledge the copyright and authors of this work.
>  .\"
>  .\" 2006-02-03, mtk, substantial wording changes and other improvements
> +.\" 2007-06-01, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> +.\"     more precise specification of behavior.
>  .\"
> -.TH MBIND 2 2006-02-07 "Linux" "Linux Programmer's Manual"
> +.TH MBIND 2 2007-07-20 Linux "Linux Programmer's Manual"
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
> -.BI "cc ... \-lnuma"
> +Link with \fI\-lnuma\fP.
>  .fi
>  .SH DESCRIPTION
> +The memory of a NUMA machine is divided into multiple nodes.
> +The memory policy defines the node on which memory is allocated.
>  .BR mbind ()
> -sets the NUMA memory
> -.I policy
> +sets the NUMA memory policy
>  for the memory range starting with
>  .I start
>  and continuing for
>  .IR len
>  bytes.
> -The memory of a NUMA machine is divided into multiple nodes.
> -The memory policy defines in which node memory is allocated.
> +.\" The following sentence added by Samuel Thibault:
> +.I start
> +must be page aligned.
> +
> +The NUMA policy consists of a policy mode, specified in
> +.IR mode ,
> +and a set of zero or nodes, specified in
> +.IR nodemask ;
> +these arguments are described below.
> +
> +If the memory range specified by the
> +.IR start " and " len
> +arguments includes an anonymous region of memory (i.e.,
> +a region of memory created using
> +.BR mmap (2)
> +with the
> +.BR MAP_ANONYMOUS
> +flag) or
> +a memory mapped file mapped using
> +.BR mmap (2)
> +with the
> +.B MAP_PRIVATE
> +flag, pages will only be allocated according to the specified
> +policy when the application writes [stores] to the page.
> +For anonymous regions, an initial read access will use a shared
> +page in the kernel containing all zeros.
> +For a file mapped with
> +.BR MAP_PRIVATE ,
> +an initial read access will allocate pages according to the
> +process policy of the process that causes the page to be allocated.
> +This might not be the process that called
> +.BR mbind ().
> +
> +If the specified memory range includes a memory mapped file mapped using
> +.BR mmap (2)
> +with the
> +.B MAP_SHARED
> +flag, the specified policy will be ignored for all page allocations
> +in this range.
> +.\" FIXME Lee / Andi: can you clarify/confirm "the specified policy
> +.\" will be ignored for all page allocations in this range".
> +.\" That text seems to be saying that if the memory range contains
> +.\" (say) some mappings that are allocated with MAP_SHARED
> +.\" and others allocated with MAP_PRIVATE, then the policy
> +.\" will be ignored for all of the mappings, including even
> +.\" the MAP_PRIVATE mappings.  Right?  I just want to be
> +.\" sure that that is what the text is meaning.

I can see from the wording how you might think this.  However, policy
will only be ignored for the SHARED mappings.  

> +Instead, the pages will be allocated according to the process policy
> +of the process that caused the page to be allocated.
> +Again, this might not be the process that called
> +.BR mbind ().
> +
> +If the specified memory range includes a shared memory region
> +created using
> +.BR shmget (2)
> +and attached using
> +.BR shmat (2),
> +pages allocated for the anonymous or shared memory region will
> +be allocated according to the policy specified, regardless of which
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
> -the range have been already touched before setting the policy,
> +the range have already been touched before setting the policy,
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
>  .BR MPOL_INTERLEAVE ,
> -and
> +or
>  .BR MPOL_PREFERRED .
> -All policies except
> +All policy modes except
>  .B MPOL_DEFAULT
> -require the caller to specify the nodes to which the policy applies in the
> +require the caller to specify
> +the node or nodes to which the mode applies, via the
>  .I nodemask
> -parameter.
> +argument.
> +
>  .I nodemask
> -is a bit mask of nodes containing up to
> +points to a bit mask of nodes containing up to
>  .I maxnode
>  bits.
> -The actual number of bytes transferred via this argument
> +The actual number of bytes transferred via
> +.I nodemask
>  is rounded up to the next multiple of
>  .IR "sizeof(unsigned long)" ,
>  but the kernel will only use bits up to
>  .IR maxnode .
> -A NULL argument means an empty set of nodes.
> +A NULL value for
> +.IR nodemask ,
> +or a
> +.I maxnode
> +value of zero specifies the empty set of nodes.
> +If the value of
> +.I maxnode
> +is zero, then the
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
> +.BR mbind (),
> +this means that the process policy should be used;
> +the process policy can be set with
> +.BR set_mempolicy (2).
> +If the mode of the process policy is also
> +.BR MPOL_DEFAULT ,
> +then pages will be allocated on the node of the CPU that
> +triggers the allocation.
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
> +the node with the lowest numeric node ID first, until that node
> +contains no free memory.
> +Allocations will then come from the node with the next highest
> +node ID specified in
> +.I nodemask
> +and so forth, until none of the specified nodes contains free memory.
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
> +The kernel will try to allocate pages on this
>  node first and fall back to other nodes if the
>  preferred nodes is low on free memory.
> -Only the first node in the
> +If
> +.I nodemask
> +specifies more than one node ID, the first node in the
> +mask will be selected as the preferred node.
> +If the
>  .I nodemask
> -is used.
> -If no node is set in the mask, then the memory is allocated on
> -the node of the CPU that triggered the allocation allocation).
> +and
> +.I maxnode
> +arguments specify the empty set, then the memory is allocated on
> +the node of the CPU that triggered the allocation.
> +This is the only way to specify "local allocation" for a
> +range of memory via
> +.BR mbind ().
> 
>  If
>  .B MPOL_MF_STRICT
> @@ -115,17 +238,20 @@
>  .BR MPOL_DEFAULT ,
>  then the call will fail with the error
>  .B EIO
> -if the existing pages in the mapping don't follow the policy.
> -In 2.6.16 or later the kernel will also try to move pages
> -to the requested node with this flag.
> +if the existing pages in the memory range don't follow the policy.
> +.\" FIXME Andi / Christoph -- can you please verify Lee's change here:
> +.\" According to the kernel code, the following is not true
> +.\" -- Lee Schermerhorn:
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
> @@ -136,8 +262,8 @@
>  .B MPOL_MF_MOVE_ALL
>  is passed in
>  .IR flags ,
> -then all pages in the mapping will be moved regardless of whether
> -other processes use the pages.
> +then the kernel will attempt to move all existing pages in the memory
> +range regardless of whether other processes use the pages.
>  The calling process must be privileged
>  .RB ( CAP_SYS_NICE )
>  to use this flag.
> @@ -154,10 +280,15 @@
>  .I errno
>  is set to indicate the error.
>  .SH ERRORS
> +.\"  I think I got all of the error returns.  -- Lee Schermerhorn
>  .TP
>  .B EFAULT
> -There was a unmapped hole in the specified memory range
> -or a passed pointer was not valid.
> +Part or all of the memory range specified by
> +.I nodemask
> +and
> +.I maxnode
> +points outside your accessible address space.
> +Or, there was a unmapped hole in the specified memory range.
>  .TP
>  .B EINVAL
>  An invalid value was specified for
> @@ -169,56 +300,96 @@
>  was less than
>  .IR start ;
>  or
> -.I policy
> -was
> +.I start
> +is not a multiple of the system page size.
> +Or,
> +.I mode
> +is
>  .B MPOL_DEFAULT
>  and
>  .I nodemask
> -pointed to a non-empty set;
> +specified a non-empty set;
>  or
> -.I policy
> -was
> +.I mode
> +is
>  .B MPOL_BIND
>  or
>  .B MPOL_INTERLEAVE
>  and
>  .I nodemask
> -pointed to an empty set,
> +is empty.
> +Or,
> +.I maxnode
> +specifies more than a page worth of bits.
> +Or,
> +.I nodemask
> +specifies one or more node IDs that are
> +greater than the maximum supported node ID,
> +or are not allowed in the calling task's context.
> +.\" "calling task's context" refers to cpusets.
> +.\" No man page avail to reference. -- Lee Schermerhorn
> +Or, none of the node IDs specified by
> +.I nodemask
> +are on-line, or none of the specified nodes contain memory.
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
>  .SH CONFORMING TO
>  This system call is Linux specific.
>  .SH NOTES
> -NUMA policy is not supported on file mappings.
> +NUMA policy is not supported on a memory mapped file range
> +that was mapped with the
> +.B MAP_SHARED
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
> -.BR mbind (2)
> +mode has different effects for
> +.BR mbind ()
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
> +the process's policy, as set by
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
> -.SS "Versions and Library Support"
> +with an empty set of nodes.
> +This method will work for
> +.BR set_mempolicy (2),
> +as well.
> +.SS "Versions and LIbrary Support"
>  The
>  .BR mbind (),
>  .BR get_mempolicy (2),
> @@ -228,16 +399,17 @@
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
> +.I \-lnuma
> +to get system call definitions.
> +.I libnuma
> +and the required
> +.I numaif.h
> +header are available in the
> +.I numactl
> +package.
> 
> -These system calls should not be used directly.
> +However, applications should not use these system calls directly.
>  Instead, the higher level interface provided by the
>  .BR numa (3)
>  functions in the
> @@ -247,20 +419,25 @@
>  .I numactl
>  package is available at
>  .IR ftp://ftp.suse.com/pub/people/ak/numa/ .
> -
> -You can link with
> -.I \-lnuma
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
>  .SH SEE ALSO
> -.BR numa (3),
> -.BR numactl (8),
> -.BR set_mempolicy (2),
>  .BR get_mempolicy (2),
> -.BR mmap (2)
> +.BR mmap (2),
> +.BR set_mempolicy (2),
> +.BR shmat (2),
> +.BR shmget (2),
> +.BR numa (3),
> +.BR numactl (8)
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

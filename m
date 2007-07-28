Message-ID: <46AB0CDB.8090600@gmx.net>
Date: Sat, 28 Jul 2007 11:31:07 +0200
From: Michael Kerrisk <mtk-manpages@gmx.net>
MIME-Version: 1.0
Subject: Re: get_mempolicy.2 man page patch
References: <1180467234.5067.52.camel@localhost>	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost> <46A44B98.8060807@gmx.net>
In-Reply-To: <46A44B98.8060807@gmx.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de, clameter@sgi.com
Cc: Michael Kerrisk <mtk-manpages@gmx.net>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andi, Christoph,

Would one or both of you be willing to review the three man page patches by
 Lee (mbind.2, set_mempolicy.2, get_mempolict.2)?

Cheers,

Michael


Michael Kerrisk wrote:
> Andi, Christoph
> 
> Could you please review these changes by Lee to the get_mempolicy.2 page?
> Patch against man-pages-2.63 (available from
> http://www.kernel.org/pub/linux/docs/manpages).
> 
> Andi/ Christoph / Lee: There are a few points marked FIXME about which I'd
> particularly like some input.
> 
> Cheers,
> 
> Michael
> 
> 
> --- get_mempolicy.2.orig        2007-06-23 09:18:02.000000000 +0200
> +++ get_mempolicy.2     2007-07-21 09:18:46.000000000 +0200
> @@ -1,4 +1,5 @@
>  .\" Copyright 2003,2004 Andi Kleen, SuSE Labs.
> +.\" and Copyright (C) 2007 Lee Schermerhorn <Lee.Schermerhorn@hp.com>
>  .\"
>  .\" Permission is granted to make and distribute verbatim copies of this
>  .\" manual provided the copyright notice and this permission notice are
> @@ -18,19 +19,22 @@
>  .\" the source, must acknowledge the copyright and authors of this work.
>  .\"
>  .\" 2006-02-03, mtk, substantial wording changes and other improvements
> +.\" 2007-06-01, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> +.\"     more precise specification of behavior.
>  .\"
> -.TH GET_MEMPOLICY 2 2006-02-07 "Linux" "Linux Programmer's Manual"
> +.TH GET_MEMPOLICY 2 2007-07-20 Linux "Linux Programmer's Manual"
>  .SH NAME
>  get_mempolicy \- Retrieve NUMA memory policy for a process
>  .SH SYNOPSIS
>  .B "#include <numaif.h>"
>  .nf
>  .sp
> -.BI "int get_mempolicy(int *" policy ", unsigned long *" nodemask ,
> +.BI "int get_mempolicy(int *" mode ", unsigned long *" nodemask ,
>  .BI "                  unsigned long " maxnode ", unsigned long " addr ,
>  .BI "                  unsigned long " flags );
> +.sp
> +Link with \fI\-lnuma\fP.
>  .fi
> -.\" FIXME rewrite this DESCRIPTION. it is confusing.
>  .SH DESCRIPTION
>  .BR get_mempolicy ()
>  retrieves the NUMA policy of the calling process or of a memory address,
> @@ -39,7 +43,7 @@
> 
>  A NUMA machine has different
>  memory controllers with different distances to specific CPUs.
> -The memory policy defines in which node memory is allocated for
> +The memory policy defines the node on which memory is allocated for
>  the process.
> 
>  If
> @@ -58,58 +62,84 @@
>  address given in
>  .IR addr .
>  This policy may be different from the process's default policy if
> -.BR set_mempolicy (2)
> -has been used to establish a policy for the page containing
> +.\" FIXME Lee changed "set_mempolicy" to "mbind" in the following;
> +.\" is that correct?
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
> +.BR get_mempolicy ()
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
> +specifies the number of node IDs
> +that can be stored into
> +.IR nodemask
> +(i.e.,
> +the maximum node ID plus one).
> +The value specified by
> +.I maxnode
> +is always rounded up to a multiple of
> +.IR "sizeof(unsigned long)" .
> +.\" FIXME: does the preceding sentence mean that if maxnode is (say)
> +.\" 22, then the call could neverthless return node IDs in node mask
> +.\" up to 31 -- e.g., node 26?
> +
> +If
> +.I flags
> +specifies both
> +.B MPOL_F_NODE
> +and
> +.BR MPOL_F_ADDR ,
> +.BR get_mempolicy ()
> +will return the node ID of the node on which the address
> +.I addr
> +is allocated.
> +The node ID is returned in the location pointed to by
> +.IR mode .
> +If no page has yet been allocated for the specified address,
> +.BR get_mempolicy ()
> +will allocate a page as if the process had performed a read
> +[load] access at that address, and return the ID of the node
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
> +.BR get_mempolicy ()
> +will return in the location pointed to by a non-NULL
> +.I mode
> +argument,
> +the node ID of the next node that will be used for
> +interleaving of internal kernel pages allocated on behalf
> +of the process.
> +.\" Note:  code returns next interleave node via 'mode'
> +.\" argument -- Lee Schermerhorn
> +These allocations include pages for memory mapped files in
> +process memory ranges mapped using the
> +.IR mmap (2)
> +call with the
> +.B MAP_PRIVATE
> +flag for read accesses, and in memory ranges mapped with the
> +.B MAP_SHARED
> +flag for all accesses.
> +
> +Other flag values are reserved.
> 
>  For an overview of the possible policies see
>  .BR set_mempolicy (2).
> @@ -120,49 +150,89 @@
>  on error, \-1 is returned and
>  .I errno
>  is set to indicate the error.
> -.\" .SH ERRORS
> -.\" FIXME -- no errors are listed on this page
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
> -.\" (And there are other
> -.\" .B EINVAL
> -.\" cases.)
> +.SH ERRORS
> +.TP
> +.B EINVAL
> +The value specified by
> +.I maxnode
> +is less than the number of node IDs supported by the system.
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
> +.TP
> +.B EFAULT
> +Part or all of the memory range specified by
> +.I nodemask
> +and
> +.I maxnode
> +points outside your accessible address space.
>  .SH CONFORMING TO
>  This system call is Linux specific.
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
> +If the mode of the process policy or the policy governing allocations
> +at the specified address is
> +.B MPOL_PREFERRED
> +and this policy was installed with an empty
> +.IR nodemask
> +(i.e., specifying local allocation),
> +.BR get_mempolicy ()
> +will return the mask of on-line node IDs, in the location pointed to by
> +a non-NULL
> +.I nodemask
> +argument.
> +This mask does not take into consideration any adminstratively imposed
> +restrictions on the process's context.
> +.\" "context" above refers to cpusets.
> +.\" No man page to reference. -- Lee Schermerhorn
> +.\"
> +.\" FIXME: Andi / Lee -- can you please resolve the following (mtk):
> +.\"
> +.\"  Christoph says the following is untrue.  These are "fully supported."
> +.\"  Andi concedes that he has lost this battle and approves [?]
> +.\"  updating the man pages to document the behavior.  -- Lee Schermerhorn
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
>  .SS "Versions and Library Support"
>  See
>  .BR mbind (2).
> +.SH CONFORMING TO
> +This system call is Linux specific.
>  .SH SEE ALSO
>  .BR mbind (2),
> +.BR mmap (2),
>  .BR set_mempolicy (2),
> -.BR numactl (8),
> -.BR numa (3)
> +.BR numa (3),
> +.BR numactl (8)
> 
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

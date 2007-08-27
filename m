Message-ID: <46D2B5C7.2090001@gmx.net>
Date: Mon, 27 Aug 2007 13:30:15 +0200
From: Michael Kerrisk <mtk-manpages@gmx.net>
MIME-Version: 1.0
Subject: Re: [PATCH] Mempolicy Man Pages 2.64 3/3 - get_mempolicy.2
References: <1180467234.5067.52.camel@localhost>	 <Pine.LNX.4.64.0705291247001.26308@schroedinger.engr.sgi.com>	 <200705292216.31102.ak@suse.de> <1180541849.5850.30.camel@localhost>	 <20070531082016.19080@gmx.net> <1180732544.5278.158.camel@localhost>	 <46A44B98.8060807@gmx.net> <46AB0CDB.8090600@gmx.net>	 <20070816200520.GB16680@bingen.suse.de>  <20070818055026.265030@gmx.net>	 <1187711147.5066.13.camel@localhost>  <20070822041050.158210@gmx.net> <1187799145.5166.18.camel@localhost>
In-Reply-To: <1187799145.5166.18.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: clameter@sgi.com, akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

Applied for man-pages-2.65.

Thanks Lee!

Cheers,

Michael

Lee Schermerhorn wrote:
> [PATCH]  Mempolicy Man Pages 2.64 3/3 - get_mempolicy.2
> 
> Against:  man pages 2.64
> 
> Changes:
> 
> + changed the "policy" parameter to "mode" through out the
>   descriptions in an attempt to promote the concept that the memory
>   policy is a tuple consisting of a mode and optional set of nodes.
> 
> + added requirement to link '-lnuma' to synopsis
> 
> + rewrite portions of description for clarification.
> 
> + added all errors currently returned by sys call.
> 
> + removed cautionary note that use of MPOL_F_NODE|MPOL_F_ADDR
>   is not supported.  This is no longer true.
> 
> + added mmap(2) to See Also list.
> 
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
> 
> Index: Linux/man2/get_mempolicy.2
> ===================================================================
> --- Linux.orig/man2/get_mempolicy.2	2007-06-22 14:25:23.000000000 -0400
> +++ Linux/man2/get_mempolicy.2	2007-08-10 12:33:23.000000000 -0400
> @@ -18,6 +18,7 @@
>  .\" the source, must acknowledge the copyright and authors of this work.
>  .\"
>  .\" 2006-02-03, mtk, substantial wording changes and other improvements
> +.\" 2007-06-01, lts, more precise specification of behavior.
>  .\"
>  .TH GET_MEMPOLICY 2 2006-02-07 "Linux" "Linux Programmer's Manual"
>  .SH NAME
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
>  .\" FIXME rewrite this DESCRIPTION. it is confusing.
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
> @@ -120,49 +140,84 @@ returns 0;
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
> -.SH CONFORMING TO
> -This system call is Linux specific.
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
> +.\" FIXME:
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
>  .SS "Versions and Library Support"
>  See
>  .BR mbind (2).
>  .SH SEE ALSO
>  .BR mbind (2),
> +.BR mmap (2),
>  .BR set_mempolicy (2),
>  .BR numactl (8),
>  .BR numa (3)
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

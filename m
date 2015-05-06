Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 2DBBF6B006E
	for <linux-mm@kvack.org>; Wed,  6 May 2015 08:32:07 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so9860800wgy.2
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:32:06 -0700 (PDT)
Received: from mail-wi0-x229.google.com (mail-wi0-x229.google.com. [2a00:1450:400c:c05::229])
        by mx.google.com with ESMTPS id op3si1992978wic.73.2015.05.06.05.32.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 May 2015 05:32:05 -0700 (PDT)
Received: by widdi4 with SMTP id di4so20454779wid.0
        for <linux-mm@kvack.org>; Wed, 06 May 2015 05:32:05 -0700 (PDT)
Message-ID: <554A09BE.7030800@gmail.com>
Date: Wed, 06 May 2015 14:31:58 +0200
From: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH] set/get_mempolicy.2: policy is per thread, not per process
References: <5542046D.5060703@inria.fr>
In-Reply-To: <5542046D.5060703@inria.fr>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Brice Goglin <Brice.Goglin@inria.fr>, mtk.manpages@gmail.com, Linux Memory Management List <linux-mm@kvack.org>

Hi Andi,

Brice's patch seems broadly okay to me, but you originally wrote the
pages, so I'd be happy if you could comment. Could you take a look please?

Cheers,

Michael


On 04/30/2015 12:31 PM, Brice Goglin wrote:
> Hello,
> 
> set/get_mempolicy manpages say that the memory allocation policy is
> per process while reading the code and testing shows that it's actually
> per thread.
> Here's a quick fix, which may need to be improved to better explain that we're
> allocating in the context of a thread within a process address space.
> 
> Brice
>  
> 
> 
> 
> 
> 
> set/get_mempolicy.2: policy is per thread, not per process
> 
> Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
> 
> diff --git a/man2/get_mempolicy.2 b/man2/get_mempolicy.2
> index a17c0f3..c0e9639 100644
> --- a/man2/get_mempolicy.2
> +++ b/man2/get_mempolicy.2
> @@ -26,7 +26,7 @@
>  .\"
>  .TH GET_MEMPOLICY 2 2008-08-15 Linux "Linux Programmer's Manual"
>  .SH NAME
> -get_mempolicy \- retrieve NUMA memory policy for a process
> +get_mempolicy \- retrieve NUMA memory policy for a thread
>  .SH SYNOPSIS
>  .B "#include <numaif.h>"
>  .nf
> @@ -39,19 +39,19 @@ Link with \fI\-lnuma\fP.
>  .fi
>  .SH DESCRIPTION
>  .BR get_mempolicy ()
> -retrieves the NUMA policy of the calling process or of a memory address,
> +retrieves the NUMA policy of the calling thread or of a memory address,
>  depending on the setting of
>  .IR flags .
>  
>  A NUMA machine has different
>  memory controllers with different distances to specific CPUs.
>  The memory policy defines from which node memory is allocated for
> -the process.
> +the thread.
>  
>  If
>  .I flags
>  is specified as 0,
> -then information about the calling process's default policy
> +then information about the calling thread's default policy
>  (as set by
>  .BR set_mempolicy (2))
>  is returned.
> @@ -59,7 +59,7 @@ The policy returned
>  .RI [ mode
>  and
>  .IR nodemask ]
> -may be used to restore the process's policy to its state at
> +may be used to restore the thread's policy to its state at
>  the time of the call to
>  .BR get_mempolicy ()
>  using
> @@ -72,7 +72,7 @@ specifies
>  (available since Linux 2.6.24), the
>  .I mode
>  argument is ignored and the set of nodes [memories] that the
> -process is allowed to specify in subsequent calls to
> +thread is allowed to specify in subsequent calls to
>  .BR mbind (2)
>  or
>  .BR set_mempolicy (2)
> @@ -94,7 +94,7 @@ specifies
>  then information is returned about the policy governing the memory
>  address given in
>  .IR addr .
> -This policy may be different from the process's default policy if
> +This policy may be different from the thread's default policy if
>  .BR mbind (2)
>  or one of the helper functions described in
>  .BR numa (3)
> @@ -135,7 +135,7 @@ is allocated into the location pointed to by
>  .IR mode .
>  If no page has yet been allocated for the specified address,
>  .BR get_mempolicy ()
> -will allocate a page as if the process had performed a read
> +will allocate a page as if the thread had performed a read
>  [load] access to that address, and return the ID of the node
>  where that page was allocated.
>  
> @@ -145,7 +145,7 @@ specifies
>  .BR MPOL_F_NODE ,
>  but not
>  .BR MPOL_F_ADDR ,
> -and the process's current policy is
> +and the thread's current policy is
>  .BR MPOL_INTERLEAVE ,
>  then
>  .BR get_mempolicy ()
> @@ -153,7 +153,7 @@ will return in the location pointed to by a non-NULL
>  .I mode
>  argument,
>  the node ID of the next node that will be used for
> -interleaving of internal kernel pages allocated on behalf of the process.
> +interleaving of internal kernel pages allocated on behalf of the thread.
>  .\" Note:  code returns next interleave node via 'mode' argument -Lee Schermerhorn
>  These allocations include pages for memory-mapped files in
>  process memory ranges mapped using the
> @@ -214,7 +214,7 @@ specified
>  .B MPOL_F_NODE
>  but not
>  .B MPOL_F_ADDR
> -and the current process policy is not
> +and the current thread policy is not
>  .BR MPOL_INTERLEAVE .
>  Or,
>  .I flags
> diff --git a/man2/set_mempolicy.2 b/man2/set_mempolicy.2
> index 9d7d1de..f5169da 100644
> --- a/man2/set_mempolicy.2
> +++ b/man2/set_mempolicy.2
> @@ -26,7 +26,7 @@
>  .\"
>  .TH SET_MEMPOLICY 2 2014-05-28 Linux "Linux Programmer's Manual"
>  .SH NAME
> -set_mempolicy \- set default NUMA memory policy for a process and its children
> +set_mempolicy \- set default NUMA memory policy for a thread and its children
>  .SH SYNOPSIS
>  .nf
>  .B "#include <numaif.h>"
> @@ -38,7 +38,7 @@ Link with \fI\-lnuma\fP.
>  .fi
>  .SH DESCRIPTION
>  .BR set_mempolicy ()
> -sets the NUMA memory policy of the calling process,
> +sets the NUMA memory policy of the calling thread,
>  which consists of a policy mode and zero or more nodes,
>  to the values specified by the
>  .IR mode ,
> @@ -50,28 +50,28 @@ arguments.
>  A NUMA machine has different
>  memory controllers with different distances to specific CPUs.
>  The memory policy defines from which node memory is allocated for
> -the process.
> +the thread.
>  
> -This system call defines the default policy for the process.
> -The process policy governs allocation of pages in the process's
> +This system call defines the default policy for the thread.
> +The thread policy governs allocation of pages in the process's
>  address space outside of memory ranges
>  controlled by a more specific policy set by
>  .BR mbind (2).
> -The process default policy also controls allocation of any pages for
> +The thread default policy also controls allocation of any pages for
>  memory-mapped files mapped using the
>  .BR mmap (2)
>  call with the
>  .B MAP_PRIVATE
> -flag and that are only read [loaded] from by the process
> +flag and that are only read [loaded] from by the thread
>  and of memory-mapped files mapped using the
>  .BR mmap (2)
>  call with the
>  .B MAP_SHARED
>  flag, regardless of the access type.
>  The policy is applied only when a new page is allocated
> -for the process.
> +for the thread.
>  For anonymous memory this is when the page is first
> -touched by the application.
> +touched by the thread.
>  
>  The
>  .I mode
> @@ -154,7 +154,7 @@ cpuset context includes one or more of the nodes specified by
>  
>  The
>  .B MPOL_DEFAULT
> -mode specifies that any nondefault process memory policy be removed,
> +mode specifies that any nondefault thread memory policy be removed,
>  so that the memory policy "falls back" to the system default policy.
>  The system default policy is "local allocation"\(emthat is,
>  allocate memory on the node of the CPU that triggered the allocation.
> @@ -211,9 +211,9 @@ arguments specify the empty set, then the policy
>  specifies "local allocation"
>  (like the system default policy discussed above).
>  
> -The process memory policy is preserved across an
> +The thread memory policy is preserved across an
>  .BR execve (2),
> -and is inherited by child processes created using
> +and is inherited by child threads created using
>  .BR fork (2)
>  or
>  .BR clone (2).
> @@ -279,9 +279,9 @@ system call was added to the Linux kernel in version 2.6.7.
>  .SH CONFORMING TO
>  This system call is Linux-specific.
>  .SH NOTES
> -Process policy is not remembered if the page is swapped out.
> +Memory policy is not remembered if the page is swapped out.
>  When such a page is paged back in, it will use the policy of
> -the process or memory range that is in effect at the time the
> +the thread or memory range that is in effect at the time the
>  page is allocated.
>  
>  For information on library support, see
> 
> 


-- 
Michael Kerrisk
Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
Linux/UNIX System Programming Training: http://man7.org/training/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

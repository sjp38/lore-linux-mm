Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id E35716B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 13:20:05 -0400 (EDT)
Date: Fri, 7 Oct 2011 10:19:58 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: [Xen-devel] Re: RFC -- new zone type
Message-ID: <20111007171958.GG7007@labbmf-linux.qualcomm.com>
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default20111005165643.GE7007@labbmf-linux.qualcomm.com>
 <cc1256f9-4808-4d74-a321-6a3ec129cc05@default20111006230348.GF7007@labbmf-linux.qualcomm.com>
 <4d0a5da4-00de-40dd-8d75-8ed6e3d0831c@default>
 <4E8F2242.3030406@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E8F2242.3030406@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, Xen-devel@lists.xensource.com

On 07 Oct 11 11:01, Seth Jennings wrote:
> On 10/07/2011 10:23 AM, Dan Magenheimer wrote:
> >> From: Larry Bassel [mailto:lbassel@codeaurora.org]
> >> Sent: Thursday, October 06, 2011 5:04 PM
> >> To: Dan Magenheimer
> >> Cc: Larry Bassel; linux-mm@kvack.org; Xen-devel@lists.xensource.com
> >> Subject: Re: [Xen-devel] Re: RFC -- new zone type
> >>
> >> Thanks for your answers to my questions. I have one more:
> >>
> >> Will there be any problem if the memory I want to be
> >> transcendent is highmem (i.e. doesn't have any permanent
> >> virtual<->physical mapping)?
> 
> I guess I need to make the distinction between tmem, the transcendent
> memory layer, and zcache, a tmem backend that does the compression
> and storage work.  Tmem is highmem agnostic.  It's just passing the
> page information through to the backend, zcache.

I'm sorry if my question was ambiguous -- I want to use the
"cleancache" concept to allow us to have a large (> 100M) piece
of contiguous physical memory which can either be used as
such or otherwise used as a cleancache for discardable pages.
It is this memory that I'm asking if it can be highmem.
> 
> Zcache can store data stored in highmem pages (after the patch that Dan
> referred to), but can't use highmem pages in it's own storage pools.  Both
> zbud (storage for compressed ephemeral pages) and xvmalloc (storage for
> compressed persistent pages) don't set __GFP_HIGHMEM in their page
> allocation calls because they return the virtual address of the page to
> zcache.  Since highmem pages have no virtual address expect for the short
> time they are mapped, this prevents highmem pages from being used by zbud
> and xvmalloc.

As this area must be very large and contiguous, I can't use kmalloc or similar
allocation APIs -- I imagine I'll carve it out early in boot with
memblock_remove() -- luckily this area is of fixed size. If this memory
were in ZONE_HIGHMEM, I'd just have to use kmap to get a temporary mapping
to use when the page is copied to or from "normal" system memory (or am
I missing something here?). Whether this area is in highmem or not, I imagine
I'll need to write an allocator to allocate/free pages from the "dual-purpose"
memory when it is cleancache.

> 
> I did write a patch a while back that allows xvmalloc to use highmem
> pages in it's storage pool.  Although, from looking at the history of this
> conversation, you'd be writing a different backend for tmem and not using
> zcache anyway.

We're going to want a backend which is (at least to a
first approximation) a simplification of zcache
-- no compression and no frontswap is needed.
Possibly we'll start with zcache and remove things we don't need.
> 
> Currently the tmem code is in the zcache driver.  However, if there are
> going to be other backends designed for it, we may need to move it into its
> own module so it can be shared.
> 
> --
> Seth
> 

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and ignore cpuset/memory policy restrictions.
Date: Fri, 11 Aug 2006 14:41:34 -0500
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0608111112000.18296@schroedinger.engr.sgi.com> <20060811114243.49fa4390.akpm@osdl.org>
In-Reply-To: <20060811114243.49fa4390.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit
Content-Disposition: inline
Message-Id: <200608111441.34648.dmccr@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 11 August 2006 1:42 pm, Andrew Morton wrote:
> How about we do
>
> /*
>  * We do this to avoid lots of ifdefs and their consequential conditional
>  * compilation
>  */
> #ifdef CONFIG_NUMA
> #define NUMA_BUILD 1
> #else
> #define NUMA_BUILD 0
> #endif
>
> Then we can do
>
> --- a/mm/page_alloc.c~a
> +++ a/mm/page_alloc.c
> @@ -903,7 +903,7 @@ get_page_from_freelist(gfp_t gfp_mask, u
>          */
>         do {
>                 zone = *z;
> -               if (unlikely((gfp_mask & __GFP_THISNODE) &&
> +               if (NUMA_BUILD && unlikely((gfp_mask & __GFP_THISNODE) &&
>                         zone->zone_pgdat !=
> zonelist->zones[0]->zone_pgdat)) break;
>                 if ((alloc_flags & ALLOC_CPUSET) &&
> _

Wouldn't you get a similar effect by doing

#ifdef CONFIG_NUMA
#define	gfp_thisnode(__mask)		((__mask) & __GFP_THISNODE)
#else
#define	gfp_thisnode(__mask)		(0)

Or are there too many different ways this is used to make a macro practical?  
What am I missing here?

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

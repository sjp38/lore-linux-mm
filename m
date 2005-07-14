Date: Thu, 14 Jul 2005 04:06:13 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [Fwd: [PATCH 2/4] cpusets new __GFP_HARDWALL flag]
Message-Id: <20050714040613.10b244ee.pj@sgi.com>
In-Reply-To: <Pine.LNX.4.58.0507130815420.1174@skynet>
References: <1121101013.15095.19.camel@localhost>
	<42D2AE0F.8020809@austin.ibm.com>
	<20050711195540.681182d0.pj@sgi.com>
	<Pine.LNX.4.58.0507121353470.32323@skynet>
	<20050712132940.148a9490.pj@sgi.com>
	<Pine.LNX.4.58.0507130815420.1174@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: jschopp@austin.ibm.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel wrote:
> Well, what would people feel is obvious?

The lines that you (Mel) add that I am puzzling over ways to clarify are
these added lines in gfp.h:

    +#define __GFP_KERNRCLM  0x20000u  /* Kernel page that is easily reclaimable */
    +#define __GFP_USERRCLM  0x40000u  /* User is a userspace user */

    +#define __GFP_TYPE_SHIFT 17     /* Translate RCLM flags to array index */

and perhaps these added lines in mmzone.h:

    +/* Page allocations are divided into these types */
    +#define ALLOC_TYPES 4
    +#define ALLOC_KERNNORCLM 0
    +#define ALLOC_KERNRCLM 1
    +#define ALLOC_USERRCLM 2
    +#define ALLOC_FALLBACK 3
    +
    +/* Number of bits required to encode the type */
    +#define BITS_PER_ALLOC_TYPE 2

It didn't jump out at me, first pass, that these two GFP bits
were a 2 bit field, not 2 separate and independent bits.  The name
GFP_TYPE_SHIFT is vague.  There are some redundant (interdependent)
defines here.

How about (just brainstorming here) something like the following:

    #define __GFP_RCLM_BITS 0x60000u	/* page reclaim types: see RCLM_* defines */

    /*
     * Reduce buddy heap fragmentation by keeping pages with similar
     * reclaimability behavior together.  The two bit field __GFP_RECLAIMBITS
     * enumerates the following 4 kinds of page reclaimability:
     */
    #define RCLM_NONRECLAIMABLE 0	/* nonreclaimable kernel pages */
    #define RCLM_KERNEL 1		/* reclaimable kernel pages */
    #define RCLM_USER 2			/* reclaimable user pages */
    #define RCLM_FALLBACK 3		/* mark alloc requests when memory low */

    #define RCLM_SHIFT 17		/* Shift __GFP_RECLAIMBITS to RCLM_* values */

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

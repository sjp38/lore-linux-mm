Message-ID: <428C6FB9.4060602@shadowen.org>
Date: Thu, 19 May 2005 11:51:37 +0100
From: Andy Whitcroft <apw@shadowen.org>
MIME-Version: 1.0
Subject: Re: page flags ?
References: <1116450834.26913.1293.camel@dyn318077bld.beaverton.ibm.com>	<20050518145644.717afc21.akpm@osdl.org>	<1116456143.26913.1303.camel@dyn318077bld.beaverton.ibm.com> <20050518162302.13a13356.akpm@osdl.org>
In-Reply-To: <20050518162302.13a13356.akpm@osdl.org>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> Anything's possible ;)
> 
> How many bits are spare now?  ZONETABLE_PGSHIFT hurts my brain.

The short answer is that on 32 bit architectures there are 24 bits
allocated to general page flags, page-flags.h indicates that 21 are
currently assigned so assuming it is accurate there are currently 3 bits
free.

Perhaps this my cue to chip in and provide some commentry on the
zonetable patches.

Before the zonetable patches the flags were essentially split into two
sections, the top 8 bits for the NODEZONE 'pointer' and the remaining 24
bits for page flags.  The NODEZONE bits were further subdivided into
NODE and ZONE.  For i386 for instance 2 bits were allocated to ZONE and
6 bits for NODE.  There was no flexibility in layout.

	32           24             0
	| NODE | ZONE | ... | FLAGS |

The zonetable patches came out of the need to add a new field into this
area; the SECTION field for the SPARSEMEM work.  This meant that we
wanted to be able to specify both the size and packing order for these
fields.  This would allow us to specify unused fields as 0 width to
reclaim precious bits.  It would also allow us to optimise order such
that the key performance critical mapping from page to struct zone
pointer was efficient to extract (a single shift).  This key is commonly
NODE,ZONE but may be SECTION,ZONE when short of space, the two fields in
use need to be contigious and preferably at the left.

The zonetable patches work by allowing us to simply define the width of
each field we are using and the order of those fields.  Field widths are
defined by the *_WIDTH definitions, these are either the architecture
specific default width *_SHIFT or 0 where the field is not required (for
instance if not used by the current memory model).  The field order is
defined by the relationships between the *_PGOFF definitions, packing
them from the left of the field.  Access to these fields is via the
*_PGSHIFT and *_MASK defines.  Care is taken to ensure that they are
valid for a zero with field.  The ZONETABLE_PGSHIFT and _MASK define the
combined key field used to locate the struct zone for this page.

Overall the allocation to the NODEZONE area is defined to be the highest
order FLAGS_RESERVED bits of the flags word (8 on 32 bit architectures,
and 32 on 64 bit).  The overall allocation to this field is unchanged.

-apw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

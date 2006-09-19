Date: Mon, 18 Sep 2006 17:08:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] Get rid of zone_table V2
In-Reply-To: <20060918165808.c410d1d4.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0609181701200.30365@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0609181215120.20191@schroedinger.engr.sgi.com>
 <20060918132818.603196e2.akpm@osdl.org> <Pine.LNX.4.64.0609181544420.29365@schroedinger.engr.sgi.com>
 <20060918161528.9714c30c.akpm@osdl.org> <Pine.LNX.4.64.0609181642210.30206@schroedinger.engr.sgi.com>
 <20060918165808.c410d1d4.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 18 Sep 2006, Andrew Morton wrote:

> > We avoid one memory reference for SMP and UP and do an address calculation
> > instead.
> 
> What memory reference do we avoid?  zone_table?

Yes.
 
> In exchange for that we've added an additional deref of page->flags and a
> new read from contig_page_data.

The additional deref of page->flags is the same as before. The compiler 
optimizes that one away. We need to extract two sets of bits from the same
register.

> > NODE_DATA() is constant for the UP and SMP case.
> 
> setenv ARCH i386
> make allnoconfig
> make mm/page_alloc.i
> grep contig_page_data mm/page_alloc.i
> 
> and that's mainline.  Changing page_zone to also read from contig_page_data
> will presumably worsen things.

Hmmm... I have not checked i386 code generation.
But include/linux/mmzone.h has

extern struct pglist_data contig_page_data;
#define NODE_DATA(nid)          (&contig_page_data)

So we should have an address there on SMP/UP.

NODE_DATA(nid0->node_zones == contig_page_data.node_zones

which I thought would still be constant. Then we calculate the address of 
the ith element of node_zones.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

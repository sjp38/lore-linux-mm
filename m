Date: Thu, 15 Feb 2007 21:19:01 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <20070216135714.669701b4.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0702152102580.2290@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <20070215171355.67c7e8b4.akpm@linux-foundation.org> <45D50B79.5080002@mbligh.org>
 <20070215174957.f1fb8711.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151830080.1471@schroedinger.engr.sgi.com>
 <20070215184800.e2820947.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151849030.1511@schroedinger.engr.sgi.com>
 <20070215191858.1a864874.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151929180.1696@schroedinger.engr.sgi.com>
 <20070215194258.a354f428.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0702151945090.1696@schroedinger.engr.sgi.com>
 <45D52F89.5020008@redhat.com> <Pine.LNX.4.64.0702152015110.1696@schroedinger.engr.sgi.com>
 <20070216135714.669701b4.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: riel@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Fri, 16 Feb 2007, KAMEZAWA Hiroyuki wrote:

> > On 64 bit platforms we can add one unsigned long to get from 56 to 64 
> > bytes.
> > 
> 
> I sometimes dreams 
> ==
> struct page {
> 	...
> 	struct zone	*zone;
> 	...
> };
> #define page_zone(page)		(page)->zone
> ==
> but never tried ;)

Hmmm..... Currently we have

static inline struct zone *page_zone(struct page *page)
{
        return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
}

page_to_nid is extracting a piece of the page flags. Then we need to do a 
lookup and find the zonenum (another extract from page flags).

This is not expensive. Look at __pagevec_lru_add. This boils down to (r9 
= struct page * ):

0xa000000100117ef0 <__pagevec_lru_add+80>:      [MMI]       ld8 r33=[r9];;
0xa000000100117ef1 <__pagevec_lru_add+81>:                  ld8 r8=[r33]
0xa000000100117ef2 <__pagevec_lru_add+82>:                  nop.i 0x0;;
0xa000000100117f00 <__pagevec_lru_add+96>:      [MII]       nop.m 0x0
0xa000000100117f01 <__pagevec_lru_add+97>:                  shr.u r3=r8,54;;
0xa000000100117f02 <__pagevec_lru_add+98>:                  nop.i 0x0
0xa000000100117f10 <__pagevec_lru_add+112>:     [MMI]       shladd r14=r3,3,r15;;
0xa000000100117f11 <__pagevec_lru_add+113>:                 ld8 r34=[r14]
0xa000000100117f12 <__pagevec_lru_add+114>:                 nop.i 0x0;;
0xa000000100117f20 <__pagevec_lru_add+128>:     [MIB]       nop.m 0x0
0xa000000100117f21 <__pagevec_lru_add+129>:                 cmp.eq p6,p7=r2,r34

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

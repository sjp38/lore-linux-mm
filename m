Date: Fri, 25 Apr 2008 12:13:19 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 02/18] hugetlb: factor out huge_new_page
In-Reply-To: <20080425165424.GA9680@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0804251210530.5971@schroedinger.engr.sgi.com>
References: <20080423015302.745723000@nick.local0.net>
 <20080423015429.834926000@nick.local0.net> <20080424235431.GB4741@us.ibm.com>
 <20080424235829.GC4741@us.ibm.com> <481183FC.9060408@firstfloor.org>
 <20080425165424.GA9680@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andi Kleen <andi@firstfloor.org>, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On Fri, 25 Apr 2008, Nishanth Aravamudan wrote:

> > >>> This happens to fix a minor bug. When alloc_bootmem_node returns
> > >>> a fallback node on a different node than passed the old code
> > >>> would have put it into the free lists of the wrong node.
> > >>> Now it would end up in the freelist of the correct node.
> > >> This is rather frustrating. The whole point of having the __GFP_THISNODE
> > >> flag is to indicate off-node allocations are *not* supported from the
> > >> caller... This was all worked on quite heavily a while back.
> > 
> > Perhaps it was, but the result in hugetlb.c was not correct.
> 
> Huh? There is a case in current code (current hugepage sizes) that
> allows __GFP_THISNODE to go off-node?

Argh. Danger. SLAB will crash and/or corrupt data if that occurs.

> > No, the bug is already there even without the bootmem patch.
> 
> Where does alloc_pages_node go off-node? It is a bug in the core VM if
> it does, as we decided __GFP_THISNODE semantics with a nid specified
> indicates *no* fallback should occur.

But this is only for bootmem right? SLAB is not using bootmem so we could 
make an exception there. The issue is support of __GFP_THISNODE in the 
bootmem allocator?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

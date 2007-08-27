Date: Mon, 27 Aug 2007 16:48:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 1/1] alloc_pages(): permit get_zeroed_page(GFP_ATOMIC)
 from interrupt context
In-Reply-To: <20070827164050.64af7153.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0708271644001.21218@schroedinger.engr.sgi.com>
References: <200708232107.l7NL7XDt026979@imap1.linux-foundation.org>
 <Pine.LNX.4.64.0708271308380.5457@schroedinger.engr.sgi.com>
 <20070827133347.424f83a6.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271357220.6435@schroedinger.engr.sgi.com>
 <20070827140440.d2109ea5.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271411200.6566@schroedinger.engr.sgi.com>
 <20070827143459.82bdeddd.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271441530.8293@schroedinger.engr.sgi.com>
 <20070827151107.31f18742.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271512390.8783@schroedinger.engr.sgi.com>
 <20070827154558.1c04e77f.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0708271550550.9100@schroedinger.engr.sgi.com>
 <20070827164050.64af7153.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Ingo Molnar <mingo@elte.hu>, thomas.jarosch@intra2net.com
List-ID: <linux-mm.kvack.org>

On Mon, 27 Aug 2007, Andrew Morton wrote:

> > kmap_atomic is a 
> > function to be used in atomic context. I.e. interrupts. Nested by 
> > definition. It is broken as is since it BUG()s on a legitimate nested 
> > call.
> 
> Is it broken?  Dunno.  It's a bit silly to run kmap_atomic() against a page
> which the caller *knows* cannot be a highmem page.

So far we allow running kmap_atomic against a non-highmem page and 
kmap_atomic contains code to deal with that case.

> > Would that not mean leaving kmap_atomic broken on i386? Before Ingo's 
> > commit things were fine. Revert the commit and there is no need 
> > to change core code.
> 
> If we revert the commit we lose a bit of debug support.
> 
> We could move the assert to after we've checked for PageHighmem, but then
> we'd fail to detect a bug if the nested caller happened to get a lowmem
> page for a __GFP_HIGHMEM allocation.

We will ultimately detect it if he gets that type of page. Like many 
other checks in the code it may only trigger sometimes. Reverting 
656dad312fb41ed95ef08325e9df9bece3aacbbb will get us to a known good 
situation that also triggers the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

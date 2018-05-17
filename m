Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D07876B04FC
	for <linux-mm@kvack.org>; Thu, 17 May 2018 11:23:37 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id z1-v6so2912433pfh.3
        for <linux-mm@kvack.org>; Thu, 17 May 2018 08:23:37 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v15-v6si3970430pgq.292.2018.05.17.08.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 17 May 2018 08:23:35 -0700 (PDT)
Date: Thu, 17 May 2018 08:23:34 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC] mm, THP: Map read-only text segments using large THP pages
Message-ID: <20180517152333.GA26718@bombadil.infradead.org>
References: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, May 14, 2018 at 07:12:13AM -0600, William Kucharski wrote:
> One of the downsides of THP as currently implemented is that it only supports
> large page mappings for anonymous pages.

It does also support shmem.

> I embarked upon this prototype on the theory that it would be advantageous to 
> be able to map large ranges of read-only text pages using THP as well.

I'm certain it is.  The other thing I believe is true that we should be
able to share page tables (my motivation is thousands of processes each
mapping the same ridiculously-sized file).  I was hoping this prototype
would have code that would be stealable for that purpose, but you've
gone in a different direction.  Which is fine for a prototype; you've
produced useful numbers.

> As currently implemented for test purposes, the prototype will only use large 
> pages to map an executable with a particular filename ("testr"), enabling easy 
> comparison of the same executable using 4K and 2M (x64) pages on the same 
> kernel. It is understood that this is just a proof of concept implementation 
> and much more work regarding enabling the feature and overall system usage of 
> it would need to be done before it was submitted as a kernel patch. However, I 
> felt it would be worthy to send it out as an RFC so I can find out whether 
> there are huge objections from the community to doing this at all, or a better 
> understanding of the major concerns that must be assuaged before it would even 
> be considered. I currently hardcode CONFIG_TRANSPARENT_HUGEPAGE to the 
> equivalent of "always" and bypass some checks for anonymous pages by simply 
> #ifdefing the code out; obviously I would need to determine the right thing to 
> do in those cases.

Understood that it's completely inappropriate for merging as it stands ;-)

I think the first step is to get variable sized pages in the page cache
working.  Then the map-around functionality can probably just notice if
they're big enough to map with a PMD and make that happen.  I don't immediately
see anything from this PoC that can be used, but it at least gives us a
good point of comparison for any future work.

> 4K Pages:
> =========
> 
>   180,990,026,447      dTLB-loads:u              #  589.440 M/sec                    ( +-  0.00% )  (30.77%)
>           707,373      dTLB-load-misses:u        #    0.00% of all dTLB cache hits   ( +-  4.62% )  (30.77%)
>         5,583,675      iTLB-loads:u              #    0.018 M/sec                    ( +-  0.31% )  (30.77%)
>     1,219,514,499      iTLB-load-misses:u        # 21840.71% of all iTLB cache hits  ( +-  0.01% )  (30.77%)
> 
> 307.093088771 seconds time elapsed                                          ( +-  0.20% )
> 
> 2M Pages:
> =========
> 
>   180,987,794,366      dTLB-loads:u              #  625.165 M/sec                    ( +-  0.00% )  (30.77%)
>               835      dTLB-load-misses:u        #    0.00% of all dTLB cache hits   ( +- 14.35% )  (30.77%)
>         6,386,207      iTLB-loads:u              #    0.022 M/sec                    ( +-  0.42% )  (30.77%)
>        51,929,869      iTLB-load-misses:u        #  813.16% of all iTLB cache hits   ( +-  1.61% )  (30.77%)
> 
> 289.551551387 seconds time elapsed                                          ( +-  0.20% )

I think that really tells the story.  We almost entirely eliminate
dTLB load misses (down to almost 0.1%) and iTLB load misses drop to 4%
of what they were.  Does this test represent any kind of real world load,
or is it designed to show the best possible improvement?

> Q: How about architectures (ARM, for instance) with multiple large page 
>    sizes that are reasonable for text mappings?
> A: At present a "large page" is just PMD size; it would be possible with
>    additional effort to allow for mapping using PUD-sized pages.
> 
> Q: What about the use of non-PMD large page sizes (on non-x86 architectures)?
> A: I haven't looked into that; I don't have an answer as to how to best 
>    map a page that wasn't sized to be a PMD or PUD.

Yes, we really make no effort to support the kind of arbitrary page sizes
supported by IA64 or PA-RISC.  ARM might be interesting; I think you
can mix 64k and 4k pages fairly arbitrarily (judging from the A57 docs).
We don't have any generic interface for inserting TLB entries that are
intermediate in size between a single page and a PMD, so we'll have to
devise something like that.

I can't find any information on what page sizes SPARC supports.
Maybe you could point me at a reference?  All I've managed to find is
the architecture manuals for SPARC which believe it is not their purpose
to mandate an MMU.

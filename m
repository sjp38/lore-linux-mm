Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 361E96B0047
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 07:17:25 -0500 (EST)
Date: Fri, 12 Feb 2010 12:17:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [Bugme-new] [Bug 15214] New: Oops at __rmqueue+0x51/0x2b3
Message-ID: <20100212121709.GC5707@csn.ul.ie>
References: <bug-15214-10286@http.bugzilla.kernel.org/> <20100208111852.a0ada2b4.akpm@linux-foundation.org> <20100209144537.GA5098@csn.ul.ie> <201002101217.34131.ajlill@ajlc.waterloo.on.ca> <20100211182031.GA5707@csn.ul.ie> <alpine.LFD.2.00.1002111038070.7792@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1002111038070.7792@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tony Lill <ajlill@ajlc.waterloo.on.ca>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, bugme-daemon@bugzilla.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 11, 2010 at 10:49:44AM -0800, Linus Torvalds wrote:
> 
> 
> On Thu, 11 Feb 2010, Mel Gorman wrote:
> > 
> > Tony posted the assember files (KCFLAGS=-save-temps) from
> > the broken and working compilers which a copy of is available at
> > http://www.csn.ul.ie/~mel/postings/bug-20100211/ . Have you any suggestions
> > on what the best way to go about finding where the badly generated code
> > might be so a warning can be added for gcc 4.1?  My strongest suspicion is
> > that the problem is in the assembler that looks up the struct page from a
> > PFN in sparsemem but I'm failing to prove it.
> 
> Try contacting the gcc people. They are (well, _some_ of them are) much 
> more used to walking through asm differences, and may have more of a clue 
> about where the difference is likely to be for those compiler versions.
> 

Ok, thanks. Will get on to them if the other suggestions don't work out.

> I'm personally very comfortable with x86 assembly, but having tried to 
> find compiler bugs in the past I can also say that despite my x86 comfort 
> I've almost always failed. The trivial stupid differences tend to always 
> just totally overwhelm the actual real difference that causes the bug.
> 

I don't feel quite as bad then. I was hoping it would be "obvious" but
was getting tripped up by reordering and slightly-different ways of
achieving the same end result.

> One thing to try is to see if the buggy compiler version can be itself 
> triggered to create a non-buggy asm listing by using some compiler flag. 
> That way the "trivial differences" tend to be smaller, and the bug stands 
> out more.
> 
> For example, that's how we found the problem with "-fwrapv" - testing the 
> same compiler version with different flags (see commit a137802ee83).
> 

The compiler of interest is still available so I should be able to reproduce
the problem locally once I get an old distro installed.

> Sometimes if the trivial differences are mostly register allocation, you 
> can get a "feel" for the differences by replacing all register names with 
> just the string "REG" (and "[0-9x](%e[sb]p)" with "STACKSLOT", and try to 
> do the diff that way. If everything else is roughly the same, you then see 
> the place where the code is _really_ different.
> 

Will try this first, then installing and old distro before resorting to
the gcc people. There is a good chance their response will be "go away"
once they realise it'd fixed in later compilers.

> But when the compiler actually re-orders basic blocks etc, then diffs are 
> basically impossible to get anything sane out of.
> 

Thanks for the suggestions.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

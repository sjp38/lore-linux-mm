Received: by zproxy.gmail.com with SMTP id k1so321610nzf
        for <linux-mm@kvack.org>; Thu, 13 Oct 2005 01:00:32 -0700 (PDT)
Message-ID: <aec7e5c30510130100w296a7290ya7d7124eb54671ad@mail.gmail.com>
Date: Thu, 13 Oct 2005 17:00:32 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: Benchmarks to exploit LRU deficiencies
In-Reply-To: <Pine.LNX.4.62.0510110820070.897@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <20051010184636.GA15415@logos.cnet> <200510110213.29937.ak@suse.de>
	 <Pine.LNX.4.62.0510110820070.897@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: Andi Kleen <ak@suse.de>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, linux-mm@kvack.org, sjiang@lanl.gov, rni@andrew.cmu.edu, a.p.zijlstra@chello.nl, riel@redhat.com
List-ID: <linux-mm.kvack.org>

On 10/12/05, Christoph Lameter <clameter@engr.sgi.com> wrote:
> On Tue, 11 Oct 2005, Andi Kleen wrote:
>
> > I think if you want to really see advantages you should not implement
> > the advanced algorithms for the page cache, but for the inode/dentry
> > cache. We seem to have far more problems in this area than with the
> > standard page cache.
>
> We have had significant problems with the page cache for a long time.
> Systems slow down because node memory is filled up with page cache
> pages that are not properly reclaimed and thus off node allocation
> occurs. The current method of freeing memory requires a scan which
> makes this whole thing painfully slow. There are special hacks in SLES9 to
> deal with these issues.
>
> Moreover the LRU algorithm leads to the eviction of important pages if a
> program does a simple scan of a large file.
>
> I hope that the advanced page replacement methods address some of these
> problems.

I think it would be interesting to separate the handling of mapped
pages from unmapped ones. The reason for this separation is the
difference how the working set is estimated:

Mapped pages:  young-bits in pte:s + mark_page_accessed().
Unmapped pages: mark_page_accessed() only.

Mapped pages needs to be scanned through to determine the working set
(and young-bits needs to be cleared), but unmapped working set
estimation could be handled directly by mark_page_accessed(), removing
the need to scan unmapped pages.

Another advantage of this separation IMO would be that it is easier to
build fine-grained memory resource control on top of it, where a
per-CPUSET (or CKRM class) guarantee and limit could be implemented
both for unmapped pages and mapped pte:s.

Other interesting areas are better mapped working set estimation
through periodical pte scanning and pte ageing, but I'm sure these
topics have been rejected before...

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

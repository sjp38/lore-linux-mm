Date: Wed, 13 Feb 2008 12:33:22 -0600
From: Paul Jackson <pj@sgi.com>
Subject: Re: SLUB tbench regression due to page allocator deficiency
Message-Id: <20080213123322.e1c202e6.pj@sgi.com>
In-Reply-To: <20080211235607.GA27320@wotan.suse.de>
References: <Pine.LNX.4.64.0802091332450.12965@schroedinger.engr.sgi.com>
	<20080209143518.ced71a48.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0802091549120.13328@schroedinger.engr.sgi.com>
	<20080210024517.GA32721@wotan.suse.de>
	<Pine.LNX.4.64.0802091938160.14089@schroedinger.engr.sgi.com>
	<20080211071828.GD8717@wotan.suse.de>
	<Pine.LNX.4.64.0802111117440.24379@schroedinger.engr.sgi.com>
	<20080211234029.GB14980@wotan.suse.de>
	<Pine.LNX.4.64.0802111540550.28729@schroedinger.engr.sgi.com>
	<20080211235607.GA27320@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: clameter@sgi.com, akpm@linux-foundation.org, mel@csn.ul.ie, linux-mm@kvack.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

Nick, listing things __alloc_pages() does:
> cpuset -- zone softwall stuff

That should be off the fast path.  So long as there is enough memory
(above watermarks on some node in current->mems_allowed) then there
should be no need to consider the cpuset softwall details.  Notice
that the first invocation of get_page_from_freelist() in __alloc_pages()
has the __GFP_HARDWALL included, bypassing the cpuset software code.

==

Is there someway to get profiling data from __alloc_pages() and
get_page_from_freelist(), for Christoph's test case.  I am imagining
publishing a listing of that code, with a column to the right
indicating how many times each line of code was executed, during the
interesting portion of running such a test case.

That would shine a bright light on any line(s) of code that get
executed way more often than seem necessary for such a load, and enable
the cast of dozens of us who have hacked this code at sometime to
notice opportunities for sucking less.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.940.382.4214

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

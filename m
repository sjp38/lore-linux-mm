Date: Fri, 4 Apr 2003 16:31:54 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-Id: <20030404163154.77f19d9e.akpm@digeo.com>
In-Reply-To: <20030405000352.GF16293@dualathlon.random>
References: <Pine.LNX.4.44.0304041453160.1708-100000@localhost.localdomain>
	<20030404105417.3a8c22cc.akpm@digeo.com>
	<20030404214547.GB16293@dualathlon.random>
	<20030404150744.7e213331.akpm@digeo.com>
	<20030405000352.GF16293@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> the worst part IMHO is that it screwup the vma making the vma->vm_file
> totally wrong for the pages in the vma.

Not sure what you mean here.  All pages in the vma are backed by the file at
vm_file.  It is vm_pgoff which is meaningless.

As for your other concerns: yes, I hear you.  I suspect something will have
to give.  Ingo has a better feel for the problems which this code is solving
and hopefully he can comment.

Perhaps it is useful to itemise the prblems which we're trying to solve here:

- ZONE_NORMAL consumption by pte_chains

  Solved by objrmap and presumably page clustering.

- ZONE_NORMAL consumption by VMAs

  Solved by remap_file_pages.  Neither objrmap nor page clustering will
  help here.

- pte_chain setup and teardown CPU cost.

  objrmap does not seem to help.  Page clustering might, but is unlikely to
  be enabled on the machines which actually care about the overhead.

- get_unmapped_area() search complexity.

  Solved by remap_file_pages and by as-yet unimplemented algorithmic rework.

- pagefault frequency and TLB invalidation cost.

  Solved by MAP_POPULATE, could also be solved by MAP_PREFAULT (but it's
  not really a demonstrated problem).

Anything else?


So looking at the above, remap_file_pages() actually has pretty good
coverage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>

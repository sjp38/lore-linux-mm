Date: Wed, 23 Apr 2003 14:46:48 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.68-mm2
Message-Id: <20030423144648.5ce68d11.akpm@digeo.com>
In-Reply-To: <18400000.1051109459@[10.10.2.4]>
References: <20030423012046.0535e4fd.akpm@digeo.com>
	<18400000.1051109459@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> > . I got tired of the objrmap code going BUG under stress, so it is now in
> >   disgrace in the experimental/ directory.
> 
> Any chance of some more info on that? BUG at what point in the code,
> and with what test to reproduce?

A bash-shared-mapping (from ext3 CVS) will quickly knock it over.  It gets
its PageAnon/page->mapping state tangled up.

Must confess that I have trouble getting excited over objrmap.  It introduces

- inconsistency (pte_chains versus vma-list scanning)

- code complexity

- a quadratic search

- nasty, nasty problems with remap_file_pages().  I'd rather not have to
  nobble remap_file_pages() functionality for this reason.

and what do we gain from it all?  The small fork/exec boost isn't very
significant.  What we gain is more lowmem space on
going-away-real-soon-now-we-sincerely-hope highmem boxes.

Ingo-rmap seems a better solution to me.  It would be a fairly large change
though - we'd have to hold the four atomic kmaps across an entire pte page
in copy_page_range(), for example.  But it will then have good locality of
reference between adjacent pages and may well be quicker than pte_chains.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

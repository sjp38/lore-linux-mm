Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id E0D046B0292
	for <linux-mm@kvack.org>; Tue,  4 May 2010 10:45:26 -0400 (EDT)
Date: Tue, 4 May 2010 16:44:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/2] mm,migration: Avoid race between shift_arg_pages()
 and rmap_walk() during migration by not migrating temporary stacks
Message-ID: <20100504144453.GP19891@random.random>
References: <1272529930-29505-1-git-send-email-mel@csn.ul.ie>
 <1272529930-29505-3-git-send-email-mel@csn.ul.ie>
 <20100429162120.GC22108@random.random>
 <20100504103213.GB20979@csn.ul.ie>
 <20100504125606.GK19891@random.random>
 <20100504143311.GI20979@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100504143311.GI20979@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 04, 2010 at 03:33:11PM +0100, Mel Gorman wrote:
> I'm currently testing this and have seen no problems after an hour which
> is typically good. To be absolutly sure, it needs 24 hours but so far so
> good. The changelog is a tad on the light side so maybe you'd like to take
> this one instead and edit it to your liking?

I'll take your changelog for aa.git thanks! And the non trivial stuff
was documented in the code too.

So now in aa.git I've two branches, master -> old-anon_vma,
anon_vma_chain -> new-anon_vma.

anon_vma_chain starts with Rik's patch 1/2 and then this
patch. old-anon_vma starts with backout-anon-vma and then this patch 2
backported to old anon-vma code. After the removal of all
vma->anon_vma->lock usages from THP code, and switching to a slower
get_page() spin_unlock(page_table_lock) page_lock_anon_vma(page)
model, the anon_vma_chain branch has a chance to be as solid as the
master branch. anon_vma_chain branch can be pulled from mainline
branches too. The master branch is also not using anymore any
vma->anon_vma->lock even if it still could and it'd be a bit faster,
to give more testing to the anon_vma_chain code.

You can see the difference with "git diff master anon_vma_chain".

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=summary
http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog;h=refs/heads/anon_vma_chain

This should be THP-23 and THP-23-anon_vma_chain tags, I'll do proper
release soon.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

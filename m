Date: Tue, 13 May 2003 15:06:26 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] Fix for latent bug in vmtruncate()
Message-ID: <20030513220626.GA29926@holomorphy.com>
References: <20030513135807.E2929@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030513135807.E2929@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Paul E. McKenney" <paulmck@us.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@digeo.com, mjbligh@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, May 13, 2003 at 01:58:07PM -0700, Paul E. McKenney wrote:
> The vmtruncate() function shifts down by PAGE_CACHE_SHIFT, then
> calls vmtruncate_list(), which deals in terms of PAGE_SHIFT
> instead.  Currently, no harm done, since PAGE_CACHE_SHIFT and
> PAGE_SHIFT are identical.  Some day they might not be, hence
> this patch.
> I also took the liberty of modifying a hand-coded "if" that
> seems to optimize for files that are not mapped to instead
> use unlikely().

pgoff describes a file offset in the same units used to map files
with (the size of an area covered by a PTE), which is PAGE_SIZE (in
mainline; elsewhere it's called MMUPAGE_SIZE and I had to fix this
already for my tree). When they differ this would lose the offset into
the PAGE_CACHE_SIZE-sized file page; hence, well-spotted.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

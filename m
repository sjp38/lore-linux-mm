Date: Thu, 21 Oct 2004 16:02:33 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] zap_pte_range should not mark non-uptodate pages dirty
Message-Id: <20041021160233.68a84971.akpm@osdl.org>
In-Reply-To: <20041021223613.GA8756@dualathlon.random>
References: <1098393346.7157.112.camel@localhost>
	<20041021144531.22dd0d54.akpm@osdl.org>
	<20041021223613.GA8756@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@novell.com>
Cc: shaggy@austin.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@novell.com> wrote:
>
> On Thu, Oct 21, 2004 at 02:45:31PM -0700, Andrew Morton wrote:
> > Maybe we should revisit invalidate_inode_pages2().  It used to be an
> > invariant that "pages which are mapped into process address space are
> > always uptodate".  We broke that (good) invariant and we're now seeing
> > some fallout.  There may be more.
> 
> such invariant doesn't exists since 2.4.10. There's no way to get mmaps
> reload data from disk without breaking such an invariant.

There are at least two ways:

a) Set a new page flag in invalidate, test+clear that at fault time

b) shoot down all pte's mapping the locked page at invalidate time, mark the
   page not uptodate.

The latter is complex but has the advantage of fixing the current
half-assed situation wherein existing mmaps are seeing invalidated data.

> It's not even
> for the write side, it's buffered read against O_DIRECT write that
> requires breaking such invariant.
> 
> Either you fix it the above way, or you remove the BUG() in pdflush and
> you simply clear the dirty bit without doing anything, both are fine,
> peraphs we should do both, but the above is good to have anyways since
> it's more efficient to not even show the not uptodate pages to pdflush.

We could just remove the BUG in mpage_writepage() (which I assume is the
one which was being hit) but we might still have a not uptodate page with
uptodate buffers and I suspect that the kernel will either go BUG there
instead or will bring the page uptodate again without performing any I/O. 
But I haven't checked that.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>

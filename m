Date: Tue, 17 Sep 2002 08:01:20 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: dbench on tmpfs OOM's
In-Reply-To: <3D86BE4F.75C9B6CC@digeo.com>
Message-ID: <Pine.LNX.4.44.0209170726050.19523-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 16 Sep 2002, Andrew Morton wrote:
> William Lee Irwin III wrote:
> > 
> > William Lee Irwin III wrote:
> > >> MemTotal:     32107256 kB
> > >> MemFree:      27564648 kB
> > 
> > On Mon, Sep 16, 2002 at 09:58:43PM -0700, Andrew Morton wrote:
> > > I'd be suspecting that your node fallback is bust.
> > > Suggest you add a call to show_free_areas() somewhere; consider
> > > exposing the full per-zone status via /proc with a proper patch.
> > 
> > I went through the nodes by hand. It's just a run of the mill
> > ZONE_NORMAL OOM coming out of the GFP_USER allocation. None of
> > the highmem zones were anywhere near ->pages_low.
> > 
> 
> erk.  Why is shmem using GFP_USER?
> 
> mnm:/usr/src/25> grep page_address mm/shmem.c
> mnm:/usr/src/25>

shmem uses GFP_USER for its index pages to GFP_HIGHUSER data pages.

Not to say there aren't other problems in the mix too, but Bill's
main problem here will be one you discovered a while ago, Andrew.
We fixed it then, but in my loopable tmpfs version, and I've been
slow to extract the fixes and push them to mainline (or now -mm),
since there's not much else that suffers than dbench.

The problem is that dbench likes to do large random(?) seeks and
then writes at resulting offset; and although shmem-tmpfs imposes
a cap (default: half of memory) on the data pages, it imposes no
cap on its index pages.  So it foolishly ends up filling normal
zone with empty index blocks for zero-length files, the index
page allocation being done _before_ the data cap check.

I'll rebase the relevant fixes against 2.5.35-mm1 later today,
do a little testing and post the patch.

What I never did was try GFP_HIGHUSER and kmap on the index pages:
I think I decided back then that it wasn't likely to be needed
(sparsely filled file indexes are a rarer case than sparsely filled
pagetables, once the stupidity is fixed; and small files don't use
index pages at all).  But Bill's testing may well prove me wrong.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/

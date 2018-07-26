Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 38FAD6B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 02:53:27 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id z78-v6so267965ywa.23
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 23:53:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r18-v6sor109616ybg.122.2018.07.25.23.53.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 25 Jul 2018 23:53:26 -0700 (PDT)
Date: Wed, 25 Jul 2018 23:53:15 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: kernel BUG at mm/shmem.c:LINE!
In-Reply-To: <alpine.LSU.2.11.1807240121590.1105@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1807252334420.1212@eggly.anvils>
References: <000000000000d624c605705e9010@google.com> <20180709143610.GD2662@bombadil.infradead.org> <alpine.LSU.2.11.1807221856350.5536@eggly.anvils> <20180723140150.GA31843@bombadil.infradead.org> <alpine.LSU.2.11.1807231111310.1698@eggly.anvils>
 <20180723203628.GA18236@bombadil.infradead.org> <alpine.LSU.2.11.1807231531240.2545@eggly.anvils> <20180723225454.GC18236@bombadil.infradead.org> <alpine.LSU.2.11.1807240121590.1105@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Hugh Dickins <hughd@google.com>, syzbot <syzbot+b8e0dfee3fd8c9012771@syzkaller.appspotmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com

On Tue, 24 Jul 2018, Hugh Dickins wrote:
> On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> > On Mon, Jul 23, 2018 at 03:42:22PM -0700, Hugh Dickins wrote:
> > > On Mon, 23 Jul 2018, Matthew Wilcox wrote:
> > > > I figured out a fix and pushed it to the 'ida' branch in
> > > > git://git.infradead.org/users/willy/linux-dax.git
> > > 
> > > Great, thanks a lot for sorting that out so quickly. But I've cloned
> > > the tree and don't see today's patch, so assume you've folded the fix
> > > into an existing commit? If possible, please append the diff of today's
> > > fix to this thread so that we can try it out. Or if that's difficult,
> > > please at least tell which files were modified, then I can probably
> > > work it out from the diff of those files against mmotm.
> > 
> > Sure!  It's just this:
> > 
> > diff --git a/lib/xarray.c b/lib/xarray.c
> > index 32a9c2a6a9e9..383c410997eb 100644
> > --- a/lib/xarray.c
> > +++ b/lib/xarray.c
> > @@ -660,6 +660,8 @@ void xas_create_range(struct xa_state *xas)
> >  	unsigned char sibs = xas->xa_sibs;
> >  
> >  	xas->xa_index |= ((sibs + 1) << shift) - 1;
> > +	if (!xas_top(xas->xa_node) && xas->xa_node->shift == xas->xa_shift)
> > +		xas->xa_offset |= sibs;
> >  	xas->xa_shift = 0;
> >  	xas->xa_sibs = 0;
> 
> Yes, that's a big improvement, the huge "cp" is now fine, thank you.
> 
> I've updated my xfstests tree, and tried that on mmotm with this patch.
> The few failures are exactly the same as on 4.18-rc6, whether mounting
> tmpfs as huge or not. But four of the tests, generic/{340,345,346,354}
> crash (oops) on 4.18-rc5-mm1 + your patch above, but pass on 4.18-rc6.

Now I've learnt that an oops on 0xffffffffffffffbe points to EEXIST,
not to EREMOTE, it's easy: patch below fixes those four xfstests
(and no doubt a similar oops I've seen occasionally under swapping
load): so gives clean xfstests runs for non-huge and huge tmpfs.

I can reproduce a kernel BUG at mm/khugepaged.c:1358! - that's the
VM_BUG_ON(index != xas.xa_index) in collapse_shmem() - but it will
take too long to describe how to reproduce that one, so I'm running
it past you just in case you have a quick idea on it, otherwise I'll
try harder. I did just try an xas_set(&xas, index) before the loop,
in case the xas_create_range(&xas) had interfered with initial state;
but if that made any difference at all, it only delayed the crash.

Hugh

--- mmotm/mm/shmem.c	2018-07-20 17:54:42.002805461 -0700
+++ linux/mm/shmem.c	2018-07-25 23:32:39.170892551 -0700
@@ -597,8 +597,10 @@ static int shmem_add_to_page_cache(struc
 		void *entry;
 		xas_lock_irq(&xas);
 		entry = xas_find_conflict(&xas);
-		if (entry != expected)
+		if (entry != expected) {
 			xas_set_err(&xas, -EEXIST);
+			goto unlock;
+		}
 		xas_create_range(&xas);
 		if (xas_error(&xas))
 			goto unlock;

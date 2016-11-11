Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CFFC6280290
	for <linux-mm@kvack.org>; Fri, 11 Nov 2016 05:59:24 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id s63so23725567wms.7
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:59:24 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id r192si10313443wmd.135.2016.11.11.02.59.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 11 Nov 2016 02:59:23 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u144so8594522wmu.0
        for <linux-mm@kvack.org>; Fri, 11 Nov 2016 02:59:23 -0800 (PST)
Date: Fri, 11 Nov 2016 13:59:21 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 1/6] mm: khugepaged: fix radix tree node leak in shmem
 collapse error path
Message-ID: <20161111105921.GC19382@node.shutemov.name>
References: <20161107190741.3619-1-hannes@cmpxchg.org>
 <20161107190741.3619-2-hannes@cmpxchg.org>
 <20161108095352.GH32353@quack2.suse.cz>
 <20161108161245.GA4020@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161108161245.GA4020@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Nov 08, 2016 at 11:12:45AM -0500, Johannes Weiner wrote:
> On Tue, Nov 08, 2016 at 10:53:52AM +0100, Jan Kara wrote:
> > On Mon 07-11-16 14:07:36, Johannes Weiner wrote:
> > > The radix tree counts valid entries in each tree node. Entries stored
> > > in the tree cannot be removed by simpling storing NULL in the slot or
> > > the internal counters will be off and the node never gets freed again.
> > > 
> > > When collapsing a shmem page fails, restore the holes that were filled
> > > with radix_tree_insert() with a proper radix tree deletion.
> > > 
> > > Fixes: f3f0e1d2150b ("khugepaged: add support of collapse for tmpfs/shmem pages")
> > > Reported-by: Jan Kara <jack@suse.cz>
> > > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > > ---
> > >  mm/khugepaged.c | 3 ++-
> > >  1 file changed, 2 insertions(+), 1 deletion(-)
> > > 
> > > diff --git a/mm/khugepaged.c b/mm/khugepaged.c
> > > index 728d7790dc2d..eac6f0580e26 100644
> > > --- a/mm/khugepaged.c
> > > +++ b/mm/khugepaged.c
> > > @@ -1520,7 +1520,8 @@ static void collapse_shmem(struct mm_struct *mm,
> > >  				if (!nr_none)
> > >  					break;
> > >  				/* Put holes back where they were */
> > > -				radix_tree_replace_slot(slot, NULL);
> > > +				radix_tree_delete(&mapping->page_tree,
> > > +						  iter.index);
> > 
> > Hum, but this is inside radix_tree_for_each_slot() iteration. And
> > radix_tree_delete() may end up freeing nodes resulting in invalidating
> > current slot pointer and the iteration code will do use-after-free.
> 
> Good point, we need to do another tree lookup after the deletion.
> 
> But there are other instances in the code, where we drop the lock
> temporarily and somebody else could delete the node from under us.
> 
> In the main collapse path, I *think* this is prevented by the fact
> that when we drop the tree lock we still hold the page lock of the
> regular page that's in the tree while we isolate and unmap it, thus
> pin the node. Even so, it would seem a little hairy to rely on that.
> 
> Kirill?

[ sorry for delay ]

Yes, we make sure that locked page still belong to the radix tree and fall
off if it's not. Locked page cannot be removed from radix-tree, so we
should be fine.

> I'll update this patch and prepend another fix to the series that
> addresses the other two lock dropping issues.

Feel free add my Acked-by.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

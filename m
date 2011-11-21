Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9B76B006E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 06:19:36 -0500 (EST)
Date: Mon, 21 Nov 2011 11:19:31 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/5] mm: compaction: Determine if dirty pages can be
 migreated without blocking within ->migratepage
Message-ID: <20111121111931.GB19415@suse.de>
References: <1321635524-8586-1-git-send-email-mgorman@suse.de>
 <1321635524-8586-5-git-send-email-mgorman@suse.de>
 <CAPQyPG4GTccLroA2NsdQK_PH1_KB3dD1v3m1FzenCeDW-8qb+g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPQyPG4GTccLroA2NsdQK_PH1_KB3dD1v3m1FzenCeDW-8qb+g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nai Xia <nai.xia@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On Sat, Nov 19, 2011 at 04:59:10PM +0800, Nai Xia wrote:
> > <SNIP>
> > @@ -453,13 +494,18 @@ int buffer_migrate_page(struct address_space *mapping,
> >        if (rc)
> >                return rc;
> >
> > -       bh = head;
> > -       do {
> > -               get_bh(bh);
> > -               lock_buffer(bh);
> > -               bh = bh->b_this_page;
> > -
> > -       } while (bh != head);
> > +       if (!buffer_migrate_lock_buffers(head, sync)) {
> > +               /*
> > +                * We have to revert the radix tree update. If this returns
> > +                * non-zero, it either means that the page count changed
> > +                * which "can't happen" or the slot changed from underneath
> > +                * us in which case someone operated on a page that did not
> > +                * have buffers fully migrated which is alarming so warn
> > +                * that it happened.
> > +                */
> > +               WARN_ON(migrate_page_move_mapping(mapping, page, newpage));
> > +               return -EBUSY;
> 
> If this migrate_page_move_mapping() really fails, seems disk IO will be needed
> to bring the previously already cached page back,

Aside from that, I couldn't see a way of handling the case where the
page had an elevated count due to a speculative lookup.

> I wonder if we should make the
> double check for the two conditions of "page refs is ok " and "all bh
> trylocked"
> before doing radix_tree_replace_slot() ? which I think does not
> involve IO on the
> error path.
> 

I reached the same conclusion when figuring out how to backout of the
the elevated page count case. In an updated patch,
migrate_page_move_mapping() returns with buffers locked in the async
case.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

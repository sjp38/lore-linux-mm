Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 9DC7C6B0038
	for <linux-mm@kvack.org>; Tue,  4 Aug 2015 17:33:39 -0400 (EDT)
Received: by pabxd6 with SMTP id xd6so480272pab.2
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 14:33:39 -0700 (PDT)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com. [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id du5si1309717pdb.92.2015.08.04.14.33.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Aug 2015 14:33:38 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so9201896pdb.0
        for <linux-mm@kvack.org>; Tue, 04 Aug 2015 14:33:38 -0700 (PDT)
Date: Tue, 4 Aug 2015 14:32:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm, vmscan: Do not wait for page writeback for GFP_NOFS
 allocations
In-Reply-To: <20150804095158.GE18509@dhcp22.suse.cz>
Message-ID: <alpine.LSU.2.11.1508041414170.31462@eggly.anvils>
References: <1435677437-16717-1-git-send-email-mhocko@suse.cz> <20150701061731.GB6286@dhcp22.suse.cz> <20150701133715.GA6287@dhcp22.suse.cz> <20150702142551.GB9456@thunk.org> <20150702151321.GE12547@dhcp22.suse.cz> <alpine.LSU.2.11.1508032227050.5070@eggly.anvils>
 <20150804095158.GE18509@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Nikolay Borisov <kernel@kyup.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Marian Marinov <mm@1h.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-ext4@vger.kernel.org

On Tue, 4 Aug 2015, Michal Hocko wrote:
> On Mon 03-08-15 23:32:00, Hugh Dickins wrote:
> [...]
> > But I have modified it a little, I don't think you'll mind.  As you
> > suggested yourself, I actually prefer to test may_enter_fs there, rather
> > than __GFP_FS: not a big deal, I certainly wouldn't want to delay the
> > fix if someone thinks differently; but I tend to feel that may_enter_fs
> > is what we already use for such decisions there, so better to use it.
> > (And the SwapCache case immune to ext4 or xfs IO submission pattern.)
> 
> I am not opposed. This is closer to what we had before.

Yes, it is what you had there before.

> 
> [...]
> > (I was tempted to add in
> > my unlock_page there, that we discussed once before: but again thought
> > it better to minimize the fix - it is "selfish" not to unlock_page,
> > but I think that anything heading for deadlock on the locked page would
> > in other circumstances be heading for deadlock on the writeback page -
> > I've never found that change critical.)
> 
> I agree. It would deserve a separate patch.

I'll send one day, but not for v4.2.

> 
> > And I've done quite a bit of testing.  The loads that hung at the
> > weekend have been running nicely for 24 hours now, no problem with the
> > writeback hang and no problem with the dcache ENOTDIR issue.  Though
> > I've no idea of what recent VM change turned this into a hot issue.
> > 
> > And more testing on the history of it, considering your stable 3.6+
> > designation that I wasn't satisfied with.  Getting out that USB stick
> > again, I find that 3.6, 3.7 and 3.8 all OOM if their __GFP_IO test
> > is updated to a may_enter_fs test; but something happened in 3.9
> > to make it and subsequent releases safe with the may_enter_fs test.
> 
> Interesting. I would have guessed that 3.12 would make a difference (as
> mentioned in the changelog). Why would 3.9 make a difference is not
> entirely clear to me.

Nor to me.  You were right to single out 3.12 in the changelog, but
clearly some earlier change in 3.9 altered the delicate balance on this.
It was unambiguous, so a bisection between 3.8 and 3.9 should easily
find it.  Yet, somehow, that's not very high on my TODO list...

It would be more interesting to find why this deadlock has become so
much more visible just now.  But that would be a difficult bisection,
taking many days, of restarts after wrong decisions.  Again, not
something I'll get into.

> 
> > You can certainly argue that the remote chance of a deadlock is
> > worse than the fair chance of a spurious OOM; but if you insist
> > on 3.6+, then I think it would have to go back even further,
> > because we marked that commit for stable itself.  I suggest 3.9+.
> 
> Agreed and thanks!

Thanks so much for getting back to us on it so very promptly.
I'll detach the patch, unchanged, and send direct to Linus now.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

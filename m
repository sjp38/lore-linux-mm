Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 485BE6B0069
	for <linux-mm@kvack.org>; Fri, 16 Sep 2016 21:36:12 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id mi5so182608208pab.2
        for <linux-mm@kvack.org>; Fri, 16 Sep 2016 18:36:12 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2001:1868:205::9])
        by mx.google.com with ESMTPS id s86si6685937pfd.23.2016.09.16.18.36.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Sep 2016 18:36:11 -0700 (PDT)
Date: Sat, 17 Sep 2016 03:36:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/4] mm, vmscan: Batch removal of mappings under a single
 lock during reclaim
Message-ID: <20160917013606.GM5016@twins.programming.kicks-ass.net>
References: <1473415175-20807-1-git-send-email-mgorman@techsingularity.net>
 <1473415175-20807-2-git-send-email-mgorman@techsingularity.net>
 <20160916132506.GB5035@twins.programming.kicks-ass.net>
 <CA+55aFwoEMOweMaOjFk9+H04mFXnwGk7y6n86T2ZbF_CZOkKEg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwoEMOweMaOjFk9+H04mFXnwGk7y6n86T2ZbF_CZOkKEg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Dave Chinner <david@fromorbit.com>, Ying Huang <ying.huang@intel.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Sep 16, 2016 at 11:33:00AM -0700, Linus Torvalds wrote:
> On Fri, Sep 16, 2016 at 6:25 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> >
> > So, once upon a time, in a galaxy far away,..  I did a concurrent
> > pagecache patch set that replaced the tree_lock with a per page bit-
> > spinlock and fine grained locking in the radix tree.
> 
> I'd love to see the patch for that. I'd be a bit worried about extra
> locking in the trivial cases (ie multi-level locking when we now take
> just the single mapping lock), but if there is some smart reason why
> that doesn't happen, then..

On average we'll likely take a few more locks, but its not as bad as
having to take the whole tree depth every time, or even touching the
root lock most times.

There's two cases, the first: the modification is only done on a single
node (like insert), here we do an RCU lookup of the node, lock it,
verify the node is still correct, do modification and unlock, done.

The second case, the modification needs to then back up the tree (like
setting/clearing tags, delete). For this case we can determine on our
way down where the first node is we need to modify, lock that, verify,
and then lock all nodes down to the last. i.e. we lock a partial path.

I can send you the 2.6.31 patches if you're interested, but if you want
something that applies to a kernel from this decade I'll have to go
rewrite them which will take a wee bit of time :-) Both the radix tree
code and the mm have changed somewhat.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

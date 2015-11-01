Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id BE0B882F76
	for <linux-mm@kvack.org>; Sun,  1 Nov 2015 18:03:51 -0500 (EST)
Received: by qgad10 with SMTP id d10so103867301qga.3
        for <linux-mm@kvack.org>; Sun, 01 Nov 2015 15:03:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e200si15763334qhc.22.2015.11.01.15.03.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 01 Nov 2015 15:03:51 -0800 (PST)
Date: Mon, 2 Nov 2015 00:03:48 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/6] ksm: don't fail stable tree lookups if walking over
 stale stable_nodes
Message-ID: <20151101230348.GS5390@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
 <1444925065-4841-4-git-send-email-aarcange@redhat.com>
 <alpine.LSU.2.11.1510251622340.1923@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1510251622340.1923@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Petr Holasek <pholasek@redhat.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Sun, Oct 25, 2015 at 04:34:27PM -0700, Hugh Dickins wrote:
> I'll say
> Acked-by: Hugh Dickins <hughd@google.com>
> as a gesture of goodwill, but in honesty I'm sitting on the fence,
> and couldn't decide.  I think I've gone back and forth on this in
> my own mind in the past, worried that we might get stuck a long
> time going back round to "again".  In the past I've felt that to
> give up with NULL is consistent with KSM's willingness to give way
> to any obstruction; but if you're finding "goto again" a better
> strategy, sure, go ahead.  And at least there's a cond_resched()
> just above the diff context shown.

If a couple of large process exists and create lots of stale
stable_nodes, we'll miss the opportunity to merge lots of unstable
tree nodes for potentially many passes. So KSM gets an artificial
latency in merging new unstable tree nodes. At the same time if we
don't prune aggressively, we delay the freeing of the stale
stable_nodes. Keeping stale stable_nodes around wastes memory and it
can't provide any benefit.

Ideally we should be doing a full rbtree walk to do a perfect pruning
after each pass to be sure some stale stable nodes don't stay around
forever, but walking the whole rtbree takes more memory and it'd use
more CPU. So considering we're not perfect at pruning the tree after
each pass, we can at least be more aggressive at pruning the tree
during the lookup.

> When a comment gets that long, in fact even if it were only one line,
> I'd much prefer that block inside braces.  I think I noticed Linus
> feeling the same way a few days ago, when he fixed up someone's patch.

Ok, I'll add braces, I don't mind either ways.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

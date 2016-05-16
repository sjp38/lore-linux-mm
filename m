Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 333C96B0260
	for <linux-mm@kvack.org>; Mon, 16 May 2016 07:45:31 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e201so41557317wme.1
        for <linux-mm@kvack.org>; Mon, 16 May 2016 04:45:31 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id m68si19622043wma.60.2016.05.16.04.45.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 16 May 2016 04:45:29 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id w143so17366968wmw.3
        for <linux-mm@kvack.org>; Mon, 16 May 2016 04:45:29 -0700 (PDT)
Date: Mon, 16 May 2016 13:45:28 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] writeback: Avoid exhausting allocation reserves under
 memory pressure
Message-ID: <20160516114528.GH23146@dhcp22.suse.cz>
References: <1462436092-32665-1-git-send-email-jack@suse.cz>
 <20160505082433.GC4386@dhcp22.suse.cz>
 <20160505090750.GD1970@quack2.suse.cz>
 <20160505143751.06aa4223e266c1d92b3323a2@linux-foundation.org>
 <20160512160829.GA30647@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160512160829.GA30647@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, tj@kernel.org

On Thu 12-05-16 18:08:29, Jan Kara wrote:
> On Thu 05-05-16 14:37:51, Andrew Morton wrote:
[...]
> > bdi_split_work_to_wbs() does GFP_ATOMIC as well.  Problem?  (Why the
> > heck don't we document the *reasons* for these things, sigh).
> 
> Heh, there are much more GFP_ATOMIC allocations in fs/fs-writeback.c after
> Tejun's memcg aware writeback... I believe they are GFP_ATOMIC mostly
> because they can already be called from direct reclaim (e.g. when
> requesting pages to be written through wakeup_flusher_threads()) and so we
> don't want to recurse into direct reclaim code again.

If that is the case then __GFP_DIRECT_RECLAIM should be cleared rather
than GFP_ATOMIC abused.

> > I suspect it would be best to be proactive here and use some smarter
> > data structure.  It appears that all the wb_writeback_work fields
> > except sb can be squeezed into a single word so perhaps a radix-tree. 
> > Or hash them all together and use a chained array or something.  Maybe
> > fiddle at it for an hour or so, see how it's looking?  It's a lot of
> > fuss to avoid one problematic kmalloc(), sigh.
> > 
> > We really don't want there to be *any* pathological workload which
> > results in merging failures - if that's the case then someone will hit
> > it.  They'll experience the ooms (perhaps) and the search complexity
> > issues (for sure).
> 
> So the question is what is the desired outcome. After Tetsuo's patch
> "mm,writeback: Don't use memory reserves for wb_start_writeback" we will
> use GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN instead of GFP_ATOMIC in
> wb_start_writeback(). We can treat other places using GFP_ATOMIC in a
> similar way. So my thought was that this is enough to avoid exhaustion of
> reserves for writeback work items under memory pressure. And the merging of
> writeback works I proposed was more like an optimization to avoid
> unnecessary allocations. And in that case we can allow imperfection and
> possibly large lists of queued works in pathological cases - I agree we
> should not DoS the system by going through large linked lists in any case but
> that is easily avoided if we are fine with the fact that merging won't happen
> always when it could.

Yes I think this is acceptable.

> The question which is not clear to me is: Do we want to guard against
> malicious attacker that may be consuming memory through writeback works
> that are allocated via GFP_NOWAIT | __GFP_NOMEMALLOC | __GFP_NOWARN? 
> If yes, then my patch needs further thought. Any opinions?

GFP_NOWAIT still kicks the kswapd so there is some reclaim activity
on the background. Sure if we can reduce the number of those requests
it would be better because we are losing natural throttling without
the direct reclaim. But I am not sure I can see how this would cause a
a major problem (slow down everybody - quite possible - but not DoS
AFAICS).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

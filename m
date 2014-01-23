Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 5772A6B0035
	for <linux-mm@kvack.org>; Thu, 23 Jan 2014 06:09:34 -0500 (EST)
Received: by mail-we0-f182.google.com with SMTP id w62so985346wes.27
        for <linux-mm@kvack.org>; Thu, 23 Jan 2014 03:09:33 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t13si8837558wju.91.2014.01.23.03.09.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 23 Jan 2014 03:09:21 -0800 (PST)
Date: Thu, 23 Jan 2014 12:09:20 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH -mm 2/2] memcg: fix css reference leak and endless loop
 in mem_cgroup_iter
Message-ID: <20140123110920.GE4911@dhcp22.suse.cz>
References: <20140121083454.GA1894@dhcp22.suse.cz>
 <1390301143-9541-1-git-send-email-mhocko@suse.cz>
 <1390301143-9541-2-git-send-email-mhocko@suse.cz>
 <20140121114219.8c34256dfbe7c2470b36ced8@linux-foundation.org>
 <alpine.LSU.2.11.1401211218010.5688@eggly.anvils>
 <20140122082723.GB18154@dhcp22.suse.cz>
 <alpine.LSU.2.11.1401230203070.1132@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1401230203070.1132@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Thu 23-01-14 02:42:58, Hugh Dickins wrote:
> On Wed, 22 Jan 2014, Michal Hocko wrote:
> > On Tue 21-01-14 13:18:42, Hugh Dickins wrote:
> > [...]
> > > We do have a confusing situation.  The hang goes back to 3.10 but takes
> > > two different forms, because of intervening changes: in 3.10 and 3.11
> > > mem_cgroup_iter repeatedly returns root memcg to its caller, in 3.12 and
> > > 3.13 mem_cgroup_iter repeatedly gets NULL memcg from mem_cgroup_iter_next
> > > and cannot return to its caller.
> > > 
> > > Patch 1/2 is what's needed to fix 3.10 and 3.11 (and applies correctly
> > > to 3.11, but will have to be rediffed for 3.10 because of rearrangement
> > > in between). 
> > 
> > I will backport it when it reaches stable queue.
> 
> Thank you.
> 
> Testing, at home and at work, has confirmed your two patches are good.

Great. Thanks a lot!

> Greg's particular test on 3.11 gave convincing results, and I was helped
> by Linus's tree of last night (df32e43a54d0) happening to be quite quick
> to reproduce the issue on my laptop.
> 
> > 
> > > Patch 2/2 is what's needed to fix 3.12 and 3.13 (but applies
> > > correctly to neither of them because it's diffed on top of my CSS_ONLINE
> > > fix).  Patch 1/2 is correct but unnecessary in 3.12 and 3.13: I'm unclear
> > > whether Michal is claiming that it would also fix the hang in 3.12 and
> > > 3.13 if we didn't have 2/2: I doubt that, and haven't tested that.
> > 
> > Actually both patches are needed. If we had only 2/2 then we wouldn't
> > endless loop inside mem_cgroup_iter but we could still return root to
> > caller all the time because mem_cgroup_iter_load would return NULL on
> > css_tryget failure on the cached root. Or am I missing something that
> > would prevent that?
> 
> In theory I agree with you; and if you're missing something, I can't see
> it either.  But in practice, all my earlier testing of 3.12 and 3.13 was
> just with 2/2, and I've tried without your 1/2 since: whereas I have hung
> on 3.12 and 3.13 a convincing number of times without 2/2, I have never
> hung on them with 2/2 without 1/2.  In practice 1/2 appears essential
> for 3.10 and 3.11, but irrelevant for 3.12 and 3.13.
> 
> That could be easy to explain if there were a difference at the calling
> end, shrink_zone(), between those releases: but I don't see that.  Odd.
> Either we're both missing something, or my testing is even less reliable
> than I'd thought.  But since I certainly don't dispute 1/2, it is merely
> academic.  Though still bothersome.

I would assume that it is (sc->nr_reclaimed >= sc->nr_to_reclaim) that
helps us to back off. SWAP_CLUSTER_MAX shouldn't be that hard to get to
before css_offline racing part reparents all the memory.

Anyway, I would feel safer if this was pushed fixed although you haven't
reporoduced it.
 
> > > Given how Michal has diffed this patch on top of my CSS_ONLINE one
> > > (mm-memcg-iteration-skip-memcgs-not-yet-fully-initialized.patch),
> > > it would be helpful if you could mark that one also for stable 3.12+,
> > > to save us from having to rediff this one for stable.  We don't have
> > > a concrete example of a problem it solves in the vanilla kernel, but
> > > it makes more sense to include it than to exclude it.
> > 
> > Yes, I think it makes sense to queue it for 3.12+ as well because it is
> > non intrusive and potential issues would be really subtle.
> 
> Before Andrew sends these all off to Linus, I should admit that there's
> probably a refinement still to come to the CSS_ONLINE one.  I'm ashamed
> to admit that I overlooked a much earlier comment from Greg Thelen, who
> suggested that a memory barrier might be required.

I was thinking about mem barrier while reviewing your patch but then I
convinced myself that we should be safe also without using one when
checking CSS_ONLINE.
We have basically two situations.
	- online_css when we can miss it being set which is OK because
	  we would miss a new empty group.
	- offline_css when we could still see the flag being set but
	  then css_tryget would be already failing.

So while all this is subtle and relies on cgroup core heavily I think we
should be safe wrt. memory barriers.

Or did you mean something else here?

> I think he's right, and I'd have liked to say exactly what and where
> before answering you now; but barriers are tricky elusive things, I've
> not yet decided, and better report back to you now on the testing
> result.
> 
> Hugh

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f41.google.com (mail-yh0-f41.google.com [209.85.213.41])
	by kanga.kvack.org (Postfix) with ESMTP id 0C4C76B0073
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 16:19:21 -0500 (EST)
Received: by mail-yh0-f41.google.com with SMTP id i7so2300342yha.0
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:19:20 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id f25si7542306yho.78.2014.01.21.13.19.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 13:19:19 -0800 (PST)
Received: by mail-pa0-f44.google.com with SMTP id kq14so8944830pab.17
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:19:17 -0800 (PST)
Date: Tue, 21 Jan 2014 13:18:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH -mm 2/2] memcg: fix css reference leak and endless loop
 in mem_cgroup_iter
In-Reply-To: <20140121114219.8c34256dfbe7c2470b36ced8@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1401211218010.5688@eggly.anvils>
References: <20140121083454.GA1894@dhcp22.suse.cz> <1390301143-9541-1-git-send-email-mhocko@suse.cz> <1390301143-9541-2-git-send-email-mhocko@suse.cz> <20140121114219.8c34256dfbe7c2470b36ced8@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 21 Jan 2014, Andrew Morton wrote:
> On Tue, 21 Jan 2014 11:45:43 +0100 Michal Hocko <mhocko@suse.cz> wrote:
> 
> > 19f39402864e (memcg: simplify mem_cgroup_iter) has reorganized
> > mem_cgroup_iter code in order to simplify it. A part of that change was
> > dropping an optimization which didn't call css_tryget on the root of
> > the walked tree. The patch however didn't change the css_put part in
> > mem_cgroup_iter which excludes root.
> > This wasn't an issue at the time because __mem_cgroup_iter_next bailed
> > out for root early without taking a reference as cgroup iterators
> > (css_next_descendant_pre) didn't visit root themselves.
> > 
> > Nevertheless cgroup iterators have been reworked to visit root by
> > bd8815a6d802 (cgroup: make css_for_each_descendant() and friends include
> > the origin css in the iteration) when the root bypass have been dropped
> > in __mem_cgroup_iter_next. This means that css_put is not called for
> > root and so css along with mem_cgroup and other cgroup internal object
> > tied by css lifetime are never freed.
> > 
> > Fix the issue by reintroducing root check in __mem_cgroup_iter_next
> > and do not take css reference for it.
> > 
> > This reference counting magic protects us also from another issue, an
> > endless loop reported by Hugh Dickins when reclaim races with root
> > removal and css_tryget called by iterator internally would fail. There
> > would be no other nodes to visit so __mem_cgroup_iter_next would return
> > NULL and mem_cgroup_iter would interpret it as "start looping from root
> > again" and so mem_cgroup_iter would loop forever internally.
> 
> I grabbed these two patches but I will sit on them for a week or so,
> pending review-n-test.

Thank you, yes, I'm about to give them more testing.

> 
> > Cc: stable@vger.kernel.org # mem_leak part 3.12+
> 
> What does this mean?

It's certainly a confusing comment.

I suggest just deleting the "mem_leak part ": Michal isn't referring to
any two parts of the patch itself, but to parts of his commit comment;
but it's still unclear what he's claiming.

We do have a confusing situation.  The hang goes back to 3.10 but takes
two different forms, because of intervening changes: in 3.10 and 3.11
mem_cgroup_iter repeatedly returns root memcg to its caller, in 3.12 and
3.13 mem_cgroup_iter repeatedly gets NULL memcg from mem_cgroup_iter_next
and cannot return to its caller.

Patch 1/2 is what's needed to fix 3.10 and 3.11 (and applies correctly
to 3.11, but will have to be rediffed for 3.10 because of rearrangement
in between).  Patch 2/2 is what's needed to fix 3.12 and 3.13 (but applies
correctly to neither of them because it's diffed on top of my CSS_ONLINE
fix).  Patch 1/2 is correct but unnecessary in 3.12 and 3.13: I'm unclear
whether Michal is claiming that it would also fix the hang in 3.12 and
3.13 if we didn't have 2/2: I doubt that, and haven't tested that.

Given how Michal has diffed this patch on top of my CSS_ONLINE one
(mm-memcg-iteration-skip-memcgs-not-yet-fully-initialized.patch),
it would be helpful if you could mark that one also for stable 3.12+,
to save us from having to rediff this one for stable.  We don't have
a concrete example of a problem it solves in the vanilla kernel, but
it makes more sense to include it than to exclude it.

(You would be right to point out that the CSS_ONLINE one fixes
something that goes back to 3.10: I'm saying 3.12+ because I'm not
motivated to rediff it for 3.10 and 3.11 when there's nothing to
go on top; but that's not a very good reason to lie - overrule me.)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E75C46B0069
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 08:18:09 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id a20so22354658wme.5
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 05:18:09 -0800 (PST)
Received: from mail-wj0-f193.google.com (mail-wj0-f193.google.com. [209.85.210.193])
        by mx.google.com with ESMTPS id z83si13721216wmb.72.2016.11.25.05.18.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Nov 2016 05:18:08 -0800 (PST)
Received: by mail-wj0-f193.google.com with SMTP id xy5so5581816wjc.1
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 05:18:08 -0800 (PST)
Date: Fri, 25 Nov 2016 14:18:07 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 2/2] mm, oom: do not enfore OOM killer for __GFP_NOFAIL
 automatically
Message-ID: <20161125131806.GB24353@dhcp22.suse.cz>
References: <20161123064925.9716-1-mhocko@kernel.org>
 <20161123064925.9716-3-mhocko@kernel.org>
 <201611232335.JFC30797.VOOtOMFJFHLQSF@I-love.SAKURA.ne.jp>
 <20161123153544.GN2864@dhcp22.suse.cz>
 <201611252100.ADG04225.MFOSOVtHJFFLQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201611252100.ADG04225.MFOSOVtHJFFLQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, vbabka@suse.cz, rientjes@google.com, hannes@cmpxchg.org, mgorman@suse.de, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

On Fri 25-11-16 21:00:52, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Wed 23-11-16 23:35:10, Tetsuo Handa wrote:
> > > If __alloc_pages_nowmark() called by __GFP_NOFAIL could not find pages
> > > with requested order due to fragmentation, __GFP_NOFAIL should invoke
> > > the OOM killer. I believe that risking kill all processes and panic the
> > > system eventually is better than __GFP_NOFAIL livelock.
> >
> > I violently disagree. Just imagine a driver which asks for an order-9
> > page and cannot really continue without it so it uses GFP_NOFAIL. There
> > is absolutely no reason to disrupt or even put the whole system down
> > just because of this particular request. It might take for ever to
> > continue but that is to be expected when asking for such a hard
> > requirement.
> 
> Did we find such in-tree drivers? If any, we likely already know it via
> WARN_ON_ONCE((gfp_flags & __GFP_NOFAIL) && (order > 1)); in buffered_rmqueue().
> Even if there were such out-of-tree drivers, we don't need to take care of
> out-of-tree drivers.

We do not have any costly + GFP_NOFAIL users in the tree from my quick
check. The whole point of this excercise is to make such a potential
user not seeing unexpected side effects - e.g. when transforming open
coded endless lopps into GFP_NOFAIL which is imho preferable.

The bottom line is that GFP_NOFAIL is about never failing not to get the
memory as quickly as possible or for any price.

> > > Unfortunately, there seems to be cases where the
> > > caller needs to use GFP_NOFS rather than GFP_KERNEL due to unclear dependency
> > > between memory allocation by system calls and memory reclaim by filesystems.
> >
> > I do not understand your point here. Syscall is an entry point to the
> > kernel where we cannot recurse to the FS code so GFP_NOFS seems wrong
> > thing to ask.
> 
> Will you look at http://marc.info/?t=120716967100004&r=1&w=2 which lead to
> commit a02fe13297af26c1 ("selinux: prevent rentry into the FS") and commit
> 869ab5147e1eead8 ("SELinux: more GFP_NOFS fixups to prevent selinux from
> re-entering the fs code") ? My understanding is that mkdir() system call
> caused memory allocation for inode creation and that memory allocation
> caused memory reclaim which had to be !__GFP_FS.

I will have a look later, thanks for the points.
 
> And whether we need to use GFP_NOFS at specific point is very very unclear.

And that is exactly why I am pushing for a scoped GFP_NOFS usage where
the FS code marks those scopes which are dangerous from the reclaim
recursion or for other FS internal reasons and the stacking code
shouldn't care at all. Spreading GFP_NOFS randomly is not at all helpful
nor it makes the situation any better.

I am sorry but I would prefer not to discuss this part in this thread as
it is mostly off topic. The point I am trying to make here is to clean
up GFP_NOFAIL usage. And I argue that overriding the oom prevention
decisions just because of GFP_NOFAIL is wrong. So let's please stick
with this topic. I might be wrong and miss some legitimate case but then
I would like to hear about it.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

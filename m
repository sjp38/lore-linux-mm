Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A81506B4620
	for <linux-mm@kvack.org>; Tue, 28 Aug 2018 07:59:49 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id s2-v6so1112026qth.0
        for <linux-mm@kvack.org>; Tue, 28 Aug 2018 04:59:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n16-v6sor429598qki.118.2018.08.28.04.59.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 28 Aug 2018 04:59:44 -0700 (PDT)
Date: Tue, 28 Aug 2018 07:59:42 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] mm, oom: OOM victims do not need to select next OOM
 victim unless __GFP_NOFAIL.
Message-ID: <20180828115942.GA12564@cmpxchg.org>
References: <1534761465-6449-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180820105336.GJ29735@dhcp22.suse.cz>
 <1341c62b-cb21-a592-f062-d162da01f912@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341c62b-cb21-a592-f062-d162da01f912@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, syzbot <syzbot+bab151e82a4e973fa325@syzkaller.appspotmail.com>

On Mon, Aug 20, 2018 at 08:02:30PM +0900, Tetsuo Handa wrote:
> On 2018/08/20 19:53, Michal Hocko wrote:
> > On Mon 20-08-18 19:37:45, Tetsuo Handa wrote:
> >> Commit 696453e66630ad45 ("mm, oom: task_will_free_mem should skip
> >> oom_reaped tasks") changed to select next OOM victim as soon as
> >> MMF_OOM_SKIP is set. But since OOM victims can try ALLOC_OOM allocation
> >> and then give up (if !memcg OOM) or can use forced charge and then retry
> >> (if memcg OOM), OOM victims do not need to select next OOM victim unless
> >> they are doing __GFP_NOFAIL allocations.
> > 
> > I do not like this at all. It seems hackish to say the least. And more
> > importantly...
> > 
> >> This is a quick mitigation because syzbot is hitting WARN(1) caused by
> >> this race window [1]. More robust fix (e.g. make it possible to reclaim
> >> more memory before MMF_OOM_SKIP is set, wait for some more after
> >> MMF_OOM_SKIP is set) is a future work.
> > 
> > .. there is already a patch (by Johannes) for that warning IIRC.
> 
> You mean http://lkml.kernel.org/r/20180808144515.GA9276@cmpxchg.org ?
> But I can't find that patch in linux-next.git . And as far as I know,
> no patch was sent to linux.git for handling this problem. Therefore,
> I wrote this patch so that we can apply for 4.19-rc1.

I assume it'll go in soon, it's the first patch in the -mm tree:

$ cat http://ozlabs.org/~akpm/mmots/series
origin.patch
#NEXT_PATCHES_START linus
#NEXT_PATCHES_END
#NEXT_PATCHES_START mainline-urgent (this week, approximately)
#NEXT_PATCHES_END
#NEXT_PATCHES_START mainline-later (next week, approximately)
mm-memcontrol-print-proper-oom-header-when-no-eligible-victim-left.patch

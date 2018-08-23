Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AD2B66B2BC6
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 16:06:42 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id c8-v6so4068190pfn.2
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 13:06:42 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o8-v6sor1958549plk.132.2018.08.23.13.06.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 13:06:41 -0700 (PDT)
Date: Thu, 23 Aug 2018 13:06:38 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,page_alloc: PF_WQ_WORKER threads must sleep at
 should_reclaim_retry().
In-Reply-To: <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1808231304080.15798@chino.kir.corp.google.com>
References: <9158a23e-7793-7735-e35c-acd540ca59bf@i-love.sakura.ne.jp> <20180730144647.GX24267@dhcp22.suse.cz> <20180730145425.GE1206094@devbig004.ftw2.facebook.com> <0018ac3b-94ee-5f09-e4e0-df53d2cbc925@i-love.sakura.ne.jp> <20180730154424.GG1206094@devbig004.ftw2.facebook.com>
 <20180730185110.GB24267@dhcp22.suse.cz> <20180730191005.GC24267@dhcp22.suse.cz> <6f433d59-4a56-b698-e119-682bb8bf6713@i-love.sakura.ne.jp> <20180731050928.GA4557@dhcp22.suse.cz> <d11c3aa2-0f14-d882-59c5-6634dc56eed1@i-love.sakura.ne.jp>
 <20180803061653.GB27245@dhcp22.suse.cz> <804b50cb-0b17-201a-790b-18604396f826@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, 22 Aug 2018, Tetsuo Handa wrote:

> On 2018/08/03 15:16, Michal Hocko wrote:
> > On Fri 03-08-18 07:05:54, Tetsuo Handa wrote:
> >> On 2018/07/31 14:09, Michal Hocko wrote:
> >>> On Tue 31-07-18 06:01:48, Tetsuo Handa wrote:
> >>>> On 2018/07/31 4:10, Michal Hocko wrote:
> >>>>> Since should_reclaim_retry() should be a natural reschedule point,
> >>>>> let's do the short sleep for PF_WQ_WORKER threads unconditionally in
> >>>>> order to guarantee that other pending work items are started. This will
> >>>>> workaround this problem and it is less fragile than hunting down when
> >>>>> the sleep is missed. E.g. we used to have a sleeping point in the oom
> >>>>> path but this has been removed recently because it caused other issues.
> >>>>> Having a single sleeping point is more robust.
> >>>>
> >>>> linux.git has not removed the sleeping point in the OOM path yet. Since removing the
> >>>> sleeping point in the OOM path can mitigate CVE-2016-10723, please do so immediately.
> >>>
> >>> is this an {Acked,Reviewed,Tested}-by?
> >>>
> >>> I will send the patch to Andrew if the patch is ok. 
> >>>
> >>>> (And that change will conflict with Roman's cgroup aware OOM killer patchset. But it
> >>>> should be easy to rebase.)
> >>>
> >>> That is still a WIP so I would lose sleep over it.
> >>>
> >>
> >> Now that Roman's cgroup aware OOM killer patchset will be dropped from linux-next.git ,
> >> linux-next.git will get the sleeping point removed. Please send this patch to linux-next.git .
> > 
> > I still haven't heard any explicit confirmation that the patch works for
> > your workload. Should I beg for it? Or you simply do not want to have
> > your stamp on the patch? If yes, I can live with that but this playing
> > hide and catch is not really a lot of fun.
> > 
> 
> I noticed that the patch has not been sent to linux-next.git yet.
> Please send to linux-next.git without my stamp on the patch.
> 

For those of us who are tracking CVE-2016-10723 which has peristently been 
labeled as "disputed" and with no clear indication of what patches address 
it, I am assuming that commit 9bfe5ded054b ("mm, oom: remove sleep from 
under oom_lock") and this patch are the intended mitigations?

A list of SHA1s for merged fixed and links to proposed patches to address 
this issue would be appreciated.

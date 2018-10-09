Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id BD05C6B0003
	for <linux-mm@kvack.org>; Tue,  9 Oct 2018 03:50:18 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b34-v6so754431ede.5
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 00:50:18 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j17-v6si929296edf.210.2018.10.09.00.50.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Oct 2018 00:50:17 -0700 (PDT)
Date: Tue, 9 Oct 2018 09:50:15 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom_adj: avoid meaningless loop to find processes
 sharing mm
Message-ID: <20181009075015.GC8528@dhcp22.suse.cz>
References: <67eedc4c-7afa-e845-6c88-9716fd820de6@i-love.sakura.ne.jp>
 <af7ae9c4-d7f1-69af-58fa-ec6949161f5b@I-love.SAKURA.ne.jp>
 <20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p8>
 <20181008061407epcms1p519703ae6373a770160c8f912c7aa9521@epcms1p5>
 <CGME20181008011931epcms1p82dd01b7e5c067ea99946418bc97de46a@epcms1p2>
 <20181008083855epcms1p20e691e5a001f3b94b267997c24e91128@epcms1p2>
 <f5bdf4a7-e491-1cda-590c-792526f49050@i-love.sakura.ne.jp>
 <20181009063541.GB8528@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181009063541.GB8528@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: ytk.lee@samsung.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov.dev@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue 09-10-18 08:35:41, Michal Hocko wrote:
> [I have only now noticed that the patch has been reposted]
> 
> On Mon 08-10-18 18:27:39, Tetsuo Handa wrote:
> > On 2018/10/08 17:38, Yong-Taek Lee wrote:
[...]
> > > Thank you for your suggestion. But i think it would be better to seperate to 2 issues. How about think these
> > > issues separately because there are no dependency between race issue and my patch. As i already explained,
> > > for_each_process path is meaningless if there is only one thread group with many threads(mm_users > 1 but 
> > > no other thread group sharing same mm). Do you have any other idea to avoid meaningless loop ? 
> > 
> > Yes. I suggest reverting commit 44a70adec910d692 ("mm, oom_adj: make sure processes
> > sharing mm have same view of oom_score_adj") and commit 97fd49c2355ffded ("mm, oom:
> > kill all tasks sharing the mm").
> 
> This would require a lot of other work for something as border line as
> weird threading model like this. I will think about something more
> appropriate - e.g. we can take mmap_sem for read while doing this check
> and that should prevent from races with [v]fork.

Not really. We do not even take the mmap_sem when CLONE_VM. So this is
not the way. Doing a proper synchronization seems much harder. So let's
consider what is the worst case scenario. We would basically hit a race
window between copy_signal and copy_mm and the only relevant case would
be OOM_SCORE_ADJ_MIN which wouldn't propagate to the new "thread". OOM
killer could then pick up the "thread" and kill it along with the whole
process group sharing the mm. Well, that is unfortunate indeed and it
breaks the OOM_SCORE_ADJ_MIN contract. There are basically two ways here
1) do not care and encourage users to use a saner way to set
OOM_SCORE_ADJ_MIN because doing that externally is racy anyway e.g.
setting it before [v]fork & exec. Btw. do we know about an actual user
who would care?
2) add OOM_SCORE_ADJ_MIN and do not kill tasks sharing mm and do not
reap the mm in the rare case of the race.

I would prefer the firs but if this race really has to be addressed then
the 2 sounds more reasonable than the wholesale revert.
-- 
Michal Hocko
SUSE Labs

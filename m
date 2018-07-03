Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92A1A6B0005
	for <linux-mm@kvack.org>; Tue,  3 Jul 2018 11:29:29 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id w23-v6so1129642pgv.1
        for <linux-mm@kvack.org>; Tue, 03 Jul 2018 08:29:29 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ba7-v6si1292897plb.490.2018.07.03.08.29.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jul 2018 08:29:28 -0700 (PDT)
Date: Tue, 3 Jul 2018 17:29:22 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
Message-ID: <20180703152922.GR16767@dhcp22.suse.cz>
References: <1530627910-3415-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20180703151223.GP16767@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180703151223.GP16767@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org

On Tue 03-07-18 17:12:23, Michal Hocko wrote:
> On Tue 03-07-18 23:25:01, Tetsuo Handa wrote:
> > This series provides
> > 
> >   (1) Mitigation and a fix for CVE-2016-10723.
> > 
> >   (2) A mitigation for needlessly selecting next OOM victim reported
> >       by David Rientjes and rejected by Michal Hocko.
> > 
> >   (3) A preparation for handling many concurrent OOM victims which
> >       could become real by introducing memcg-aware OOM killer.
> 
> It would have been great to describe the overal design in the cover
> letter. So let me summarize just to be sure I understand the proposal.
> You are removing the oom_reaper and moving the oom victim tear down to
> the oom path. To handle cases where we cannot get mmap_sem to do that
> work you simply decay oom_badness over time if there are no changes in
> the victims oom score.

Correction. You do not decay oom_badness. You simply increase a stall
counter anytime oom_badness hasn't changed since the last check (if that
check happend at least HZ/10 ago) and get the victim out of sight if the
counter is larger than 30. This is where 3s are coming from. So in fact
this is the low boundary while it might be considerably larger depending
on how often we examine the victim.

-- 
Michal Hocko
SUSE Labs

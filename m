Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id AA0386B0011
	for <linux-mm@kvack.org>; Tue, 20 Mar 2018 09:30:14 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id q6so884817pgv.12
        for <linux-mm@kvack.org>; Tue, 20 Mar 2018 06:30:14 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id t23-v6si1700581plo.637.2018.03.20.06.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Mar 2018 06:30:13 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm,oom_reaper: Show trace of unable to reap victim thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1521547076-3399-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20180320122818.GL23100@dhcp22.suse.cz>
	<201803202152.HED82804.QFOHLMVFFtOOJS@I-love.SAKURA.ne.jp>
	<20180320131953.GM23100@dhcp22.suse.cz>
In-Reply-To: <20180320131953.GM23100@dhcp22.suse.cz>
Message-Id: <201803202230.HDH17140.OFtMQJVLOOFHSF@I-love.SAKURA.ne.jp>
Date: Tue, 20 Mar 2018 22:30:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: linux-mm@kvack.org, rientjes@google.com

Michal Hocko wrote:
> On Tue 20-03-18 21:52:33, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > A single stack trace in the changelog would be sufficient IMHO.
> > > Appart from that. What do you expect users will do about this trace?
> > > Sure they will see a path which holds mmap_sem, we will see a bug report
> > > but we can hardly do anything about that. We simply cannot drop the lock
> > > from that path in 99% of situations. So _why_ do we want to add more
> > > information to the log?
> > 
> > This case is blocked at i_mmap_lock_write().
> 
> But why does i_mmap_lock_write matter for oom_reaping. We are not
> touching hugetlb mappings. dup_mmap holds mmap_sem for write which is
> the most probable source of the backoff.

If i_mmap_lock_write can bail out upon SIGKILL, the OOM victim will be able to
release mmap_sem held for write, which helps the OOM reaper not to back off.

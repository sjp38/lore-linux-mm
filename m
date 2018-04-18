Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 925626B0005
	for <linux-mm@kvack.org>; Wed, 18 Apr 2018 10:28:07 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id p131-v6so963648oig.10
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 07:28:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y23-v6si439629otj.370.2018.04.18.07.28.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 07:28:06 -0700 (PDT)
Subject: Re: [patch v2] mm, oom: fix concurrent munlock and oom reaper unmap
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20180418075051.GO17484@dhcp22.suse.cz>
	<201804182049.EDJ21857.OHJOMOLFQVFFtS@I-love.SAKURA.ne.jp>
	<20180418115830.GA17484@dhcp22.suse.cz>
	<201804182225.EII57887.OLMHOFVtQSFJOF@I-love.SAKURA.ne.jp>
	<20180418134401.GF17484@dhcp22.suse.cz>
In-Reply-To: <20180418134401.GF17484@dhcp22.suse.cz>
Message-Id: <201804182328.HIC57360.QHMFJtOLVFOSFO@I-love.SAKURA.ne.jp>
Date: Wed, 18 Apr 2018 23:28:01 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, aarcange@redhat.com, guro@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> > > > Then, I'm tempted to call __oom_reap_task_mm() before holding mmap_sem for write.
> > > > It would be OK to call __oom_reap_task_mm() at the beginning of __mmput()...
> > > 
> > > I am not sure I understand.
> > 
> > To reduce possibility of __oom_reap_task_mm() giving up reclaim and
> > setting MMF_OOM_SKIP.
> 
> Still do not understand. Do you want to call __oom_reap_task_mm from
> __mmput?

Yes.

>          If yes why would you do so when exit_mmap does a stronger
> version of it?

Because memory which can be reclaimed by the OOM reaper is guaranteed
to be reclaimed before setting MMF_OOM_SKIP when the OOM reaper and
exit_mmap() contended, because the OOM reaper (weak reclaim) sets
MMF_OOM_SKIP after one second for safety in case of exit_mmap()
(strong reclaim) failing to make forward progress.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 773F56B028B
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 11:46:11 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id a1-v6so3658110oti.8
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 08:46:11 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d7-v6sor2762335oia.45.2018.07.04.08.46.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 08:46:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180704075018.GE22503@dhcp22.suse.cz>
References: <CAM1WBjLv4tBm2nJTVo_aUrf3BkpkHrH3UpJv=C8r3V9-RO94vQ@mail.gmail.com>
 <20180704075018.GE22503@dhcp22.suse.cz>
From: Petros Angelatos <petrosagg@resin.io>
Date: Wed, 4 Jul 2018 18:45:48 +0300
Message-ID: <CAM1WBj+OQiADXxE2dv0BtS1BG+r_wdE_wTf0-LVq7nMPxgkPPQ@mail.gmail.com>
Subject: Re: Memory cgroup invokes OOM killer when there are a lot of dirty pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, lstoakes@gmail.com

> I assume dd just tried to fault a code page in and that failed due to
> the hard limit and unreclaimable memory. The reason why the memcg v1
> oom throttling heuristic hasn't kicked in is that there are no pages
> under writeback. This would match symptoms of the bug fixed by
> 1c610d5f93c7 ("mm/vmscan: wake up flushers for legacy cgroups too") in
> 4.16 but there might be more. You should have that fix already so there
> must be something more in the game. You've said that you are using blkio
> cgroup, right? What is the configuration? I strongly suspect that none
> of the writeback has started because of the throttling.

I'm only using a memory cgroup with no blkio restrictions so I'm not
sure why writeback hasn't started. Another thing I noticed is that
it's a lot harder to reproduce when the same amount of data is written
in a single file versus many smaller files. That's why my original
example code writes 500 files with 1MB of data.

Your mention of writeback gave me the idea to try and do a
sync_file_range() with SYNC_FILE_RANGE_WRITE after writing each file
to manually schedule writeback and surprisingly it fixed the problem.
Is that an indication of a bug in the kernel that doesn't trigger
writeback in time?

Also, you mentioned that the pagefault is probably due to a code page.
Would another remedy be to lock the whole executable and dynamic
libraries in memory with mlock() before starting the IO operations?

-- 
Petros Angelatos
CTO & Founder, Resin.io
BA81 DC1C D900 9B24 2F88  6FDD 4404 DDEE 92BF 1079

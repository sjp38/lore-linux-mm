Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3AC6B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 02:46:42 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b17-v6so2857238pff.17
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 23:46:42 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p21-v6si5135310plq.94.2018.07.04.23.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jul 2018 23:46:41 -0700 (PDT)
Date: Thu, 5 Jul 2018 08:46:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Memory cgroup invokes OOM killer when there are a lot of dirty
 pages
Message-ID: <20180705064637.GB32658@dhcp22.suse.cz>
References: <CAM1WBjLv4tBm2nJTVo_aUrf3BkpkHrH3UpJv=C8r3V9-RO94vQ@mail.gmail.com>
 <20180704075018.GE22503@dhcp22.suse.cz>
 <CAM1WBj+OQiADXxE2dv0BtS1BG+r_wdE_wTf0-LVq7nMPxgkPPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAM1WBj+OQiADXxE2dv0BtS1BG+r_wdE_wTf0-LVq7nMPxgkPPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petros Angelatos <petrosagg@resin.io>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, lstoakes@gmail.com

On Wed 04-07-18 18:45:48, Petros Angelatos wrote:
> > I assume dd just tried to fault a code page in and that failed due to
> > the hard limit and unreclaimable memory. The reason why the memcg v1
> > oom throttling heuristic hasn't kicked in is that there are no pages
> > under writeback. This would match symptoms of the bug fixed by
> > 1c610d5f93c7 ("mm/vmscan: wake up flushers for legacy cgroups too") in
> > 4.16 but there might be more. You should have that fix already so there
> > must be something more in the game. You've said that you are using blkio
> > cgroup, right? What is the configuration? I strongly suspect that none
> > of the writeback has started because of the throttling.
> 
> I'm only using a memory cgroup with no blkio restrictions so I'm not
> sure why writeback hasn't started. Another thing I noticed is that
> it's a lot harder to reproduce when the same amount of data is written
> in a single file versus many smaller files. That's why my original
> example code writes 500 files with 1MB of data.
> 
> Your mention of writeback gave me the idea to try and do a
> sync_file_range() with SYNC_FILE_RANGE_WRITE after writing each file
> to manually schedule writeback and surprisingly it fixed the problem.
> Is that an indication of a bug in the kernel that doesn't trigger
> writeback in time?

Yeah, it smells so. If you look at 1c610d5f93c7, we've had bug where we
even didn't kick flushers. So it seems they do not start to do a useful
work in time. I would start digging that direction.

> Also, you mentioned that the pagefault is probably due to a code page.
> Would another remedy be to lock the whole executable and dynamic
> libraries in memory with mlock() before starting the IO operations?

That looks like a big hammer to me.
-- 
Michal Hocko
SUSE Labs

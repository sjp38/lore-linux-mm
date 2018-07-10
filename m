Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id E57B86B0005
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 23:58:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id x18-v6so26421527oie.7
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 20:58:10 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id q6-v6si9517113oih.23.2018.07.09.20.58.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 20:58:08 -0700 (PDT)
Message-Id: <201807100357.w6A3vv5o062894@www262.sakura.ne.jp>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup problem.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Tue, 10 Jul 2018 12:57:57 +0900
References: <201807060240.w662e7Q1016058@www262.sakura.ne.jp> <20180706055644.GG32658@dhcp22.suse.cz>
In-Reply-To: <20180706055644.GG32658@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, rientjes@google.com

> On Fri 06-07-18 11:40:07, Tetsuo Handa wrote:
> > > > > > Of course, we don't have to remove the OOM reaper kernel thread.
> > > > > 
> > > > > The thing is that the current design uses the oom_reaper only as a
> > > > > backup to get situation unstuck. Once you move all that heavy lifting
> > > > > into the oom path directly then you will have to handle all sorts of
> > > > > issues. E.g. how do you handle that a random process hitting OOM path
> > > > > has to pay the full price to tear down multi TB process? This is a lot
> > > > > of time.
> > > > 
> > > > We can add a threshold to unmap_page_range() (for direct OOM reaping threads)
> > > > which aborts after given number of pages are reclaimed. There is no need to
> > > > reclaim all pages at once if the caller is doing memory allocations. 
> > > 
> > > Yes, there is no need to reclaim all pages. OOM is after freeing _some_
> > > memory after all. But that means further complications down the unmap
> > > path. I do not really see any reason for that.
> > 
> > "I do not see reason for that" cannot become a reason direct OOM reaping has to
> > reclaim all pages at once.
> 
> We are not going to polute deep mm guts for unlikely events like oom.
> 
As far as I tested, below approach does not pollute deep mm guts. It should
achieve what David wants to do, without introducing user-visible tunable
interface.

David, can you try these patches?

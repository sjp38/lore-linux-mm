Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B6617440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 06:04:44 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id r127so9057681itb.4
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 03:04:44 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id f25si5780096ioj.105.2017.11.09.03.04.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 03:04:43 -0800 (PST)
Subject: Re: [PATCH v4] printk: Add console owner and waiter logic to loadbalance console writes
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171108102723.602216b1@gandalf.local.home>
	<20171109101138.qmy3366myzjafexr@dhcp22.suse.cz>
	<201711091922.IHJ81787.OVQFFJOSOLtHMF@I-love.SAKURA.ne.jp>
	<20171109102613.hp6waybyxbkb3crz@dhcp22.suse.cz>
In-Reply-To: <20171109102613.hp6waybyxbkb3crz@dhcp22.suse.cz>
Message-Id: <201711092003.ACJ86411.FOFtFMVOJOSLHQ@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 20:03:30 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rostedt@goodmis.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, pmladek@suse.com, sergey.senozhatsky@gmail.com, vbabka@suse.cz, peterz@infradead.org, torvalds@linux-foundation.org, jack@suse.cz, mathieu.desnoyers@efficios.com, rostedt@home.goodmis.org

Michal Hocko wrote:
> On Thu 09-11-17 19:22:58, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > Hi,
> > > assuming that this passes warn stall torturing by Tetsuo, do you think
> > > we can drop http://lkml.kernel.org/r/1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
> > > from the mmotm tree?
> > 
> > I don't think so.
> > 
> > The rule that "do not try to printk() faster than the kernel can write to
> > consoles" will remain no matter how printk() changes. Unless asynchronous
> > approach like https://lwn.net/Articles/723447/ is used, I think we can't
> > obtain useful information.
> 
> Does that mean that the patch doesn't pass your test?
> 

Test is irrelevant. See the changelog.

  Synchronous approach is prone to unexpected results (e.g. too late [1], too
  frequent [2], overlooked [3]). As far as I know, warn_alloc() never helped
  with providing information other than "something is going wrong".
  I want to consider asynchronous approach which can obtain information
  during stalls with possibly relevant threads (e.g. the owner of oom_lock
  and kswapd-like threads) and serve as a trigger for actions (e.g. turn
  on/off tracepoints, ask libvirt daemon to take a memory dump of stalling
  KVM guest for diagnostic purpose).

  [1] https://bugzilla.kernel.org/show_bug.cgi?id=192981
  [2] http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMcBjBFyM_A@mail.gmail.com
  [3] commit db73ee0d46379922 ("mm, vmscan: do not loop on too_many_isolated for ever")

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

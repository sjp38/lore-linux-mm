Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AB786B0279
	for <linux-mm@kvack.org>; Thu,  1 Jun 2017 09:11:29 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id h4so45673158oib.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 06:11:29 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t4si839179otc.66.2017.06.01.06.11.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Jun 2017 06:11:27 -0700 (PDT)
Subject: Re: [PATCH] mm,page_alloc: Serialize warn_alloc() if schedulable.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1496317427-5640-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170601115936.GA9091@dhcp22.suse.cz>
In-Reply-To: <20170601115936.GA9091@dhcp22.suse.cz>
Message-Id: <201706012211.GHI18267.JFOVMSOLFFQHOt@I-love.SAKURA.ne.jp>
Date: Thu, 1 Jun 2017 22:11:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, xiyou.wangcong@gmail.com, dave.hansen@intel.com, hannes@cmpxchg.org, mgorman@suse.de, vbabka@suse.cz

Michal Hocko wrote:
> On Thu 01-06-17 20:43:47, Tetsuo Handa wrote:
> > Cong Wang has reported a lockup when running LTP memcg_stress test [1].
>
> This seems to be on an old and not pristine kernel. Does it happen also
> on the vanilla up-to-date kernel?

4.9 is not an old kernel! It might be close to the kernel version which
enterprise distributions would choose for their next long term supported
version.

And please stop saying "can you reproduce your problem with latest
linux-next (or at least latest linux)?" Not everybody can use the vanilla
up-to-date kernel!

What I'm pushing via kmallocwd patch is to prepare for overlooked problems
so that enterprise distributors can collect information and identify what
changes are needed to be backported.

As long as you ignore problems not happened with latest linux-next (or
at least latest linux), enterprise distribution users can do nothing.

>
> [...]
> > Therefore, this patch uses a mutex dedicated for warn_alloc() like
> > suggested in [3].
>
> As I've said previously. We have rate limiting and if that doesn't work
> out well, let's tune it. The lock should be the last resort to go with.
> We already throttle show_mem, maybe we can throttle dump_stack as well,
> although it sounds a bit strange that this adds so much to the picture.

Ratelimiting never works well. It randomly drops information which is
useful for debugging. Uncontrolled concurrent dump_stack() causes lockups.
And restricting dump_stack() drops more information.

What we should do is to yield CPU time to operations which might do useful
things (let threads not doing memory allocation; e.g. let printk kernel
threads to flush pending buffer, let console drivers write the output to
consoles, let watchdog kernel threads report what is happening).

When memory allocation request is stalling, serialization via waiting
for a lock does help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

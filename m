Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 4270B6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 11:27:53 -0400 (EDT)
Received: by padj3 with SMTP id j3so45840371pad.0
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 08:27:52 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ah3si22005212pad.55.2015.06.01.08.27.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 08:27:52 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150601101646.GC7147@dhcp22.suse.cz>
	<201506012102.CBE60453.FOQtFJLFSHOOVM@I-love.SAKURA.ne.jp>
	<20150601121508.GF7147@dhcp22.suse.cz>
	<201506012204.GIF87536.LFMtOOOVJFFSQH@I-love.SAKURA.ne.jp>
	<20150601131215.GI7147@dhcp22.suse.cz>
In-Reply-To: <20150601131215.GI7147@dhcp22.suse.cz>
Message-Id: <201506020027.CJI18736.FJLVtFQOHMFOSO@I-love.SAKURA.ne.jp>
Date: Tue, 2 Jun 2015 00:27:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> On Mon 01-06-15 22:04:28, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Likewise, move do_send_sig_info(SIGKILL, victim) to before
> > > > mark_oom_victim(victim) in case for_each_process() took very long time,
> > > > for the OOM victim can abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE via e.g.
> > > > memset() in user space until SIGKILL is delivered.
> > > 
> > > This is unrelated and I believe even not necessary.
> > 
> > Why unnecessary? If serial console is configured and printing a series of
> > "Kill process %d (%s) sharing same memory" took a few seconds, the OOM
> > victim can consume all memory via malloc() + memset(), can't it?
> 
> Can? You are generating one corner case after another. All of them
> without actually showing it can happen in the real life. There are
> million+1 corner cases possible yet we would prefer to handle those that
> have changes to happen in the real life. So let's focus on the real life
> scenarios.

I worked at support center for three years. I saw many unexplained hangup
cases. Some of them could be caused by these corner cases. But I can't prove
that it happened in the real life because I don't have reproducer for hangups
occurred in customer's systems. Analyzing syslog / vmcore did not help because
memory allocator gives me no hints. What I can do is to imagine possible
corner cases, but my goal is not to identify all corner cases. My goal is to
propose a backportable workaround that enterprise customers can use now.
While I feel sorry for bothering you, I also feel sorry for customers for
not being able to offer one. "[PATCH] mm: Introduce timeout based OOM killing"
is what I can come up with, without identifying one corner case after another.

I've been asking for backportable workaround for many months. I spent time for
finding potential bugs ( http://marc.info/?l=linux-mm&m=141684929114209 ).
If you are already aware that there are million+1 corner cases possible yet
(that is, we have too many potential bugs to identify and fix), why do you
keep refusing to offer for-now workaround (that is, paper over potential
bugs) ? I don't want to see customers and support staff suffering with OOM
corner cases any more...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

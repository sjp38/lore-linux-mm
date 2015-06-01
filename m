Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F112A6B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 09:04:32 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so36718123pad.2
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 06:04:32 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id yo4si12586677pac.203.2015.06.01.06.04.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 06:04:31 -0700 (PDT)
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory" message.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
	<201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
	<20150601101646.GC7147@dhcp22.suse.cz>
	<201506012102.CBE60453.FOQtFJLFSHOOVM@I-love.SAKURA.ne.jp>
	<20150601121508.GF7147@dhcp22.suse.cz>
In-Reply-To: <20150601121508.GF7147@dhcp22.suse.cz>
Message-Id: <201506012204.GIF87536.LFMtOOOVJFFSQH@I-love.SAKURA.ne.jp>
Date: Mon, 1 Jun 2015 22:04:28 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org

Michal Hocko wrote:
> > Likewise, move do_send_sig_info(SIGKILL, victim) to before
> > mark_oom_victim(victim) in case for_each_process() took very long time,
> > for the OOM victim can abuse ALLOC_NO_WATERMARKS by TIF_MEMDIE via e.g.
> > memset() in user space until SIGKILL is delivered.
> 
> This is unrelated and I believe even not necessary.

Why unnecessary? If serial console is configured and printing a series of
"Kill process %d (%s) sharing same memory" took a few seconds, the OOM
victim can consume all memory via malloc() + memset(), can't it?
What to do if the OOM victim cannot die immediately after consuming
all memory? I think that sending SIGKILL before setting TIF_MEMDIE
helps reducing consumption of memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

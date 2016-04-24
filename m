Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D7D156B0005
	for <linux-mm@kvack.org>; Sun, 24 Apr 2016 10:19:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b203so39218304pfb.1
        for <linux-mm@kvack.org>; Sun, 24 Apr 2016 07:19:12 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n5si8494700pax.112.2016.04.24.07.19.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 24 Apr 2016 07:19:11 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timeout.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160419200752.GA10437@dhcp22.suse.cz>
	<201604200655.HDH86486.HOStQFJFLOMFOV@I-love.SAKURA.ne.jp>
	<20160420144758.GA7950@dhcp22.suse.cz>
	<201604212049.GFE34338.OQFOJSMOHFFLVt@I-love.SAKURA.ne.jp>
	<20160421130750.GA18427@dhcp22.suse.cz>
In-Reply-To: <20160421130750.GA18427@dhcp22.suse.cz>
Message-Id: <201604242319.GAF12996.tOJMOQFLFVOHSF@I-love.SAKURA.ne.jp>
Date: Sun, 24 Apr 2016 23:19:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org

Michal Hocko wrote:
> I have seen that patch. I didn't get to review it properly yet as I am
> still travelling. From a quick view I think it is conflating two things
> together. I could see arguments for the panic part but I do not consider
> the move-to-kill-another timeout as justified. I would have to see a
> clear indication this is actually useful for real life usecases.

You admit that it is possible that the TIF_MEMDIE thread is blocked at
unkillable wait (due to memory allocation requests by somebody else) but
the OOM reaper cannot reap the victim's memory (due to holding the mmap_sem
for write), don't you?

Then, I think this patch makes little sense unless accompanied with the
move-to-kill-another timeout. If the OOM reaper failed to reap the victim's
memory, the OOM reaper simply clears TIF_MEMDIE from the victim thread. But
since nothing has changed (i.e. the victim continues waiting, and the victim's
memory is not reclaimed, and the victim's oom_score_adj is not updated to
OOM_SCORE_ADJ_MIN), the OOM killer will select that same victim again.
This forms an infinite loop. You will want to call panic() as soon as the OOM
reaper failed to reap the victim's memory (than waiting for the panic timeout).

For both system operators at customer's companies and staffs at support center,
avoiding hangup (due to OOM livelock) and panic (due to the OOM panic timeout)
eliminates a lot of overhead. This is a practical benefit for them.

I also think that the purpose of killing only one task at a time than calling
panic() is to save as much work as possible. Therefore, I can't understand why
you don't think that killing only another task via the move-to-kill-another
timeout is a useful real life usecase.

panic on timeout is a practical benefit for you, but giving several chances
on timeout is a practical benefit for someone you don't know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2AD776B0005
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 22:12:21 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id w17so8635667iow.23
        for <linux-mm@kvack.org>; Thu, 25 Jan 2018 19:12:21 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t73si119994ioi.54.2018.01.25.19.12.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Jan 2018 19:12:19 -0800 (PST)
Message-Id: <201801260312.w0Q3C0tr067684@www262.sakura.ne.jp>
Subject: Re: [PATCH 1/2] mm,vmscan: Kill global shrinker lock.
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
MIME-Version: 1.0
Date: Fri, 26 Jan 2018 12:12:00 +0900
References: <201801251956.FAH73425.VFJLFFtSHOOMQO@I-love.SAKURA.ne.jp> <alpine.LRH.2.11.1801252209010.6864@mail.ewheeler.net>
In-Reply-To: <alpine.LRH.2.11.1801252209010.6864@mail.ewheeler.net>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Wheeler <linux-mm@lists.ewheeler.net>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, hannes@cmpxchg.org, minchan@kernel.org, ying.huang@intel.com, mgorman@techsingularity.net, vdavydov.dev@gmail.com, akpm@linux-foundation.org, shakeelb@google.com, gthelen@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Eric Wheeler wrote:
> Hi Tetsuo,
> 
> Thank you for looking into this!
> 
> I tried running this C program in 4.14.15 but did not get a deadlock, just 
> OOM kills. Is the patch required to induce the deadlock?

This reproducer must not trigger actual deadlock. Running this reproducer
with this patch applied causes lockdep warning. I just tried to suggest
possibility that making shrink_slab() suddenly no-op might cause unexpected
results. We still don't know what is happening in your case.

> 
> Also, what are you doing to XFS to make it trigger?

Nothing.



Would you answer to Michal's questions

  Is this a permanent state or does the holder eventually releases the lock?

  Do you remember the last good kernel?

and my guess

  Since commit 0bcac06f27d75285 was not backported to 4.14-stable kernel,
  this is unlikely the bug introduced by 0bcac06f27d75285 unless Eric
  explicitly backported 0bcac06f27d75285.

?

Can you take SysRq-t (e.g. "echo t > /proc/sysrq-trigger") when processes
got stuck? I think that we need to know what other threads are doing when
__lock_page() is waiting in order to distinguish "somebody forgot to unlock
the page" and "somebody is still doing something (e.g. waiting for memory
allocation) in order to unlock the page".

If you can take SysRq-t, taking SysRq-t with
http://lkml.kernel.org/r/1510833448-19918-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp
applied and built with CONFIG_DEBUG_SHOW_MEMALLOC_LINE=y should give us
more clues (e.g. how long threads are waiting for memory allocation).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

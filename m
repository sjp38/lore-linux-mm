Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7E10E6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 18:04:12 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id td3so107000572pab.2
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 15:04:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 67si16128362pfh.155.2016.03.28.15.04.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Mar 2016 15:04:11 -0700 (PDT)
Date: Mon, 28 Mar 2016 15:04:10 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] signal: Make oom_flags a bool
Message-Id: <20160328150410.386e0435fdb16c8069ce40f5@linux-foundation.org>
In-Reply-To: <1458560293-24074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
References: <1458560293-24074-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, Hugh Dickins <hughd@google.com>

On Mon, 21 Mar 2016 20:38:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Currently the size of "struct signal_struct"->oom_flags member is
> sizeof(unsigned) bytes, but only one flag OOM_FLAG_ORIGIN which is
> updated by current thread is defined. We can convert OOM_FLAG_ORIGIN
> into a bool, and reuse the saved bytes for updating from the OOM killer
> and/or the OOM reaper thread.
> 
> By the way, do we care about a race window between run_store() and
> swapoff() because it would be theoretically possible that two threads
> sharing the "struct signal_struct" concurrently call respective
> functions? If we care, we can make oom_flags an atomic_t.

Making oom_flags atomic wouldn't fix such a race - run_store() and
swapoff() could still much with each other's state.

But no, I don't think it matters a lot - worst case is that the "wrong"
process gets oom-killed.  I think.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

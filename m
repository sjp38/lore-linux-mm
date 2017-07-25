Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 03C496B025F
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 14:26:26 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so76268060qkb.3
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:26:26 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 35si11370910qtt.80.2017.07.25.11.26.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 11:26:25 -0700 (PDT)
Date: Tue, 25 Jul 2017 20:26:19 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
Message-ID: <20170725182619.GQ29716@redhat.com>
References: <20170724072332.31903-1-mhocko@kernel.org>
 <20170725152639.GP29716@redhat.com>
 <20170725154514.GN26723@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170725154514.GN26723@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 25, 2017 at 05:45:14PM +0200, Michal Hocko wrote:
> That problem is real though as reported by David.

I'm not against fixing it, I just think it's not a major concern, and
the solution doesn't seem optimal as measured by Kirill.

I'm just skeptical it's the best to solve that tiny race, 99.9% of the
time such down_write is unnecessary.

> it is not only about exit_mmap. __mmput calls into exit_aio and that can
> wait for completion and there is no way to guarantee this will finish in
> finite time.

exit_aio blocking is actually the only good point for wanting this
concurrency where exit_mmap->unmap_vmas and
oom_reap_task->unmap_page_range have to run concurrently on the same
mm.

exit_mmap would have no issue, if there was enough time in the
lifetime CPU to allocate the memory, sure the memory will also be
freed in finite amount of time by exit_mmap.

In fact you mentioned multiple OOM in the NUMA case, exit_mmap may not
solve that, so depending on the runtime it may have been better not to
wait all memory of the process to be freed before moving to the next
task, but only a couple of seconds before the OOM reaper moves to a
new candidate. Again this is only a tradeoff between solving the OOM
faster vs risk of false positives OOM.

If it wasn't because of exit_aio (which may have to wait I/O
completion), changing the OOM reaper to return "false" if
mmget_not_zero returns zero and MMF_OOM_SKIP is not set yet, would
have been enough (and depending on the runtime it may have solved OOM
faster in NUMA) and there would be absolutely no need to run OOM
reaper and exit_mmap concurrently on the same mm. However there's such
exit_aio..

Raw I/O mempools never require memory allocations, although aio if it
involves a filesystem to complete may run into filesystem or buffering
locks which are known to loop forever or depend on other tasks stuck
in kernel allocations, so I didn't go down that chain too long.

So the simplest is to use a similar trick to what ksm_exit uses, this
is untested just to show the idea it may require further adjustment as
the bit isn't used only for the test_and_set_bit locking, but I didn't
see much issues with other set_bit/test_bit.

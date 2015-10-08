Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id EF9386B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 10:01:57 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so26846624wic.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 07:01:57 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id lb9si47981456wjb.188.2015.10.08.07.01.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 07:01:56 -0700 (PDT)
Received: by wicfx3 with SMTP id fx3so26698115wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 07:01:56 -0700 (PDT)
Date: Thu, 8 Oct 2015 16:01:55 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20151008140155.GB426@dhcp22.suse.cz>
References: <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
 <20150920125642.GA2104@redhat.com>
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com>
 <20150921142423.GC19811@dhcp22.suse.cz>
 <20150921153252.GA21988@redhat.com>
 <20150921161203.GD19811@dhcp22.suse.cz>
 <20150922160608.GA2716@redhat.com>
 <20150923205923.GB19054@dhcp22.suse.cz>
 <20151006184502.GA15787@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151006184502.GA15787@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Tue 06-10-15 20:45:02, Oleg Nesterov wrote:
[...]
> And I was going to make V1 which avoids queue_work/kthread and zaps the
> memory in oom_kill_process() context.
> 
> But this can't work because we need to increment ->mm_users to avoid
> the race with exit_mmap/etc. And this means that we need mmput() after
> that, and as we recently discussed it can deadlock if mm_users goes
> to zero, we can't do exit_mmap/etc in oom_kill_process().

Right. I hoped we could rely on mm_count just to pin mm but that is not
sufficient because exit_mmap doesn't rely on mmap_sem so we do not have
any synchronization there. Unfortunate. This means that we indeed have
to do it asynchronously. Maybe we can come up with some trickery but
let's do it later. I do agree that going with a kernel thread for now
would be easier. Sorry about misleading you, I should have realized that
mmput from the oom killing path is dangerous.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

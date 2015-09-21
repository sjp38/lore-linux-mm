Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 2E5046B025B
	for <linux-mm@kvack.org>; Mon, 21 Sep 2015 10:24:28 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so114266764wic.1
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:24:27 -0700 (PDT)
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com. [209.85.212.178])
        by mx.google.com with ESMTPS id gg17si31513309wjc.5.2015.09.21.07.24.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 07:24:26 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so149179718wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 07:24:26 -0700 (PDT)
Date: Mon, 21 Sep 2015 16:24:24 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: can't oom-kill zap the victim's memory?
Message-ID: <20150921142423.GC19811@dhcp22.suse.cz>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
 <20150920125642.GA2104@redhat.com>
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
 <20150921134414.GA15974@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150921134414.GA15974@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Mon 21-09-15 15:44:14, Oleg Nesterov wrote:
[...]
> So yes, in general oom_kill_process() can't call oom_unmap_func() directly.
> That is why the patch uses queue_work(oom_unmap_func). The workqueue thread
> takes mmap_sem and frees the memory allocated by user space.

OK, this might have been a bit confusing. I didn't mean you cannot use
mmap_sem directly from the workqueue context. You _can_ AFAICS. But I've
mentioned that you _shouldn't_ use workqueue context in the first place
because all the workers might be blocked on locks and new workers cannot
be created due to memory pressure. This has been demostrated already
where sysrq+f couldn't trigger OOM killer because the work item to do so
was waiting for a worker which never came...

So I think we probably need to do this in the OOM killer context (with
try_lock) or hand over to a special kernel thread. I am not sure a
special kernel thread is really worth that but maybe it will turn out to
be a better choice.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f182.google.com (mail-io0-f182.google.com [209.85.223.182])
	by kanga.kvack.org (Postfix) with ESMTP id EDD9F6B0253
	for <linux-mm@kvack.org>; Sat, 19 Sep 2015 19:13:09 -0400 (EDT)
Received: by ioii196 with SMTP id i196so89112150ioi.3
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 16:13:09 -0700 (PDT)
Received: from mail-io0-x235.google.com (mail-io0-x235.google.com. [2607:f8b0:4001:c06::235])
        by mx.google.com with ESMTPS id m191si12506180ioe.61.2015.09.19.16.13.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 19 Sep 2015 16:13:09 -0700 (PDT)
Received: by ioiz6 with SMTP id z6so88557598ioi.2
        for <linux-mm@kvack.org>; Sat, 19 Sep 2015 16:13:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55FDE90D.1070402@gmail.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
	<CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
	<55FDE90D.1070402@gmail.com>
Date: Sat, 19 Sep 2015 16:13:09 -0700
Message-ID: <CA+55aFwZmU1uqYEci_g6oX80V+YEezQbsANzBUNS_QM-ADyscg@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raymond Jennings <shentino@gmail.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Sat, Sep 19, 2015 at 4:00 PM, Raymond Jennings <shentino@gmail.com> wrote:
>
> Potentially stupid question that others may be asking: Is it legal to return
> EINTR from mmap() to let a SIGKILL from the OOM handler punch the task out
> of the kernel and back to userspace?

Yes. Note that mmap() itself seldom sleeps or allocates much memory
(yeah, there's the vma itself and soem minimal stuff), so it's mainly
an issue for things like MAP_POPULATE etc.

The more common situation is things like uninterruptible reads when a
device (or network) is not responding, and we have special support for
"killable" waits that act like normal uninterruptible waits but can be
interrupted by deadly signals, exactly because for those cases we
don't need to worry about things like POSIX return value guarantees
("all or nothing" for file reads) etc.

So you do generally have to write extra code for the "killable sleep".
But it's a good thing to do, if you notice that certain cases aren't
responding well to oom killing because they keep on waiting.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

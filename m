Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id E0479828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 07:08:33 -0400 (EDT)
Received: by mail-ig0-f173.google.com with SMTP id gy3so115167698igb.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 04:08:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 3si26929679iob.32.2016.04.13.04.08.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 04:08:33 -0700 (PDT)
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skip regular OOM killer path
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160408115033.GH29820@dhcp22.suse.cz>
	<201604091339.FAJ12491.FVHQFFMSJLtOOO@I-love.SAKURA.ne.jp>
	<20160411120238.GF23157@dhcp22.suse.cz>
	<201604112226.IFC52662.FOFVtQSJLOFMOH@I-love.SAKURA.ne.jp>
	<20160411134321.GI23157@dhcp22.suse.cz>
In-Reply-To: <20160411134321.GI23157@dhcp22.suse.cz>
Message-Id: <201604132008.CHC00016.FOQVOFtMJLSHOF@I-love.SAKURA.ne.jp>
Date: Wed, 13 Apr 2016 20:08:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

Michal Hocko wrote:
> There are many other possible reasons for thses symptoms. Have you
> actually seen any _evidence_ they the hang they are seeing is due to
> oom deadlock, though. A single crash dump or consistent sysrq output
> which would point that direction.

Yes. I saw several OOM livelock cases occurred in the customer's servers.

One case I was able to identify the cause was request_module() local DoS
( https://bugzilla.redhat.com/show_bug.cgi?id=CVE-2012-4398 ). That server
was running Java based enterprise application. The java process tried to
create IPv6 socket on a system where IPv6 was configured to be disabled,
and request_module() was every time called from socket() syscall for trying
to load ipv6.ko module, and the OOM killer was invoked and the java process
was selected for the OOM victim, and since request_module() was not killable,
the system got the OOM livelock.

Another case I saw is interrupts from virtio being disabled due to a bug in
qemu-kvm. Since the cron daemon continuously starts cron jobs even after
storage I/O started stalling (because the qemu-kvm stopped sending interrupts),
all memory was consumed for cron jobs and async file write requests, and the
OOM killer was invoked. And since a cron job which was selected as the OOM
victim while trying to write to file was unable to terminate due to waiting
for fs writeback, the system got the OOM livelock.

Yet another case I saw is a hangup where a process is blocked at
down_read(&mm->mmap_sem) in __access_remote_vm() while reading /proc/pid/
entries. Since I had zero knowledge about OOM livelock at that time, I was
not able to tell whether it was an OOM livelock or not.

There would be some more, but I can't recall them because I left the support
center one year ago and I have no chance to re-examine these cases.

But in general, it is rare that I can find the OOM killer messages
because their servers are force rebooted without capturing kdump or SysRq.
Hints I can use are limited to /var/log/messages which lacks suspicious
messages, /var/log/sa/ which shows that there was little free memory and
/proc/sys/kernel/hung_task_warnings already being 0 (if sosreport is also
provided).

> > I'm suggesting you to at least emit diagnostic messages when something went
> > wrong. That is what kmallocwd is for. And if you do not want to emit
> > diagnostic messages, I'm fine with timeout based approach.
>
> I am all for more diagnostic but what you were proposing was so heavy
> weight it doesn't really seem worth it.

I suspect that the reason hung_task_warnings becomes 0 is related to
use of the same watermark for GFP_KERNEL/GFP_NOFS/GFP_NOIO, but I can't
ask customers to replace their kernels for debugging. So, the first step is
to merge kmallocwd upstream, then wait until customers start using that
kernel (it may be within a few months if they are about to develop a new
server, but it may be 10 years away if they already decided not to update
kernels for their servers' lifetime).

> Anyway yet again this is getting largely off-topic...

OK. I'll stop posting to this thread.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

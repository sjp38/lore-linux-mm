Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id C53A66B025E
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 00:05:38 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id a12so13949411qka.7
        for <linux-mm@kvack.org>; Fri, 06 Oct 2017 21:05:38 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g67si2146671iof.390.2017.10.06.21.05.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 06 Oct 2017 21:05:37 -0700 (PDT)
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is killed"
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20171004231821.GA3610@cmpxchg.org>
	<20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
	<55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
	<ceb25fb9-de4d-e401-6d6d-ce240705483c@I-love.SAKURA.ne.jp>
	<20171007025131.GA12944@cmpxchg.org>
In-Reply-To: <20171007025131.GA12944@cmpxchg.org>
Message-Id: <201710071305.GJF12474.HSOtLFFJVQFOOM@I-love.SAKURA.ne.jp>
Date: Sat, 7 Oct 2017 13:05:24 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hannes@cmpxchg.org
Cc: akpm@linux-foundation.org, mhocko@kernel.org, alan@llwyncelyn.cymru, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Johannes Weiner wrote:
> On Sat, Oct 07, 2017 at 11:21:26AM +0900, Tetsuo Handa wrote:
> > On 2017/10/05 19:36, Tetsuo Handa wrote:
> > > I don't want this patch backported. If you want to backport,
> > > "s/fatal_signal_pending/tsk_is_oom_victim/" is the safer way.
> > 
> > If you backport this patch, you will see "complete depletion of memory reserves"
> > and "extra OOM kills due to depletion of memory reserves" using below reproducer.
> > 
> > ----------
> > #include <linux/module.h>
> > #include <linux/slab.h>
> > #include <linux/oom.h>
> > 
> > static char *buffer;
> > 
> > static int __init test_init(void)
> > {
> > 	set_current_oom_origin();
> > 	buffer = vmalloc((1UL << 32) - 480 * 1048576);
> 
> That's not a reproducer, that's a kernel module. It's not hard to
> crash the kernel from within the kernel.
> 

When did we agree that "reproducer" is "userspace program" ?
A "reproducer" is a program that triggers something intended.

Year by year, people are spending efforts for kernel hardening.
It is silly to say that "It's not hard to crash the kernel from
within the kernel." when we can easily mitigate.

Even with cd04ae1e2dc8, there is no point with triggering extra
OOM kills by needlessly consuming memory reserves.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

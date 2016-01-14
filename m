Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f49.google.com (mail-wm0-f49.google.com [74.125.82.49])
	by kanga.kvack.org (Postfix) with ESMTP id 7BBA1828DF
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 06:00:47 -0500 (EST)
Received: by mail-wm0-f49.google.com with SMTP id f206so339100037wmf.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 03:00:47 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id gj5si8773567wjb.86.2016.01.14.03.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 03:00:43 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id f206so339096552wmf.0
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 03:00:42 -0800 (PST)
Date: Thu, 14 Jan 2016 12:00:38 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
Message-ID: <20160114110037.GC29943@dhcp22.suse.cz>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org>
 <1452632425-20191-2-git-send-email-mhocko@kernel.org>
 <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com>
 <20160113093046.GA28942@dhcp22.suse.cz>
 <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Wed 13-01-16 16:38:26, David Rientjes wrote:
> On Wed, 13 Jan 2016, Michal Hocko wrote:
[...]
> > > I think it would be 
> > > better for sysrq+f to first select a process with fatal_signal_pending() 
> > > set so it silently gets access to memory reserves and then a second 
> > > sysrq+f to choose a different process, if necessary, because of 
> > > TIF_MEMDIE.
> > 
> > The disadvantage of this approach is that sysrq+f might silently be
> > ignored and the administrator doesn't have any signal about that.

Sorry I meant to say "administrator doesn't know why it has been
ignored". But it would have been better to say "administrator cannot do
anything about that".

> The administrator can check the kernel log for an oom kill.

What should the admin do when the request got ignored, though? sysrq+i?
sysrq+b?

> Killing additional processes is not going to help

Whether it is going to help or not is a different topic. My point is
that we have a sysrq action which might get ignored without providing
any explanation. But what I consider much bigger issue is that the
deliberate request of the admin is ignored in the first place. Me as an
admin do not expect the system knows better than me when I perform some
action.

> and has never been the semantics 
> of the sysrq trigger, it is quite clearly defined as killing a process 
> when out of memory,

I disagree. Being OOM has never been the requirement for sysrq+f to kill
a task. It should kill _a_ memory hog. Your system might be trashing to
the point you are not able to log in and resolve the situation in a
reasonable time yet you are still not OOM. sysrq+f is your only choice
then.

> not serial killing everything on the machine.

Which is not proposed here. The only thing I would like to achive is to
get rid of OOM killer heuristics which assume some forward progress in
order to prevent from killing a task. Those make perfect sense when the
system tries to resolve the OOM condition but when the administrator has
clearly asked to _kill_a_ memory hog then the result should be killing a
task which consumes memory (ideally the largest one).

What would be a regression scenario for this change? I can clearly see
deficiency of the current implementation so we should weigh cons and
pros here I believe.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

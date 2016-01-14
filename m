Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f182.google.com (mail-pf0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 363196B0264
	for <linux-mm@kvack.org>; Thu, 14 Jan 2016 16:51:19 -0500 (EST)
Received: by mail-pf0-f182.google.com with SMTP id 65so106112367pff.2
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 13:51:19 -0800 (PST)
Received: from mail-pf0-x236.google.com (mail-pf0-x236.google.com. [2607:f8b0:400e:c00::236])
        by mx.google.com with ESMTPS id bs10si11646408pad.73.2016.01.14.13.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jan 2016 13:51:18 -0800 (PST)
Received: by mail-pf0-x236.google.com with SMTP id q63so109297315pfb.1
        for <linux-mm@kvack.org>; Thu, 14 Jan 2016 13:51:18 -0800 (PST)
Date: Thu, 14 Jan 2016 13:51:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/3] oom, sysrq: Skip over oom victims and killed tasks
In-Reply-To: <20160114110037.GC29943@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1601141347220.16227@chino.kir.corp.google.com>
References: <1452632425-20191-1-git-send-email-mhocko@kernel.org> <1452632425-20191-2-git-send-email-mhocko@kernel.org> <alpine.DEB.2.10.1601121639450.28831@chino.kir.corp.google.com> <20160113093046.GA28942@dhcp22.suse.cz> <alpine.DEB.2.10.1601131633550.3406@chino.kir.corp.google.com>
 <20160114110037.GC29943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, LKML <linux-kernel@vger.kernel.org>

On Thu, 14 Jan 2016, Michal Hocko wrote:

> > > > I think it would be 
> > > > better for sysrq+f to first select a process with fatal_signal_pending() 
> > > > set so it silently gets access to memory reserves and then a second 
> > > > sysrq+f to choose a different process, if necessary, because of 
> > > > TIF_MEMDIE.
> > > 
> > > The disadvantage of this approach is that sysrq+f might silently be
> > > ignored and the administrator doesn't have any signal about that.
> 
> Sorry I meant to say "administrator doesn't know why it has been
> ignored". But it would have been better to say "administrator cannot do
> anything about that".
> 
> > The administrator can check the kernel log for an oom kill.
> 
> What should the admin do when the request got ignored, though? sysrq+i?
> sysrq+b?
> 

We're not striving for a solution to general process exiting issues or oom 
livelock situations by requiring admins to use a sysrq trigger.  Sysrq+F 
could arguably be removed at this point since it solely existed to trigger 
the oom killer when newly rewritten reclaim thrashed and the page 
allocator didn't call it fast enough.  Since the oom killer allows killed 
processes to gain access to memory reserves, we could extend that to 
contexts that do not allow calling the oom killer to set TIF_MEMDIE, and 
then simply require root to send a SIGKILL rather than do sysrq+F.  I 
think it's time to kill sysrq+F and I'll send those two patches unless 
there is a usecase I'm not aware of.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

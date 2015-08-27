Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id DE58B6B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 16:52:49 -0400 (EDT)
Received: by pabzx8 with SMTP id zx8so37332779pab.1
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:52:49 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id e5si5838310pds.29.2015.08.27.13.52.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 13:52:48 -0700 (PDT)
Received: by pacdd16 with SMTP id dd16so37162210pac.2
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 13:52:48 -0700 (PDT)
Date: Thu, 27 Aug 2015 13:52:47 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm, oom: add global access to memory reserves on
 livelock
In-Reply-To: <20150827124122.GD27052@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1508271345330.30543@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1508201358490.607@chino.kir.corp.google.com> <20150821081745.GG23723@dhcp22.suse.cz> <alpine.DEB.2.10.1508241358230.32561@chino.kir.corp.google.com> <20150825142503.GE6285@dhcp22.suse.cz> <alpine.DEB.2.10.1508251635560.10653@chino.kir.corp.google.com>
 <20150826070127.GB25196@dhcp22.suse.cz> <alpine.DEB.2.10.1508261507270.2973@chino.kir.corp.google.com> <20150827124122.GD27052@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Oleg Nesterov <oleg@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Thu, 27 Aug 2015, Michal Hocko wrote:

> > If Andrew would prefer moving in a direction where all Linux users are 
> > required to have their admin use sysrq+f to manually trigger an oom kill, 
> > which may or may not resolve the livelock since there's no way to 
> > determine which process is holding the common mutex (or even which 
> > processes are currently allocating), in such situations, then we can carry 
> > this patch internally.  I disagree with that solution for upstream Linux.
> 
> There are other possibilities than the manual sysrq intervention. E.g.
> the already mentioned oom_{panic,reboot}_timeout which has a little
> advantage that it allows admin to opt in into the policy rather than
> having it hard coded into the kernel.
>  

This falls under my scenario (2) from Tuesday's message:

 (2) depletion of memory reserves, which can also happen today without 
     this patchset and we have fixed in the past.

You can deplete memory reserves today without access to global reserves on 
oom livelock.  I'm indifferent to whether the machine panics as soon as 
memory reserves are fully depleted, independent of oom livelock and this 
patch to address it, or whether there is a configurable timeout.  It's an 
independent issue, though, since the oom killer is not the only way for 
this to happen and it seems there will be additional possibilities in the 
future (the __GFP_NOFAIL case you bring up).

> > My patch has defined that by OOM_EXPIRE_MSECS.  The premise is that an oom 
> > victim with full access to memory reserves should never take more than 5s 
> > to exit, which I consider a very long time.  If it's increased, we see 
> > userspace responsiveness issues with our processes that monitor system 
> > health which timeout.
> 
> Yes but it sounds very much like a policy which should better be defined
> from the userspace because different users might have different
> preferences.
> 

My patch internally actually does make this configurable through yet 
another VM sysctl and it defaults to what OOM_EXPIRE_MSECS does in my 
patch.  We would probably never increase it, but may decrease it from the 
default of 5000.  I was concerned about adding another sysctl that doesn't 
have a clear user.  If you feel that OOM_EXPIRE_MSECS is too small and 
believe there would be a user who desires their system to be livelocked 
for 10s, 5m, 1h, etc, then I can add the sysctl upstream as well even it's 
unjustified as far as I'm concerned.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

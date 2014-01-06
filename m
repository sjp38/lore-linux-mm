Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f49.google.com (mail-ee0-f49.google.com [74.125.83.49])
	by kanga.kvack.org (Postfix) with ESMTP id 1664F6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 09:03:06 -0500 (EST)
Received: by mail-ee0-f49.google.com with SMTP id c41so7902560eek.36
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 06:03:06 -0800 (PST)
Received: from moutng.kundenserver.de (moutng.kundenserver.de. [212.227.17.10])
        by mx.google.com with ESMTPS id y48si4553616eew.142.2014.01.06.06.03.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 06:03:06 -0800 (PST)
Message-ID: <1389016976.5536.10.camel@marge.simpson.net>
Subject: Re: [PATCH] sched/auto_group: fix consume memory even if add
 'noautogroup' in the cmdline
From: Mike Galbraith <bitbucket@online.de>
Date: Mon, 06 Jan 2014 15:02:56 +0100
In-Reply-To: <20140106121719.GH31570@twins.programming.kicks-ass.net>
References: <1388139751-19632-1-git-send-email-liwanp@linux.vnet.ibm.com>
	 <20140106121719.GH31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2014-01-06 at 13:17 +0100, Peter Zijlstra wrote: 
> On Fri, Dec 27, 2013 at 06:22:31PM +0800, Wanpeng Li wrote:
> > We have a server which have 200 CPUs and 8G memory, there is auto_group creation 
> 
> I'm hoping that is 8T, otherwise that's a severely under provisioned
> system, that's a mere 40M per cpu, does that even work?
> 
> > which will almost consume 12MB memory even if add 'noautogroup' in the kernel 
> > boot parameter. In addtion, SLUB per cpu partial caches freeing that is local to 
> > a processor which requires the taking of locks at the price of more indeterminism 
> > in the latency of the free. This patch fix it by check noautogroup earlier to avoid 
> > free after unnecessary memory consumption.
> 
> That's just a bad changelog. It fails to explain the actual problem and
> it babbles about unrelated things like SLUB details.
> 
> Also, I'm not entirely sure what the intention was of this code, I've so
> far tried to ignore the entire autogroup fest... 
> 
> It looks like it creates and maintains the entire autogroup hierarchy,
> such that if you at runtime enable the sysclt and move tasks 'back' to
> the root cgroup you get the autogroup behaviour.
> 
> Was this intended? Mike?

Yeah, it was intended that autogroups always exist if you config it in.
We could make is such that noautogroup makes it irreversibly off/dead.  

People with 200 ram starved CPUs can turn it off in their .config too :)

-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

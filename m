Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A524A828F3
	for <linux-mm@kvack.org>; Mon, 11 Jan 2016 10:02:16 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id f206so216421204wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:02:16 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id v10si23639565wmd.0.2016.01.11.07.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Jan 2016 07:02:15 -0800 (PST)
Received: by mail-wm0-f43.google.com with SMTP id f206so273009188wmf.0
        for <linux-mm@kvack.org>; Mon, 11 Jan 2016 07:02:15 -0800 (PST)
Date: Mon, 11 Jan 2016 16:02:13 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Unrecoverable Out Of Memory kernel error
Message-ID: <20160111150212.GG27317@dhcp22.suse.cz>
References: <1451408582.2783.20.camel@libero.it>
 <20160105155400.GC15594@dhcp22.suse.cz>
 <1452194792.7839.20.camel@libero.it>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1452194792.7839.20.camel@libero.it>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guido Trentalancia <g.trentalancia@libero.it>
Cc: linux-mm@kvack.org

On Thu 07-01-16 20:26:32, Guido Trentalancia wrote:
> Hello Michal.
> 
> I believe it's a serious problem, as an unprivileged user-space
> application can basically render the system completely unusable, so
> that it must be hard-rebooted.

Unfortunatelly there are many other ways how your user can consume a lot
of memory without some way of memory containment. E.g. memory cgroups
can help in that regards.

[...]
> > > Dec 29 12:28:25 vortex kernel: Killed process 10197 (cc1plus)
> > > total-vm:969632kB, anon-rss:809184kB, file-rss:9308kB
> > 
> > This task is consuming a lot of memory so killing it should help to
> > release the memory pressure. It would be interesting to see whether
> > the
> > task has died or not. 
> 
> I am not able to login into any console and therefore I cannot check
> whether the gcc task died or not.

sysrq is not an option?

> > Are there any follow up messages in the log?
> 
> The first message have been posted entirely. Such message is then
> repeated several times (for the "cc1plus" task and once for the "as"
> assembler). The other messages are similar and therefore have not been
> posted...

A full kernel log is usually more interesting to see the timing and
other information (e.g. how much has the situation changed after the OOM
killer invocation).
 
> It only appears to happen with parallel builds ("make -j4") and not
> with normal builds ("make" or "make -j1"), but that's another issue,

This could mean that the memory got so fragmented that a larger fork
load which requires higher order allocations can trigger OOM killer.
Your OOM report talks about order-0 request triggering the OOM killer
but higher parallel load might contribute

> I mean a user-space application should not be able to render the
> system unusable by sucking all of its memory...
> 
> Is the hard-disk working continuosly because the kernel is trying to
> swap endlessly and cannot reclaim back memory ?!?

I would suspect page cache trashing to be a more probable reason. As
already pointed out your swap space is full and so the anonymous memory
which is the largest contributor to the memory consumption cannot be
reclaimed. So all you get is to reclaim the page cache and your load
will likely need more of it then would fit into the remaining memory.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

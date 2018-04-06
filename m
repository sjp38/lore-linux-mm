Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 41D596B0003
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 16:36:03 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so1725080plo.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 13:36:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 73si7619024pgg.68.2018.04.06.13.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 13:36:01 -0700 (PDT)
Date: Fri, 6 Apr 2018 13:36:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 199297] New: OOMs writing to files from processes with
 cgroup memory limits
Message-Id: <20180406133600.afb9c2b0e1ba92b526f279ce@linux-foundation.org>
In-Reply-To: <bug-199297-27@https.bugzilla.kernel.org/>
References: <bug-199297-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, cbehrens@codestud.com, David Rientjes <rientjes@google.com>, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Thu, 05 Apr 2018 21:55:26 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=199297
> 
>             Bug ID: 199297
>            Summary: OOMs writing to files from processes with cgroup
>                     memory limits
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.11+
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: high
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: cbehrens@codestud.com
>         Regression: No
> 
> Created attachment 275113
>   --> https://bugzilla.kernel.org/attachment.cgi?id=275113&action=edit
> script to reproduce issue + kernel config + oom log from dmesg
> 
> OVERVIEW:
> 
> Processes that have a cgroup memory limit can easily OOM just writing to files.
> It appears there is no throttling and the process can very quickly exceed the
> cgroup memory limit. vm.dirty_ratio appears to be applied to global available
> memory and not available memory for the cgroup, at least in my case.
> 
> This issue came to light by using kubernetes and putting memory limits on pods,
> but is completely reproducible stand-alone.
> 
> STEPS TO REPRODUCE:
> 
> * create a memory cgroup
> * put a memory limit on the cgroup.. say 256M.
> * add a shell process to the cgroup
> * use dd from that shell to write a bunch of data to a file
> 
> See attached simple script that reproduces the issue every time.
> 
> dd will end up getting OOMkilled very shortly after starting. OOM logging will
> show dirty pages above the cgroup limit.
> 
> Kernels before 4.11 do not see this behavior. I've tracked the issue to the
> following commit:
> 
> https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=726d061fbd3658e4bfeffa1b8e82da97de2ca4dd
> 
> When I reverse this commit, dd will complete successfully.
> 
> I believe there to be a larger issue here, though. I did a bit of debugging. As
> mentioned above, it doesn't appear there's any throttling. It also doesn't
> appear that writebacks are fired when dirty pages build up for the cgroup. From
> what I can tell, vm.dirty* configs would only get applied against the cgroup
> limit IFF inode_cgwb_enabled(inode) returns true in
> balance_dirty_pages_ratelimited(). That appears to be returning false for me.
> I'm using ext4 and CONFIG_CGROUP_WRITEBACK is enabled. The code removed from
> the above commit seems to be saving things by reclaiming during try_charge().
> But from what I can tell, we actually want to throttle in
> balance_dirty_pages(), instead.. but that's not happening. This code is all
> foreign to me, but just wanted to dump a bit about what I saw from my
> debugging.
> 
> NOTE: If I set vm.dirty_bytes to a value lower than my cgroup memory limit, I
> no longer see OOMs... as it appears the process gets throttled correctly.
> 
> I'm attaching a script to reproduce the issue, kernel config, and OOM log
> messages from dmesg for kernel 4.15.0.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 382386B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 20:29:22 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id a190so1352973830pgc.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 17:29:22 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id n11si74111046plg.331.2017.01.04.17.29.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 17:29:21 -0800 (PST)
Date: Wed, 4 Jan 2017 17:30:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 190841] New: [REGRESSION] Intensive Memory CGroup removal
 leads to high load average 10+
Message-Id: <20170104173037.7e501fdfee9ec21f0a3a5d55@linux-foundation.org>
In-Reply-To: <bug-190841-27@https.bugzilla.kernel.org/>
References: <bug-190841-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: bugzilla-daemon@bugzilla.kernel.org, frolvlad@gmail.com, linux-mm@kvack.org


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 21 Dec 2016 19:56:16 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=190841
> 
>             Bug ID: 190841
>            Summary: [REGRESSION] Intensive Memory CGroup removal leads to
>                     high load average 10+
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.7.0-rc1+
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: frolvlad@gmail.com
>         Regression: No
> 
> My simplified workflow looks like this:
> 
> 1. Create a Memory CGroup with memory limit
> 2. Exec a child process
> 3. Add the child process PID into the Memory CGroup
> 4. Wait for the child process to finish
> 5. Remove the Memory CGroup
> 
> The child processes usually run less than 0.1 seconds, but I have lots of them.
> Normally, I could run over 10000 child processes per minute, but with newer
> kernels, I can only do 400-500 executions per minute, and my system becomes
> extremely sluggish (the only indicator of the weirdness I found is an unusually
> high load average, which sometimes goes over 250!).
> 
> Here is a simple reproduction script:
> 
> #!/bin/sh
> CGROUP_BASE=/sys/fs/cgroup/memory/qq
> 
> for $i in $(seq 1000); do
>     echo "Iteration #$i"
>     sh -c "
>         mkdir '$CGROUP_BASE'
>         sh -c 'echo \$$ > $CGROUP_BASE/tasks ; sleep 0.0'
>         rmdir '$CGROUP_BASE' || true
>     "
> done
> # ===
> 
> Running this script on 4.7.0-rc1 and above I get a noticeable slowdown and also
> high load average with no other indicators like high CPU or IO usage reported
> in top/iotop/vmstat.
> 
> It used to work just fine up until Kernel 4.7.0. In fact, I have jumped from
> 4.4 to 4.8 kernel, so I had to test several kernels before I came to the
> conclusion that this seems to be a regression in Kernel. Currently, I have
> tried the following kernels (using a fresh minimal Ubuntu 16.04 on VirtualBox
> with their binary mainline kernels):
> 
> * Ubuntu 4.4.0-57 kernel works fine
> * Mainline 4.4.39 and below seem to work just fine -
> https://youtu.be/tGD6sfwa-3c
> * Mainline 4.6.7 kernel behaves seminormal, load average is higher than on 4.4,
> but not as bad as on 4.7+ - https://youtu.be/-CyhmkkPbKE
> * Mainline 4.7.0-rc1 kernel is the first kernel after 4.6.7 that is available
> in binaries, so I chose to test it and it doesn't play nicely -
> https://youtu.be/C_J5es74Ars
> * Mainline 4.9.0 kernel still doesn't play nicely -
> https://youtu.be/_o17U5x3bmY
> 
> OTHER NOTES:
> 1. Using VirtualBox I have noticed that this bug only reproducible when I have
> 2+ CPU cores!
> 2. This bug is also reproducible on other Linux distibutions: Fedora 25 with
> 4.8.14-300.fc25.x86_64 kernel, latest Arch Linux with 4.8.13 and 4.8.15 with
> Liquorix patchset.
> 3. Commenting out `rmdir '$CGROUP_BASE'` in the reproduction script makes
> things fly yet again, but I don't want to leave leftovers after the runs.
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

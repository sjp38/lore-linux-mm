Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id BA14883292
	for <linux-mm@kvack.org>; Thu, 22 Jun 2017 15:37:40 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id g46so7240713wrd.3
        for <linux-mm@kvack.org>; Thu, 22 Jun 2017 12:37:40 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w61si2271953wrc.14.2017.06.22.12.37.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Jun 2017 12:37:39 -0700 (PDT)
Date: Thu, 22 Jun 2017 12:37:36 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 196157] New: 100+ times slower disk writes on
 4.x+/i386/16+RAM, compared to 3.x
Message-Id: <20170622123736.1d80f1318eac41cd661b7757@linux-foundation.org>
In-Reply-To: <bug-196157-27@https.bugzilla.kernel.org/>
References: <bug-196157-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: bugzilla-daemon@bugzilla.kernel.org, alkisg@gmail.com, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

hm, that's news to me.

Does anyone have access to a large i386 setup?  Interested in
reproducing this and figuring out what's going wrong?


On Thu, 22 Jun 2017 06:25:49 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=196157
> 
>             Bug ID: 196157
>            Summary: 100+ times slower disk writes on 4.x+/i386/16+RAM,
>                     compared to 3.x
>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.x
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Page Allocator
>           Assignee: akpm@linux-foundation.org
>           Reporter: alkisg@gmail.com
>         Regression: No
> 
> Me and a lot of other users have an issue where disk writes start fast (e.g.
> 200 MB/sec), but after intensive disk usage, they end up 100+ times slower
> (e.g. 2 MB/sec), and never get fast again until we run "echo 3 >
> /proc/sys/vm/drop_caches".
> 
> This issue happens on systems with any 4.x kernel, i386 arch, 16+ GB RAM.
> It doesn't happen if we use 3.x kernels (i.e. it's a regression) or any 64bit
> kernels (i.e. it only affects i386).
> 
> My initial bug report was in Ubuntu:
> https://bugs.launchpad.net/ubuntu/+source/linux-hwe/+bug/1698118
> 
> I included a test case there, which mostly says "Copy /lib around 100 times.
> You'll see that the first copy happens in 5 seconds, and the 30th copy may need
> more than 800 seconds".
> 
> Here is my latest version of the script (basically, the (3) step below):
> 1) . /etc/os-release; echo -n "$VERSION, $(uname -r), $(dpkg
> --print-architecture), RAM="; awk '/MemTotal:/ { print $2 }' /proc/meminfo
> 2) mount /dev/sdb2 /mnt && rm -rf /mnt/tmp/lib && mkdir -p /mnt/tmp/lib && sync
> && echo 3 > /proc/sys/vm/drop_caches && chroot /mnt
> 3) mkdir -p /tmp/lib; cd /tmp/lib; s=/lib; d=1; echo -n "Copying $s to $d: ";
> while /usr/bin/time -f %e sh -c "cp -a '$s' '$d'; sync"; do s=$d;
> d=$((($d+1)%100)); echo -n "Copying $s to $d: "; done
> 
> And here are some results, where you can see that all 4.x+ i386 kernels are
> affected:
> -----------------------------------------------------------------------------
> 14.04, Trusty Tahr, 3.13.0-24-generic, i386, RAM=16076400 [Live CD]
> 8-13 secs
> 
> 15.04 (Vivid Vervet), 3.19.0-15-generic, i386, RAM=16083080 [Live CD]
> 5-7 secs
> 
> 15.10 (Wily Werewolf), 4.2.0-16-generic, i386, RAM=16082536 [Live CD]
> 4-350 secs
> 
> 16.04.2 LTS (Xenial Xerus), 3.19.0-80-generic, i386, RAM=16294832 [HD install]
> 10-25 secs
> 
> 16.04.2 LTS (Xenial Xerus), 4.2.0-42-generic, i386, RAM=16294392 [HD install]
> 14-89 secs
> 
> 16.04.2 LTS (Xenial Xerus), 4.4.0-79-generic, i386, RAM=16293556 [HD install]
> 15-605 secs
> 
> 16.04.2 LTS (Xenial Xerus), 4.8.0-54-generic, i386, RAM=16292708 [HD install]
> 6-160 secs
> 
> 16.04.2 LTS (Xenial Xerus), 4.12.0-041200rc5-generic, i386, RAM=16292588 [HD
> install]
> 46-805 secs
> 
> 16.04.2 LTS (Xenial Xerus), 4.8.0-36-generic, amd64, RAM=16131028 [Live CD]
> 4-11 secs
> 
> An example single run of the script:
> -----------------------------------------------------------------------------
> 16.04.2 LTS (Xenial Xerus), 4.8.0-54-generic, i386, RAM=16292708 [HD install]
> -----------------------------------------------------------------------------
> Copying /lib to 1: 37.23
> Copying 1 to 2: 6.74
> Copying 2 to 3: 6.88
> Copying 3 to 4: 7.89
> Copying 4 to 5: 7.91
> Copying 5 to 6: 9.03
> Copying 6 to 7: 8.46
> Copying 7 to 8: 8.10
> Copying 8 to 9: 8.93
> Copying 9 to 10: 10.51
> Copying 10 to 11: 10.33
> Copying 11 to 12: 11.08
> Copying 12 to 13: 11.78
> Copying 13 to 14: 14.18
> Copying 14 to 15: 18.42
> Copying 15 to 16: 23.19
> Copying 16 to 17: 61.08
> Copying 17 to 18: 155.88
> Copying 18 to 19: 141.96
> Copying 19 to 20: 152.98
> Copying 20 to 21: 163.03
> Copying 21 to 22: 154.85
> Copying 22 to 23: 137.13
> Copying 23 to 24: 146.08
> Copying 24 to 25:
> 
> Thank you!
> 
> -- 
> You are receiving this mail because:
> You are the assignee for the bug.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 39C736B0006
	for <linux-mm@kvack.org>; Sun, 22 Jul 2018 19:40:37 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 66-v6so12091195plb.18
        for <linux-mm@kvack.org>; Sun, 22 Jul 2018 16:40:37 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id y125-v6si6844369pgy.251.2018.07.22.16.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 22 Jul 2018 16:40:36 -0700 (PDT)
Date: Sun, 22 Jul 2018 16:40:34 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 200627] New: Stutters and high kernel CPU usage from
 list_lru_count_one when cache fills memory
Message-Id: <20180722164034.62bf461029073a21e591b8c3@linux-foundation.org>
In-Reply-To: <bug-200627-27@https.bugzilla.kernel.org/>
References: <bug-200627-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kevin@potatofrom.space
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Sun, 22 Jul 2018 23:33:57 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=200627
> 
>             Bug ID: 200627
>            Summary: Stutters and high kernel CPU usage from
>                     list_lru_count_one when cache fills memory

Thanks.  Please do note the above request.

>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.18-rc4, 4.16
>           Hardware: x86-64
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: kevin@potatofrom.space
>         Regression: No
> 
> I've recently noticed stuttering and general sluggishness, in Xorg, Firefox,
> and other graphical applications, when the memory becomes completely filled
> with cache. In `htop`, the stuttering manifests as all CPU cores at 100% usage,
> mostly in kernel mode.

How recently?  Were earlier kernels better behaved?

> Doing a `perf top` shows that `list_lru_count_one` causes a lot of overhead:
> 
> ```
> Overhead  Shared Object                              Symbol                     
>   18.38%  [kernel]                                   [k] list_lru_count_one     
>    4.90%  [kernel]                                   [k] nmi                    
>    3.27%  [kernel]                                   [k] read_hpet              
>    2.66%  [kernel]                                   [k] super_cache_count      
>    1.84%  [kernel]                                   [k] shrink_slab.part.52    
>    1.63%  [kernel]                                   [k]
> shmem_unused_huge_count                                                         
>    1.19%  restic                                     [.] 0x00000000002e696c     
>    0.98%  restic                                     [.] 0x00000000002e6a2f     
>    0.81%  restic                                     [.] 0x00000000002e699b     
>    0.80%  restic                                     [.] 0x00000000002e69b6     
>    0.79%  restic                                     [.] 0x00000000002e697d     
>    0.74%  .perf-wrapped                              [.] rb_next                
>    0.62%  [kernel]                                   [k] _aesni_dec4            
>    0.57%  restic                                     [.] 0x00000000002e6a18     
>    0.56%  [kernel]                                   [k] aesni_xts_crypt8       
>    0.51%  restic                                     [.] 0x000000000005676a     
>    0.50%  restic                                     [.] 0x00000000002e69de     
>    0.50%  restic                                     [.] 0x00000000002e69f1     
>    0.43%  restic                                     [.] 0x00000000002e6a10     
>    0.43%  restic                                     [.] 0x00000000002e69c9     
>    0.41%  .perf-wrapped                              [.] hpp__sort_overhead     
>    0.41%  restic                                     [.] 0x00000000002e6996     
>    0.40%  [kernel]                                   [k]
> update_blocked_averages                                                         
>    0.38%  restic                                     [.] 0x00000000002e6a05     
>    0.38%  [kernel]                                   [k] __indirect_thunk_start 
>    0.37%  [kernel]                                   [k]
> copy_user_enhanced_fast_string                                                  
>    0.35%  rclone                                     [.] crypto/md5.block
> ```
> 
> I've seen it hit up to 25% overhead, while normally (when the cache hasn't
> filled up) it only has ~4% overhead. I believe that this is the cause of the
> stutter.
> 
> I've kludged together a workaround, as running `echo 3 >
> /proc/sys/vm/drop_caches` every minute keeps the cache from filling up and the
> system responsive, but I was wondering if this was a potential issue in the
> kernel.
> 
> More details on my workload:
> 
> - Running Docker containers connected via NFS to disk; this computer serves ~20
> NFSv4.2 shares, though most of them have fairly light IO.
> - Running a restic backup with rclone, which requires significant CPU usage and
> does a lot of disk-waiting on hard drives. (It doesn't impact responsiveness
> when the cache isn't full, though.)
> 
> System:
> 
> - Linux 4.18-rc4, NixOS unstable
> - Intel i7-4820k
> - 20 GB RAM
> - AMD RX 580
> 
> Let me know if there are any more details I can provide or any tests I can run.

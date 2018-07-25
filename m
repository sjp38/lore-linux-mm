Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A41D06B0006
	for <linux-mm@kvack.org>; Wed, 25 Jul 2018 15:52:41 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id j4-v6so5430744pgq.16
        for <linux-mm@kvack.org>; Wed, 25 Jul 2018 12:52:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t10-v6si13326978plh.306.2018.07.25.12.52.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Jul 2018 12:52:40 -0700 (PDT)
Date: Wed, 25 Jul 2018 12:52:39 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 200651] New: cgroups iptables-restor: vmalloc: allocation
 failure
Message-Id: <20180725125239.b591e4df270145f9064fe2c5@linux-foundation.org>
In-Reply-To: <bug-200651-27@https.bugzilla.kernel.org/>
References: <bug-200651-27@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gnikolov@icdsoft.com
Cc: bugzilla-daemon@bugzilla.kernel.org, linux-mm@kvack.org, netfilter-devel@vger.kernel.org

(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 25 Jul 2018 11:42:57 +0000 bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=200651
> 
>             Bug ID: 200651
>            Summary: cgroups iptables-restor: vmalloc: allocation failure

Thanks.  Please do note the above request.

>            Product: Memory Management
>            Version: 2.5
>     Kernel Version: 4.14
>           Hardware: All
>                 OS: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: Other
>           Assignee: akpm@linux-foundation.org
>           Reporter: gnikolov@icdsoft.com
>         Regression: No
> 
> Created attachment 277505
>   --> https://bugzilla.kernel.org/attachment.cgi?id=277505&action=edit
> iptables save
> 
> After creating large number of cgroups and under memory pressure, iptables
> command fails with following error:
> 
> "iptables-restor: vmalloc: allocation failure, allocated 3047424 of 3465216
> bytes, mode:0x14010c0(GFP_KERNEL|__GFP_NORETRY), nodemask=(null)"

I'm not sure what the problem is here, apart from iptables being
over-optimistic about vmalloc()'s abilities.

Are cgroups having any impact on this, or is it simply vmalloc arena
fragmentation, and the iptables code should use some data structure
more sophisticated than a massive array?

Maybe all that ccgroup metadata is contributing to the arena
fragmentation, but that allocations will be small and the two systems
should be able to live alongside, by being realistic about vmalloc.

> System which is used to reproduce the bug is with 2 vcpus and 2GB of ram, but
> it happens on more powerfull systems.
> 
> Steps to reproduce:
> 
> mkdir /cgroup
> mount cgroup -t cgroup -omemory,pids,blkio,cpuacct /cgroup
> for a in `seq 1 1000`; do for b in `seq 1 4` ; do mkdir -p
> "/cgroup/user/$a/$b"; done; done
> 
> Then in separate consoles
> 
> cat /dev/vda > /dev/null
> ./test
> ./test
> i=0;while sleep 0 ; do iptables-restore < iptables.save ; i=$(($i+1)); echo $i;
> done
> 
> Here is the source of "test" program and attached iptables.save. It happens
> also with smaller iptables.save file.
> 
> #include <stdio.h>
> #include <stdlib.h>
> 
> int main(void) {
> 
>     srand(time(NULL));
>     int i = 0, j = 0, randnum=0;
>     int arr[6] = { 3072, 7168, 15360 , 31744, 64512, 130048}; 
>     while(1) {
> 
>         for (i = 0; i < 6 ; i++) {
> 
>             int *ptr = (int*) malloc(arr[i] * 93);  
> 
>             for(j = 0 ; j < arr[i] * 93 / sizeof(int); j++) {
>                 *(ptr+j) = j+1;
>             }
> 
>             free(ptr);
>         }
>     }       
> }
> 

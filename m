Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id AFFA26B0007
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 10:48:17 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id b7-v6so17085196ybn.14
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 07:48:17 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id t19si6827516qtb.327.2018.04.05.07.48.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Apr 2018 07:48:15 -0700 (PDT)
Date: Thu, 5 Apr 2018 15:47:50 +0100
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RFC] mm: allow to decrease swap.max below actual swap usage
Message-ID: <20180405144744.GA15097@castle.DHCP.thefacebook.com>
References: <20180320223543.6188-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20180320223543.6188-1-guro@fb.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Shaohua Li <shli@fb.com>, Rik van Riel <riel@surriel.com>, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

On Tue, Mar 20, 2018 at 10:35:43PM +0000, Roman Gushchin wrote:
> Currently an attempt to set swap.max into a value lower
> than the actual swap usage fails. And a user can't do much
> with it, except turning off swap globally (using swapoff).
> 
> This patch aims to fix this issue by allowing setting swap.max
> into any value (which corresponds to cgroup v2 API design),
> and schedule a background job to fit swap size into the new limit.
> 
> The following script can be used to test the memory.swap behavior:
>   #!/bin/bash
> 
>   mkdir -p /sys/fs/cgroup/test_swap
>   echo 100M > /sys/fs/cgroup/test_swap/memory.max
>   echo max > /sys/fs/cgroup/test_swap/memory.swap.max
> 
>   mkdir -p /sys/fs/cgroup/test_swap_2
>   echo 100M > /sys/fs/cgroup/test_swap_2/memory.max
>   echo max > /sys/fs/cgroup/test_swap_2/memory.swap.max
> 
>   echo $$ > /sys/fs/cgroup/test_swap/cgroup.procs
>   allocate 200M &
> 
>   echo $$ > /sys/fs/cgroup/test_swap_2/cgroup.procs
>   allocate 200M &
> 
>   sleep 2
> 
>   cat /sys/fs/cgroup/test_swap/memory.swap.current
>   cat /sys/fs/cgroup/test_swap_2/memory.swap.current
> 
>   echo max > /sys/fs/cgroup/test_swap/memory.max
>   echo 50M > /sys/fs/cgroup/test_swap/memory.swap.max
> 
>   sleep 10
> 
>   cat /sys/fs/cgroup/test_swap/memory.swap.current
>   cat /sys/fs/cgroup/test_swap_2/memory.swap.current
> 
>   pkill allocate
> 
> Original test results:
>   106024960
>   106348544
>   ./swap.sh: line 23: echo: write error: Device or resource busy
>   106024960
>   106348544
> 
> With this patch applied:
>   106045440
>   106352640
>   52428800
>   106201088

Any comments, thoughts, feedback?

Rebased version below.

---

Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 9C23A6B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 20:37:57 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so114363543pac.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 17:37:57 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id fv2si542623pdb.209.2015.08.10.17.37.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 17:37:56 -0700 (PDT)
Received: by pacrr5 with SMTP id rr5so114363182pac.3
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 17:37:56 -0700 (PDT)
Date: Mon, 10 Aug 2015 17:37:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2 1/2] smaps: fill missing fields for vma(VM_HUGETLB)
In-Reply-To: <1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.DEB.2.10.1508101727230.28691@chino.kir.corp.google.com>
References: <20150806074443.GA7870@hori1.linux.bs1.fc.nec.co.jp> <1438932278-7973-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1438932278-7973-2-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?Q?J=C3=B6rn_Engel?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 7 Aug 2015, Naoya Horiguchi wrote:

> Currently smaps reports many zero fields for vma(VM_HUGETLB), which is
> inconvenient when we want to know per-task or per-vma base hugetlb usage.
> This patch enables these fields by introducing smaps_hugetlb_range().
> 
> before patch:
> 
>   Size:              20480 kB
>   Rss:                   0 kB
>   Pss:                   0 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:         0 kB
>   Referenced:            0 kB
>   Anonymous:             0 kB
>   AnonHugePages:         0 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 
> after patch:
> 
>   Size:              20480 kB
>   Rss:               18432 kB
>   Pss:               18432 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:     18432 kB
>   Referenced:        18432 kB
>   Anonymous:         18432 kB
>   AnonHugePages:         0 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 

I think this will lead to breakage, unfortunately, specifically for users 
who are concerned with resource management.

An example: we use memcg hierarchies to charge memory for individual jobs, 
specific users, and system overhead.  Memcg is a cgroup, so this is done 
for an aggregate of processes, and we often have to monitor their memory 
usage.  Each process isn't assigned to its own memcg, and I don't believe 
common users of memcg assign individual processes to their own memcgs.  

When a memcg is out of memory, we need to track the memory usage of 
processes attached to its memcg hierarchy to determine what is unexpected, 
either as a result of a new rollout or because of a memory leak.  To do 
that, we use the rss exported by smaps that is now changed with this 
patch.  By using smaps rather than /proc/pid/status, we can report where 
memory usage is unexpected.

This would cause our process that manages all memcgs on our systems to 
break.  Perhaps I haven't been as convincing in my previous messages of 
this, but it's quite an obvious userspace regression.

This memory was not included in rss originally because memory in the 
hugetlb persistent pool is always resident.  Unmapping the memory does not 
free memory.  For this reason, hugetlb memory has always been treated as 
its own type of memory.

It would have been arguable back when hugetlbfs was introduced whether it 
should be included.  I'm afraid the ship has sailed on that since a decade 
has past and it would cause userspace to break if existing metrics are 
used that already have cleared defined semantics.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

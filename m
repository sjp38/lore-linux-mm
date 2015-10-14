Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 013C26B0038
	for <linux-mm@kvack.org>; Wed, 14 Oct 2015 18:05:00 -0400 (EDT)
Received: by pabrc13 with SMTP id rc13so65789630pab.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 15:04:59 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id kh9si16259910pab.221.2015.10.14.15.04.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Oct 2015 15:04:59 -0700 (PDT)
Received: by pabrc13 with SMTP id rc13so65789429pab.0
        for <linux-mm@kvack.org>; Wed, 14 Oct 2015 15:04:59 -0700 (PDT)
Date: Wed, 14 Oct 2015 15:04:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: RE: [RESEND PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat
 counter
In-Reply-To: <081301d10686$370d2e10$a5278a30$@samsung.com>
Message-ID: <alpine.DEB.2.10.1510141501470.32680@chino.kir.corp.google.com>
References: <1444656800-29915-1-git-send-email-pintu.k@samsung.com> <1444660139-30125-1-git-send-email-pintu.k@samsung.com> <alpine.DEB.2.10.1510132000270.18525@chino.kir.corp.google.com> <081301d10686$370d2e10$a5278a30$@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com

On Wed, 14 Oct 2015, PINTU KUMAR wrote:

> For me it was very helpful during sluggish and long duration ageing tests.
> With this, I don't have to look into the logs manually.
> I just monitor this count in a script. 
> The moment I get nr_oom_victims > 1, I know that kernel OOM would have happened
> and I need to take the log dump.
> So, then I do: dmesg >> oom_logs.txt
> Or, even stop the tests for further tuning.
> 

I think eventfd(2) was created for that purpose, to avoid the constant 
polling that you would have to do to check nr_oom_victims and then take a 
snapshot.

> > I disagree with this one, because we can encounter oom kills due to
> > fragmentation rather than low memory conditions for high-order allocations.
> > The amount of free memory may be substantially higher than all zone
> > watermarks.
> > 
> AFAIK, kernel oom happens only for lower-order (PAGE_ALLOC_COSTLY_ORDER).
> For higher-order we get page allocation failure.
> 

Order-3 is included.  I've seen machines with _gigabytes_ of free memory 
in ZONE_NORMAL on a node and have an order-3 page allocation failure that 
called the oom killer.

> > We've long had a desire to have a better oom reporting mechanism rather than
> > just the kernel log.  It seems like you're feeling the same pain.  I think it
> would be
> > better to have an eventfd notifier for system oom conditions so we can track
> > kernel oom kills (and conditions) in userspace.  I have a patch for that, and
> it
> > works quite well when userspace is mlocked with a buffer in memory.
> > 
> Ok, this would be interesting.
> Can you point me to the patches?
> I will quickly check if it is useful for us.
> 

https://lwn.net/Articles/589404.  It's invasive and isn't upstream.  I 
would like to restructure that patchset to avoid the memcg trickery and 
allow for a root-only eventfd(2) notification through procfs on system 
oom.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

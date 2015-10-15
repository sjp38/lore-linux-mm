Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 13B2E6B0038
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 10:35:29 -0400 (EDT)
Received: by pabur7 with SMTP id ur7so7264734pab.2
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 07:35:28 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id kz10si22075834pab.59.2015.10.15.07.35.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 15 Oct 2015 07:35:28 -0700 (PDT)
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NW901MI2N72ZY60@mailout3.samsung.com> for linux-mm@kvack.org;
 Thu, 15 Oct 2015 23:35:26 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1444656800-29915-1-git-send-email-pintu.k@samsung.com>
 <1444660139-30125-1-git-send-email-pintu.k@samsung.com>
 <alpine.DEB.2.10.1510132000270.18525@chino.kir.corp.google.com>
 <081301d10686$370d2e10$a5278a30$@samsung.com>
 <alpine.DEB.2.10.1510141501470.32680@chino.kir.corp.google.com>
In-reply-to: <alpine.DEB.2.10.1510141501470.32680@chino.kir.corp.google.com>
Subject: RE: [RESEND PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat
 counter
Date: Thu, 15 Oct 2015 20:05:17 +0530
Message-id: <002101d10756$dcae7e20$960b7a60$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'David Rientjes' <rientjes@google.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, mhocko@suse.cz, koct9i@gmail.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com

Hi,

> -----Original Message-----
> From: David Rientjes [mailto:rientjes@google.com]
> Sent: Thursday, October 15, 2015 3:35 AM
> To: PINTU KUMAR
> Cc: akpm@linux-foundation.org; minchan@kernel.org; dave@stgolabs.net;
> mhocko@suse.cz; koct9i@gmail.com; hannes@cmpxchg.org; penguin-kernel@i-
> love.sakura.ne.jp; bywxiaobai@163.com; mgorman@suse.de; vbabka@suse.cz;
> js1304@gmail.com; kirill.shutemov@linux.intel.com;
> alexander.h.duyck@redhat.com; sasha.levin@oracle.com; cl@linux.com;
> fengguang.wu@intel.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.ping@gmail.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com; c.rajkumar@samsung.com
> Subject: RE: [RESEND PATCH 1/1] mm: vmstat: Add OOM victims count in vmstat
> counter
> 
> On Wed, 14 Oct 2015, PINTU KUMAR wrote:
> 
> > For me it was very helpful during sluggish and long duration ageing tests.
> > With this, I don't have to look into the logs manually.
> > I just monitor this count in a script.
> > The moment I get nr_oom_victims > 1, I know that kernel OOM would have
> > happened and I need to take the log dump.
> > So, then I do: dmesg >> oom_logs.txt
> > Or, even stop the tests for further tuning.
> >
> 
> I think eventfd(2) was created for that purpose, to avoid the constant polling
> that you would have to do to check nr_oom_victims and then take a snapshot.
> 
> > > I disagree with this one, because we can encounter oom kills due to
> > > fragmentation rather than low memory conditions for high-order
allocations.
> > > The amount of free memory may be substantially higher than all zone
> > > watermarks.
> > >
> > AFAIK, kernel oom happens only for lower-order
> (PAGE_ALLOC_COSTLY_ORDER).
> > For higher-order we get page allocation failure.
> >
> 
> Order-3 is included.  I've seen machines with _gigabytes_ of free memory in
> ZONE_NORMAL on a node and have an order-3 page allocation failure that
> called the oom killer.
> 
Yes, if PAGE_ALLOC_COSTLY_ORDER is defined as 3, then order-3 will be included
for OOM. But that's fine. We are just interested to know if system entered oom
state.
That's the reason, earlier I added even _oom_stall_ to know if system ever
entered oom but resulted into page allocation failure instead of oom killing.

> > > We've long had a desire to have a better oom reporting mechanism
> > > rather than just the kernel log.  It seems like you're feeling the
> > > same pain.  I think it
> > would be
> > > better to have an eventfd notifier for system oom conditions so we
> > > can track kernel oom kills (and conditions) in userspace.  I have a
> > > patch for that, and
> > it
> > > works quite well when userspace is mlocked with a buffer in memory.
> > >
> > Ok, this would be interesting.
> > Can you point me to the patches?
> > I will quickly check if it is useful for us.
> >
> 
> https://lwn.net/Articles/589404.  It's invasive and isn't upstream.  I would
like to
> restructure that patchset to avoid the memcg trickery and allow for a
root-only
> eventfd(2) notification through procfs on system oom.

I am interested only in global oom case and not memcg. We have memcg enabled but
I think even memcg_oom will finally invoke _oom_kill_process_.
So, I am interested in a patchset that can trigger notifications from
oom_kill_process, as soon as any victim is killed.
Sorry, from your patchset, I could not actually local the system_oom
notification patch.
If you have similar patchset please point me to it.
It will be really helpful.
Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

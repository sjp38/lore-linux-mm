Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 30A4D6B026A
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 18:19:19 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id s46-v6so3201758ybe.8
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:19:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7-v6sor1196090ywe.61.2018.07.18.15.19.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 15:19:11 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:21:57 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180718222157.GG2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180716155745.10368-1-drake@endlessm.com>
 <20180717112515.GE7193@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717112515.GE7193@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Daniel Drake <drake@endlessm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux@endlessm.com, linux-block@vger.kernel.org, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linuxfoundation.org>, Tejun Heo <tj@kernel.org>, Balbir Singh <bsingharora@gmail.com>, Mike Galbraith <efault@gmx.de>, Oliver Yang <yangoliver@me.com>, Shakeel Butt <shakeelb@google.com>, xxx xxx <x.qendo@gmail.com>, Taras Kondratiuk <takondra@cisco.com>, Daniel Walker <danielwa@cisco.com>, Vinayak Menon <vinmenon@codeaurora.org>, Ruslan Ruslichenko <rruslich@cisco.com>, kernel-team@fb.com

On Tue, Jul 17, 2018 at 01:25:15PM +0200, Michal Hocko wrote:
> On Mon 16-07-18 10:57:45, Daniel Drake wrote:
> > Hi Johannes,
> > 
> > Thanks for your work on psi! 
> > 
> > We have also been investigating the "thrashing problem" on our Endless
> > desktop OS. We have seen that systems can easily get into a state where the
> > UI becomes unresponsive to input, and the mouse cursor becomes extremely
> > slow or stuck when the system is running out of memory. We are working with
> > a full GNOME desktop environment on systems with only 2GB RAM, and
> > sometimes no real swap (although zram-swap helps mitigate the problem to
> > some extent).
> > 
> > My analysis so far indicates that when the system is low on memory and hits
> > this condition, the system is spending much of the time under
> > __alloc_pages_direct_reclaim. "perf trace -F" shows many many page faults
> > in executable code while this is going on. I believe the kernel is
> > swapping out executable code in order to satisfy memory allocation
> > requests, but then that swapped-out code is needed a moment later so it
> > gets swapped in again via the page fault handler, and all this activity
> > severely starves the system from being able to respond to user input.
> > 
> > I appreciate the kernel's attempt to keep processes alive, but in the
> > desktop case we see that the system rarely recovers from this situation,
> > so you have to hard shutdown. In this case we view it as desirable that
> > the OOM killer would step in (it is not doing so because direct reclaim
> > is not actually failing).

Yes, we currently use a userspace application that monitors pressure
and OOM kills (there is usually plenty of headroom left for a small
application to run by the time quality of service for most workloads
has already tanked to unacceptable levels). We want to eventually add
this back into the kernel with the appropriate configuration options
(pressure threshold value and sustained duration etc.)

> Yes this is really unfortunate. One thing that could help would be to
> consider a trashing level during the reclaim (get_scan_count) to simply
> forget about LRUs which are constantly refaulting pages back. We already
> have the infrastructure for that. We just need to plumb it in.

This doesn't work without quantifying the actual time you're spending
on thrashing IO. The cutoff for acceptable refaults is very different
between rotating disks, crappy SSDs, and high-end flash.

But in the future we might want the OOM killer to monitor psi memory
levels and dispatch tasks when we sustain X percent for Y seconds.

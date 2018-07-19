Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 23A2A6B0003
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 08:47:56 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b8-v6so5806121qto.16
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 05:47:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c25-v6sor2701276qvc.14.2018.07.19.05.47.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 05:47:53 -0700 (PDT)
Date: Thu, 19 Jul 2018 08:50:38 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180719125038.GB13799@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180718120318.GC2476@hirez.programming.kicks-ass.net>
 <20180719092614.GY2512@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180719092614.GY2512@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 19, 2018 at 11:26:14AM +0200, Peter Zijlstra wrote:
> On Wed, Jul 18, 2018 at 02:03:18PM +0200, Peter Zijlstra wrote:
> 
> > Leaving us just 5 bytes short of needing a single cacheline :/
> > 
> > struct ponies {
> >         unsigned int               tasks[3];                                             /*     0    12 */
> >         unsigned int               cpu_state:2;                                          /*    12:30  4 */
> >         unsigned int               io_state:2;                                           /*    12:28  4 */
> >         unsigned int               mem_state:2;                                          /*    12:26  4 */
> > 
> >         /* XXX 26 bits hole, try to pack */
> > 
> >         /* typedef u64 */ long long unsigned int     last_time;                          /*    16     8 */
> >         /* typedef u64 */ long long unsigned int     some_time[3];                       /*    24    24 */
> >         /* typedef u64 */ long long unsigned int     full_time[2];                       /*    48    16 */
> >         /* --- cacheline 1 boundary (64 bytes) --- */
> >         /* typedef u64 */ long long unsigned int     nonidle_time;                       /*    64     8 */
> > 
> >         /* size: 72, cachelines: 2, members: 8 */
> >         /* bit holes: 1, sum bit holes: 26 bits */
> >         /* last cacheline: 8 bytes */
> > };
> > 
> > ARGGH!
> 
> It _might_ be possible to use curr->se.exec_start for last_time if you
> very carefully audit and place the hooks. I've not gone through it in
> detail, but it might just work.

Hnngg, and chop off an entire cacheline...

But don't we flush that delta out and update the timestamp on every
tick? entity_tick() does update_curr(). That might be too expensive :(

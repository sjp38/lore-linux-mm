Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6B116B000D
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 18:15:15 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id q141-v6so18659818ywg.5
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 15:15:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y124-v6sor5977047ywc.551.2018.07.13.15.15.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 15:15:14 -0700 (PDT)
Date: Fri, 13 Jul 2018 18:17:58 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [RFC PATCH 10/10] psi: aggregate ongoing stall events when
 somebody reads pressure
Message-ID: <20180713221758.GB30013@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-11-hannes@cmpxchg.org>
 <20180712164537.324caee21fd68c47a02af009@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712164537.324caee21fd68c47a02af009@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 04:45:37PM -0700, Andrew Morton wrote:
> On Thu, 12 Jul 2018 13:29:42 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > Right now, psi reports pressure and stall times of already concluded
> > stall events. For most use cases this is current enough, but certain
> > highly latency-sensitive applications, like the Android OOM killer,
> > might want to know about and react to stall states before they have
> > even concluded (e.g. a prolonged reclaim cycle).
> > 
> > This patches the procfs/cgroupfs interface such that when the pressure
> > metrics are read, the current per-cpu states, if any, are taken into
> > account as well.
> > 
> > Any ongoing states are concluded, their time snapshotted, and then
> > restarted. This requires holding the rq lock to avoid corruption. It
> > could use some form of rq lock ratelimiting or avoidance.
> > 
> > Requested-by: Suren Baghdasaryan <surenb@google.com>
> > Not-yet-signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> What-does-that-mean:?

I didn't think this patch was ready for upstream yet, hence the RFC
and the lack of a proper sign-off.

But Suren has been testing this and found it useful in his specific
low-latency application, so I included it for completeness, for other
testers to find, and for possible suggestions on how to improve it.

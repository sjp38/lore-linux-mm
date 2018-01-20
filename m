Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id B94226B0069
	for <linux-mm@kvack.org>; Sat, 20 Jan 2018 07:33:01 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id k23so6940182qtc.14
        for <linux-mm@kvack.org>; Sat, 20 Jan 2018 04:33:01 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r18sor7606676qkr.107.2018.01.20.04.33.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 20 Jan 2018 04:33:00 -0800 (PST)
Date: Sat, 20 Jan 2018 04:32:51 -0800
From: Tejun Heo <tj@kernel.org>
Subject: Re: [patch -mm 3/4] mm, memcg: replace memory.oom_group with policy
 tunable
Message-ID: <20180120123251.GB1096857@devbig577.frc2.facebook.com>
References: <alpine.DEB.2.10.1801161812550.28198@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801161814130.28198@chino.kir.corp.google.com>
 <20180117154155.GU3460072@devbig577.frc2.facebook.com>
 <alpine.DEB.2.10.1801171348190.86895@chino.kir.corp.google.com>
 <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1801191251080.177541@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hello, David.

On Fri, Jan 19, 2018 at 12:53:41PM -0800, David Rientjes wrote:
> Hearing no response, I'll implement this as a separate tunable in a v2 
> series assuming there are no better ideas proposed before next week.  One 
> of the nice things about a separate tunable is that an admin can control 
> the overall policy and they can delegate the mechanism (killall vs one 
> process) to a user subtree.  I agree with your earlier point that killall 
> vs one process is a property of the workload and is better defined 
> separately.

If I understood your arguments correctly, the reasons that you thought
your selectdion policy changes must go together with Roman's victim
action were two-fold.

1. You didn't want a separate knob for group oom behavior and wanted
   it to be combined with selection policy.  I'm glad that you now
   recognize that this would be the wrong design choice.

2. The current selection policy may be exploited by delegatee and
   strictly hierarchical seleciton should be available.  We can debate
   the pros and cons of different heuristics; however, to me, the
   followings are clear.

   * Strictly hierarchical approach can't replace the current policy.
     It doesn't work well for a lot of use cases.

   * OOM victim selection policy has always been subject to changes
     and improvements.

I don't see any blocker here.  The issue you're raising can and should
be handled separately.

In terms of interface, what makes an interface bad is when the
purposes aren't crystalized enough and different interface pieces fail
to clearnly encapsulate what's actually necessary.

Here, whether a workload can survive being killed piece-wise or not is
an inherent property of the workload and a pretty binary one at that.
I'm not necessarily against changing it to take string inputs but
don't see rationales for doing so yet.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

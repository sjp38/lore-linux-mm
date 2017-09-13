Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f197.google.com (mail-qt0-f197.google.com [209.85.216.197])
	by kanga.kvack.org (Postfix) with ESMTP id 286F06B0038
	for <linux-mm@kvack.org>; Wed, 13 Sep 2017 17:56:51 -0400 (EDT)
Received: by mail-qt0-f197.google.com with SMTP id b1so1726936qtc.4
        for <linux-mm@kvack.org>; Wed, 13 Sep 2017 14:56:51 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j187si15054424qkc.458.2017.09.13.14.56.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Sep 2017 14:56:49 -0700 (PDT)
Date: Wed, 13 Sep 2017 14:56:07 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
Message-ID: <20170913215607.GA19259@castle>
References: <20170911131742.16482-1-guro@fb.com>
 <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
 <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170913122914.5gdksbmkolum7ita@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Sep 13, 2017 at 02:29:14PM +0200, Michal Hocko wrote:
> On Mon 11-09-17 13:44:39, David Rientjes wrote:
> > On Mon, 11 Sep 2017, Roman Gushchin wrote:
> > 
> > > This patchset makes the OOM killer cgroup-aware.
> > > 
> > > v8:
> > >   - Do not kill tasks with OOM_SCORE_ADJ -1000
> > >   - Make the whole thing opt-in with cgroup mount option control
> > >   - Drop oom_priority for further discussions
> > 
> > Nack, we specifically require oom_priority for this to function correctly, 
> > otherwise we cannot prefer to kill from low priority leaf memcgs as 
> > required.
> 
> While I understand that your usecase might require priorities I do not
> think this part missing is a reason to nack the cgroup based selection
> and kill-all parts. This can be done on top. The only important part
> right now is the current selection semantic - only leaf memcgs vs. size
> of the hierarchy).

I agree.

> I strongly believe that comparing only leaf memcgs
> is more straightforward and it doesn't lead to unexpected results as
> mentioned before (kill a small memcg which is a part of the larger
> sub-hierarchy).

One of two main goals of this patchset is to introduce cgroup-level
fairness: bigger cgroups should be affected more than smaller,
despite the size of tasks inside. I believe the same principle
should be used for cgroups.

Also, the opposite will make oom_semantics more weird: it will mean
kill all tasks, but also treat memcg as a leaf cgroup.

> 
> I didn't get to read the new version of this series yet and hope to get
> to it soon.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

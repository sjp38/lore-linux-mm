Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8916E6B02F0
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 16:44:42 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id p5so562707pgn.7
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 13:44:42 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n3sor5067654pld.50.2017.09.11.13.44.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Sep 2017 13:44:41 -0700 (PDT)
Date: Mon, 11 Sep 2017 13:44:39 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [v8 0/4] cgroup-aware OOM killer
In-Reply-To: <20170911131742.16482-1-guro@fb.com>
Message-ID: <alpine.DEB.2.10.1709111334210.102819@chino.kir.corp.google.com>
References: <20170911131742.16482-1-guro@fb.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roman Gushchin <guro@fb.com>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, kernel-team@fb.com, cgroups@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org

On Mon, 11 Sep 2017, Roman Gushchin wrote:

> This patchset makes the OOM killer cgroup-aware.
> 
> v8:
>   - Do not kill tasks with OOM_SCORE_ADJ -1000
>   - Make the whole thing opt-in with cgroup mount option control
>   - Drop oom_priority for further discussions

Nack, we specifically require oom_priority for this to function correctly, 
otherwise we cannot prefer to kill from low priority leaf memcgs as 
required.  v8 appears to implement new functionality that we want, to 
compare two memcgs based on usage, but without the ability to influence 
that decision to protect important userspace, so now I'm in a position 
where (1) nothing has changed if I don't use the new mount option or (2) I 
get completely different oom kill selection with the new mount option but 
not the ability to influence it.  I was much happier with the direction 
that v7 was taking, but since v8 causes us to regress without the ability 
to change memcg priority, this has to be nacked.

>   - Kill the whole cgroup if oom_group is set and it's
>     memory.max is reached
>   - Update docs and commit messages

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

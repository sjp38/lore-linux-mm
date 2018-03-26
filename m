Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 850356B0008
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:01:27 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h81-v6so9814004itb.0
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 15:01:27 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id c28si6696703ioa.215.2018.03.26.15.01.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 15:01:25 -0700 (PDT)
Subject: Re: [v2 PATCH] mm: introduce arg_lock to protect arg_start|end and env_start|end in mm_struct
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1522088439-105930-1-git-send-email-yang.shi@linux.alibaba.com>
	<20180326183725.GB27373@bombadil.infradead.org>
	<20180326192132.GE2236@uranus>
	<0bfa8943-a2fe-b0ab-99a2-347094a2bcec@i-love.sakura.ne.jp>
	<20180326212944.GF2236@uranus>
In-Reply-To: <20180326212944.GF2236@uranus>
Message-Id: <201803270700.IJB35465.HJQFSFMVLFOtOO@I-love.SAKURA.ne.jp>
Date: Tue, 27 Mar 2018 07:00:56 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gorcunov@gmail.com
Cc: willy@infradead.org, yang.shi@linux.alibaba.com, adobriyan@gmail.com, mhocko@kernel.org, mguzik@redhat.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Cyrill Gorcunov wrote:
> On Tue, Mar 27, 2018 at 06:10:09AM +0900, Tetsuo Handa wrote:
> > On 2018/03/27 4:21, Cyrill Gorcunov wrote:
> > > That said I think using read-lock here would be a bug.
> > 
> > If I understand correctly, the caller can't set both fields atomically, for
> > prctl() does not receive both fields at one call.
> > 
> >   prctl(PR_SET_MM, PR_SET_MM_ARG_START xor PR_SET_MM_ARG_END xor PR_SET_MM_ENV_START xor PR_SET_MM_ENV_END, new value, 0, 0);
> > 
> 
> True, but the key moment is that two/three/four system calls can
> run simultaneously. And while previously they are ordered by "write",
> with read lock they are completely unordered and this is really
> worries me.

Yes, we need exclusive lock when updating these fields.

>             To be fair I would prefer to drop this old per-field
> interface completely. This per-field interface was rather an ugly
> solution from my side.

But this is userspace visible API and thus we cannot change.

> 
> > Then, I wonder whether reading arg_start|end and env_start|end atomically makes
> > sense. Just retry reading if arg_start > env_end or env_start > env_end is fine?
> 
> Tetsuo, let me re-read this code tomorrow, maybe I miss something obvious.
> 

You are not missing my point. What I thought is

+retry:
-	down_read(&mm->mmap_sem);
 	arg_start = mm->arg_start;
 	arg_end = mm->arg_end;
 	env_start = mm->env_start;
 	env_end = mm->env_end;
-	up_read(&mm->mmap_sem);
 
-	BUG_ON(arg_start > arg_end);
-	BUG_ON(env_start > env_end);
+	if (unlikely(arg_start > arg_end || env_start > env_end)) {
+		cond_resched();
+		goto retry;
+	}

for reading these fields.

By the way, /proc/pid/ readers are serving as a canary who tells something
mm_mmap related problem is happening. On the other hand, it is sad that
such canary cannot be terminated by signal due to use of unkillable waits.
I wish we can use killable waits.

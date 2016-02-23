Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 1116F82F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 20:06:32 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id fl4so100229325pad.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:06:32 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id rq5si37889226pab.126.2016.02.22.17.06.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Feb 2016 17:06:31 -0800 (PST)
Received: by mail-pf0-x22c.google.com with SMTP id q63so101813151pfb.0
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 17:06:31 -0800 (PST)
Date: Mon, 22 Feb 2016 17:06:29 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm,oom: exclude oom_task_origin processes if they
 are OOM-unkillable.
In-Reply-To: <20160218080909.GA18149@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1602221701170.4688@chino.kir.corp.google.com>
References: <1455719460-7690-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1602171430500.15429@chino.kir.corp.google.com> <20160218080909.GA18149@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, mgorman@suse.de, oleg@redhat.com, torvalds@linux-foundation.org, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 18 Feb 2016, Michal Hocko wrote:

> > Anyway, this is NACK'd since task->signal->oom_score_adj is checked under 
> > task_lock() for threads with memory attached, that's the purpose of 
> > finding the correct thread in oom_badness() and taking task_lock().  We 
> > aren't going to duplicate logic in several functions that all do the same 
> > thing.
> 
> Is the task_lock really necessary, though? E.g. oom_task_origin()
> doesn't seem to depend on it for task->signal safety. If you are
> referring to races with changing oom_score_adj does such a race matter
> at all?
> 

oom_badness() ranges from 0 (don't kill) to 1000 (please kill).  It 
factors in the setting of /proc/self/oom_score_adj to change that value.  
That is where OOM_SCORE_ADJ_MIN is enforced.  It is also needed in 
oom_badness() to determine whether a child process should be sacrificed 
for its parent.  We don't add duplicate logic everywhere if you want the 
code to be maintainable; the only exception would be for performance 
critical code which the oom killer most certainly is not.

I'm simply not entertaining any patch to the oom killer that duplicates 
code everywhere, increases its complexity, makes it grow in text size, and 
makes it more difficult to maintain.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

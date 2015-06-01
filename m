Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABC46B0038
	for <linux-mm@kvack.org>; Mon,  1 Jun 2015 06:16:50 -0400 (EDT)
Received: by wizo1 with SMTP id o1so98357815wiz.1
        for <linux-mm@kvack.org>; Mon, 01 Jun 2015 03:16:49 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ga6si17898522wib.68.2015.06.01.03.16.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 01 Jun 2015 03:16:48 -0700 (PDT)
Date: Mon, 1 Jun 2015 12:16:46 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm/oom: Suppress unnecessary "sharing same memory"
 message.
Message-ID: <20150601101646.GC7147@dhcp22.suse.cz>
References: <201505280659.HBE69765.SOtQMJLVFHFFOO@I-love.SAKURA.ne.jp>
 <20150528180524.GB2321@dhcp22.suse.cz>
 <201505292140.JHE18273.SFFMJFHOtQLOVO@I-love.SAKURA.ne.jp>
 <20150529144922.GE22728@dhcp22.suse.cz>
 <201505300220.GCH51071.FVOOFOLQStJMFH@I-love.SAKURA.ne.jp>
 <201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201505312010.JJJ26561.FJOOVSQHLFOtMF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org

On Sun 31-05-15 20:10:23, Tetsuo Handa wrote:
[...]
> By the way, I got two mumbles.
> 
> Is "If any of p's children has a different mm and is eligible for kill," logic
> in oom_kill_process() really needed? Didn't select_bad_process() which was
> called proior to calling oom_kill_process() already choose a best victim
> using for_each_process_thread() ?

This tries to have smaller effect on the system. It tries to kill
younger tasks because this might be and quite often is sufficient to
resolve the OOM condition.

> Is "/* mm cannot safely be dereferenced after task_unlock(victim) */" true?
> It seems to me that it should be "/* mm cannot safely be compared after
> task_unlock(victim) */" because it is theoretically possible to have
> 
>   CPU 0                         CPU 1                   CPU 2
>   task_unlock(victim);
>                                 victim exits and releases mm.
>                                 Usage count of the mm becomes 0 and thus released.
>                                                         New mm is allocated and assigned to some thread.
>   (p->mm == mm) matches the recreated mm and kill unrelated p.
> 
> sequence. We need to either get a reference to victim's mm before
> task_unlock(victim) or do comparison before task_unlock(victim).

Hmm, I guess you are right. The race is theoretically possible,
especially when there are many tasks when iterating over the list might
take some time. reference to the mm would solve this. Care to send a
patch?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

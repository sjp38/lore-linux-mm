Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C79EB6B0069
	for <linux-mm@kvack.org>; Sun, 18 Sep 2016 02:13:33 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id v67so254865515pfv.1
        for <linux-mm@kvack.org>; Sat, 17 Sep 2016 23:13:33 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id tm1si6389951pac.254.2016.09.17.23.13.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 17 Sep 2016 23:13:33 -0700 (PDT)
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160914085227.GB1612@dhcp22.suse.cz>
	<57D91771.9050108@huawei.com>
	<7edef3e0-b7cd-426a-5ed7-b1dad822733a@I-love.SAKURA.ne.jp>
	<57D95620.8000404@huawei.com>
	<201609181500.HIC05206.QJOFMOFHOFtLVS@I-love.SAKURA.ne.jp>
In-Reply-To: <201609181500.HIC05206.QJOFMOFHOFtLVS@I-love.SAKURA.ne.jp>
Message-Id: <201609181513.FBI69733.FFFHOMLQOJOSVt@I-love.SAKURA.ne.jp>
Date: Sun, 18 Sep 2016 15:13:18 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhongjiang@huawei.com
Cc: mhocko@suse.cz, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, qiuxishi@huawei.com, guohanjun@huawei.com, hughd@google.com

Tetsuo Handa wrote:
> As of 4.8-rc6, the OOM reaper cannot take mmap_sem for read at __oom_reap_task()
> because of TIF_MEMDIE thread waiting at ksm_exit() from __mmput() from mmput()
>  from exit_mm() from do_exit(). Thus, __oom_reap_task() returns false and
> oom_reap_task() will emit "oom_reaper: unable to reap pid:%d (%s)\n" message.
> Then, oom_reap_task() clears TIF_MEMDIE from that thread, which in turn
> makes oom_scan_process_thread() not to return OOM_SCAN_ABORT because
> atomic_read(&task->signal->oom_victims) becomes 0 due to exit_oom_victim()
> by the OOM reaper. Then, the OOM killer selects next OOM victim because
> ksmd is waking up the OOM killer via a __GFP_FS allocation request.

Oops. As of 4.8-rc6, __oom_reap_task() returns true because of
find_lock_task_mm() returning NULL. Thus, oom_reap_task() clears TIF_MEMDIE
without emitting "oom_reaper: unable to reap pid:%d (%s)\n" message.

> 
> Thus, this bug will be completely solved (at the cost of selecting next
> OOM victim) as of 4.8-rc6.

The conclusion is same.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

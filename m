Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id CA0056B0069
	for <linux-mm@kvack.org>; Mon, 19 Sep 2016 00:49:31 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id y10so311095547qty.2
        for <linux-mm@kvack.org>; Sun, 18 Sep 2016 21:49:31 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id s129si18089347qkf.110.2016.09.18.21.49.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 18 Sep 2016 21:49:31 -0700 (PDT)
Message-ID: <57DF6D36.3040108@huawei.com>
Date: Mon, 19 Sep 2016 12:44:38 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <20160914085227.GB1612@dhcp22.suse.cz> <57D91771.9050108@huawei.com> <7edef3e0-b7cd-426a-5ed7-b1dad822733a@I-love.SAKURA.ne.jp> <57D95620.8000404@huawei.com> <201609181500.HIC05206.QJOFMOFHOFtLVS@I-love.SAKURA.ne.jp> <201609181513.FBI69733.FFFHOMLQOJOSVt@I-love.SAKURA.ne.jp>
In-Reply-To: <201609181513.FBI69733.FFFHOMLQOJOSVt@I-love.SAKURA.ne.jp>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.cz, akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, qiuxishi@huawei.com, guohanjun@huawei.com, hughd@google.com

On 2016/9/18 14:13, Tetsuo Handa wrote:
> Tetsuo Handa wrote:
>> As of 4.8-rc6, the OOM reaper cannot take mmap_sem for read at __oom_reap_task()
>> because of TIF_MEMDIE thread waiting at ksm_exit() from __mmput() from mmput()
>>  from exit_mm() from do_exit(). Thus, __oom_reap_task() returns false and
>> oom_reap_task() will emit "oom_reaper: unable to reap pid:%d (%s)\n" message.
>> Then, oom_reap_task() clears TIF_MEMDIE from that thread, which in turn
>> makes oom_scan_process_thread() not to return OOM_SCAN_ABORT because
>> atomic_read(&task->signal->oom_victims) becomes 0 due to exit_oom_victim()
>> by the OOM reaper. Then, the OOM killer selects next OOM victim because
>> ksmd is waking up the OOM killer via a __GFP_FS allocation request.
  hi, Tetsuo

  OOM reaper indeed relieve the issue,  as had discussed with Michal,  but it is not completely
  solved.  and OOM livelock had been solved by backport the patch from Michal.
 
  The key is that ksmd enter into the OOM and bail out quickly. because other process implement
  a OOM in the same zone. therefore, ksmd can not obtain the memory.

  Thanks
  zhongjiang
> Oops. As of 4.8-rc6, __oom_reap_task() returns true because of
> find_lock_task_mm() returning NULL. Thus, oom_reap_task() clears TIF_MEMDIE
> without emitting "oom_reaper: unable to reap pid:%d (%s)\n" message.
>
>> Thus, this bug will be completely solved (at the cost of selecting next
>> OOM victim) as of 4.8-rc6.
> The conclusion is same.
>
> .
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

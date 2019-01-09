Return-Path: <SRS0=IlG+=PR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4229C43387
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 10:57:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4348B20883
	for <linux-mm@archiver.kernel.org>; Wed,  9 Jan 2019 10:57:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4348B20883
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B756E8E009E; Wed,  9 Jan 2019 05:57:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFD5B8E0038; Wed,  9 Jan 2019 05:57:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 99FDD8E009E; Wed,  9 Jan 2019 05:57:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6C44E8E0038
	for <linux-mm@kvack.org>; Wed,  9 Jan 2019 05:57:09 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id t133so6062841iof.20
        for <linux-mm@kvack.org>; Wed, 09 Jan 2019 02:57:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=UtaovIX4JZ9p/GRG8Vlhz8qNzEhzzDofppvEHt7Xwzc=;
        b=ipNR9W9dO2g31EK4PA3nr6IZd/8MbVLeWqtdV+dRF/av9eBnPWerthMbOJxGx4gKDW
         /wzEpLDq9amf7SpUWzbrnvLLKzdnNJn2jT63dq/8WeFJW4k8uil88KBQsD53/Lq0vLL1
         hDdRvlpT8shMhFwTjc5rEDzBjXIQT/WDrsq4jWx/VeI2IYtWr9cnjwbmsgj96YbVKhF6
         SfHS9Mpwyi3H/QH2t9vOQVkDu8206LOAP2xw77X4ZeVNGc+AuHHJtyu4003hsFR6Yc68
         Pz4WL5hnP56sWz9AIosXSqzAQxQkisKHFdHLv4oSxm+ikSg24J+S4Uuhe5BWQblm8Idp
         LUJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: AJcUukdgG0bHct86DTz+wS+Dzi+b3IGJEjQj9mhju59MJUqindSt/ItZ
	TpSSUZs6aSTKGFi3harneMd2NMJkQc0nTBejthDWZvtDQkjGzvNrix0YmyB3GkEtUBgI8s2d9Ru
	dz1bh6/2PG9wUWHgexfXjaIjQSa3HK97auT1uvW7Wuv/5sivIagJIh0YgyqsU2cGyDA==
X-Received: by 2002:a6b:c948:: with SMTP id z69mr3647243iof.161.1547031429178;
        Wed, 09 Jan 2019 02:57:09 -0800 (PST)
X-Google-Smtp-Source: ALg8bN58dZWbfnhbz77vwWXi5YikORZd18XmIs4tob1eDP7M9JZqWBPtR6l8NcI/B39mbLZOOEd8
X-Received: by 2002:a6b:c948:: with SMTP id z69mr3647214iof.161.1547031428336;
        Wed, 09 Jan 2019 02:57:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1547031428; cv=none;
        d=google.com; s=arc-20160816;
        b=JIYwzl47Go6HDzQamH5WMAWkv7PkYY+Ur5x4hmV4LcPJwqyXtnaQMqOPmrYHp+mpUn
         hQSqpfDVBEdQvC1P+IXRxl851TV6IahNn1rhn26PGqWj9ERlYkCeiATCmFnVFvbusebC
         cg8RIzd2efalX9p0pX/FfZ3sALBJoZ27dIoyidwCbj7xt7uGf1ZKuwJGW/EGhmjrgmFz
         A3QzPzPnpbmTAEI4rEE3s19xnmT9H2b9RAzY/+YmWMz3eJPeriSwTe3RWCwKGuM26BXU
         L9MfLvQ1bM/lckg+H5Y1QC+5ZTmiTDKxgvVGWk8/Nq2MLjwVN+SyiIGHcePKg9eZdy2P
         k6/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=UtaovIX4JZ9p/GRG8Vlhz8qNzEhzzDofppvEHt7Xwzc=;
        b=Cu+gHh11Oz9/0PK2bm9xLw+4A5iq+L7nOdv8TfuiSe/2XdH2SW9yHsxdxjccd918ra
         TqhC/hJAdfQY4n/KILXki0zqTAy1Jz/+RVcQLPfl04NmRnb/HZJ8rwzmIglQP5IwXXVG
         p80PdpOwIFavgaQydGjHN17iMRjVraSJllePlgaVtvUK9jT/HPqoUY/49Z3smLNID3H+
         9Up7OrHzLJZmp7hKLwpxARP0HZtzSc1v8/9OedyBuQA68IhzYKt6qls39dc0p1MmSMcA
         NyxAGWVzOrm3wXgCOezjQlX3TjxHyNtieGBUUIzf+uPWul/+OzPgto5LQLhU03YQfHGG
         0cdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id j82si1888781itb.63.2019.01.09.02.57.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Jan 2019 02:57:08 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x09Av2GN025416;
	Wed, 9 Jan 2019 19:57:02 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Wed, 09 Jan 2019 19:57:02 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126126163036.bbtec.net [126.126.163.36])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x09Auvj3025373
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 9 Jan 2019 19:57:01 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
To: Andrew Morton <akpm@linux-foundation.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        David Rientjes <rientjes@google.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org,
        Kirill Tkhai <ktkhai@virtuozzo.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
 <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
 <20190107133720.GH31793@dhcp22.suse.cz>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <935ae77c-9663-c3a4-c73a-fa69f9a3065f@i-love.sakura.ne.jp>
Date: Wed, 9 Jan 2019 19:56:57 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190107133720.GH31793@dhcp22.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20190109105657.A9rqqP6me8yPS54e-PzCofrsSG3RBIW_PXTWe7aqQlw@z>

On 2019/01/07 22:37, Michal Hocko wrote:
> On Mon 07-01-19 22:07:43, Tetsuo Handa wrote:
>> On 2019/01/07 20:41, Michal Hocko wrote:
>>> On Sun 06-01-19 15:02:24, Tetsuo Handa wrote:
>>>> Michal and Johannes, can we please stop this stupid behavior now?
>>>
>>> I have proposed a patch with a much more limited scope which is still
>>> waiting for feedback. I haven't heard it wouldn't be working so far.
>>>
>>
>> You mean
>>
>>   mutex_lock_killable would take care of exiting task already. I would
>>   then still prefer to check for mark_oom_victim because that is not racy
>>   with the exit path clearing signals. I can update my patch to use
>>   _killable lock variant if we are really going with the memcg specific
>>   fix.
>>
>> ? No response for two months.
> 
> I mean http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
> which has died in nit picking. I am not very interested to go back there
> and spend a lot of time with it again. If you do not respect my opinion
> as the maintainer of this code then find somebody else to push it
> through.
> 

OK. It turned out that Michal's comment is independent with this patch.
We can apply both Michal's patch and my patch, and here is my patch.

From 0fb58415770a83d6c40d471e1840f8bc4a35ca83 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 26 Dec 2018 19:13:35 +0900
Subject: [PATCH] memcg: killed threads should not invoke memcg OOM killer

If $N > $M, a single process with $N threads in a memcg group can easily
kill all $M processes in that memcg group, for mem_cgroup_out_of_memory()
does not check if current thread needs to invoke the memcg OOM killer.

  T1@P1     |T2...$N@P1|P2...$M   |OOM reaper
  ----------+----------+----------+----------
                        # all sleeping
  try_charge()
    mem_cgroup_out_of_memory()
      mutex_lock(oom_lock)
             try_charge()
               mem_cgroup_out_of_memory()
                 mutex_lock(oom_lock)
      out_of_memory()
        select_bad_process()
        oom_kill_process(P1)
        wake_oom_reaper()
                                   oom_reap_task() # ignores P1
      mutex_unlock(oom_lock)
                 out_of_memory()
                   select_bad_process(P2...$M)
                        # all killed by T2...$N@P1
                   wake_oom_reaper()
                                   oom_reap_task() # ignores P2...$M
                 mutex_unlock(oom_lock)

We don't need to invoke the memcg OOM killer if current thread was killed
when waiting for oom_lock, for mem_cgroup_oom_synchronize(true) and
memory_max_write() can bail out upon SIGKILL, and try_charge() allows
already killed/exiting threads to make forward progress.

If memcg OOM events in different domains are pending, already OOM-killed
threads needlessly wait for pending memcg OOM events in different domains.
An out_of_memory() call is slow because it involves printk(). With slow
serial consoles, out_of_memory() might take more than a second. Therefore,
allowing killed processes to quickly call mmput() from exit_mm() from
do_exit() will help calling __mmput() (which can reclaim more memory than
the OOM reaper can reclaim) quickly.

At first Michal thought that fatal signal check is racy compared to
tsk_is_oom_victim() check. But actually there is no such race, for
by the moment mutex_unlock(&oom_lock) is called after returning from
out_of_memory(), fatal_signal_pending() == F && tsk_is_oom_victim() == T
can't happen if current thread is holding oom_lock inside
mem_cgroup_out_of_memory(). On the other hand,
fatal_signal_pending() == T && tsk_is_oom_victim() == F can happen, and
bailing out upon that condition will save some process from needlessly
being OOM-killed.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/memcontrol.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index b860dd4f7..b0d3bf3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1389,8 +1389,13 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	};
 	bool ret;
 
-	mutex_lock(&oom_lock);
-	ret = out_of_memory(&oc);
+	if (mutex_lock_killable(&oom_lock))
+		return true;
+	/*
+	 * A few threads which were not waiting at mutex_lock_killable() can
+	 * fail to bail out. Therefore, check again after holding oom_lock.
+	 */
+	ret = fatal_signal_pending(current) || out_of_memory(&oc);
 	mutex_unlock(&oom_lock);
 	return ret;
 }
-- 
1.8.3.1


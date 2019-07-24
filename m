Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46D11C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 02:48:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4EA7229F3
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 02:48:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4EA7229F3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=i-love.sakura.ne.jp
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EDA466B0003; Tue, 23 Jul 2019 22:48:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E8BDB6B0005; Tue, 23 Jul 2019 22:48:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D524A6B0006; Tue, 23 Jul 2019 22:48:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 999BE6B0003
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 22:48:01 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id l11so5921123pgc.14
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:48:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DRRaGs64cnwC7u5EA6RmEy4CdRHH9MSLp11mb43YvTk=;
        b=cTT30jZGiyjUzQs6mfgjop6tY2C5lIwKpajSw3XULSNY1m324rtH57oyXi3DBnjcXS
         TWHOa8Yd4Ox+2TUqehEdAZ76WU2a2EXstZUB9XpcG7P0X1oxVTcnw05wfyCFjUnj49sj
         QL/mTVNPJt5dVcCnDX5UvJcRSQEcnJwKkIcUOEKKPNDANO48SX169O1343wbTBZ+XNki
         7O+vz0KxjEGs/xqQ331fIZcUNU4FrVnRgo1SMHJJ7A+FnEkXiB3R81ycrEfdVAepS/pV
         xDxcIEL//KdI9GTnF2y4cAqMeXSdG6d9zMU3g9Y9ypwc8rQhKTxLAYK1k/i2aE6Ek+IQ
         E4dg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
X-Gm-Message-State: APjAAAUX1K6elYAij+DA438syvI1+nNBB6iXKcwvoQGX975juVesBY3z
	ijCRjJA228udUW0q0Il3bfYr0m2AN7IXTPsNZZ65L92vfRaOKsi7KBSzbTvvTMK9fTAaAz1d5N3
	JLxIWX1kn9glp0cmCzICihoyP9frjbM2DW4xvlxMpvbNa8o9CF7huXNuuz6YiI/hD2A==
X-Received: by 2002:a17:902:e383:: with SMTP id ch3mr83104937plb.23.1563936481228;
        Tue, 23 Jul 2019 19:48:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzc72rPeejHBPRLcPR4j8aXX3zTo+q6SndcizuKFR1nWZWkCIhDinOjD2u72GZEOUUnSM4x
X-Received: by 2002:a17:902:e383:: with SMTP id ch3mr83104898plb.23.1563936480550;
        Tue, 23 Jul 2019 19:48:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563936480; cv=none;
        d=google.com; s=arc-20160816;
        b=Tz6BjJRGfIwiBRbnRVx9Zl4k+m3B5Sgt0O9hafjqeYkgsriGiKwYBKWUtK6uckmuSV
         cH8dOr15qurzgDxOGEoK7p4O5qw73DsSyOvvqNXAbM+AkKqdnb0wLEKPmHkyG8txfgeE
         iy/nhFlKJxLGVQPgXyd7xp3p24hmqODIxHFfS0um5HvS3T/Hwxluyxka+NsJMKssDEuJ
         xXPVQOrehMKeO0L8dBU625gJcQvVVAI7MryR/Btlw6ftVkqeLEm2Gu9w0A9VRnPlKyJe
         a3Jc0H0+AKJDNi9jMk+pkGnu6SZU51Kpg7dTsP4ArUW6N5BjccRr6KFgYPrQrQ6/r/uS
         LRLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DRRaGs64cnwC7u5EA6RmEy4CdRHH9MSLp11mb43YvTk=;
        b=S1db3CTZr01KN2qRoHg2l8TPgdfV4oVaOIqVr14Q+8urbjO0QCEpwlFSonSmYxyY9E
         CSXoGl2XBzaVPSAQMDAQTe6ZmAZq3ZHYjM71NubgtY3AX8ILrAMHyalbxxAC8tAEJ7+u
         +zjBrhG50ztss1NPNtQPuvmEtz4LcCdZKYh/MuUoEM6IA832UeMfNOWe06W5r86gIDtT
         KdOFuaJEhXMfzelR78g/AHDE/vVWyAqS7J++/8yDWSw0rbyLiDfXAPxOPLMXbdqF81lS
         Qvc4I2nNkboM2Y91aZ0OWNTpUq7Qvl6Gv70rLCYT/5O7dhMpLOWRHGj+XPNPdL5gbfvV
         zFoA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id x6si13663205pjn.10.2019.07.23.19.47.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 19:48:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) client-ip=202.181.97.72;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of penguin-kernel@i-love.sakura.ne.jp designates 202.181.97.72 as permitted sender) smtp.mailfrom=penguin-kernel@i-love.sakura.ne.jp
Received: from fsav405.sakura.ne.jp (fsav405.sakura.ne.jp [133.242.250.104])
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTP id x6O1lS5P055675;
	Wed, 24 Jul 2019 10:47:28 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Received: from www262.sakura.ne.jp (202.181.97.72)
 by fsav405.sakura.ne.jp (F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp);
 Wed, 24 Jul 2019 10:47:28 +0900 (JST)
X-Virus-Status: clean(F-Secure/fsigk_smtp/530/fsav405.sakura.ne.jp)
Received: from [192.168.1.8] (softbank126012062002.bbtec.net [126.12.62.2])
	(authenticated bits=0)
	by www262.sakura.ne.jp (8.15.2/8.15.2) with ESMTPSA id x6O1lMno055571
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NO);
	Wed, 24 Jul 2019 10:47:28 +0900 (JST)
	(envelope-from penguin-kernel@i-love.sakura.ne.jp)
Subject: Re: [PATCH] mm, oom: avoid printk() iteration under RCU
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>,
        Roman Gushchin <guro@fb.com>, Shakeel Butt <shakeelb@google.com>
References: <1563360901-8277-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20190723161412.df47e0c9ecd8bc28d3183604@linux-foundation.org>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f4b00a4d-3f0d-fc3a-cef8-62a20ec39ea3@i-love.sakura.ne.jp>
Date: Wed, 24 Jul 2019 10:47:26 +0900
User-Agent: Mozilla/5.0 (Windows NT 6.3; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190723161412.df47e0c9ecd8bc28d3183604@linux-foundation.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019/07/24 8:14, Andrew Morton wrote:
> On Wed, 17 Jul 2019 19:55:01 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:
> 
>> Currently dump_tasks() might call printk() for many thousands times under
>> RCU, which might take many minutes for slow consoles. Therefore, split
>> dump_tasks() into three stages; take a snapshot of possible OOM victim
>> candidates under RCU, dump the snapshot from reschedulable context, and
>> destroy the snapshot.
>>
>> In a future patch, the first stage would be moved to select_bad_process()
>> and the third stage would be moved to after oom_kill_process(), and will
>> simplify refcount handling.
> 
> Look straightforward enough.

Thanks.

> 
>>
>> ...
>>
>>  static void dump_tasks(struct oom_control *oc)
>>  {
>> -	pr_info("Tasks state (memory values in pages):\n");
>> -	pr_info("[  pid  ]   uid  tgid total_vm      rss pgtables_bytes swapents oom_score_adj name\n");
>> +	static LIST_HEAD(list);
> 
> I don't think this needs to be static?

Well, the OOM killer is serialized by oom_lock mutex.
Thus, I guess we should reduce stack usage where reasonable.
For now you can drop this "static" if you want. But this
variable will be after all moved to outside of this function
by a future patch...

> 
>> +	struct task_struct *p;
>> +	struct task_struct *t;
>>  


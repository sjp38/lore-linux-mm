Return-Path: <SRS0=9Pd6=UE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24AD6C282CE
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 01:15:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B7AFF2070B
	for <linux-mm@archiver.kernel.org>; Wed,  5 Jun 2019 01:15:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B7AFF2070B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EEDE06B000C; Tue,  4 Jun 2019 21:15:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E9E256B000D; Tue,  4 Jun 2019 21:15:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8C9A6B0266; Tue,  4 Jun 2019 21:15:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A28596B000C
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 21:15:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id r12so17267956pfl.2
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 18:15:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=HK7V/1xYaTdEIIJp/rlOb4zcGTio+6dRx3uOe3+SOGQ=;
        b=DPWxKFI8Ts0Bp7orivA10Ky/7bAsmr8ZMLxXKs6HCPlcgub9+SPSB5e4tnvO/a7IRx
         hYNw0++ny+Ay0VTNXxWQG9LirkN4oUfwhfe/cgh9bS2Wk1tePLcvdIsXPENTGRfEbbiW
         h6jQBs8Q3ZVV/qeVzLaLGLyqfhwYKggJITYK8hMiLgRAlz44ipkhj9VvWPk/y67307uD
         tBOxfflNBPMoxnERw4gLpxmJT1AQmRmZajXO3uVWwm1tx6QkVe68xWpg45KvpGcvpjX6
         LFXI8Q5IUjoNA+CtOjbYK8eEsC08rjNbGBEBoLA0PGkkcjMYX1MWzmaC0akE0ry8lRF9
         Gbxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAVmZnfK/9g0YrZrYHAIZyl3ZaGIzcdWtwR8axaPRF/dJw5Kryr8
	ShvqD8a0zSyOY7ojb3EAzMkjrFaRdDTDQnozLhuewRmh/rtxNjIzA1wgIQOfOg7zhmZrp0NxqTf
	55IhvglAVUwFEq9sufxhQVc2RZ7EoedON2QnkhnnCJ7l1o2ItRE66CaVikt6Y05VDtw==
X-Received: by 2002:a17:902:2ba9:: with SMTP id l38mr33520826plb.300.1559697339214;
        Tue, 04 Jun 2019 18:15:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzq2VvtijYZStCNpCZwap0cYQ0g3TOmoOBqID8rv8ocy4krPEM0o7DADbqXBZOKTNzHclDm
X-Received: by 2002:a17:902:2ba9:: with SMTP id l38mr33520742plb.300.1559697337670;
        Tue, 04 Jun 2019 18:15:37 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559697337; cv=none;
        d=google.com; s=arc-20160816;
        b=h9opT2dm1S4BS6W9aSb4qT6ukm2UFzFHGgiz9ppzNZ/TWKD2KYBesYX3l81leZ/SrA
         gRo38AtJyfaTsjsYNne2qel1BF3Hm6Sx0IknE0bFf6IeDXmYmpQfBUP2fK99y+XXmWpZ
         3lcZEoUTOu2yy+QB4899HwQt/g0YQhiaTmLqi49bWntV/vkpiTPk0s8zCARlI7LyD9Xr
         jkJvY6Qp2bl5hGmWNpYBsOm5bsy5fXW/N5Ys+YkgM9d/TksEBy6EfUV93EvTCd8v34qL
         eO+S0aOShnSOSstyWnTKtbcmZNupmwhebNG0kB/O6ccT7tIoQHhuW6EVkPgtz4WUPBxr
         ROMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=HK7V/1xYaTdEIIJp/rlOb4zcGTio+6dRx3uOe3+SOGQ=;
        b=aia48flSxhQY6AAIFzDgPs05qvIm8/KYBTZ6umjdSYx9CntbidrSSMvpvDJVW3bn9J
         iyfJomWQoZh0aiV3NVKDN3UdQ++E1mcmJd5R2AU+WAszEWNwpO799zCGPEZMKJOBHbKd
         8xmWkWCmdq9ETyxkIlsy3WyWzT4Mhfpb1g4BrUBUz+UgaOh6kmaP+c+NAHFIsfHF7TU0
         wtlBUkS1iWtPMLTS7Hyn2sY6nk3ng6wm9gW69UW06QkeaHfjxFhbmEqqOY593h6FtmEa
         yt9NHx0f1ZG0CJH3thNTv+qGprDVbjIbWRY27vOPIJKWgUr6llpYZhVWbWCML8J+UrbA
         YPLA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-56.freemail.mail.aliyun.com (out30-56.freemail.mail.aliyun.com. [115.124.30.56])
        by mx.google.com with ESMTPS id f7si23402258pgd.155.2019.06.04.18.15.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 18:15:37 -0700 (PDT)
Received-SPF: pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.56 as permitted sender) client-ip=115.124.30.56;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of joseph.qi@linux.alibaba.com designates 115.124.30.56 as permitted sender) smtp.mailfrom=joseph.qi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R421e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e04407;MF=joseph.qi@linux.alibaba.com;NM=1;PH=DS;RN=7;SR=0;TI=SMTPD_---0TTSDNmF_1559697333;
Received: from JosephdeMacBook-Pro.local(mailfrom:joseph.qi@linux.alibaba.com fp:SMTPD_---0TTSDNmF_1559697333)
          by smtp.aliyun-inc.com(127.0.0.1);
          Wed, 05 Jun 2019 09:15:34 +0800
Subject: Re: [RFC PATCH 2/3] psi: cgroup v1 support
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, akpm@linux-foundation.org,
 Tejun Heo <tj@kernel.org>, Jiufei Xue <jiufei.xue@linux.alibaba.com>,
 Caspar Zhang <caspar@linux.alibaba.com>
References: <20190604015745.78972-1-joseph.qi@linux.alibaba.com>
 <20190604015745.78972-3-joseph.qi@linux.alibaba.com>
 <20190604115519.GA18545@cmpxchg.org>
From: Joseph Qi <joseph.qi@linux.alibaba.com>
Message-ID: <7c9e6755-5996-5d96-c0d7-fd3d00d59a8a@linux.alibaba.com>
Date: Wed, 5 Jun 2019 09:15:33 +0800
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.11; rv:60.0)
 Gecko/20100101 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190604115519.GA18545@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

Thanks for the quick comments.

On 19/6/4 19:55, Johannes Weiner wrote:
> On Tue, Jun 04, 2019 at 09:57:44AM +0800, Joseph Qi wrote:
>> Implements pressure stall tracking for cgroup v1.
>>
>> Signed-off-by: Joseph Qi <joseph.qi@linux.alibaba.com>
>> ---
>>  kernel/sched/psi.c | 65 +++++++++++++++++++++++++++++++++++++++-------
>>  1 file changed, 56 insertions(+), 9 deletions(-)
>>
>> diff --git a/kernel/sched/psi.c b/kernel/sched/psi.c
>> index 7acc632c3b82..909083c828d5 100644
>> --- a/kernel/sched/psi.c
>> +++ b/kernel/sched/psi.c
>> @@ -719,13 +719,30 @@ static u32 psi_group_change(struct psi_group *group, int cpu,
>>  	return state_mask;
>>  }
>>  
>> -static struct psi_group *iterate_groups(struct task_struct *task, void **iter)
>> +static struct cgroup *psi_task_cgroup(struct task_struct *task, enum psi_res res)
>> +{
>> +	switch (res) {
>> +	case NR_PSI_RESOURCES:
>> +		return task_dfl_cgroup(task);
>> +	case PSI_IO:
>> +		return task_cgroup(task, io_cgrp_subsys.id);
>> +	case PSI_MEM:
>> +		return task_cgroup(task, memory_cgrp_subsys.id);
>> +	case PSI_CPU:
>> +		return task_cgroup(task, cpu_cgrp_subsys.id);
>> +	default:  /* won't reach here */
>> +		return NULL;
>> +	}
>> +}
>> +
>> +static struct psi_group *iterate_groups(struct task_struct *task, void **iter,
>> +					enum psi_res res)
>>  {
>>  #ifdef CONFIG_CGROUPS
>>  	struct cgroup *cgroup = NULL;
>>  
>>  	if (!*iter)
>> -		cgroup = task->cgroups->dfl_cgrp;
>> +		cgroup = psi_task_cgroup(task, res);
>>  	else if (*iter == &psi_system)
>>  		return NULL;
>>  	else
>> @@ -776,15 +793,45 @@ void psi_task_change(struct task_struct *task, int clear, int set)
>>  		     wq_worker_last_func(task) == psi_avgs_work))
>>  		wake_clock = false;
>>  
>> -	while ((group = iterate_groups(task, &iter))) {
>> -		u32 state_mask = psi_group_change(group, cpu, clear, set);
>> +	if (cgroup_subsys_on_dfl(cpu_cgrp_subsys) ||
>> +	    cgroup_subsys_on_dfl(memory_cgrp_subsys) ||
>> +	    cgroup_subsys_on_dfl(io_cgrp_subsys)) {
>> +		while ((group = iterate_groups(task, &iter, NR_PSI_RESOURCES))) {
>> +			u32 state_mask = psi_group_change(group, cpu, clear, set);
>>  
>> -		if (state_mask & group->poll_states)
>> -			psi_schedule_poll_work(group, 1);
>> +			if (state_mask & group->poll_states)
>> +				psi_schedule_poll_work(group, 1);
>>  
>> -		if (wake_clock && !delayed_work_pending(&group->avgs_work))
>> -			schedule_delayed_work(&group->avgs_work, PSI_FREQ);
>> +			if (wake_clock && !delayed_work_pending(&group->avgs_work))
>> +				schedule_delayed_work(&group->avgs_work, PSI_FREQ);
>> +		}
>> +	} else {
>> +		enum psi_task_count i;
>> +		enum psi_res res;
>> +		int psi_flags = clear | set;
>> +
>> +		for (i = NR_IOWAIT; i < NR_PSI_TASK_COUNTS; i++) {
>> +			if ((i == NR_IOWAIT) && (psi_flags & TSK_IOWAIT))
>> +				res = PSI_IO;
>> +			else if ((i == NR_MEMSTALL) && (psi_flags & TSK_MEMSTALL))
>> +				res = PSI_MEM;
>> +			else if ((i == NR_RUNNING) && (psi_flags & TSK_RUNNING))
>> +				res = PSI_CPU;
>> +			else
>> +				continue;
>> +
>> +			while ((group = iterate_groups(task, &iter, res))) {
>> +				u32 state_mask = psi_group_change(group, cpu, clear, set);
> 
> This doesn't work. Each resource state is composed of all possible
> task states:
> 
> static bool test_state(unsigned int *tasks, enum psi_states state)
> {
> 	switch (state) {
> 	case PSI_IO_SOME:
> 		return tasks[NR_IOWAIT];
> 	case PSI_IO_FULL:
> 		return tasks[NR_IOWAIT] && !tasks[NR_RUNNING];
> 	case PSI_MEM_SOME:
> 		return tasks[NR_MEMSTALL];
> 	case PSI_MEM_FULL:
> 		return tasks[NR_MEMSTALL] && !tasks[NR_RUNNING];
> 	case PSI_CPU_SOME:
> 		return tasks[NR_RUNNING] > 1;
> 	case PSI_NONIDLE:
> 		return tasks[NR_IOWAIT] || tasks[NR_MEMSTALL] ||
> 			tasks[NR_RUNNING];
> 	default:
> 		return false;
> 	}
> }
> 
> So the IO controller needs to know of NR_RUNNING to tell some vs full,
> the memory controller needs to know of NR_IOWAIT to tell nonidle etc.
> 
> You need to run the full psi task tracking and aggregation machinery
> separately for each of the different cgroups a task can be in in v1.
> 
Yes, since different controllers have their own hierarchy.

> Needless to say, that is expensive. For cpu, memory and io, it's
> triple the scheduling overhead with three ancestor walks and three
> times the cache footprint; three times more aggregation workers every
> two seconds... We could never turn this on per default.
> 
IC, but even on cgroup v2, would it still be expensive if we have many
cgroups?

> Have you considered just co-mounting cgroup2, if for nothing else, to
> get the pressure numbers?
> 
Do you mean mounting cgroup1 and cgroup2 at the same time? 
IIUC, this may not work since many cgroup code have xxx_on_dfl check.

Thanks,
Joseph


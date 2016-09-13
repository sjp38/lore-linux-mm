Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A36AC6B025E
	for <linux-mm@kvack.org>; Tue, 13 Sep 2016 09:24:29 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id q188so260174615oia.1
        for <linux-mm@kvack.org>; Tue, 13 Sep 2016 06:24:29 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id v79si14071309oif.177.2016.09.13.06.24.12
        for <linux-mm@kvack.org>;
        Tue, 13 Sep 2016 06:24:13 -0700 (PDT)
Message-ID: <57D7FB71.9090102@huawei.com>
Date: Tue, 13 Sep 2016 21:13:21 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz> <57D67A8A.7070500@huawei.com> <20160912111327.GG14524@dhcp22.suse.cz> <57D6B0C4.6040400@huawei.com> <20160912174445.GC14997@dhcp22.suse.cz>
In-Reply-To: <20160912174445.GC14997@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On 2016/9/13 1:44, Michal Hocko wrote:
> On Mon 12-09-16 21:42:28, zhong jiang wrote:
>> On 2016/9/12 19:13, Michal Hocko wrote:
>>> On Mon 12-09-16 17:51:06, zhong jiang wrote:
>>> [...]
>>>> hi,  Michal
>>>> oom reaper indeed can accelerate the recovery of memory, but the patch
>>>> solve the extreme scenario, I hit it by runing trinity. I think the
>>>> scenario can happen whether oom reaper or not.
>>> could you be more specific about the case when the oom reaper and the
>>> current oom code led to the oom deadlock?
>> It is not the oom deadlock.  It will lead to hungtask.  The explain is
>> as follows.
>>
>> process A occupy a resource and lock it. then A need to allocate
>> memory when memory is very low. at the some time, oom will come up and
>> return directly. because it find other process is freeing memory in
>> same zone.
>>
>> however, the freed memory is taken away by another process.
>> it will lead to A oom again and again.
>>
>> process B still wait some resource holded by A. so B will obtain the
>> lock until A release the resource. therefor, if A spend much time to
>> obtain memory, B will hungtask.
> OK, I see what you are aiming for. And indeed such a starvation and
> resulting priority inversion is possible. It is a hard problem to solve
> and your patch doesn't address it either. You can spend enough time
> reclaiming and retrying without ever getting to the oom path to trigger
> this hungtask warning.
  Yes.
> If you want to solve this problem properly then you would have to give
> tasks which are looping in the page allocator access to some portion of
> memory reserves. This is quite tricky to do right, though.
  To use some portion of memory reserves is almost no effect in a so starvation scenario.
   I think the hungtask still will occur. it can not  solve the problem primarily.
> Retry counters with the fail path have been proposed in the past and not
> accepted.
  The above patch have been tested by runing the trinity.  The question is fixed. 
  Is there  any reasonable reason oppose to the patch ?  or it will bring in  any side-effect.

 Thanks
zhongjiang


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

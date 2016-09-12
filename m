Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 156D16B0253
	for <linux-mm@kvack.org>; Mon, 12 Sep 2016 09:47:14 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id o7so305234319oif.0
        for <linux-mm@kvack.org>; Mon, 12 Sep 2016 06:47:14 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id z34si10183261otb.198.2016.09.12.06.47.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 12 Sep 2016 06:47:09 -0700 (PDT)
Message-ID: <57D6B0C4.6040400@huawei.com>
Date: Mon, 12 Sep 2016 21:42:28 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz> <57D67A8A.7070500@huawei.com> <20160912111327.GG14524@dhcp22.suse.cz>
In-Reply-To: <20160912111327.GG14524@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On 2016/9/12 19:13, Michal Hocko wrote:
> On Mon 12-09-16 17:51:06, zhong jiang wrote:
> [...]
>> hi,  Michal
>> oom reaper indeed can accelerate the recovery of memory, but the patch
>> solve the extreme scenario, I hit it by runing trinity. I think the
>> scenario can happen whether oom reaper or not.
> could you be more specific about the case when the oom reaper and the
> current oom code led to the oom deadlock?
  It is not the oom deadlock.  It will lead  to hungtask.  The explain is as follows.

  process A occupy a resource and lock it.  then A need to allocate memory when memory is
  very low. at the some time, oom will come up and return directly. because it find other process
  is freeing memory in same zone.  however,  the freed memory is taken away by another process.
 it will lead to A oom again and again.

process B still wait some resource holded by A. so B will obtain the lock until A release the resource.
therefor,  if A spend much time to obtain memory,  B will hungtask. 

Thanks
zhongjiang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

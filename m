Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0BA986B0253
	for <linux-mm@kvack.org>; Wed, 14 Sep 2016 03:21:24 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id e20so27880057itc.0
        for <linux-mm@kvack.org>; Wed, 14 Sep 2016 00:21:24 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id r7si17356253oig.5.2016.09.14.00.21.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 14 Sep 2016 00:21:07 -0700 (PDT)
Message-ID: <57D8F8AE.1090404@huawei.com>
Date: Wed, 14 Sep 2016 15:13:50 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix oom work when memory is under pressure
References: <1473173226-25463-1-git-send-email-zhongjiang@huawei.com> <20160909114410.GG4844@dhcp22.suse.cz> <57D67A8A.7070500@huawei.com> <20160912111327.GG14524@dhcp22.suse.cz> <57D6B0C4.6040400@huawei.com> <20160912174445.GC14997@dhcp22.suse.cz> <57D7FB71.9090102@huawei.com> <20160913132854.GB6592@dhcp22.suse.cz>
In-Reply-To: <20160913132854.GB6592@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: akpm@linux-foundation.org, vbabka@suse.cz, rientjes@google.com, linux-mm@kvack.org, Xishi Qiu <qiuxishi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>

On 2016/9/13 21:28, Michal Hocko wrote:
> On Tue 13-09-16 21:13:21, zhong jiang wrote:
>> On 2016/9/13 1:44, Michal Hocko wrote:
> [...]
>>> If you want to solve this problem properly then you would have to give
>>> tasks which are looping in the page allocator access to some portion of
>>> memory reserves. This is quite tricky to do right, though.
>> To use some portion of memory reserves is almost no effect in a so
>> starvation scenario.  I think the hungtask still will occur. it can
>> not solve the problem primarily.
> Granting an access to memory reserves is of course no full solution but
> it raises chances for a forward progress. Other solutions would have to
> guarantee that the memory reclaimed on behalf of the requester will be
> given to the requester. Not an easy task
>
>>> Retry counters with the fail path have been proposed in the past and not
>>> accepted.
>> The above patch have been tested by runing the trinity.  The question
>> is fixed.  Is there any reasonable reason oppose to the patch ? or it
>> will bring in any side-effect.
> Sure there is. Low order allocations have been traditionally non failing
> and changing that behavior is a major obstacle because it opens up a
> door to many bugs. I've tried to do something similar in the past and
> there was a strong resistance against it. Believe me been there done
> that...
>
  hi, Michal

  Recently, I hit the same issue when run a OOM case of the LTP and ksm enable.
 
[  601.937145] Call trace:
[  601.939600] [<ffffffc000086a88>] __switch_to+0x74/0x8c
[  601.944760] [<ffffffc000a1bae0>] __schedule+0x23c/0x7bc
[  601.950007] [<ffffffc000a1c09c>] schedule+0x3c/0x94
[  601.954907] [<ffffffc000a1eb84>] rwsem_down_write_failed+0x214/0x350
[  601.961289] [<ffffffc000a1e32c>] down_write+0x64/0x80
[  601.966363] [<ffffffc00021f794>] __ksm_exit+0x90/0x19c
[  601.971523] [<ffffffc0000be650>] mmput+0x118/0x11c
[  601.976335] [<ffffffc0000c3ec4>] do_exit+0x2dc/0xa74
[  601.981321] [<ffffffc0000c46f8>] do_group_exit+0x4c/0xe4
[  601.986656] [<ffffffc0000d0f34>] get_signal+0x444/0x5e0
[  601.991904] [<ffffffc000089fcc>] do_signal+0x1d8/0x450
[  601.997065] [<ffffffc00008a35c>] do_notify_resume+0x70/0x78

The root case is that ksmd hold the read lock. and the lock is not released.
 scan_get_next_rmap_item
         down_read
                   get_next_rmap_item
                             alloc_rmap_item     #ksmd will loop permanently.

How do you see this kind of situation ? or  let the issue alone.

Thanks
zhongjiang
 
                      
    

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

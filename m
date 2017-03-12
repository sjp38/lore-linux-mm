Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D98F56B046D
	for <linux-mm@kvack.org>; Sun, 12 Mar 2017 06:17:23 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id w189so245625943pfb.4
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 03:17:23 -0700 (PDT)
Received: from smtpbg.qq.com (SMTPBG354.QQ.COM. [59.37.110.87])
        by mx.google.com with ESMTPS id w5si8419642pgo.121.2017.03.12.03.17.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 12 Mar 2017 03:17:22 -0700 (PDT)
Subject: Re: [PATCH v2 RFC] mm/vmscan: more restrictive condition for retry in
 do_try_to_free_pages
References: <1489240264-3290-1-git-send-email-ysxie@foxmail.com>
 <CALvZod6dptidW33mpvSkQfMBM=xsfSPEEJzB+3u4ekr8m3bSOA@mail.gmail.com>
From: Yisheng Xie <ysxie@foxmail.com>
Message-ID: <58C51FA9.4000705@foxmail.com>
Date: Sun, 12 Mar 2017 18:15:05 +0800
MIME-Version: 1.0
In-Reply-To: <CALvZod6dptidW33mpvSkQfMBM=xsfSPEEJzB+3u4ekr8m3bSOA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shakeel Butt <shakeelb@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, riel@redhat.com, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, xieyisheng1@huawei.com, guohanjun@huawei.com, Xishi Qiu <qiuxishi@huawei.com>

hi, Shakeel,

On 03/12/2017 01:52 AM, Shakeel Butt wrote:
> On Sat, Mar 11, 2017 at 5:51 AM, Yisheng Xie <ysxie@foxmail.com> wrote:
>> From: Yisheng Xie <xieyisheng1@huawei.com>
>>
>> When we enter do_try_to_free_pages, the may_thrash is always clear, and
>> it will retry shrink zones to tap cgroup's reserves memory by setting
>> may_thrash when the former shrink_zones reclaim nothing.
>>
>> However, when memcg is disabled or on legacy hierarchy, it should not do
>> this useless retry at all, for we do not have any cgroup's reserves
>> memory to tap, and we have already done hard work but made no progress.
>>
>> To avoid this time costly and useless retrying, add a stub function
>> may_thrash and return true when memcg is disabled or on legacy
>> hierarchy.
>>
>> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
>> Suggested-by: Shakeel Butt <shakeelb@google.com>
>> ---
>>
>>                 return 1;
>>
>>         /* Untapped cgroup reserves?  Don't OOM, retry. */
>> -       if (!sc->may_thrash) {
>> +       if (!may_thrash(sc)) {
> Thanks Yisheng. The name of the function may_thrash() is confusing in
> the sense that it is returning exactly the opposite of what its name
> implies. 
Right.

> How about reversing the condition of may_thrash() function
> and change the scan_control's field may_thrash to thrashed?
hmm, maybe I can change the may_thrash() function to mem_cgroup_thrashed().
For, if change the scan_control's may_thrash to thrashed, it may also looks
confusing in shrink_node, and it will be like:
                         if (mem_cgroup_low(root, memcg)) {
                                 if (!sc->thrashed) -----> looks confuse here?
                                         continue;
                                 mem_cgroup_events(memcg, MEMCG_LOW, 1);
                        }

Thanks
Yisheng Xie
	@

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

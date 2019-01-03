Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 71B718E0002
	for <linux-mm@kvack.org>; Thu,  3 Jan 2019 12:34:36 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id h10so25813509plk.12
        for <linux-mm@kvack.org>; Thu, 03 Jan 2019 09:34:36 -0800 (PST)
Received: from out4437.biz.mail.alibaba.com (out4437.biz.mail.alibaba.com. [47.88.44.37])
        by mx.google.com with ESMTPS id z67si53419796pfb.268.2019.01.03.09.34.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jan 2019 09:34:35 -0800 (PST)
Subject: Re: [RFC PATCH 0/3] mm: memcontrol: delayed force empty
References: <1546459533-36247-1-git-send-email-yang.shi@linux.alibaba.com>
 <20190103101215.GH31793@dhcp22.suse.cz>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <b3ad06ed-f620-7aa0-5697-a1bbe2d7bfe1@linux.alibaba.com>
Date: Thu, 3 Jan 2019 09:33:14 -0800
MIME-Version: 1.0
In-Reply-To: <20190103101215.GH31793@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 1/3/19 2:12 AM, Michal Hocko wrote:
> On Thu 03-01-19 04:05:30, Yang Shi wrote:
>> Currently, force empty reclaims memory synchronously when writing to
>> memory.force_empty.  It may take some time to return and the afterwards
>> operations are blocked by it.  Although it can be interrupted by signal,
>> it still seems suboptimal.
> Why it is suboptimal? We are doing that operation on behalf of the
> process requesting it. What should anybody else pay for it? In other
> words why should we hide the overhead?

Please see the below explanation.

>
>> Now css offline is handled by worker, and the typical usecase of force
>> empty is before memcg offline.  So, handling force empty in css offline
>> sounds reasonable.
> Hmm, so I guess you are talking about
> echo 1 > $MEMCG/force_empty
> rmdir $MEMCG
>
> and you are complaining that the operation takes too long. Right? Why do
> you care actually?

We have some usecases which create and remove memcgs very frequently, 
and the tasks in the memcg may just access the files which are unlikely 
accessed by anyone else. So, we prefer force_empty the memcg before 
rmdir'ing it to reclaim the page cache so that they don't get 
accumulated to incur unnecessary memory pressure. Since the memory 
pressure may incur direct reclaim to harm some latency sensitive 
applications.

And, the create/remove might be run in a script sequentially (there 
might be a lot scripts or applications are run in parallel to do this), i.e.
mkdir cg1
do something
echo 0 > cg1/memory.force_empty
rmdir cg1

mkdir cg2
...

The creation of the afterwards memcg might be blocked by the force_empty 
for long time if there are a lot page caches, so the overall throughput 
of the system may get hurt.
And, it is not that urgent to reclaim the page cache right away and it 
is not that important who pays the cost, we just need a mechanism to 
reclaim the pages soon in a short while. The overhead could be smoothed 
by background workqueue.

And, the patch still keeps the old behavior, just in case someone else 
still depends on it.

Thanks,
Yang

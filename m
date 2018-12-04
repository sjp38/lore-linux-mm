Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id C5B5B6B6C6D
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 21:53:49 -0500 (EST)
Received: by mail-pl1-f200.google.com with SMTP id a10so11553105plp.14
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 18:53:49 -0800 (PST)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id a193si16137169pfa.214.2018.12.03.18.53.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Dec 2018 18:53:48 -0800 (PST)
Reply-To: xlpang@linux.alibaba.com
Subject: Re: [PATCH 3/3] mm/memcg: Avoid reclaiming below hard protection
References: <20181203080119.18989-1-xlpang@linux.alibaba.com>
 <20181203080119.18989-3-xlpang@linux.alibaba.com>
 <20181203115736.GQ31738@dhcp22.suse.cz>
From: Xunlei Pang <xlpang@linux.alibaba.com>
Message-ID: <8d8e860d-f9a4-6708-ccab-d47180f0ad0a@linux.alibaba.com>
Date: Tue, 4 Dec 2018 10:53:32 +0800
MIME-Version: 1.0
In-Reply-To: <20181203115736.GQ31738@dhcp22.suse.cz>
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Roman Gushchin <guro@fb.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2018/12/3 PM 7:57, Michal Hocko wrote:
> On Mon 03-12-18 16:01:19, Xunlei Pang wrote:
>> When memcgs get reclaimed after its usage exceeds min, some
>> usages below the min may also be reclaimed in the current
>> implementation, the amount is considerably large during kswapd
>> reclaim according to my ftrace results.
> 
> And here again. Describe the setup and the behavior please?
> 

step 1
mkdir -p /sys/fs/cgroup/memory/online
cd /sys/fs/cgroup/memory/online
echo 512M > memory.max
echo 409600000 > memory.min
echo $$ > tasks
dd if=/dev/sda of=/dev/null


while true; do sleep 1; cat memory.current ; cat memory.min; done


step 2
create global memory pressure by allocating annoymous and cached
pages to constantly trigger kswap: dd if=/dev/sdb of=/dev/null

step 3
Then observe "online" groups, hundreds of kbytes a little over
memory.min can cause tens of MiB to be reclaimed by kswapd.

Here is one of test results I got:
cat memory.current; cat memory.min; echo;
409485312   // current
409600000   // min

385052672   // See current got over reclaimed for 23MB
409600000   // min

Its corresponding ftrace output I monitored:
kswapd_0-281   [000] ....   304.706632: shrink_node_memcg:
min_excess=24, nr_reclaimed=6013, sc->nr_to_reclaim=1499997, exceeds
5989pages

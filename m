Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 53B4A8E005B
	for <linux-mm@kvack.org>; Sat, 29 Dec 2018 04:52:27 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id p65-v6so7444466ljb.16
        for <linux-mm@kvack.org>; Sat, 29 Dec 2018 01:52:27 -0800 (PST)
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id l64si35145371lfe.31.2018.12.29.01.52.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 29 Dec 2018 01:52:25 -0800 (PST)
Subject: Re: Re: [PATCH] netfilter: account ebt_table_info to kmemcg
References: <20181229015524.222741-1-shakeelb@google.com>
 <20181229073325.GZ16738@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <7c0fa75f-df2f-668e-ebc2-3d3e9831030f@virtuozzo.com>
Date: Sat, 29 Dec 2018 12:52:19 +0300
MIME-Version: 1.0
In-Reply-To: <20181229073325.GZ16738@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>, Florian Westphal <fw@strlen.de>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, Roopa Prabhu <roopa@cumulusnetworks.com>, Nikolay Aleksandrov <nikolay@cumulusnetworks.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, netfilter-devel@vger.kernel.org, coreteam@netfilter.org, bridge@lists.linux-foundation.org, linux-kernel@vger.kernel.org, syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com

Hi, Michal!

On 29.12.2018 10:33, Michal Hocko wrote:
> On Fri 28-12-18 17:55:24, Shakeel Butt wrote:
>> The [ip,ip6,arp]_tables use x_tables_info internally and the underlying
>> memory is already accounted to kmemcg. Do the same for ebtables. The
>> syzbot, by using setsockopt(EBT_SO_SET_ENTRIES), was able to OOM the
>> whole system from a restricted memcg, a potential DoS.
> 
> What is the lifetime of these objects? Are they bound to any process?

These are list of ebtables rules, which may be displayed with $ebtables-save command.
In case of we do not account them, a low priority container may eat all the memory
and OOM killer in berserk mode will kill all the processes on machine. They are not bound
to any process, but they are bound to network namespace.

OOM killer does not analyze such the memory cgroup-related allocations, since it
is task-aware only. Maybe we should do it namespace-aware too...

Kirill

>> Reported-by: syzbot+7713f3aa67be76b1552c@syzkaller.appspotmail.com
>> Signed-off-by: Shakeel Butt <shakeelb@google.com>
>> ---
>>  net/bridge/netfilter/ebtables.c | 6 ++++--
>>  1 file changed, 4 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/bridge/netfilter/ebtables.c b/net/bridge/netfilter/ebtables.c
>> index 491828713e0b..5e55cef0cec3 100644
>> --- a/net/bridge/netfilter/ebtables.c
>> +++ b/net/bridge/netfilter/ebtables.c
>> @@ -1137,14 +1137,16 @@ static int do_replace(struct net *net, const void __user *user,
>>  	tmp.name[sizeof(tmp.name) - 1] = 0;
>>  
>>  	countersize = COUNTER_OFFSET(tmp.nentries) * nr_cpu_ids;
>> -	newinfo = vmalloc(sizeof(*newinfo) + countersize);
>> +	newinfo = __vmalloc(sizeof(*newinfo) + countersize, GFP_KERNEL_ACCOUNT,
>> +			    PAGE_KERNEL);
>>  	if (!newinfo)
>>  		return -ENOMEM;
>>  
>>  	if (countersize)
>>  		memset(newinfo->counters, 0, countersize);
>>  
>> -	newinfo->entries = vmalloc(tmp.entries_size);
>> +	newinfo->entries = __vmalloc(tmp.entries_size, GFP_KERNEL_ACCOUNT,
>> +				     PAGE_KERNEL);
>>  	if (!newinfo->entries) {
>>  		ret = -ENOMEM;
>>  		goto free_newinfo;
>> -- 
>> 2.20.1.415.g653613c723-goog
>>
> 

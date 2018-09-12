Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6413E8E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 09:30:07 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id w68-v6so3450020ith.0
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 06:30:07 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id q70-v6si921185itc.3.2018.09.12.06.30.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 06:30:05 -0700 (PDT)
Subject: Re: [RFC PATCH v2 1/8] mm, memcontrol.c: make memcg lru stats
 thread-safe without lru_lock
References: <20180911004240.4758-1-daniel.m.jordan@oracle.com>
 <20180911004240.4758-2-daniel.m.jordan@oracle.com>
 <e62ef1a0-9518-5a16-df5b-86977b4e8881@linux.vnet.ibm.com>
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Message-ID: <a81f27b1-00c0-53ac-4d0b-241effdca9a6@oracle.com>
Date: Wed, 12 Sep 2018 09:28:58 -0400
MIME-Version: 1.0
In-Reply-To: <e62ef1a0-9518-5a16-df5b-86977b4e8881@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org
Cc: aaron.lu@intel.com, ak@linux.intel.com, akpm@linux-foundation.org, dave.dice@oracle.com, dave.hansen@linux.intel.com, hannes@cmpxchg.org, levyossi@icloud.com, mgorman@techsingularity.net, mhocko@kernel.org, Pavel.Tatashin@microsoft.com, steven.sistare@oracle.com, tim.c.chen@intel.com, vdavydov.dev@gmail.com, ying.huang@intel.com, daniel.m.jordan@oracle.com

On 9/11/18 12:32 PM, Laurent Dufour wrote:
> On 11/09/2018 02:42, Daniel Jordan wrote:
>> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
>> index d99b71bc2c66..6377dc76dc41 100644
>> --- a/include/linux/memcontrol.h
>> +++ b/include/linux/memcontrol.h
>> @@ -99,7 +99,8 @@ struct mem_cgroup_reclaim_iter {
>>   };
>>
>>   struct lruvec_stat {
>> -	long count[NR_VM_NODE_STAT_ITEMS];
>> +	long node[NR_VM_NODE_STAT_ITEMS];
>> +	long lru_zone_size[MAX_NR_ZONES][NR_LRU_LISTS];
> 
> It might be better to use different name for the lru_zone_size field to
> distinguish it from the one in the mem_cgroup_per_node structure.

Yes, not very grep-friendly.  I'll change it to this:

struct lruvec_stat {
	long node_stat_cpu[NR_VM_NODE_STAT_ITEMS];
	long lru_zone_size_cpu[MAX_NR_ZONES][NR_LRU_LISTS];
};

So the fields are named like the corresponding fields in the mem_cgroup_per_node structure, plus _cpu.  And I'm certainly open to other ideas.

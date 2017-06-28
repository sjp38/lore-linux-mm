Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7F976B0292
	for <linux-mm@kvack.org>; Wed, 28 Jun 2017 05:35:04 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id p204so5019561wmg.3
        for <linux-mm@kvack.org>; Wed, 28 Jun 2017 02:35:04 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k33si1418458wre.240.2017.06.28.02.35.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 28 Jun 2017 02:35:03 -0700 (PDT)
Subject: Re: [PATCH] mm/memory_hotplug: just build zonelist for new added node
References: <20170626035822.50155-1-richard.weiyang@gmail.com>
 <20170628092329.GC5225@dhcp22.suse.cz>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <f92958f9-e831-8dc7-f8e6-2f4a46171e71@suse.cz>
Date: Wed, 28 Jun 2017 11:35:00 +0200
MIME-Version: 1.0
In-Reply-To: <20170628092329.GC5225@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/28/2017 11:23 AM, Michal Hocko wrote:
> On Mon 26-06-17 11:58:22, Wei Yang wrote:
>> In commit (9adb62a5df9c0fbef7) "mm/hotplug: correctly setup fallback
>> zonelists when creating new pgdat" tries to build the correct zonelist for
>> a new added node, while it is not necessary to rebuild it for already exist
>> nodes.
>>
>> In build_zonelists(), it will iterate on nodes with memory. For a new added
>> node, it will have memory until node_states_set_node() is called in
>> online_pages().
>>
>> This patch will avoid to rebuild the zonelists for already exist nodes.
> 
> It is not very clear from the changelog why that actually matters. The
> only effect I can see is that other zonelists on other online nodes will
> not learn about the currently memory less node. This is a good think
> because we do not pointlessly try to allocate from that node.

build_zonelists_node() seems to use managed_zone(zone) checks, so it
should not include empty zones anyway. So effectively seems to me we
just avoid some pointless work under stop_machine().

>> Signed-off-by: Wei Yang <richard.weiyang@gmail.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
>> ---
>>  mm/page_alloc.c | 16 +++++++++-------
>>  1 file changed, 9 insertions(+), 7 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 560eafe8234d..fc8181b44fd8 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -5200,15 +5200,17 @@ static int __build_all_zonelists(void *data)
>>  	memset(node_load, 0, sizeof(node_load));
>>  #endif
>>  
>> -	if (self && !node_online(self->node_id)) {
>> +	/* This node is hotadded and no memory preset yet.
>> +	 * So just build zonelists is fine, no need to touch other nodes.
>> +	 */
> 
> This comment doesn't make much sense to me. What about
> 	/*
> 	 * Do not rebuild zonelists on all online nodes if the current
> 	 * node is not online yet (it doesn't have any memory) and
> 	 * allocating from it is pointless. Still build zonelist for
> 	 * self because we need to handle memoryless nodes.
> 	 */
>> +	if (self && !node_online(self->node_id))
>>  		build_zonelists(self);
>> -	}
>> -
>> -	for_each_online_node(nid) {
>> -		pg_data_t *pgdat = NODE_DATA(nid);
>> +	else
>> +		for_each_online_node(nid) {
>> +			pg_data_t *pgdat = NODE_DATA(nid);
>>  
>> -		build_zonelists(pgdat);
>> -	}
>> +			build_zonelists(pgdat);
>> +		}
>>  
>>  	/*
>>  	 * Initialize the boot_pagesets that are going to be used
>> -- 
>> 2.11.0
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
